---
name: sitecore-layout-inspect
description: 'Inspect the current live layout on a Sitecore XM Cloud page — shows all renderings, datasources, placeholders, and DynamicPlaceholderIds in a readable table. Use when: auditing what is on a page, comparing poc vs live site, debugging layout order, checking placeholder assignments, verifying a build script ran correctly.'
argument-hint: 'Optional: specify a different page path (default: Home at /sitecore/content/dev-demos/standard/Home)'
---

# Sitecore Layout Inspect

## When to Use
- Auditing what components and datasources are currently on a page
- Comparing our POC layout against a live reference site
- Debugging rendering order or placeholder assignment issues
- Verifying a build script ran correctly without opening Sitecore Pages UI
- Before adding a new section — confirm current DynamicPlaceholderId counter state

## Key Facts
- Reads `__Final Renderings` on the master database via Authoring GraphQL
- Token must be valid (CM tokens expire in 15 min) — always refresh first
- Default target: `/sitecore/content/dev-demos/standard/Home`
- CM endpoint: `https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io`

---

## Procedure

### Step 1 — Refresh token

Follow the `sitecore-token-refresh` skill. If client credentials fail, fall back to stored token:

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
$ep = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud
$body = "client_id=$([uri]::EscapeDataString($ep.clientId))&client_secret=$([uri]::EscapeDataString($ep.clientSecret))&audience=$([uri]::EscapeDataString($ep.audience))&grant_type=client_credentials"
try {
    $result = Invoke-RestMethod -Method POST -Uri "$($ep.authority)/oauth/token" -ContentType "application/x-www-form-urlencoded" -Body $body
    $TOKEN = $result.access_token
    Write-Host "Token refreshed (expires_in=$($result.expires_in)s)" -ForegroundColor Green
} catch {
    $TOKEN = $ep.accessToken
    Write-Host "Client credentials unavailable — using stored token" -ForegroundColor Yellow
}
```

### Step 2 — Query __Final Renderings

```powershell
$cmUrl  = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io"
$uri    = "$cmUrl/sitecore/api/authoring/graphql/v1"
$hdrs   = @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" }
$page   = "/sitecore/content/dev-demos/standard/Home"   # change if needed

$query  = "{ item(where: { database: `"master`", path: `"$page`" }) { fields { nodes { name value } } } }"
$body   = ConvertTo-Json @{ query = $query } -Compress
$r      = Invoke-RestMethod -Uri $uri -Method POST -Headers $hdrs -Body $body
$fr     = ($r.data.item.fields.nodes | Where-Object { $_.name -eq "__Final Renderings" }).value
```

### Step 3 — Parse and display as a table

```powershell
# Map known rendering GUIDs to friendly names
$renderingNames = @{
    "{E80C2A78-FCC2-4D32-8EC5-4133F608BE5C}" = "Full Bleed Container"
    "{3A96ECF8-20CE-4F57-A9A6-D2D25F952A1E}" = "VXA Video"
    "{1D2998C5-170A-433A-B1EF-90ADB86BB594}" = "Container 50/50"
    "{7246EF71-352F-4C0E-BE90-FB643FCCA413}" = "VXA Rich Text"
    "{87FAFE78-A3FE-4DDC-8AB8-1054FF60F2A8}" = "VXA Hero"
    "{A161BB73-6198-472C-B998-2D3714576F93}" = "Multi Promo"
    "{0DCB68F2-F540-4A4F-B32F-A95391B44811}" = "CTA Banner"
}

[xml]$xml = $fr
$rows = $xml.r.d.r | ForEach-Object {
    $id   = $_.'s:id'
    $dpid = if ($_.'s:par' -match 'DynamicPlaceholderId=(\d+)') { $Matches[1] } else { '?' }
    $cs   = if ($_.'s:par' -match 'colorScheme=([^&]+)') { $Matches[1] } else { '' }
    [pscustomobject]@{
        '#'         = $dpid
        Component   = $(if ($renderingNames[$id]) { $renderingNames[$id] } else { $id })
        ColorScheme = $cs
        Datasource  = $_.'s:ds'
        Placeholder = $_.'s:ph'
    }
}
$rows | Format-Table -AutoSize
```

### Step 4 (optional) — Show raw XML

```powershell
Write-Host $fr
```

---

## Expected output shape (5-section Velir POC)

```
# Component            ColorScheme  Datasource                  Placeholder
- ---------            -----------  ----------                  -----------
1 Full Bleed Container dark                                     headless-main
2 VXA Video            dark         local:/Data/VXA Video 1     /headless-main/container-fullbleed-1
3 Full Bleed Container light                                    headless-main
4 Container 50/50      light                                    /headless-main/container-fullbleed-3
5 VXA Rich Text        light        local:/Data/RT Left 1       /headless-main/container-fullbleed-3/container-fifty-left-4
6 VXA Rich Text        light        local:/Data/RT Right 1      /headless-main/container-fullbleed-3/container-fifty-right-4
7 Full Bleed Container dark                                     headless-main
8 Multi Promo          dark         local:/Data/Multi Promo 1   /headless-main/container-fullbleed-7
9 Full Bleed Container dark                                     headless-main
10 Multi Promo         dark         local:/Data/Multi Promo 2   /headless-main/container-fullbleed-9
11 Full Bleed Container vibrant                                 headless-main
12 CTA Banner          vibrant      local:/Data/CTA Banner 1    /headless-main/container-fullbleed-11
```

The `#` column is the DynamicPlaceholderId. The highest number tells you what the next new rendering should use.
