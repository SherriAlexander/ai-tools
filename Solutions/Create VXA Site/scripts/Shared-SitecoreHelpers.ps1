#Requires -Version 5.1
<#
.SYNOPSIS
    Shared helper functions for all Sitecore XM Cloud Authoring GraphQL scripts.
.DESCRIPTION
    Dot-source this file at the top of any script that calls the Authoring GraphQL API:

        . (Join-Path $PSScriptRoot "Shared-SitecoreHelpers.ps1")

    Before calling any helper, set these two variables in the script's scope:

        $uri  = "$CmUrl/sitecore/api/authoring/graphql/v1"
        $hdrs = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }

    Standard script header pattern:

        param(
            [string]$CmUrl  = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io",
            [string]$ApiKey,
            [switch]$WhatIf
        )
        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        . (Join-Path $PSScriptRoot "Shared-SitecoreHelpers.ps1")

        # Always request a fresh token -- CM tokens expire in 15 minutes
        if (-not $ApiKey) {
            $ApiKey = Get-SitecoreToken -UserJsonPath (Join-Path $PSScriptRoot "..\\.sitecore\\user.json")
        }

        $uri  = "$CmUrl/sitecore/api/authoring/graphql/v1"
        $hdrs = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }

.NOTES
    Functions defined here:
        Get-SitecoreToken       - Request a fresh OAuth token via client credentials (CM or API scope).
                                  Call ONCE at the top of every script; assign result to $ApiKey.
                                  Avoids stale-token failures on long-running scripts (CM token = 15 min).
        Invoke-Gql              - Execute a GraphQL query or mutation
        Get-SitecoreItemId      - Resolve item GUID from a content path
        Get-OrCreate-SitecoreItem - Create item if absent; return itemId either way
                                    -Fields   : fold field values into createItem (1 call vs 2)
                                    -ForceCreate: skip existence check (fresh-page fast path)
        Set-SitecoreFields      - Update named fields on an item (language: en)
        Get-MediaItemIds        - Batch-check N media paths in a single GQL round trip
        New-LayoutGuid          - Generate a random {GUID} for layout XML uid attributes
        Remove-OrphanedSitecoreChildren
                                - Delete children of a parent item whose names are NOT in a
                                  given keep-list. Call after building a Multi Promo card list
                                  to remove stale cards from previous runs.
        Add-RenderingToPageLayout
                                - Non-destructively append one rendering to a page's
                                  __Final Renderings XML (reads, appends, writes back).
                                  Use for headless-header and headless-footer placements.

    Performance notes:
        Pass -Fields to Get-OrCreate-SitecoreItem to save 1 GQL call per NEW item.
        Pass -ForceCreate on a known-fresh page to save 1 additional call per item.
        Use Get-MediaItemIds to check N media paths in 1 call instead of N sequential calls.

    $WhatIf is supported by Get-OrCreate-SitecoreItem and Set-SitecoreFields.
    When set, mutations are skipped and intent is printed to the console.

    See docs/SITECORE_SCRIPTING_CONVENTIONS.md for GraphQL rules and layout XML patterns.
    See docs/VXA_COMPONENT_SPECS.md Component Registry for rendering IDs and template IDs.
#>

function Invoke-Gql {
    param([string]$Query, [object]$Variables = $null)
    $payload = [ordered]@{ query = $Query }
    if ($null -ne $Variables) { $payload.variables = $Variables }
    $body = ConvertTo-Json $payload -Depth 20 -Compress
    $r = Invoke-RestMethod -Uri $uri -Method POST -Headers $hdrs -Body $body
    if ($r.PSObject.Properties['errors'] -and $r.errors) {
        $r.errors | ForEach-Object { Write-Warning "GQL: $($_.message)" }
        return $null
    }
    return $r.data
}

function Get-SitecoreItemId {
    param([string]$Path)
    $d = Invoke-Gql -Query "{ item(where: { database: `"master`", path: `"$Path`" }) { itemId } }"
    if ($null -ne $d -and $null -ne $d.item) { return $d.item.itemId }
    return $null
}

function Get-OrCreate-SitecoreItem {
    # Returns the itemId of an existing item, or creates it and returns the new itemId.
    #
    # Performance flags:
    #   -Fields      Pass field values to fold into the createItem call (1 GQL call instead of 2).
    #                On creates:  fields are written inline with createItem (saves 1 call per item).
    #                On exists:   fields are written via a separate updateItem call (idempotent rerun).
    #   -ForceCreate Skip the existence check (Get-SitecoreItemId) entirely.
    #                Use only when you KNOW the item does not exist (e.g. freshly created page).
    #                Saves 1 call per item. Sitecore will error on duplicate name -- fail-fast, no corruption.
    param(
        [string]$Path,
        [string]$Name,
        [string]$TemplateId,
        [string]$ParentId,
        [array]$Fields = @(),
        [switch]$ForceCreate
    )
    if (-not $ForceCreate) {
        $existing = Get-SitecoreItemId -Path $Path
        if ($existing) {
            Write-Host "  = Exists: $Path  [$existing]" -ForegroundColor DarkGray
            if ($Fields.Count -gt 0) {
                Set-SitecoreFields -ItemId $existing -Fields $Fields
            }
            return $existing
        }
    }
    if ($WhatIf) {
        Write-Host "[WHATIF] Create '$Name' under $ParentId"
        return "whatif-id-$Name"
    }
    $mutation = 'mutation CreateItem($input: CreateItemInput!) { createItem(input: $input) { item { itemId name path } } }'
    $vars = [ordered]@{
        input = [ordered]@{
            name       = $Name
            templateId = $TemplateId
            parent     = $ParentId
            language   = "en"
            fields     = $Fields
        }
    }
    $d = Invoke-Gql -Query $mutation -Variables $vars
    if ($null -ne $d -and $null -ne $d.createItem) {
        $item = $d.createItem.item
        Write-Host "  + Created: $($item.path)  [$($item.itemId)]" -ForegroundColor Green
        return $item.itemId
    }
    throw "Failed to create item: $Name"
}

function Get-MediaItemIds {
    # Batch-check existence of multiple media items in a single GQL round trip.
    # Returns a hashtable of { name -> itemId } where itemId is $null if not found.
    #
    # Usage:
    #   $check = Get-MediaItemIds @{
    #       "hero"     = "/sitecore/media library/dev-demos/standard/hero-banner--our-services"
    #       "wendy"    = "/sitecore/media library/dev-demos/standard/headshots/wendy-karlyn"
    #   }
    #   if ($check["hero"]) { Write-Host "hero exists: $($check['hero'])" }
    #
    # GraphQL aliases must start with a letter and contain only [a-zA-Z0-9_].
    # Keys are sanitized: non-alphanumeric chars replaced with underscores, prefixed with 'm_'.
    param([hashtable]$Items)

    $aliasMap = [ordered]@{}  # alias -> original key
    $aliases  = foreach ($entry in $Items.GetEnumerator()) {
        $alias = 'm_' + ($entry.Key -replace '[^a-zA-Z0-9]', '_')
        $aliasMap[$alias] = $entry.Key
        "$alias : item(where: { database: `"master`", path: `"$($entry.Value)`" }) { itemId }"
    }
    $query = "{ $($aliases -join ' ') }"
    $d = Invoke-Gql -Query $query

    $results = @{}
    foreach ($alias in $aliasMap.Keys) {
        $origKey = $aliasMap[$alias]
        $results[$origKey] = if ($null -ne $d -and $null -ne $d.$alias) { $d.$alias.itemId } else { $null }
    }
    return $results
}

function Set-SitecoreFields {
    param([string]$ItemId, [array]$Fields)
    if ($WhatIf) { Write-Host "[WHATIF] Update fields on $ItemId"; return }
    $mutation = 'mutation UpdateItem($input: UpdateItemInput!) { updateItem(input: $input) { item { itemId name } } }'
    $d = Invoke-Gql -Query $mutation -Variables ([ordered]@{
        input = [ordered]@{
            itemId   = $ItemId
            language = "en"
            fields   = $Fields
        }
    })
    if ($null -ne $d -and $null -ne $d.updateItem) {
        Write-Host "  ~ Updated: $($d.updateItem.item.name)" -ForegroundColor DarkGreen
    }
}

function New-LayoutGuid {
    return "{$([System.Guid]::NewGuid().ToString().ToUpper())}"
}

function Remove-OrphanedSitecoreChildren {
    # Deletes any children of $ParentPath whose names are NOT in $KeepNames.
    # Use after creating/updating a Multi Promo or other item-collection datasource
    # to remove stale children left over from a previous script run with a different card list.
    #
    # Usage:
    #   Remove-OrphanedSitecoreChildren `
    #       -ParentPath "$dataPath/Multi Promo Work Grid" `
    #       -KeepNames  @("Card-Suncoast","Card-CNH","Card-NAHB")
    param(
        [string]$ParentPath,
        [string[]]$KeepNames
    )
    $d = Invoke-Gql -Query "{ item(where: { database: `"master`", path: `"$ParentPath`" }) { children { nodes { itemId name } } } }"
    if ($null -eq $d -or $null -eq $d.item) {
        Write-Host "  RemoveOrphans: parent not found at $ParentPath" -ForegroundColor DarkGray
        return
    }
    $children = $d.item.children.nodes
    foreach ($child in $children) {
        if ($KeepNames -notcontains $child.name) {
            if ($WhatIf) {
                Write-Host "  [WHATIF] Would delete orphan: $($child.name) [$($child.itemId)]" -ForegroundColor DarkYellow
                continue
            }
            $del = Invoke-Gql -Query "mutation { deleteItem(input: { itemId: `"$($child.itemId)`" }) { successful } }"
            if ($del -and $del.deleteItem.successful) {
                Write-Host "  - Deleted orphan: $($child.name) [$($child.itemId)]" -ForegroundColor Yellow
            } else {
                Write-Warning "  Failed to delete orphan: $($child.name) [$($child.itemId)]"
            }
        }
    }
}

function Get-SitecoreToken {
    # Request a fresh OAuth access token via client credentials flow.
    # Always call this at the top of every script instead of reading accessToken
    # directly from user.json -- the stored token expires in 15 minutes and will
    # cause mid-script failures on long runs.
    #
    # Usage:
    #   . (Join-Path $PSScriptRoot "Shared-SitecoreHelpers.ps1")
    #   $ApiKey = Get-SitecoreToken -UserJsonPath (Join-Path $PSScriptRoot "..\\.sitecore\\user.json")
    #
    # Scope:
    #   'cm'  -- Authoring GraphQL endpoint (default). Audience = $ep.audience. Expires: 15 min.
    #   'api' -- Pages / Sites REST API.  Audience = https://api.sitecorecloud.io. Expires: 24 hr.
    param(
        [string]$UserJsonPath = ".sitecore/user.json",
        [ValidateSet('cm','api')]
        [string]$Scope = 'cm'
    )
    $ep = (Get-Content $UserJsonPath -Raw | ConvertFrom-Json).endpoints.xmCloud

    $audience = if ($Scope -eq 'cm') { $ep.audience } else { 'https://api.sitecorecloud.io' }

    $body = "client_id=$([uri]::EscapeDataString($ep.clientId))" +
            "&client_secret=$([uri]::EscapeDataString($ep.clientSecret))" +
            "&audience=$([uri]::EscapeDataString($audience))" +
            "&grant_type=client_credentials"

    $result = Invoke-RestMethod -Method POST `
        -Uri "$($ep.authority)/oauth/token" `
        -ContentType 'application/x-www-form-urlencoded' `
        -Body $body

    Write-Host "  Token refreshed (scope=$Scope, expires_in=$($result.expires_in)s)" -ForegroundColor DarkGray
    return $result.access_token
}

function Add-RenderingToPageLayout {
    # Non-destructively appends one rendering to a page's __Final Renderings XML.
    # Reads the existing layout, appends the <r> element before </d>, writes back.
    # Safe to call on re-runs: checks if the placeholder is already populated and
    # skips if so (idempotent).
    #
    # Use for headless-header and headless-footer placements only.
    # Content renderings in headless-main should be written as a full layout block.
    #
    # Usage:
    #   Add-RenderingToPageLayout `
    #       -PagePath    "/sitecore/content/dev-demos/standard/Home" `
    #       -PageId      "9dc3828e91a74e5da4fde622ea089d54" `
    #       -RenderingId "{68B9AC48-0D6B-4F9C-8C3C-1C5566ADC671}" `
    #       -Placeholder "headless-footer" `
    #       -DatasourceId "162d81b0922344199acd48c6ff43cb38" `
    #       -Par         "footerNavColorScheme=dark&amp;footerSubnavColorScheme=dark"
    #
    # IMPORTANT: DatasourceId must be the explicit item GUID (N format).
    # The DatasourceLocation query on the rendering definition is UI-only
    # and does NOT resolve at render time in scripted layouts.
    param(
        [string]$PagePath,
        [string]$PageId,
        [string]$RenderingId,     # braced GUID: {68B9AC48-...}
        [string]$Placeholder,     # e.g. "headless-footer" (no leading slash)
        [string]$DatasourceId,    # N-format GUID of datasource item
        [string]$Par = ""
    )
    Write-Host "  Checking $Placeholder on $PagePath..." -ForegroundColor DarkGray

    $q    = "{ item(where:{database:`"master`",path:`"$PagePath`"}){ field(name:`"__Final Renderings`"){value} } }"
    $data = Invoke-Gql -Query $q
    $currentXml = if ($data -and $data.item -and $data.item.field) { $data.item.field.value } else { $null }

    if (-not $currentXml) {
        Write-Warning "  Could not read __Final Renderings for $PagePath -- skipping layout patch"
        return
    }

    # Idempotency: skip if placeholder already occupied
    if ($currentXml -match "ph=`"/$Placeholder`"" -or $currentXml -match "s:ph=`"/$Placeholder`"") {
        Write-Host "  = $Placeholder already has a rendering -- skipping" -ForegroundColor DarkGray
        return
    }

    if ($WhatIf) {
        Write-Host "[WHATIF] Would add $RenderingId to /$Placeholder on $PagePath"
        return
    }

    $dsAttr = if ($DatasourceId) {
        $braced = "{$([guid]::new($DatasourceId).ToString().ToUpper())}"
        " s:ds=`"$braced`""
    } else { "" }

    $uid       = New-LayoutGuid
    $newR      = "<r uid=`"$uid`"$dsAttr s:id=`"$RenderingId`" s:ph=`"/$Placeholder`" s:par=`"$Par`" />"
    $updated   = $currentXml -replace '</d>\s*</r>', "$newR</d></r>"
    if ($updated -eq $currentXml) { $updated = $currentXml -replace '</d>', "$newR</d>" }

    Set-SitecoreFields -ItemId $PageId -Fields @(
        [ordered]@{ name = "__Final Renderings"; value = $updated }
    )
    Write-Host "  + Added /$Placeholder rendering on $PagePath" -ForegroundColor Green
}
