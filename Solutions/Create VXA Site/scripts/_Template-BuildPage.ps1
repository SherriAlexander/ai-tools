#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the [CLIENT] "[PAGE NAME]" POC page in Sitecore XM Cloud.
.DESCRIPTION
    Idempotent script that creates or updates datasource items under [page]/Data/ and
    applies a full N-section layout to the target page.

    Sections:
      Section 1  -- [describe]
      Section 2  -- [describe]
      ...

    Page:    /sitecore/content/dev-demos/standard/Home/[page-slug]
    Page ID: resolved at runtime by Get-SitecoreItemId in Step 1
    Source:  https://[client-url]   (fetched [date])
    Layout:  N DPIDs (1-N)

    DPID assignment:
      Section 1 -- [name] (1-2):   Full Bleed [colorScheme] + [Component]
      ...
.EXAMPLE
    .\Build-[PageName]Page.ps1
    .\Build-[PageName]Page.ps1 -WhatIf
#>
[CmdletBinding()]
param(
    [string]$CmUrl = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io",
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
$hdrs = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }

# ---------------------------------------------------------------------------
# Target page -- ID resolved dynamically at runtime (Step 1)
# ---------------------------------------------------------------------------
$targetPagePath = "/sitecore/content/dev-demos/standard/Home/[page-slug]"
$dataPath       = "$targetPagePath/Data"

# ---------------------------------------------------------------------------
# Template IDs (N format -- no hyphens, no braces)
# Source: docs/VXA_COMPONENT_SPECS.md Component Registry
# Only include the templates you actually use on this page.
# ---------------------------------------------------------------------------
$tVxaHero        = "4579b39145b746a987b20456c66bf807"
$tVxaVideo       = "14490dcb06554d24b44428c955d790d3"
$tVxaRichText    = "82462949f3754363a4e21224f16f7311"
$tVxaImage       = "4a1cf144249d438da82471e7341d1e19"
$tPromo          = "d100f089a4d34d229d1de7ab0e721f81"
$tCtaBanner      = "5486c1debf464bc2b4fb9faf59903b29"
$tMultiPromo     = "380ffba85f494abca903d069a0add3ec"
$tMultiPromoItem = "b81775e545b54238961b8b2996ff2503"
$tFolder         = "a87a00b1e6db45ab8b54636fec3b5523"

# ---------------------------------------------------------------------------
# Rendering IDs (braced GUID format for layout XML s:id)
# Source: docs/VXA_COMPONENT_SPECS.md Component Registry
# Only include the renderings you actually use on this page.
# ---------------------------------------------------------------------------
$rFullBleed     = "{E80C2A78-FCC2-4D32-8EC5-4133F608BE5C}"
$rContainer5050 = "{1D2998C5-170A-433A-B1EF-90ADB86BB594}"
$rVxaHero       = "{87FAFE78-A3FE-4DDC-8AB8-1054FF60F2A8}"
$rVxaVideo      = "{3A96ECF8-20CE-4F57-A9A6-D2D25F952A1E}"
$rVxaRichText   = "{7246EF71-352F-4C0E-BE90-FB643FCCA413}"
$rVxaImage      = "{BEAD2829-BFB1-41C9-9233-8B17D65047E3}"
$rPromo         = "{82B3AE49-7D2E-4157-85A2-3D43C8F79224}"
$rMultiPromo    = "{A161BB73-6198-472C-B998-2D3714576F93}"
$rCtaBanner     = "{0DCB68F2-F540-4A4F-B32F-A95391B44811}"
$deviceId       = "{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}"
$gridParams     = "%7B7465D855-992E-4DC2-9855-A03250DFA74B%7D"

# ---------------------------------------------------------------------------
# s:par format strings — use -f operator to fill in colorScheme and DPID
#
#   $cp  — Full Bleed / Split containers (has marginTop/marginBottom/gap)
#   $rp  — All non-container content renderings
#   $ppr — Promo with ImageRight variant (FieldNames param added)
#
# Usage:
#   Container:  s:par="`$($cp  -f 'dark','1')`"
#   Child:      s:par="`$($rp  -f 'dark','2')`"
#   PromoIR:    s:par="`$($ppr -f 'default','2')`"
#
# colorScheme values: default | light | dark | vibrant
# ---------------------------------------------------------------------------
$cp  = "marginTop=none&amp;marginBottom=none&amp;gap=none&amp;inset&amp;colorScheme={0}&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"
$rp  = "colorScheme={0}&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"
$ppr = "colorScheme={0}&amp;FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"

# ---------------------------------------------------------------------------
# Helper: convert N-format GUID to braced hyphenated for image fields
# Usage: $imgFoo = "<image mediaid=`"$(fg 'abc123...')`" />"
# ---------------------------------------------------------------------------
function fg { param([string]$n) "{$([guid]::new($n).ToString().ToUpper())}" }

# ---------------------------------------------------------------------------
# Media GUIDs -- confirmed in Sitecore media library, Phase 2, [date]
# Use the upload script (_upload-[section]-images.ps1) to get these.
# Format: "<image mediaid=`"$(fg 'N-FORMAT-GUID')`" />"
# ---------------------------------------------------------------------------
# TODO: add image variables here
# $imgHero = "<image mediaid=`"$(fg 'N-FORMAT-GUID-HERE')`" />"

# ---------------------------------------------------------------------------
# Content
# SOURCE: fetched [date] from [source URL]
#
# RULES (enforced by PS 5.1 / Sitecore field constraints):
#   - ASCII-only: no em-dashes (--), no smart quotes ('') -- PS 5.1 corrupts Unicode
#   - VXA Hero:       title (str), description (plain str, no HTML), link (XML), image (XML)
#   - Promo:          eyebrow, title, description (plain, no HTML), primaryLink (XML), image (XML)
#                     NOTE: Promo CTA is "primaryLink" -- NOT "link"
#   - Multi Promo:    title (str), link (XML)   -- only 2 fields, no numberOfColumns
#   - Multi Promo Item: eyebrow, title, description, link, image
#   - CTA Banner:     title (str), description (plain str, no HTML), link (XML)
#   - Rich Text:      text (HTML accepted -- use <h2>, <p>, <a href="..."> etc.)
#   - All link XML:   linktype="external" url="https://..."  NEVER linktype="internal" without GUID
#   - Empty link:     "<link />"
# ---------------------------------------------------------------------------

# TODO: Section 1 -- [name]
# $heroTitle       = "[title]"
# $heroDescription = "[plain text, no HTML]"
# $heroLink        = '<link text="[label]" linktype="external" url="https://..." target="_blank" />'

# TODO: add remaining content variables per section...

# ===========================================================================
# Step 1 -- Locate page and Data folder
# ===========================================================================
Write-Host "`nStep 1: Locating page and Data folder..." -ForegroundColor Cyan
$pageId = Get-SitecoreItemId $targetPagePath
if (-not $pageId) { throw "Target page not found at $targetPagePath" }
Write-Host "  Page: $pageId"

$dataId = Get-OrCreate-SitecoreItem -Path $dataPath -Name "Data" -TemplateId $tFolder -ParentId $pageId

# ===========================================================================
# Step 2 -- [First component] datasource
# ===========================================================================
# Write-Host "`nStep 2: [Component] datasource..." -ForegroundColor Cyan
# $heroId = Get-OrCreate-SitecoreItem `
#     -Path "$dataPath/[ItemName]" -Name "[ItemName]" `
#     -TemplateId $tVxaHero -ParentId $dataId `
#     -Fields @(
#         [ordered]@{ name="title";       value=$heroTitle }
#         [ordered]@{ name="description"; value=$heroDescription }
#         [ordered]@{ name="link";        value=$heroLink }
#         [ordered]@{ name="image";       value=$imgHero }
#     )
#
# PERFORMANCE NOTES:
#   - Passing -Fields to Get-OrCreate-SitecoreItem folds the field write into the createItem
#     call (1 GQL round trip instead of 2) when the item doesn't exist yet.
#     On re-runs where the item exists, fields are still applied via a separate updateItem.
#   - On a known-fresh page (you just created it in Phase 0), add -ForceCreate to skip the
#     existence check entirely -- saves 1 additional call per item.
#     Only safe when Data/ is guaranteed empty.
# ---------------------------------------------------------------------------
# Multi Promo pattern reminder:
#   1. Create parent with -Fields @( title, link )
#   2. foreach card: Get-OrCreate-SitecoreItem -ParentId $parentId -Fields @( eyebrow, title, description, link, image, __Sortorder )
#   3. ALWAYS call Remove-OrphanedSitecoreChildren after the card loop:
#        Remove-OrphanedSitecoreChildren -ParentPath "$dataPath/Multi Promo [Name]" -KeepNames ($gridItems | ForEach-Object { $_.name })
#      Without this, cards from previous runs with a different list will remain on the page.
#   NOTE: Multi Promo parent only has "title" and "link" -- no numberOfColumns, no eyebrow

# ===========================================================================
# Step N -- Apply layout to page
#
# DynamicPlaceholderId (DPID) is a GLOBAL counter across all renderings.
# Every rendering (containers AND children) each consume one slot in document order.
# Container at id=N exposes placeholder container-fullbleed-N (or container-fifty-left-N etc.)
# Child s:ph must reference its PARENT container's DPID, not the child's own.
#
# Nested 50/50 pattern:
#   Outer Full Bleed (DPID=3) -> inner Split 50/50 (DPID=4)
#   Left child  s:ph = "/headless-main/container-fullbleed-3/container-fifty-left-4"
#   Right child s:ph = "/headless-main/container-fullbleed-3/container-fifty-right-4"
#
# p:before / p:after intentionally OMITTED -- document order = render order.
# ===========================================================================
Write-Host "`nStep N: Applying layout to page..." -ForegroundColor Cyan

# TODO: change 1..N to the actual total DPID count
$uid = @{}; 1..N | ForEach-Object { $uid[$_] = New-LayoutGuid }

$layoutXml = "<r xmlns:p=`"p`" xmlns:s=`"s`" p:p=`"1`"><d id=`"$deviceId`">" +

    "<!-- Section 1: [Name] (DPIDs 1-2) -->" +
    "<r uid=`"$($uid[1])`"  s:id=`"$rFullBleed`"   s:par=`"$($cp -f '[colorScheme]','1')`" s:ph=`"headless-main`" />" +
    "<r uid=`"$($uid[2])`"  s:ds=`"local:/Data/[ItemName]`"  s:id=`"$rVxaHero`"  s:par=`"$($rp -f '[colorScheme]','2')`" s:ph=`"/headless-main/container-fullbleed-1`" />" +

    # TODO: add remaining sections...

    "</d></r>"

Set-SitecoreFields -ItemId $pageId -Fields @(
    [ordered]@{ name="__Final Renderings"; value=$layoutXml }
)

# ===========================================================================
# Done
# ===========================================================================
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  [Page Name] POC layout applied!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Page path : $targetPagePath"
Write-Host "  Page ID   : $pageId"
Write-Host "  Data path : $dataPath"
Write-Host ""
Write-Host "  Datasource items:"
# TODO: list each datasource item and its ID variable
# Write-Host "    [ItemName] : $heroId"
Write-Host ""
Write-Host "  Next: publish to Experience Edge, then take a screenshot."
Write-Host "  Follow poc-publish-page skill for publish steps."
