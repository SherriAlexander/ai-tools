#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the [CLIENT] Global Header for a Sitecore XM Cloud POC site.
.DESCRIPTION
    Idempotent script that creates the Global Header content hierarchy and wires
    the VxaGlobalHeader rendering into the Header Partial Design (site-wide).

    Content structure created under the SITE DATA FOLDER:
      Data/
        Global Header               (VXA Global Header Root)   <- datasource
          Primary Nav               (VXA Primary Navigation Root)
            [NAV_ITEM_1]            (VXA Primary Navigation Item)
              Dropdown              (VXA Primary Navigation Subheader, if has dropdown)
                [DROPDOWN_LINK ...] (VXA Link)
            [NAV_ITEM_2 ...]
          Header Utility Nav        (VXA Header Utility Nav Root)
            [UTILITY_ITEM ...]      (VXA Utility Navigation Item)

    Wired via:
      /[SITE_ROOT]/Presentation/Partial Designs/Header
      (updates __Renderings on the Partial Design -- NOT per-page __Final Renderings)

    Source URL: [SOURCE_URL]   (fetched [DATE])
    Logo URL:   [LOGO_URL]

.NOTES
    ADAPTING FOR A NEW CLIENT SITE:
      1. Update $CmUrl to the new site's CM URL.
      2. Update $SiteRoot.
      3. Update $logoMediaPath to the media library path where the logo was uploaded
         by the footer script (must run footer first; this script throws if logo is missing).
      4. Update $primaryNavItems with the new site's top-level nav and dropdown links.
      5. Update $utilityNavItems with the new site's utility nav (e.g. Contact, Login).
      6. Update $headerPar if sticky or color scheme differs.
      7. Re-run. The script is idempotent.

    WIRING ARCHITECTURE (⚠️ READ BEFORE MODIFYING):
      The VXA site scaffold ships a Header Partial Design at:
        [SITE_ROOT]/Presentation/Partial Designs/Header
      This partial design is automatically merged into every page's layout by the
      SXA engine -- NO per-page __Final Renderings patch is needed or appropriate.

      This script writes to __Renderings on the Partial Design item directly, setting
      s:ds to the explicit GUID of the Global Header Root datasource.

      ⚠️ DO NOT add VxaGlobalHeader to individual page __Final Renderings.
         Doing so creates duplicate headers (one from the partial design + one from the page).
         This was confirmed as a bug on the Velir POC (2026-04-04).

      ⚠️ s:ds in the partial design MUST use an explicit {braced GUID}.
         local: paths resolve relative to the partial design item's own Data subfolder,
         NOT the site's Data folder. local: paths silently fail with no error.

    LOGO DEPENDENCY:
      The logo media item must already exist in the media library before running this script.
      Run Build-[CLIENT]GlobalFooter.ps1 first -- it uploads the logo as part of Step 2.

    KNOWN LIMITATION -- Logo rendering in Next.js:
      If the logo is not visible on the live site after publishing, the likely cause is that
      the Sitecore media blob storage domain is not whitelisted in next.config.js
      remotePatterns. This requires a Next.js deployment change and is out of scope for the
      build scripts. Document it in the site context file and flag it at verification time.
      It is NOT a Sitecore content or script issue.

    DROPDOWN LINKS ARCHITECTURE:
      VXAPrimaryNavigationSubheader is required as an intermediate layer for dropdown links.
      VXALink items placed directly under a Primary Nav Item are ignored by the renderer --
      the ComponentQuery only reads links through a Subheader. Use one Subheader per nav item
      with an empty title (renders as no visible column header). This is VXA's intended model.

.EXAMPLE
    .\Build-[CLIENT]GlobalHeader.ps1
    .\Build-[CLIENT]GlobalHeader.ps1 -WhatIf
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
# Source: docs/VXA_COMPONENT_SPECS.md + VXA monorepo authoring YML
# ---------------------------------------------------------------------------
$tGlobalHeaderRoot = "7dc35bdca28b480b8774659a1caa9be9"  # VXA Global Header Root
$tPrimaryNavRoot   = "22a8abd0f48947c7b022d7ecfa4c1d03"  # VXA Primary Navigation Root
$tPrimaryNavItem   = "00c23ad1b99749bc9c5a10132cca9ccf"  # VXA Primary Navigation Item
$tPrimaryNavSubhdr = "d64c8b84379243bb9294c23df836760f"  # VXA Primary Navigation Subheader
$tUtilityNavRoot   = "b034e8e04912451abfea2753b9400be3"  # VXA Header Utility Nav Root
$tUtilityNavItem   = "f0290f617a114a16baa3f04a0d6d530a"  # VXA Utility Navigation Item
$tVxaLink          = "68197e935b3d4a3ba9fb970ad58ba293"  # VXA Link (shared nav link)

# Rendering ID (braced format for layout XML s:id)
$rHeader  = "{1FA3C6FB-340F-4577-9EF2-B549C2B23039}"    # VxaGlobalHeader

# ---------------------------------------------------------------------------
# Site root and data paths  -- TODO: update for new client
# ---------------------------------------------------------------------------
$SiteRoot = "/sitecore/content/[ORG]/[SITE]"
$SiteData = "$SiteRoot/Data"

# Path to the logo media item created by the footer script (must run footer first)
# TODO: update to the client's logo path in the media library
$logoMediaPath = "/sitecore/media library/[ORG]/[SITE]/navigation/[logo-filename-without-extension]"

# ---------------------------------------------------------------------------
# Header rendering params (s:par in Partial Design __Renderings)
#   sticky=1                        : header sticks on scroll (recommended for most sites)
#   primaryNavColorScheme=Default   : use Default (light) nav bar color scheme
#   Valid primaryNavColorScheme values: Default, dark, light -- check source site
# ---------------------------------------------------------------------------
$headerPar = "sticky=1&amp;primaryNavColorScheme=Default"

# ---------------------------------------------------------------------------
# Source content  -- TODO: populate from source site (fetched [DATE])
# ASCII-only -- no em-dashes, smart quotes, or non-ASCII characters.
#
# Primary nav structure:
#   - Top-level items: name, href, optional target, optional dropdownLinks array
#   - dropdownLinks: child links shown in the flyout/mega-menu
#   - Items with no dropdownLinks should have an empty array: dropdownLinks = @()
#
# Utility nav:
#   - Appears on the right side of the header (typically a CTA button or login link)
#   - isButton = $true renders the item as a styled button
# ---------------------------------------------------------------------------
$primaryNavItems = @(
    [ordered]@{
        name          = "[Nav Item 1]"
        href          = "[https://...]"
        dropdownLinks = @(
            [ordered]@{ name = "[Dropdown Link A]"; href = "[https://...]" }
            [ordered]@{ name = "[Dropdown Link B]"; href = "[https://...]" }
        )
    }
    [ordered]@{
        name          = "[Nav Item 2]"
        href          = "[https://...]"
        dropdownLinks = @()   # No dropdown -- empty array required
    }
    # Add more nav items here...
)

$utilityNavItems = @(
    [ordered]@{
        name     = "[Utility Item, e.g. Contact]"
        href     = "[https://...]"
        isButton = $true   # $true = renders as a CTA button; $false = plain link
    }
)

# ---------------------------------------------------------------------------
# Helper -- convert N-format GUID to braced hyphenated (for image/item ref fields)
# ---------------------------------------------------------------------------
function fg { param([string]$n) "{$([guid]::new($n).ToString().ToUpper())}" }

# ---------------------------------------------------------------------------
# Helper -- build a General Link XML value (external links only, for POC)
# ---------------------------------------------------------------------------
function New-LinkXml {
    param([string]$Href, [string]$Text = "", [string]$Target = "")
    $targetAttr = if ($Target) { " target=`"$Target`"" } else { "" }
    return "<link text=`"$Text`" linktype=`"external`" url=`"$Href`"$targetAttr />"
}

# ===========================================================================
# Step 1 -- Locate site Data folder
# ===========================================================================
Write-Host "`nStep 1: Locating Data folder..." -ForegroundColor Cyan
$dataId = Get-SitecoreItemId -Path $SiteData
if (-not $dataId) { throw "Site Data folder not found at $SiteData" }
Write-Host "  Data folder: $dataId"

# ===========================================================================
# Step 2 -- Resolve logo media GUID (must be uploaded by the footer script first)
# ===========================================================================
Write-Host "`nStep 2: Resolving header logo media..." -ForegroundColor Cyan
$logoId = Get-SitecoreItemId -Path $logoMediaPath
if (-not $logoId) {
    Write-Warning "  Logo media not found at $logoMediaPath"
    Write-Warning "  Run Build-[CLIENT]GlobalFooter.ps1 first to upload the logo."
    throw "Logo media required. Run the footer script first."
}
Write-Host "  Logo GUID: $logoId" -ForegroundColor Green
$imgFieldValue = "<image mediaid=`"$(fg $logoId)`" />"

# --------------------------------------------------------------------------------------------------
# LOGO COLOR NOTE:
#   Ensure the logo variant is correct for the header's color scheme.
#   Example: Default (light background) = use dark/colored logo; dark scheme = use reversed/white logo.
#   A white-on-white logo is a common silent failure -- verify visually after screenshotting.
# --------------------------------------------------------------------------------------------------

# ===========================================================================
# Step 3 -- Global Header Root datasource
# ===========================================================================
Write-Host "`nStep 3: Global Header Root datasource..." -ForegroundColor Cyan
$headerRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Header" `
    -Name       "Global Header" `
    -TemplateId $tGlobalHeaderRoot `
    -ParentId   $dataId `
    -Fields     @(
        [ordered]@{ name = "logo"; value = $imgFieldValue }
        # logoMobile: omit for POC -- component falls back to the logo field
    )

# ===========================================================================
# Step 4 -- Primary Navigation Root
# ===========================================================================
Write-Host "`nStep 4: Primary Navigation Root..." -ForegroundColor Cyan
$primaryNavRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Header/Primary Nav" `
    -Name       "Primary Nav" `
    -TemplateId $tPrimaryNavRoot `
    -ParentId   $headerRootId

# ===========================================================================
# Step 5 -- Primary Navigation Items + dropdown children
#
# ARCHITECTURE:
#   Dropdown links MUST be children of a VXAPrimaryNavigationSubheader item.
#   The ComponentQuery does not read VXALink items directly under a Primary Nav Item.
#   One Subheader per nav item with empty title = untitled column (no visible header).
# ===========================================================================
Write-Host "`nStep 5: Primary Navigation Items..." -ForegroundColor Cyan
$sortOrder = 10
foreach ($navItem in $primaryNavItems) {
    $target  = if ($navItem.Contains('target') -and $navItem.target) { $navItem.target } else { "" }
    $linkXml = New-LinkXml -Href $navItem.href -Text $navItem.name -Target $target

    $navItemId = Get-OrCreate-SitecoreItem `
        -Path       "$SiteData/Global Header/Primary Nav/$($navItem.name)" `
        -Name       $navItem.name `
        -TemplateId $tPrimaryNavItem `
        -ParentId   $primaryNavRootId `
        -Fields     @(
            [ordered]@{ name = "title";       value = $navItem.name }
            [ordered]@{ name = "link";        value = $linkXml      }
            [ordered]@{ name = "__Sortorder"; value = "$sortOrder"  }
        )

    if ($navItem.dropdownLinks.Count -gt 0) {
        $subhdrPath = "$SiteData/Global Header/Primary Nav/$($navItem.name)/Dropdown"
        $subhdrId = Get-OrCreate-SitecoreItem `
            -Path       $subhdrPath `
            -Name       "Dropdown" `
            -TemplateId $tPrimaryNavSubhdr `
            -ParentId   $navItemId `
            -Fields     @(
                [ordered]@{ name = "title"; value = "" }
            )

        $linkSort = 10
        foreach ($dl in $navItem.dropdownLinks) {
            $dlTarget  = if ($dl.Contains('target') -and $dl.target) { $dl.target } else { "" }
            $dlLinkXml = New-LinkXml -Href $dl.href -Text $dl.name -Target $dlTarget
            Get-OrCreate-SitecoreItem `
                -Path       "$subhdrPath/$($dl.name)" `
                -Name       $dl.name `
                -TemplateId $tVxaLink `
                -ParentId   $subhdrId `
                -Fields     @(
                    [ordered]@{ name = "link";        value = $dlLinkXml }
                    [ordered]@{ name = "__Sortorder"; value = "$linkSort" }
                ) | Out-Null
            $linkSort += 10
        }
    }

    $sortOrder += 10
}

# ===========================================================================
# Step 6 -- Header Utility Nav Root + utility items
# ===========================================================================
Write-Host "`nStep 6: Header Utility Nav Root..." -ForegroundColor Cyan
$utilNavRootId = Get-OrCreate-SitecoreItem `
    -Path       "$SiteData/Global Header/Header Utility Nav" `
    -Name       "Header Utility Nav" `
    -TemplateId $tUtilityNavRoot `
    -ParentId   $headerRootId

$uSort = 10
foreach ($ui in $utilityNavItems) {
    $uLinkXml = New-LinkXml -Href $ui.href -Text $ui.name
    $isBtn    = if ($ui.isButton) { "1" } else { "0" }
    Get-OrCreate-SitecoreItem `
        -Path       "$SiteData/Global Header/Header Utility Nav/$($ui.name)" `
        -Name       $ui.name `
        -TemplateId $tUtilityNavItem `
        -ParentId   $utilNavRootId `
        -Fields     @(
            [ordered]@{ name = "utilityLink";  value = $uLinkXml }
            [ordered]@{ name = "isButton";     value = $isBtn    }
            [ordered]@{ name = "__Sortorder";  value = "$uSort"  }
        ) | Out-Null
    $uSort += 10
}

Write-Host "`n  Header datasource summary:" -ForegroundColor Green
Write-Host "  Global Header Root GUID : $headerRootId"
Write-Host "  Primary Nav Root GUID   : $primaryNavRootId"
Write-Host "  Utility Nav Root GUID   : $utilNavRootId"
Write-Host "  Logo GUID               : $logoId"

# ===========================================================================
# Step 7 -- Wire VxaGlobalHeader via the Partial Design (site-wide)
#
# ARCHITECTURE (⚠️ DO NOT change to per-page __Final Renderings):
#   Update __Renderings on the Partial Design item to point s:ds at our
#   populated Global Header Root. The SXA engine merges this automatically
#   into every page layout -- no per-page patching required.
#
#   s:ds MUST be an explicit {braced GUID} -- local: paths resolve relative
#   to the partial design's own Data subfolder, not the site Data folder.
# ===========================================================================
Write-Host "`nStep 7: Wiring header via Partial Design (site-wide)..." -ForegroundColor Cyan

$partialDesignPath = "$SiteRoot/Presentation/Partial Designs/Header"
$ourHeaderDs       = "{$($headerRootId.ToUpper())}"
$partialRenderings = "<r xmlns:p=`"p`" xmlns:s=`"s`" p:p=`"1`"><d id=`"{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}`"><r uid=`"{05E79A40-3DBE-46E6-AD23-149752A6BAC1}`" s:ds=`"$ourHeaderDs`" s:id=`"$rHeader`" s:par=`"$headerPar`" s:ph=`"headless-header`" /></d></r>"

if ($WhatIf) {
    Write-Host "  [WhatIf] Would update Partial Design __Renderings at $partialDesignPath" -ForegroundColor DarkGray
} else {
    $mutation7 = "mutation { updateItem(input: { database: `"master`" path: `"$partialDesignPath`" fields: [{ name: `"__Renderings`" value: $(ConvertTo-Json $partialRenderings) }] }) { item { path } } }"
    $r7 = Invoke-Gql -Query $mutation7
    if ($r7 -and $r7.updateItem -and $r7.updateItem.item.path) {
        Write-Host "  Partial Design updated: $($r7.updateItem.item.path)" -ForegroundColor Green
        Write-Host "  s:ds set to: $ourHeaderDs"
    } else {
        Write-Warning "  updateItem returned unexpected result -- check errors above"
        Write-Warning "  Partial Design path: $partialDesignPath"
    }
}

# ===========================================================================
# Step 8 -- Publish Partial Design + Data folder to Experience Edge
# ===========================================================================
Write-Host "`nStep 8: Publishing to Experience Edge..." -ForegroundColor Cyan
$publishPaths = @($partialDesignPath, $SiteData)

foreach ($path in $publishPaths) {
    Write-Host "  Publishing: $path" -ForegroundColor DarkGray
    $mutation = "mutation { publishItem(input: { rootItemPath: `"$path`" languages: `"en`" targetDatabases: `"experienceedge`" publishItemMode: SMART publishRelatedItems: true publishSubItems: true }) { operationId } }"
    $d = Invoke-Gql -Query $mutation
    if ($d -and $d.publishItem) {
        Write-Host "  operationId: $($d.publishItem.operationId)" -ForegroundColor Green
    }
}

Write-Host "`n=== Build-[CLIENT]GlobalHeader.ps1 complete ===" -ForegroundColor Green
Write-Host "  Wait 30-60 seconds for Experience Edge propagation before screenshotting." -ForegroundColor Yellow
Write-Host ""
Write-Host "VERIFY: Query current item version before screenshotting:" -ForegroundColor Yellow
Write-Host "  { item(where:{database:`"master`",path:`"$SiteRoot/Home`"}){versions{number}}}" -ForegroundColor DarkGray
Write-Host ""
Write-Host "KNOWN LIMITATION: If the logo is not visible on the live site, check next.config.js" -ForegroundColor Yellow
Write-Host "  remotePatterns -- the Sitecore media blob domain may not be whitelisted." -ForegroundColor Yellow
Write-Host "  This requires a Next.js deployment change; it is not a Sitecore content issue." -ForegroundColor Yellow
