#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the VXA Global Footer for the Velir POC site in Sitecore XM Cloud.
.DESCRIPTION
    Idempotent script that creates the complete Global Footer content hierarchy and
    wires the VxaGlobalFooter rendering into the headless-footer placeholder on all POC pages.

    Content structure created under the SITE DATA FOLDER (not a page Data folder):
      Data/
        Social Links/               (VXA Social Link Folder)
          LinkedIn                  (VXA Social Link)
          Instagram                 (VXA Social Link)
          Twitter                   (VXA Social Link)
        Global Footer               (VXA Global Footer Root)
          Column Nav Root           (VXA Column Navigation Root)
            Column 1                (VXA Column Navigation Item)
              Who We Are            (VXA Link)
              What We Do            (VXA Link)
              Our Work              (VXA Link)
              Latest Ideas          (VXA Link)
              Data Studio           (VXA Link)
            Column 2                (VXA Column Navigation Item)
              Our Solutions         (VXA Link)
              Our Partners          (VXA Link)
              Careers               (VXA Link)
              News                  (VXA Link)
              Contact               (VXA Link)
          Footer Utility Root       (VXA Footer Utility Root)
            Privacy Policy          (VXA Link)

    Media uploaded to:
      /sitecore/media library/dev-demos/standard/navigation/

    Pages patched (headless-footer placeholder):
      Home, Who We Are, What We Do, Work

    Source URL: https://www.velir.com (fetched 2026-04-04)
    Logo URL:   https://www.velir.com/-/media/logos/2025/velirhorizontalreversed.svg

.NOTES
    ADAPTING FOR A NEW CLIENT SITE:
      1. Update $CmUrl to the new site's CM URL.
      2. Update $SiteRoot to the new site's content path.
      3. Update all $logoUrl, $socialLinks*, $copyright, $contactAddress* variables.
      4. Update the column link arrays ($col1Links, $col2Links).
      5. Update $pages to the list of page paths for the new site.
      6. Re-run. The script is idempotent: existing items are skipped, field values are re-applied.

.EXAMPLE
    .\Build-GlobalFooter.ps1
    .\Build-GlobalFooter.ps1 -WhatIf
#>
[CmdletBinding()]
param(
    [string]$CmUrl  = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io",
    [string]$ApiKey,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $ApiKey) {
    $ApiKey = (Get-Content (Join-Path $PSScriptRoot "..\\.sitecore\\user.json") | ConvertFrom-Json).endpoints.xmCloud.accessToken
}

. (Join-Path $PSScriptRoot "Shared-SitecoreHelpers.ps1")

$uri  = "$CmUrl/sitecore/api/authoring/graphql/v1"
$hdrs = @{ Authorization = "Bearer $ApiKey"; "Content-Type" = "application/json" }

# ---------------------------------------------------------------------------
# Sitecore item template IDs (N format -- no hyphens, no braces)
# Source: docs/VXA_COMPONENT_SPECS.md Component Registry -- Global Navigation section
# ---------------------------------------------------------------------------
$tSocialLinkFolder = "79a05ed1420840eaaabb0f9588b2101b"  # VXA Social Link Folder
$tSocialLink       = "38dfd0e084ba42ea89941cdb91f2b121"  # VXA Social Link
$tFooterRoot       = "3e97ce77e29e4540a7f7342b4eefc298"  # VXA Global Footer Root
$tColumnNavRoot    = "aaa3550b1ac945d991af0c16fc529332"  # VXA Column Navigation Root
$tColumnNavItem    = "cc85bda20c934e23b689737e9dfd9454"  # VXA Column Navigation Item
$tFooterUtilRoot   = "aca438cf515942ea91c2d587789026af"  # VXA Footer Utility Root
$tVxaLink          = "68197e935b3d4a3ba9fb970ad58ba293"  # VXA Link (shared nav link)
$tFolder           = "a87a00b1e6db45ab8b54636fec3b5523"  # Standard folder

# Rendering ID (braced format for layout XML s:id)
$rFooter  = "{68B9AC48-0D6B-4F9C-8C3C-1C5566ADC671}"    # VxaGlobalFooter
$deviceId = "{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}"    # Default device

# ---------------------------------------------------------------------------
# Site root and data paths
# ---------------------------------------------------------------------------
$SiteRoot   = "/sitecore/content/dev-demos/standard"
$SiteData   = "$SiteRoot/Data"
$MediaRoot  = "dev-demos/standard/navigation"  # uploadMedia path (no leading slash)
$MediaQuery = "/sitecore/media library/dev-demos/standard/navigation"

# ---------------------------------------------------------------------------
# Pages to receive the footer rendering
# path -> itemId (N format)
# ---------------------------------------------------------------------------
$pages = [ordered]@{
    "/sitecore/content/dev-demos/standard/Home"            = "9dc3828e91a74e5da4fde622ea089d54"
    "/sitecore/content/dev-demos/standard/Home/who-we-are" = "8a07b2865dd14ba0800b6c430ecaa6ec"
    "/sitecore/content/dev-demos/standard/Home/what-we-do" = "de056beee64f443e937afc2585b6914f"
    "/sitecore/content/dev-demos/standard/Home/work"       = "c4740980 0a104b9cbf951339cc4f3f88"
}

# Fix: Work page ID had a space in velir.md -- normalise
$pages["/sitecore/content/dev-demos/standard/Home/work"] = "c47409800a104b9cbf951339cc4f3f88"

# ---------------------------------------------------------------------------
# Footer rendering params
# footerNavColorScheme=dark : main nav area (dark background like velir.com)
# footerSubnavColorScheme=dark : utility bar (copyright + social links)
# These are URL-encoded name=value pairs; use &amp; in XML attribute context.
# ---------------------------------------------------------------------------
$footerPar = "footerNavColorScheme=dark&amp;footerSubnavColorScheme=dark"

# ---------------------------------------------------------------------------
# Source content (velir.com, fetched 2026-04-04)
# ASCII-only -- no em-dashes, smart quotes, or non-ASCII characters.
#
# RULES:
#   - VXA Link "link" field: General Link XML with linktype="external" for POC
#   - VXA Social Link "socialIcon" field: icon name string (see Icon.enum.ts values)
#     Valid values: linkedin, instagram, twitter, facebook, youtube, email
#   - VXA Column Navigation Item "columnHeader" field: plain text (blank = no header shown)
#   - VXA Global Footer Root fields: plain text or XML (see below)
# ---------------------------------------------------------------------------
$logoUrl     = "https://www.velir.com/-/media/logos/2025/velirhorizontalreversed.svg"
$logoMediaPath = "$MediaQuery/velirhorizontalreversed"
$logoUploadPath = "$MediaRoot/velirhorizontalreversed"

$contactAddress  = "info@velir.com"
$copyright       = "(c)2025 Velir"   # ASCII-safe: (c) instead of Unicode copyright symbol

# Social links
$socialLinks = @(
    [ordered]@{
        name = "LinkedIn"
        icon = "linkedin"
        href = "https://www.linkedin.com/company/velir"
        text = "Follow us on LinkedIn"
    }
    [ordered]@{
        name = "Instagram"
        icon = "instagram"
        href = "https://www.instagram.com/velirstudios"
        text = "Follow us on Instagram"
    }
    [ordered]@{
        name = "Twitter"
        icon = "twitter"
        href = "https://twitter.com/Velir"
        text = "Follow us on Twitter"
    }
)

# Footer column link definitions
# "link" field = General Link XML
$col1Links = @(
    [ordered]@{ name = "Who We Are";    href = "https://www.velir.com/who-we-are"    }
    [ordered]@{ name = "What We Do";    href = "https://www.velir.com/what-we-do"    }
    [ordered]@{ name = "Our Work";      href = "https://www.velir.com/work"          }
    [ordered]@{ name = "Latest Ideas";  href = "https://www.velir.com/ideas"         }
    [ordered]@{ name = "Data Studio";   href = "https://www.brooklyndata.co/"        }
)
$col2Links = @(
    [ordered]@{ name = "Our Solutions"; href = "https://www.velir.com/what-we-do/our-solutions" }
    [ordered]@{ name = "Our Partners";  href = "https://www.velir.com/what-we-do/partners"      }
    [ordered]@{ name = "Careers";       href = "https://www.velir.com/who-we-are/careers"       }
    [ordered]@{ name = "News";          href = "https://www.velir.com/news"                      }
    [ordered]@{ name = "Contact";       href = "https://www.velir.com/contact"                   }
)
$utilLinks = @(
    [ordered]@{ name = "Privacy Policy"; href = "https://www.velir.com/privacy-policy" }
)

# ---------------------------------------------------------------------------
# Helper -- convert N-format GUID to braced hyphenated for image / item ref fields
# ---------------------------------------------------------------------------
function fg { param([string]$n) "{$([guid]::new($n).ToString().ToUpper())}" }

# ---------------------------------------------------------------------------
# Helper -- build General Link XML value
# ---------------------------------------------------------------------------
function New-LinkXml {
    param([string]$Href, [string]$Text = "", [string]$Target = "")
    $targetAttr = if ($Target) { " target=`"$Target`"" } else { "" }
    return "<link text=`"$Text`" linktype=`"external`" url=`"$Href`"$targetAttr />"
}

# ---------------------------------------------------------------------------
# Helper -- read __Final Renderings XML from a page item
# ---------------------------------------------------------------------------
function Get-FinalRenderings {
    param([string]$Path)
    # Authoring GQL: item fields query
    $q = "{ item(where:{database:`"master`",path:`"$Path`"}){ field(name:`"__Final Renderings`"){value} } }"
    $d = Invoke-Gql -Query $q
    if ($null -ne $d -and $null -ne $d.item -and $null -ne $d.item.field) {
        return $d.item.field.value
    }
    # Fallback: try versions-based query
    $q2 = "{ item(where:{database:`"master`",path:`"$Path`"}){ versions{results{fields{results{name value}}}} } }"
    $d2 = Invoke-Gql -Query $q2
    if ($null -ne $d2 -and $null -ne $d2.item) {
        $allFields = $d2.item.versions.results | ForEach-Object { $_.fields.results } | Where-Object { $_.name -eq "__Final Renderings" }
        return ($allFields | Select-Object -Last 1).value
    }
    return $null
}

# ---------------------------------------------------------------------------
# Helper -- add one rendering to a page's headless-* placeholder if not present
# Reads current __Final Renderings, appends the <r> node, writes back.
# ---------------------------------------------------------------------------
function Add-RenderingToPageLayout {
    param(
        [string]$PagePath,
        [string]$PageId,
        [string]$RenderingId,     # braced format e.g. {68B9AC48-...}
        [string]$Placeholder,     # e.g. "headless-footer"
        [string]$DatasourceId,    # N-format GUID of the datasource item
        [string]$Par = ""
    )
    Write-Host "  Checking $Placeholder on $PagePath..." -ForegroundColor DarkGray

    $currentXml = Get-FinalRenderings -Path $PagePath
    if (-not $currentXml) {
        Write-Warning "  Could not read __Final Renderings for $PagePath -- skipping layout patch"
        Write-Host "  Manual fallback: use MCP add_component_on_page with placeholderPath=/$Placeholder" -ForegroundColor Yellow
        return
    }

    # Check if this placeholder already has a rendering
    if ($currentXml -match [regex]::Escape("ph=`"/$Placeholder`"") -or
        $currentXml -match [regex]::Escape("s:ph=`"/$Placeholder`"")) {
        Write-Host "  = $Placeholder already has a rendering -- skipping" -ForegroundColor DarkGray
        return
    }

    if ($WhatIf) {
        Write-Host "[WHATIF] Would add $RenderingId to /$Placeholder on $PagePath"
        return
    }

    # Build the datasource attribute: use full path for clarity
    $dsAttr = if ($DatasourceId) { " s:ds=`"$(fg $DatasourceId)`"" } else { "" }
    $uid    = New-LayoutGuid
    $newR   = "<r uid=`"$uid`"$dsAttr s:id=`"$RenderingId`" s:ph=`"/$Placeholder`" s:par=`"$Par`" />"

    # Append before the closing </d> tag
    $updatedXml = $currentXml -replace '</d>\s*</r>', "$newR</d></r>"
    if ($updatedXml -eq $currentXml) {
        # Fallback: simpler replace
        $updatedXml = $currentXml -replace '</d>', "$newR</d>"
    }

    Set-SitecoreFields -ItemId $PageId -Fields @(
        [ordered]@{ name = "__Final Renderings"; value = $updatedXml }
    )
    Write-Host "  + Added /$Placeholder rendering on $PagePath" -ForegroundColor Green
}

# ===========================================================================
# Step 1 -- Locate site Data folder
# ===========================================================================
Write-Host "`nStep 1: Locating site Data folder..." -ForegroundColor Cyan
$dataId = Get-SitecoreItemId -Path $SiteData
if (-not $dataId) { throw "Site Data folder not found at $SiteData" }
Write-Host "  Data folder: $dataId"

# ===========================================================================
# Step 2 -- Upload footer logo
# ===========================================================================
Write-Host "`nStep 2: Footer logo -- uploading if needed..." -ForegroundColor Cyan
$logoId = Get-SitecoreItemId -Path $logoMediaPath
if ($logoId) {
    Write-Host "  = Logo already exists: $logoId" -ForegroundColor DarkGray
} else {
    Write-Host "  Downloading logo from velir.com..."
    $tmpLogo = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "velirhorizontalreversed.svg")
    Invoke-WebRequest -Uri $logoUrl -OutFile $tmpLogo -UseBasicParsing

    $d = Invoke-Gql -Query "mutation { uploadMedia(input: { itemPath: `"$logoUploadPath`" }) { presignedUploadUrl } }"
    if (-not $d -or -not $d.uploadMedia) { throw "uploadMedia mutation failed" }
    $presignedUrl = $d.uploadMedia.presignedUploadUrl
    Write-Host "  Got presigned URL" -ForegroundColor DarkGreen

    # curl.exe upload -- Authorization header required even though URL has token= param
    & curl.exe --silent --show-error --request POST $presignedUrl `
        --header "Authorization: Bearer $ApiKey" `
        --form "=@$tmpLogo;type=image/svg+xml"
    if ($LASTEXITCODE -ne 0) { throw "curl.exe upload failed (exit $LASTEXITCODE)" }
    Write-Host "  Uploaded logo" -ForegroundColor Green

    Start-Sleep -Seconds 2
    $logoId = Get-SitecoreItemId -Path $logoMediaPath
    if (-not $logoId) { throw "Could not resolve logo GUID after upload at $logoMediaPath" }
    Write-Host "  Logo GUID: $logoId" -ForegroundColor Green
    Remove-Item $tmpLogo -Force -ErrorAction SilentlyContinue
}
$imgFooterLogo      = "<image mediaid=`"$(fg $logoId)`" />"
$footerLogoLink     = New-LinkXml -Href "https://www.velir.com" -Text "Velir"

# ===========================================================================
# Step 3 -- Social Links folder + 3 social link items
# ===========================================================================
Write-Host "`nStep 3: Social Links folder and items..." -ForegroundColor Cyan
$socialLinksFolderId = Get-OrCreate-SitecoreItem `
    -Path   "$SiteData/Social Links" `
    -Name   "Social Links" `
    -TemplateId $tSocialLinkFolder `
    -ParentId   $dataId

$socialLinkIds = @()
$sortOrder = 10
foreach ($sl in $socialLinks) {
    $linkXml = "<link text=`"$($sl.text)`" linktype=`"external`" url=`"$($sl.href)`" target=`"_blank`" />"
    $slId = Get-OrCreate-SitecoreItem `
        -Path       "$SiteData/Social Links/$($sl.name)" `
        -Name       $sl.name `
        -TemplateId $tSocialLink `
        -ParentId   $socialLinksFolderId `
        -Fields     @(
            [ordered]@{ name = "link";       value = $linkXml }
            [ordered]@{ name = "socialIcon"; value = $sl.icon }
            [ordered]@{ name = "__Sortorder"; value = "$sortOrder" }
        )
    $socialLinkIds += $slId
    $sortOrder += 10
}
# Build pipe-separated braced GUID list for Multilist field
$socialLinksMultilist = ($socialLinkIds | ForEach-Object { fg $_ }) -join "|"
Write-Host "  Social links multilist value: $socialLinksMultilist"

# ===========================================================================
# Step 4 -- Global Footer Root item (top-level datasource)
# ===========================================================================
Write-Host "`nStep 4: Global Footer Root datasource..." -ForegroundColor Cyan
$footerRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Footer" `
    -Name       "Global Footer" `
    -TemplateId $tFooterRoot `
    -ParentId   $dataId `
    -Fields     @(
        [ordered]@{ name = "contactAddress"; value = $contactAddress }
        [ordered]@{ name = "copyright";      value = $copyright      }
        [ordered]@{ name = "footerLogo";     value = $imgFooterLogo  }
        [ordered]@{ name = "footerLogoLink"; value = $footerLogoLink }
        [ordered]@{ name = "socialLinks";    value = $socialLinksMultilist }
    )

# ===========================================================================
# Step 5 -- Column Navigation Root (child of footer root)
# ===========================================================================
Write-Host "`nStep 5: Column Navigation Root..." -ForegroundColor Cyan
$colNavRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Footer/Column Nav Root" `
    -Name       "Column Nav Root" `
    -TemplateId $tColumnNavRoot `
    -ParentId   $footerRootId

# Column Nav Item helper: creates the item and its VXA Link children
function New-FooterColumn {
    param(
        [string]$Name,
        [string]$ColumnHeader,    # display text; empty = no header rendered
        [string]$ParentId,
        [string]$ParentPath,
        [array]$Links
    )
    $colId = Get-OrCreate-SitecoreItem `
        -Path       "$ParentPath/$Name" `
        -Name       $Name `
        -TemplateId $tColumnNavItem `
        -ParentId   $ParentId `
        -Fields     @(
            [ordered]@{ name = "columnHeader"; value = $ColumnHeader }
        )
    $sort = 10
    foreach ($link in $Links) {
        $linkXml = New-LinkXml -Href $link.href -Text $link.name
        Get-OrCreate-SitecoreItem `
            -Path       "$ParentPath/$Name/$($link.name)" `
            -Name       $link.name `
            -TemplateId $tVxaLink `
            -ParentId   $colId `
            -Fields     @(
                [ordered]@{ name = "link";        value = $linkXml }
                [ordered]@{ name = "__Sortorder"; value = "$sort"  }
            ) | Out-Null
        $sort += 10
    }
    return $colId
}

# ===========================================================================
# Step 6 -- Column 1: Who We Are, What We Do, Our Work, Latest Ideas, Data Studio
# ===========================================================================
Write-Host "`nStep 6: Footer Column 1 (Who We Are / What We Do / Our Work / Latest Ideas / Data Studio)..." -ForegroundColor Cyan
New-FooterColumn `
    -Name         "Column 1" `
    -ColumnHeader "" `
    -ParentId     $colNavRootId `
    -ParentPath   "$SiteData/Global Footer/Column Nav Root" `
    -Links        $col1Links | Out-Null

# ===========================================================================
# Step 7 -- Column 2: Our Solutions, Our Partners, Careers, News, Contact
# ===========================================================================
Write-Host "`nStep 7: Footer Column 2 (Our Solutions / Our Partners / Careers / News / Contact)..." -ForegroundColor Cyan
New-FooterColumn `
    -Name         "Column 2" `
    -ColumnHeader "" `
    -ParentId     $colNavRootId `
    -ParentPath   "$SiteData/Global Footer/Column Nav Root" `
    -Links        $col2Links | Out-Null

# ===========================================================================
# Step 8 -- Footer Utility Root + Privacy Policy link
# ===========================================================================
Write-Host "`nStep 8: Footer Utility Root and utility links..." -ForegroundColor Cyan
$utilRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Footer/Footer Utility Root" `
    -Name       "Footer Utility Root" `
    -TemplateId $tFooterUtilRoot `
    -ParentId   $footerRootId

$sort = 10
foreach ($ul in $utilLinks) {
    $linkXml = New-LinkXml -Href $ul.href -Text $ul.name
    Get-OrCreate-SitecoreItem `
        -Path       "$SiteData/Global Footer/Footer Utility Root/$($ul.name)" `
        -Name       $ul.name `
        -TemplateId $tVxaLink `
        -ParentId   $utilRootId `
        -Fields     @(
            [ordered]@{ name = "link";        value = $linkXml }
            [ordered]@{ name = "__Sortorder"; value = "$sort"  }
        ) | Out-Null
    $sort += 10
}

Write-Host "`n  Footer datasource summary:" -ForegroundColor Green
Write-Host "  Global Footer Root GUID: $footerRootId"
Write-Host "  Social Links Folder GUID: $socialLinksFolderId"
Write-Host "  Logo GUID: $logoId"

# ===========================================================================
# Step 9 -- Add VxaGlobalFooter rendering to headless-footer on all POC pages
#
# NOTE: This step requires reading the current __Final Renderings XML from each page,
# appending the new rendering node, and writing back. If Get-FinalRenderings returns
# null (Authoring GQL schema gap), the step will print a manual MCP fallback instruction.
#
# MCP fallback (run manually if needed):
#   Tool: mcp_sitecore-mark_add_component_on_page
#   Parameters:
#     pageId:               <page GUID>
#     componentRenderingId: 68b9ac48-0d6b-4f9c-8c3c-1c5566adc671
#     placeholderPath:      /headless-footer
#   Then: mcp_sitecore-mark_set_component_datasource
#     componentId: <returned componentId>
#     datasourcePath: /sitecore/content/dev-demos/standard/Data/Global Footer
# ===========================================================================
Write-Host "`nStep 9: Adding footer rendering to all POC pages..." -ForegroundColor Cyan
foreach ($entry in $pages.GetEnumerator()) {
    $pagePath = $entry.Key
    $pageId   = $entry.Value
    Write-Host "`n  Page: $pagePath" -ForegroundColor White
    Add-RenderingToPageLayout `
        -PagePath     $pagePath `
        -PageId       $pageId `
        -RenderingId  $rFooter `
        -Placeholder  "headless-footer" `
        -DatasourceId $footerRootId `
        -Par          $footerPar
}

Write-Host "`n=== Build-GlobalFooter.ps1 complete ===" -ForegroundColor Green
Write-Host "  Global Footer Root:     $footerRootId"
Write-Host "  Social Links Folder:    $socialLinksFolderId"
Write-Host "  Logo media GUID:        $logoId"
Write-Host "`nNext steps:"
Write-Host "  1. Publish all pages + Data folder (poc-publish-page skill)"
Write-Host "  2. Screenshot each page (mcp_sitecore-mark_get_page_screenshot)"
Write-Host "  3. Verify: footer with Velir logo, 2 nav columns, social icons, copyright bar"
