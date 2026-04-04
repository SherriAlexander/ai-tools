---
name: poc-upload-images
description: 'Upload images from a source website to the Sitecore XM Cloud media library and wire them into Build-VelirPocPage.ps1. Use when: a component needs an image field populated, article thumbnails need uploading, logo images need uploading, or any image currently absent from the media library. Always use this before leaving an image field blank.'
argument-hint: 'Describe which images need uploading: source URL(s), intended media path folder, and which component/datasource needs the image field set'
---

# POC Upload Images

## When to Use
- A VXA component has an image field that should be populated (Multi Promo items, Hero, Promo, etc.)
- Source page has visible images that the POC should replicate
- Logos for a Multi Promo logo wall need uploading
- Article thumbnails need uploading for an "ideas" or blog section

## When NOT to Use
- The image already exists in the media library (check with `Get-SitecoreItemId` first)
- The component intentionally has no image (text-only layout)

## Critical Fact: MCP `upload_asset` Does NOT Work

> ❌ `mcp_sitecore-mark_upload_asset` fails with `fs.readFile is not implemented yet`. The MCP runtime has no filesystem access. This is a permanent limitation. **Always use the PowerShell + GraphQL + curl.exe pattern below.**

---

## Key Rules

1. **Source images from the live website** — never invent image paths. Scrape `og:image` tags or `<img src>` attributes from the actual source page.
2. **Do not guess filenames** — CDN slugs don't always match page slugs (e.g. `johnnieo.png` not `johnnie-o.png`). Regex-match the actual HTML.
3. **Idempotent** — check if the item exists at the target media path before uploading; skip if present.
4. **`uploadMedia` path format:** `dev-demos/standard/folder/item-name` — **NO leading slash**, NO `/sitecore/media library/` prefix.
5. **`UploadMediaPayload` only has `presignedUploadUrl`** — never request `mediaItemId` on this type (GQL error).
6. **curl.exe for file upload** — PowerShell 5.1 multipart encoding is broken. Always use `curl.exe`, never `Invoke-RestMethod`. The `Authorization: Bearer $ApiKey` header is **required** in the curl call even though the presigned URL contains a `token=` parameter — without it the endpoint returns a 302 redirect to the auth portal and the upload silently fails (curl exits 0 with an HTML redirect body).
7. **Resolve GUID after upload** — query by the full media path after upload to get the item ID.
8. **Image field format** — always `<image mediaid="{GUID-UPPERCASE-HYPHENATED-IN-BRACES}" />` — braced GUID required.

---

## Step-by-Step Procedure

### Step 1 — Identify Images to Upload

Fetch the source page(s) and extract image URLs:

```powershell
$html = (Invoke-WebRequest -Uri "https://www.velir.com/some-page" -UseBasicParsing).Content

# For og:image tags:
[regex]::Matches($html, 'og:image.*?content="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }

# For a specific CDN folder (e.g. blog images):
[regex]::Matches($html, 'blog-images/([^"]+\.(?:png|jpg|webp))') | ForEach-Object { $_.Value } | Sort-Object -Unique

# For logos in a specific CDN folder:
[regex]::Matches($html, 'client-logo/([^"]+\.(?:png|svg))') | ForEach-Object { $_.Value } | Sort-Object -Unique
```

Record the exact filenames. Do not construct paths by guessing from display names.

### Step 2 — Choose Media Library Paths

Follow this naming convention:
- **Media path format:** `dev-demos/standard/<section>/<item-name>` (for `uploadMedia` mutation — NO leading slash, NO `/sitecore/media library/` prefix)
- **Full library path:** `/sitecore/media library/dev-demos/standard/<section>/<item-name>` (for GUID lookup — starts with `/sitecore/media library/dev-demos/standard/`, NOT `/sitecore/media library/Project/...`)
- **Section examples:** `services`, `ideas-thumbnails`, `client-logos`, `headshots`
- Use the source filename (without extension) as the `item-name` to preserve traceability

> ⚠️ **Media items do not survive a site/environment reset.** When a Sitecore environment is reset or the media library is wiped, all previously recorded GUIDs become invalid. Always run a live idempotency check (query by path) at the start of Phase 2 — never assume GUIDs from a prior session are still valid.

### Step 3 — Write the Upload Script

Create a dedicated upload script (e.g. `scripts/_upload-<section>-images.ps1`). Use this template:

```powershell
#Requires -Version 5.1
# Uploads images for the "<Section>" section.
# SOURCE: scraped from <source URL>, <date>.
param(
    [string]$CmUrl = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io",
    [string]$ApiKey
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $ApiKey) {
    $ApiKey = (Get-Content (Join-Path $PSScriptRoot "..\\.sitecore\\user.json") | ConvertFrom-Json).endpoints.xmCloud.accessToken
}

$uri  = "$CmUrl/sitecore/api/authoring/graphql/v1"
$hdrs = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }

function Invoke-Gql {
    param([string]$Query)
    $body = ConvertTo-Json ([ordered]@{ query = $Query }) -Depth 10 -Compress
    $r = Invoke-RestMethod -Uri $uri -Method POST -Headers $hdrs -Body $body
    if ($r.PSObject.Properties['errors'] -and $r.errors) {
        $r.errors | ForEach-Object { Write-Warning "GQL: $($_.message)" }
        return $null
    }
    return $r.data
}

function Get-SitecoreItemId {
    param([string]$Path)
    $d = Invoke-Gql "{ item(where: { database: `"master`", path: `"$Path`" }) { itemId } }"
    if ($null -ne $d -and $null -ne $d.item) { return $d.item.itemId }
    return $null
}

$images = @(
    [ordered]@{
        name       = "item-name-no-extension"
        sourceUrl  = "https://www.velir.com/-/media/images/.../<filename>.png"
        uploadPath = "dev-demos/standard/<section>/item-name-no-extension"
        mediaPath  = "/sitecore/media library/dev-demos/standard/<section>/item-name-no-extension"
        fileName   = "item-name-no-extension.png"
    }
    # Add more entries here
)

$results = @{}

foreach ($img in $images) {
    Write-Host "`nProcessing: $($img.name)" -ForegroundColor Cyan

    # Idempotency check
    $existing = Get-SitecoreItemId $img.mediaPath
    if ($existing) {
        Write-Host "  = Already exists: $existing" -ForegroundColor DarkGray
        $results[$img.name] = $existing
        continue
    }

    # Download to temp
    $tmpFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), $img.fileName)
    Write-Host "  Downloading..."
    Invoke-WebRequest -Uri $img.sourceUrl -OutFile $tmpFile -UseBasicParsing

    # Get presigned upload URL
    # NOTE: uploadPath must NOT start with / and must NOT include "/sitecore/media library/"
    $d = Invoke-Gql "mutation { uploadMedia(input: { itemPath: `"$($img.uploadPath)`" }) { presignedUploadUrl } }"
    if (-not $d -or -not $d.uploadMedia) { Write-Warning "  uploadMedia failed"; continue }
    $presignedUrl = $d.uploadMedia.presignedUploadUrl
    Write-Host "  Got presigned URL" -ForegroundColor DarkGreen

    # Upload via curl.exe — PS 5.1 multipart is broken, always use curl.exe
    # NOTE: --header Authorization is REQUIRED even though the URL has token= in it.
    # Without it the endpoint returns a 302 redirect to the auth portal.
    $curlResult = & curl.exe --silent --show-error --request POST $presignedUrl `
        --header "Authorization: Bearer $ApiKey" `
        --form "=@$tmpFile;type=image/png"
    if ($LASTEXITCODE -ne 0) { Write-Warning "  curl failed: $curlResult"; continue }
    Write-Host "  Uploaded" -ForegroundColor Green

    # Resolve GUID (wait for item creation)
    Start-Sleep -Seconds 2
    $newId = Get-SitecoreItemId $img.mediaPath
    if ($newId) {
        Write-Host "  GUID: $newId" -ForegroundColor Green
        $results[$img.name] = $newId
    } else {
        Write-Warning "  Could not resolve GUID at $($img.mediaPath)"
    }

    Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
}

Write-Host "`n=== Upload Results ===" -ForegroundColor Cyan
$results.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key) : $($_.Value)" }
```

### Step 4 — Run the Script

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
.\scripts\_upload-<section>-images.ps1
```

Collect the GUID(s) from the output.

### Step 5 — Format Image Field Values

Convert each GUID to the Sitecore image field format:
- GUIDs from `Get-SitecoreItemId` are returned in **N format** (32 hex, no hyphens): `c3e92e3c...`
- Convert to **braced hyphenated** format: `{C3E92E3C-F224-4C33-BED6-B9E709688E18}`
- Wrap in XML: `<image mediaid="{C3E92E3C-F224-4C33-BED6-B9E709688E18}" />`

PowerShell helper to convert N-format GUID to braced:
```powershell
function Format-Guid { param([string]$raw) "{$([guid]::new($raw).ToString().ToUpper())}" }
```

### Step 6 — Add Image Variables to Build-VelirPocPage.ps1

In the `## Image Field Values` section near the top of variables:

```powershell
# <Section> images — uploaded <date> from <source URL>
$imgSection1 = '<image mediaid="{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}" />'  # item-name.png
$imgSection2 = '<image mediaid="{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}" />'  # item-name.png
```

Then reference `$imgSection1` etc. in the appropriate `fields` hash when calling `create_content_item` or in the datasource update step.

### Step 7 — Verify by Screenshot

After rebuilding and publishing, take a screenshot to confirm images render:

```
Tool: mcp_sitecore-mark_get_page_screenshot
Parameters:
  pageId:   9dc3828e-91a7-4e5d-a4fd-e622ea089d54
  version:  2
  width:    1280
  height:   5000
  fullPage: true
```

---

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `itemPath should not start with '/'` | Used `/sitecore/media library/...` as `uploadMedia` path | Use `dev-demos/standard/folder/name` — no leading slash |
| `wrong structure` or `unexpected fields` | Used variable binding (`$input`) or extra fields in `uploadMedia` | Use inline: `uploadMedia(input: { itemPath: "..." })` — no variable binding |
| `mediaItemId` GQL error | Requested `mediaItemId` on `UploadMediaPayload` | Only `presignedUploadUrl` exists on this type |
| curl multipart fails | Used `Invoke-RestMethod -Form` | Always use `curl.exe --form` — PS 5.1 multipart is broken |
| GUID resolves null after upload | Item creation not yet complete | Add `Start-Sleep -Seconds 2` before the GUID query |
| `fs.readFile is not implemented` | Used `mcp_sitecore-mark_upload_asset` | Don't use that tool — use GraphQL + curl.exe |

---

## Reference: Existing Upload Scripts

- `scripts/_upload-ideas-images.ps1` — uploads 3 article thumbnails (2026-04-02)
- `scripts/_upload-logos.ps1` — uploads 12 client logo PNGs for logo wall (earlier session)

Both scripts follow the idempotency pattern and can be re-run safely.

---

## Reference: Previously Uploaded Images

| Variable in Build Script | GUID | Source Filename |
|---|---|---|
| `$imgIdeasWorkflows` | `C3E92E3C-F224-4C33-BED6-B9E709688E18` | workflows-and-governance_4x3.png |
| `$imgIdeasSitecoreAI` | `D64A1806-7544-473A-8D03-A4A62033D95A` | sitecore-ai-eval-frameworkd-4x3.png |
| `$imgIdeasWomensDay` | `D78D0649-6F0C-484A-92FE-A57104AC5353` | women-in-leadership-4x3.png |
