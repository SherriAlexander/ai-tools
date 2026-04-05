#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the [CLIENT] Global Footer for a Sitecore XM Cloud POC site.
.DESCRIPTION
    Idempotent script that creates the complete Global Footer content hierarchy and
    wires the VxaGlobalFooter rendering into the headless-footer placeholder on all
    specified POC pages.

    Content structure created under the SITE DATA FOLDER (not a page Data folder):
      Data/
        Social Links/               (VXA Social Link Folder)
          [SOCIAL_LINK_1]           (VXA Social Link)
          ...
        Global Footer               (VXA Global Footer Root)
          Column Nav Root           (VXA Column Navigation Root)
            Column 1                (VXA Column Navigation Item)
              [LINK ...]            (VXA Link)
            Column 2                (VXA Column Navigation Item)
              [LINK ...]            (VXA Link)
          Footer Utility Root       (VXA Footer Utility Root)
            [UTILITY_LINK ...]      (VXA Link)

    Media uploaded to:
      /sitecore/media library/[MEDIA_ROOT]/navigation/

    Pages patched (headless-footer placeholder -- per-page __Final Renderings):
      [PAGE_1], [PAGE_2], ...

    Source URL: [SOURCE_URL]   (fetched [DATE])
    Logo URL:   [LOGO_URL]

.NOTES
    ADAPTING FOR A NEW CLIENT SITE:
      1. Update $CmUrl to the new site's CM URL.
      2. Update $SiteRoot to the new site's content path.
      3. Update $MediaRoot and $MediaQuery to the new site's media library path.
      4. Update $logoUrl, $logoMediaPath, $logoUploadPath to the new site's logo.
      5. Update $contactAddress, $copyright.
      6. Update $socialLinks array with the new site's social accounts.
      7. Update $col1Links and $col2Links with the new site's footer nav.
      8. Update $utilLinks with the new site's utility nav (e.g. Privacy Policy).
      9. Update $footerPar if color scheme differs from the default dark/dark.
     10. Update $pagePaths to the list of all POC page paths for the new site.
     11. Re-run. The script is idempotent: existing items are skipped, field values are re-applied.

    WIRING ARCHITECTURE:
      The footer is wired per-page via __Final Renderings. Each page in $pagePaths
      has the VxaGlobalFooter rendering appended to its /headless-footer placeholder.
      This differs from the header, which is wired site-wide via the Header Partial Design.
      Reason: footers are typically per-page or per-section in SXA; the VXA scaffold
      does not include a Footer Partial Design equivalent.

    MCP FALLBACK (if Add-RenderingToPageLayout cannot read __Final Renderings):
      mcp_sitecore-mark_add_component_on_page
        pageId:               <page GUID>
        componentRenderingId: 68b9ac48-0d6b-4f9c-8c3c-1c5566adc671
        placeholderPath:      /headless-footer
      Then: mcp_sitecore-mark_set_component_datasource
        componentId: <returned componentId>
        datasourcePath: [SITE_DATA_PATH]/Global Footer

.EXAMPLE
    .\Build-[CLIENT]GlobalFooter.ps1
    .\Build-[CLIENT]GlobalFooter.ps1 -WhatIf
#>
[CmdletBinding()]
param(
    [string]$CmUrl  = "[CM_URL]",   # e.g. https://xmc-orgname-sitename.sitecorecloud.io
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

# Rendering ID (braced format for layout XML s:id)
$rFooter  = "{68B9AC48-0D6B-4F9C-8C3C-1C5566ADC671}"    # VxaGlobalFooter

# ---------------------------------------------------------------------------
# Site root and data paths  -- TODO: update for new client
# ---------------------------------------------------------------------------
$SiteRoot   = "/sitecore/content/[ORG]/[SITE]"
$SiteData   = "$SiteRoot/Data"
$MediaRoot  = "[ORG]/[SITE]/navigation"   # uploadMedia path (no leading slash)
$MediaQuery = "/sitecore/media library/[ORG]/[SITE]/navigation"

# ---------------------------------------------------------------------------
# Pages to receive the footer rendering -- IDs resolved dynamically at Step 9
# TODO: replace with all POC page paths for this client.
# ---------------------------------------------------------------------------
$pagePaths = @(
    "$SiteRoot/Home"
    # "$SiteRoot/Home/[page-2]"
    # "$SiteRoot/Home/[page-3]"
)

# ---------------------------------------------------------------------------
# Footer rendering params
# footerNavColorScheme=dark    : main nav area
# footerSubnavColorScheme=dark : utility bar (copyright + social icons)
# Valid values: Default, dark, light   (check source site to confirm)
# ---------------------------------------------------------------------------
$footerPar = "footerNavColorScheme=dark&amp;footerSubnavColorScheme=dark"

# ---------------------------------------------------------------------------
# Source content  -- TODO: populate from source site (fetched [DATE])
# ASCII-only -- no em-dashes, smart quotes, or non-ASCII characters.
#
# RULES:
#   - VXA Link "link" field: General Link XML with linktype="external" for POC
#   - VXA Social Link "socialIcon": icon name string
#     Valid values: linkedin, instagram, twitter, facebook, youtube, email
#   - VXA Column Navigation Item "columnHeader": plain text (blank = no header)
#   - $copyright: brand name only -- component renders "© {year}" automatically
# ---------------------------------------------------------------------------
$logoUrl        = "[LOGO_URL]"          # full URL to the logo file (SVG or PNG)
$logoMediaPath  = "$MediaQuery/[logo-filename-without-extension]"
$logoUploadPath = "$MediaRoot/[logo-filename-without-extension]"
$logoMimeType   = "image/svg+xml"       # or image/png

$contactAddress = "[CONTACT_EMAIL_OR_ADDRESS]"
$copyright      = "[CLIENT_BRAND_NAME]"   # e.g. "Velir" (component prepends "© YEAR")

# Social links  -- update or add/remove entries as needed
$socialLinks = @(
    [ordered]@{
        name = "[SOCIAL_PLATFORM]"        # e.g. "LinkedIn"
        icon = "[icon-name]"              # e.g. "linkedin"
        href = "[SOCIAL_URL]"
        text = "[ACCESSIBLE_TEXT]"        # e.g. "Follow us on LinkedIn"
    }
    # Add more social links here...
)

# Footer column 1 links  -- TODO: populate from source site footer
$col1Links = @(
    [ordered]@{ name = "[Link Name]"; href = "[https://...]" }
    # ...
)

# Footer column 2 links  -- TODO: populate from source site footer
$col2Links = @(
    [ordered]@{ name = "[Link Name]"; href = "[https://...]" }
    # ...
)

# Utility nav links (bottom bar)  -- e.g. Privacy Policy, Terms
$utilLinks = @(
    [ordered]@{ name = "[Utility Link Name]"; href = "[https://...]" }
)

# ---------------------------------------------------------------------------
# Helper -- convert N-format GUID to braced hyphenated (for image/item ref fields)
# ---------------------------------------------------------------------------
function fg { param([string]$n) "{$([guid]::new($n).ToString().ToUpper())}" }

# ---------------------------------------------------------------------------
# Helper -- build General Link XML value (external links only, for POC)
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
    $q = "{ item(where:{database:`"master`",path:`"$Path`"}){ field(name:`"__Final Renderings`"){value} } }"
    $d = Invoke-Gql -Query $q
    if ($null -ne $d -and $null -ne $d.item -and $null -ne $d.item.field) {
        return $d.item.field.value
    }
    return $null
}

# ---------------------------------------------------------------------------
# Helper -- add one rendering to a page's headless-footer placeholder if not present
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

    if ($currentXml -match [regex]::Escape("ph=`"/$Placeholder`"") -or
        $currentXml -match [regex]::Escape("s:ph=`"/$Placeholder`"")) {
        Write-Host "  = $Placeholder already has a rendering -- skipping" -ForegroundColor DarkGray
        return
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Would add $RenderingId to /$Placeholder on $PagePath"
        return
    }

    $dsAttr = if ($DatasourceId) { " s:ds=`"$(fg $DatasourceId)`"" } else { "" }
    $uid    = New-LayoutGuid
    $newR   = "<r uid=`"$uid`"$dsAttr s:id=`"$RenderingId`" s:ph=`"/$Placeholder`" s:par=`"$Par`" />"

    # Append before the closing </d> tag
    $updatedXml = $currentXml -replace '</d>\s*</r>', "$newR</d></r>"
    if ($updatedXml -eq $currentXml) {
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
# Step 2 -- Upload footer logo (idempotent)
# ===========================================================================
Write-Host "`nStep 2: Footer logo..." -ForegroundColor Cyan
$logoId = Get-SitecoreItemId -Path $logoMediaPath
if ($logoId) {
    Write-Host "  = Logo already exists: $logoId" -ForegroundColor DarkGray
} else {
    Write-Host "  Downloading logo..."
    $tmpLogo = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetFileName($logoUrl))
    Invoke-WebRequest -Uri $logoUrl -OutFile $tmpLogo -UseBasicParsing

    $d = Invoke-Gql -Query "mutation { uploadMedia(input: { itemPath: `"$logoUploadPath`" }) { presignedUploadUrl } }"
    if (-not $d -or -not $d.uploadMedia) { throw "uploadMedia mutation failed" }
    $presignedUrl = $d.uploadMedia.presignedUploadUrl

    & curl.exe --silent --show-error --request POST $presignedUrl `
        --header "Authorization: Bearer $ApiKey" `
        --form "=@$tmpLogo;type=$logoMimeType"
    if ($LASTEXITCODE -ne 0) { throw "curl.exe upload failed (exit $LASTEXITCODE)" }

    Start-Sleep -Seconds 2
    $logoId = Get-SitecoreItemId -Path $logoMediaPath
    if (-not $logoId) { throw "Logo uploaded but item not found at $logoMediaPath" }
    Write-Host "  Logo GUID: $logoId" -ForegroundColor Green
    Remove-Item $tmpLogo -Force -ErrorAction SilentlyContinue
}
$imgFooterLogo  = "<image mediaid=`"$(fg $logoId)`" />"
$footerLogoLink = New-LinkXml -Href "[$CLIENT_HOME_URL]" -Text "[$CLIENT_NAME]"

# ===========================================================================
# Step 3 -- Social Links folder + social link items
# ===========================================================================
Write-Host "`nStep 3: Social Links..." -ForegroundColor Cyan
$socialLinksFolderId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Social Links" `
    -Name       "Social Links" `
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
            [ordered]@{ name = "link";        value = $linkXml    }
            [ordered]@{ name = "socialIcon";  value = $sl.icon    }
            [ordered]@{ name = "__Sortorder"; value = "$sortOrder" }
        )
    $socialLinkIds += $slId
    $sortOrder += 10
}
$socialLinksMultilist = ($socialLinkIds | ForEach-Object { fg $_ }) -join "|"

# ===========================================================================
# Step 4 -- Global Footer Root datasource
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
# Step 5 -- Column Navigation Root
# ===========================================================================
Write-Host "`nStep 5: Column Navigation Root..." -ForegroundColor Cyan
$colNavRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Footer/Column Nav Root" `
    -Name       "Column Nav Root" `
    -TemplateId $tColumnNavRoot `
    -ParentId   $footerRootId

# Helper: creates a Column Nav Item and its VXA Link children
function New-FooterColumn {
    param(
        [string]$Name,
        [string]$ColumnHeader,   # empty string = no column header rendered
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
# Step 6 -- Footer Column 1
# ===========================================================================
Write-Host "`nStep 6: Footer Column 1..." -ForegroundColor Cyan
New-FooterColumn `
    -Name         "Column 1" `
    -ColumnHeader "" `
    -ParentId     $colNavRootId `
    -ParentPath   "$SiteData/Global Footer/Column Nav Root" `
    -Links        $col1Links | Out-Null

# ===========================================================================
# Step 7 -- Footer Column 2
# ===========================================================================
Write-Host "`nStep 7: Footer Column 2..." -ForegroundColor Cyan
New-FooterColumn `
    -Name         "Column 2" `
    -ColumnHeader "" `
    -ParentId     $colNavRootId `
    -ParentPath   "$SiteData/Global Footer/Column Nav Root" `
    -Links        $col2Links | Out-Null

# ===========================================================================
# Step 8 -- Footer Utility Root + utility links
# ===========================================================================
Write-Host "`nStep 8: Footer Utility Root..." -ForegroundColor Cyan
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
            [ordered]@{ name = "__Sortorder"; value = "$sort" }
        ) | Out-Null
    $sort += 10
}

Write-Host "`n  Footer datasource summary:" -ForegroundColor Green
Write-Host "  Global Footer Root GUID:    $footerRootId"
Write-Host "  Social Links Folder GUID:   $socialLinksFolderId"
Write-Host "  Logo GUID:                  $logoId"

# ===========================================================================
# Step 9 -- Add VxaGlobalFooter rendering to headless-footer on all POC pages
# ===========================================================================
Write-Host "`nStep 9: Adding footer rendering to all POC pages..." -ForegroundColor Cyan
Write-Host "  Resolving page IDs..." -ForegroundColor DarkGray
$pages = [ordered]@{}
foreach ($path in $pagePaths) {
    $id = Get-SitecoreItemId -Path $path
    if (-not $id) { Write-Warning "Could not resolve page ID for: $path -- skipping"; continue }
    $pages[$path] = $id
}
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

Write-Host "`n=== Build-[CLIENT]GlobalFooter.ps1 complete ===" -ForegroundColor Green
Write-Host "  Global Footer Root:   $footerRootId"
Write-Host "  Social Links Folder:  $socialLinksFolderId"
Write-Host "  Logo media GUID:      $logoId"
Write-Host "`nNext steps:"
Write-Host "  1. Run Build-[CLIENT]GlobalHeader.ps1"
Write-Host "  2. Publish all pages + Data folder (poc-publish-page skill)"
Write-Host "  3. Screenshot each page to verify footer renders"
