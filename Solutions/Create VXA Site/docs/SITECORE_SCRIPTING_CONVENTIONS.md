# Sitecore Scripting Conventions

Lessons learned from scripting against the Sitecore XM Cloud Authoring GraphQL API.

---

## PowerShell Compatibility (5.1)

- **Never inline `Invoke-Gql` / `Get-SitecoreItemId` / `Get-OrCreate-SitecoreItem`** — always dot-source `Shared-SitecoreHelpers.ps1` instead. Inlining these helpers requires precise PS 5.1 backtick-escape quoting inside GQL strings (`` `" `` not `` ` ``), which is error-prone and causes `Unexpected character (96)` GQL errors. Every script must start with:
  ```powershell
  . (Join-Path $PSScriptRoot "Shared-SitecoreHelpers.ps1")
  ```
  This applies to upload scripts (`_upload-*.ps1`) as well as build scripts.
- **File encoding:** Save `.ps1` files as **UTF-8 with BOM**. PowerShell 5.1 defaults to Windows-1252 and will corrupt multi-byte characters (e.g. em-dashes become `â€"`). UTF-8 BOM forces correct decoding.
- **Null-coalescing:** The `??` operator is **PowerShell 7+ only**. Use `$(if ($x) { $x } else { $default })` for PS 5.1 compatibility.
- **StrictMode and missing properties:** Under `Set-StrictMode -Version Latest`, accessing a property that doesn't exist on a PSObject throws a terminating error. Always guard with `$obj.PSObject.Properties['propName']` before accessing optional properties (e.g. `errors` on a GraphQL response).
- **Subexpressions in conditions:** `if ($(...))` requires `$()` wrapping in PS 5.1; bare `if ((expr))` may not evaluate correctly in all contexts.

---

## Sitecore Authoring GraphQL API

### GUID Formats

- The API accepts and returns GUIDs in **N format** (32 hex chars, no hyphens, no braces): `0de95ae441ab4d019eb067441b7c2450`
- **Do not** use standard `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` or hyphenated formats — the API will return a GUID type conversion error.

### Item References

- When passing a parent or item reference to a mutation, use the **item's GUID** (N format), not a path string like `/sitecore/content/...`.
- To get an item's GUID: query `itemId` in the same request that locates the item by path, then pass that value to subsequent mutations.

### Field Values

- The Authoring API stores and returns field values as plain strings. **Rich Text and other fields do not preserve special Unicode characters** like em-dashes (`—`). Use plain ASCII hyphens (`-`) in test values and expected strings when asserting round-trips.

### GraphQL Variable Types

- `itemId` filter arguments expect type `ID!`, not `String!`. Using `String!` will pass type checking but fail at runtime with a type mismatch error.

### Field Connection Queries

- Fields are returned as a **connection type**. Always use `fields { nodes { name value } }`.
- `fields { name value }` will fail with `"name does not exist on type ItemFieldConnection"`.

### Layout XML — Rendering Order and DynamicPlaceholderIds

- **Do not use `p:before` / `p:after` attributes** in layout XML. These are Experience Editor UI hints only. Including them (especially `p:before="*"`) on multiple renderings causes rendering order bugs in the headless rendering service. Document order in the XML is what controls the render order.
- **DynamicPlaceholderId is a global counter** across all renderings on a page, not per-component. Each rendering — both containers and their children — gets a unique incrementing integer. Example pattern for 6-section layout:
  - Container 1 → `DynamicPlaceholderId="1"` → exposes `container-fullbleed-1`
  - Child 1 (e.g. Video) → `DynamicPlaceholderId="2"` → placed in `container-fullbleed-1`
  - Container 2 → `DynamicPlaceholderId="3"` → exposes `container-fullbleed-3`
  - Child 2 (e.g. Promo) → `DynamicPlaceholderId="4"` → placed in `container-fullbleed-3`
  - And so on…
- The `placeholderKey` for a child rendering must reference its **parent container's DynamicPlaceholderId**, not its own. Example: a child at id=4 inside a container at id=3 uses `placeholderKey="container-fullbleed-3"`.

### Layout XML — Nested Container Placeholders

Containers inside containers (e.g. `Container5050` inside a `Full Bleed Container`) create nested placeholder paths. The format is:

```
/headless-main/container-fullbleed-{outerId}/container-fifty-left-{innerId}
/headless-main/container-fullbleed-{outerId}/container-fifty-right-{innerId}
```

Where `{innerId}` is the **DynamicPlaceholderId of the inner container** (the `Container5050`). The DynamicPlaceholderId counter is still global — every rendering on the page consumes one slot. Example for a page that has a `Full Bleed` at id=3 containing a `Container5050` at id=4:
- Left child → `s:ph="/headless-main/container-fullbleed-3/container-fifty-left-4"`
- Right child → `s:ph="/headless-main/container-fullbleed-3/container-fifty-right-4"`

### Layout XML — General Link Field Format

Link fields (`General Link` type) store XML strings, **not plain URLs**. The correct formats:

```xml
<!-- External URL -->
<link text="Learn More" linktype="external" url="https://example.com" target="_blank" />

<!-- Empty link (safe default) -->
<link />
```

- **Never** use `linktype="internal"` without a valid item GUID in `id="{GUID}"` — this crashes the rendering host.
- For video fields on VXA Video: same format — the `video` field is a General Link that accepts an external URL (YouTube, Vimeo, or direct MP4).
- The `ambient` rendering parameter on VXA Video (`params` attribute in layout XML) controls background/ambient display styling. It is a rendering parameter, not a field.

---

## Media Upload

### `uploadMedia` Mutation Schema

- `UploadMediaPayload` has **only** `presignedUploadUrl` — the field `mediaItemId` **does not exist** on this type and will cause a GQL error if requested.
- Upload is always two steps: (1) call `uploadMedia` to get the presigned URL, (2) POST the file via `curl.exe`.
- **`Authorization` header required in curl** — the presigned URL contains a `token=` parameter but the CM endpoint still requires `--header "Authorization: Bearer $TOKEN"` in the curl call. Without it, the endpoint returns a 302 redirect to the auth portal and the upload silently fails (curl exits 0 with an HTML body, no item is created).
- To check idempotency (skip re-upload if already present), query the item by path before calling `uploadMedia`.
- **`uploadMedia` input takes only `itemPath`** — the valid input object is `{ itemPath: "..." }`. The fields `itemName` and `language` do **not** exist on `UploadMediaInput` and will cause a `field does not exist` GQL error. `itemPath` must be the full path including the desired item name (e.g. `dev-demos/standard/work/my-image`). No leading slash, no `/sitecore/media library/` prefix.

### Scraping Actual Media Filenames

When guessing filenames for media assets from a known CDN folder (e.g. `velir.com/-/media/images/services-images/client-logo/`), **do not guess** — scrape the actual page HTML first:

```powershell
$html = (Invoke-WebRequest -Uri "https://www.velir.com" -UseBasicParsing).Content
[regex]::Matches($html, 'client-logo/([^"]+\.(?:png|svg|jpg|webp))') | ForEach-Object { $_.Value } | Sort-Object -Unique
```

Real-world mismatches on velir.com (2026-04-02):
- `johnnie-o` → actual: `johnnieo.png`
- `american-bankers-association` → actual: `aba.png`
- `kellogg` → actual: `northwestern-kellogg.png`
- `metropolitan-museum-of-art` → actual: `the-met.png`

### Color Scheme for Logo Walls

Multi Promo with black-on-transparent PNG logos: use `light` colorScheme on the Full Bleed container — `dark` makes logos invisible (black on black).

---

## Content Scraping Rules

### Card Grid Images — Always Use `og:image` from Each Item's Own Page

When building a Multi Promo card grid from a listing page (e.g. `/work`, `/ideas`), **do not use images scraped from the listing page HTML**. The listing page may contain carousel images, hero images, or other non-grid assets mixed in.

**Correct approach:** fetch `og:image` from each card's individual page:

```powershell
$slugs = @("suncoast-credit-union","childrens-national-hospital-dx","nahb-homepage")
foreach ($s in $slugs) {
    $h = (Invoke-WebRequest "https://www.velir.com/work/case-studies/$s" -UseBasicParsing).Content
    $og = [regex]::Match($h, '<meta[^>]*property="og:image"[^>]*content="([^"]+)"')
    Write-Host "$s`: $($og.Groups[1].Value)"
}
```

`og:image` is always the correct 4:3 card thumbnail. Listing-page scrapes return unpredictable aspect ratios.

### Card Grid Item Order — Verify the Order Before Writing Cards

When extracting the ordered list of card items from a listing page, **cross-check the scraped link list against a visual screenshot** before using it as card data. Listing pages often have carousels, hero sections, or featured items above the main grid — a naive link scrape will interleave carousel items with grid items.

**Correct approach:**
1. Take a Playwright/MCP screenshot of the listing page.
2. Scrape all case study slugs from the HTML: `[regex]::Matches($html, '/work/case-studies/([a-z0-9-]+)')`.
3. Visually compare the scraped slug list against the visible grid in the screenshot. Remove any that belong to the carousel/hero section.
4. Only then fetch `og:image` for each confirmed grid slug.

### Item Versioning and `__Final Renderings`

- `__Final Renderings` is a **shared field** — mutations affect ALL versions of the item.
- To target a specific version in `updateItem`, include `version:` in the input.
- Use `addItemVersion` to create a new version programmatically before writing to it.
- **Sitecore item versions cannot isolate layout changes.** Use separate page items for layout experiments.

### MCP Screenshots — Always Pass the Correct Item Version

`mcp_sitecore-mark_get_page_screenshot` requires a `version` parameter. Getting it wrong returns either an error or a screenshot of the wrong version.

- Newly created pages always start at **version 1**. Pass `version: 1` unless you have explicitly created additional versions.
- If you created item version 2 to work in (e.g. to preserve the original), pass `version: 2`.
- If unsure, query the current version count before screenshotting:
  ```graphql
  { item(where: { database: "master", path: "/sitecore/content/..." }) { versions { number } } }
  ```
  Use the highest number returned.

### Datasource References in Layout XML

- `local:/Data/ItemName` resolves relative to the **page item** that owns the `__Final Renderings`.
- Moving layout XML to a different page requires either creating matching datasource items under the new page's `Data/` folder, or switching to absolute GUID references (N format).
- Prefer `local:` paths for maintainability; use absolute GUIDs only when datasources live outside the page tree.

### Link Field Values

- `linktype="internal"` **requires** a valid item GUID in the `id` attribute. Omitting the `id` or using only `url="/path"` causes the layout service to fail, crashing the Next.js editing host with a 500.
- Use `linktype="external"` with a full URL for links that don't target a Sitecore item.
- Leave link fields empty (`<link />` or blank string) rather than writing invalid internal links.
- **Corrupted link fields on shared datasource items break ALL versions** of every page that references them.

### Authentication

- Tokens are stored in `.sitecore/user.json` under `endpoints.xmCloud.accessToken` after running `dotnet sitecore cloud login`.
- Re-run `dotnet sitecore cloud login` to switch organizations — the new token overwrites the previous one.
- **Token expiry:** The CM access token (`endpoints.xmCloud.accessToken`) expires in **15 minutes** (`expires_in: 900`). Long-running scripts will fail mid-run if they use a stale token.
- **Non-interactive login:** Use `dotnet sitecore cloud login --client-credentials --client-id <id> --client-secret <secret>` for CI/automation flows (no browser required).

### Token Auto-Refresh Practice

Do not assume the token in `user.json` is valid. Re-request it at the start of every script run using the credentials already stored in `user.json`:

```powershell
function Get-SitecoreToken {
    param(
        [string]$UserJsonPath = ".sitecore/user.json",
        # Use 'cm' for Authoring GraphQL (15-min token)
        # Use 'api' for Pages/Sites REST API (24-hour token)
        [ValidateSet('cm','api')]
        [string]$Scope = 'cm'
    )
    $userJson = Get-Content $UserJsonPath -Raw | ConvertFrom-Json
    $ep       = $userJson.endpoints.xmCloud

    $audience = if ($Scope -eq 'cm') { $ep.audience } else { 'https://api.sitecorecloud.io' }

    $body = "client_id=$([uri]::EscapeDataString($ep.clientId))" +
            "&client_secret=$([uri]::EscapeDataString($ep.clientSecret))" +
            "&audience=$([uri]::EscapeDataString($audience))" +
            "&grant_type=client_credentials"

    $result = Invoke-RestMethod -Method POST `
        -Uri "$($ep.authority)/oauth/token" `
        -ContentType 'application/x-www-form-urlencoded' `
        -Body $body

    return $result.access_token
}

# Usage — call once at the top of each script:
$TOKEN = Get-SitecoreToken -UserJsonPath ".sitecore/user.json" -Scope cm
```

**Two token scopes exist:**
| Scope | Audience | Expiry | Used for |
|-------|----------|--------|----------|
| `cm` | `$ep.audience` (e.g. `https://xmcloud-cm.sitecorecloud.io`) | 15 min | Authoring GraphQL mutations |
| `api` | `https://api.sitecorecloud.io` | 24 hr | Pages REST API, Sites REST API |

The `user.json` `audience` field is the CM audience. Swap to `https://api.sitecorecloud.io` for REST APIs.

---

---

## Pages REST API (XM Apps)

A REST API for managing pages, layouts, and fields. Separate from and complementary to the Authoring GraphQL API.

- **Base URL:** `https://xmapps-api.sitecorecloud.io`
- **Auth:** Bearer token with `audience: https://api.sitecorecloud.io` (24-hour expiry — use `Get-SitecoreToken -Scope api`)
- **API Docs:** https://api-docs.sitecore.com/sai/pages-api

### Key Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/api/v1/pages/{pageId}` | Retrieve page (fields, layout, template, workflow) |
| `POST` | `/api/v1/pages/{pageId}/layout` | Save layout (Final or Shared) |
| `PATCH` | `/api/v1/pages/{pageId}` | Update field values by field name |
| `POST` | `/api/v1/pages/{pageId}/fields` | Save page fields |
| `POST` | `/api/v1/pages/{pageId}/version` | Add a page version |

### SaveLayout Request Shape

The `layout.body` is a **JSON string** (not XML like `__Final Renderings`). This is the Pages/XM Apps representation, distinct from the Sitecore layout XML stored on the item itself.

```json
{
  "site": "my-site",
  "language": "en-US",
  "layout": {
    "kind": "Final",
    "body": "{\"devices\":[{\"id\":\"fe5d7fdf-89c0-4d99-9aa3-b5fbd009c9f3\",\"layoutId\":\"<layoutId>\",\"renderings\":[{\"id\":\"<renderingId>\",\"instanceId\":\"<guid>\",\"placeholderKey\":\"headless-main\",\"dataSource\":\"local:/Data/MyItem\",\"parameters\":{\"DynamicPlaceholderId\":\"1\"}}]}]}"
  }
}
```

**Note:** `pageId` must be the item GUID. The `environmentId` query parameter is optional but recommended for clarity.

**Status:** Not yet validated against our live environment. Authoring GraphQL remains our proven path; Pages REST API is a candidate for a cleaner layout-write approach once tested.

---

## Sitecore CLI — Additional Commands

### Publish via CLI

```powershell
# Publish a single item and its subitems + related items
dotnet sitecore publish item --path /sitecore/content/Home -sub -rel
```

Flags: `-sub` (publish subitems), `-rel` (publish related items). Alternative to our current GraphQL-based publish calls.

> ⚠️ **CLI publish requires a live CLI session** — separate from the bearer token used by `Invoke-Gql`. When the CLI session has expired, this command fails with `Make sure the GraphQL service is installed and available` (exit code 1). This error message is misleading — the GraphQL service is fine; the CLI just isn't authenticated.
>
> **Reliable fallback:** Use the `publishItem` GraphQL mutation directly. It uses the same bearer token as all other mutations and is the preferred publish path in scripted/agent contexts:
> ```powershell
> $mutation = 'mutation { publishItem(input: { rootItemPath: "/sitecore/content/dev-demos/standard/Home/target-page" languages: "en" targetDatabases: "experienceedge" publishItemMode: SMART publishRelatedItems: true publishSubItems: true }) { operationId } }'
> $body = ConvertTo-Json @{ query = $mutation } -Compress
> $r = Invoke-RestMethod -Method POST -Uri "$CmUrl/sitecore/api/authoring/graphql/v1" -Headers @{ Authorization = "Bearer $TOKEN"; "Content-Type" = "application/json" } -Body $body
> Write-Host "Publish operationId: $($r.data.publishItem.operationId)"
> ```
> Publish is async — wait 30-60 seconds for Edge propagation before screenshotting.

### Serialization push with immediate publish

```powershell
# Push serialized items and publish in one step
dotnet sitecore ser push -p
```

The `-p` / `--publish` flag triggers a publish after the push completes.

---

## currentUser Query

- The `User` type on the Authoring GraphQL endpoint only exposes `name`. The `email` field does **not** exist and will cause a field-not-found error.

```graphql
# Correct
query { currentUser { name } }

# Wrong — email field does not exist
query { currentUser { name email } }
```

---

## VXA Component Knowledge

### VxaPromo — Image+Text Only, Not Text+Text

`VxaPromo` (`82b3ae49`) is an **image + text** component. It has an image slot on one side and text on the other. Without an image datasource field, one column is always blank — it cannot be used for title-left / body-right layouts with no image.

**Variants:**
| FieldNames value | Layout |
|---|---|
| `Default` | Text left, image right ✅ (confirmed 2026-04-02 against live velir.com Promo section) |
| `Animated` | Same as Default with scroll animation |
| `ImageRight` | ⚠️ Name is misleading — despite the name, this does NOT reliably place the image on the right. Tested 2026-04-02: applying `FieldNames=ImageRight` in layout XML params produced swapped columns vs. Default. Use `Default` (no FieldNames param) for text-left / image-right layout. |
| `ImageRightAnimated` | Same as ImageRight with scroll animation |

> **Lesson (2026-04-02):** Do not assume VxaPromo variant names are self-describing. Always verify the rendered column order against the live site. `Default` (omit FieldNames from params) = text left, image right — which matches the velir.com homepage Brooklyn Data section.

**For a two-column text layout (no image):** Use `Container5050` with `VxaRichText` in each column instead.

### Container5050 — Two-Column Text/Component Layout

Rendering ID: `1d2998c5-170a-433a-b1ef-90adb86bb594`  
Placeholder keys (dynamic): `container-fifty-left-{N}` / `container-fifty-right-{N}`  
where `{N}` is the `DynamicPlaceholderId` of the `Container5050` rendering itself.

Allowed content components in each column: `VxaRichText`, `VxaImage`, `VxaVideo`, `VxaMultiPromo`, `CTABanner`, `VxaPromo`, `VxaAccordion`.

**Container variants available:** `Container70` (70/30), `Container7030` (70/30), `Container3070` (30/70).

### VxaBodyText vs VxaRichText

- `VxaBodyText` (`20c6df53`) — **no datasource template**. `get_component` returns 404. Cannot be used in scripted layout — invisible to both the Agent API and container placeholder allowed-controls.
- `VxaRichText` (`7246ef71`) — has `datasourceTemplateId`, single `text` field (Rich Text type). Use this for any inline HTML content blocks. Supports `<h1>`–`<h6>`, `<p>`, `<a>`, lists, etc.

### VxaRichText Rendering Parameters

No `FieldNames`/variant parameter. Only standard params: `colorScheme`, `GridParameters`, `Styles`, `CSSStyles`, `DynamicPlaceholderId`.

---

## Source Content Fetching Lessons

### Carousel Content — Only the Active Item Is Visible in a Static Fetch

`fetch_webpage` returns the initial page render. When velir.com uses a carousel or slider, only the **currently active item** appears in the fetched text. The remaining items are in the DOM but not rendered as visible text.

**Signal:** Look for "Item X of Y" in the fetched output. That means the section is a carousel and you are only seeing item X.

**DO NOT** assume the first carousel item represents all cards in that section. Example: the velir.com homepage "Use Data to Take Your Digital Experiences to the Next Level" section is a carousel. Item 1 showed Brooklyn Data content — but the 3 actual service cards (Digital Marketing, Experience Design, Data Strategy) are the full set, visible only when you fetch `/what-we-do` where they appear as a grid.

**Rule:** When a section has a carousel, always fetch the corresponding sub-page (e.g., `/what-we-do`) rather than relying on the homepage carousel state.

### Thematically Similar Sections Can Be Confused

The velir.com homepage has **two separate sections** that are both about data/Brooklyn Data:
1. **Multi Promo** — "Use Data to Take Your Digital Experiences to the Next Level" — 3 service cards (Digital Marketing, Experience Design, Data Strategy)
2. **Promo (50/50)** — "Harness the power of your data..." — Brooklyn Data partnership section with co-brand logo image

Because both reference data and Brooklyn Data, a carousel-limited fetch caused us to populate Service-1 in the Multi Promo with the Brooklyn Data partnership content instead of the correct Digital Marketing card.

**Rule:** After building a section from fetched content, compare your result against a fresh screenshot of the live site before moving on. Do not rely solely on DOM text. If content seems thematically similar across sections, verify you've correctly mapped each piece to its source component.

---

## Layout XML `s:par` Patterns

Every rendering in layout XML requires an `s:par` attribute encoding its rendering parameters. Define these pattern strings once at the top of each build script and use PowerShell's `-f` format operator to substitute `colorScheme` and `DynamicPlaceholderId`.

### Pattern Definitions

```powershell
# Set once at the top of each build script
$gridParams = "%7B7465D855-992E-4DC2-9855-A03250DFA74B%7D"

# Full Bleed Container  (margins zeroed, inset mode)
# Usage: $cp -f 'dark', 1
$cp = "marginTop=none&amp;marginBottom=none&amp;gap=none&amp;inset&amp;colorScheme={0}&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"

# Standard content component or nested container  (no margin override)
# Usage: $rp -f 'light', 4
$rp = "colorScheme={0}&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"

# VXA Video in ambient (background hero) mode
# Usage: $vp -f 'dark', 2
$vp = "ambient=1&amp;colorScheme={0}&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"

# Promo with ImageRight variant (FieldNames GUID = 65c44a3b-df9c-4f4a-bd13-12b572d4fc24)
# Usage: $ppr -f 'default', 10
$ppr = "colorScheme={0}&amp;FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"
```

### Which Pattern to Use

| Component | Pattern |
|---|---|
| Full Bleed Container | `$cp` |
| Split 50/50 Container | `$rp` |
| VXA Hero | `$rp` |
| VXA Video (ambient/hero background) | `$vp` |
| VXA Video (standard playback) | `$rp` |
| VXA Rich Text | `$rp` |
| VXA Image | `$rp` |
| Multi Promo | `$rp` |
| Promo (image left / default) | `$rp` |
| Promo (image right) | `$ppr` |
| CTA Banner | `$rp` |

### `colorScheme` Values

`default`, `light`, `dark`, `vibrant`

### Layout Row Templates

```powershell
# Generate UIDs for all renderings at the top of the layout step:
$uid = @{}; 1..{totalCount} | ForEach-Object { $uid[$_] = New-LayoutGuid }

# Full Bleed Container row (goes in headless-main):
"<r uid=`"$($uid[N])`" s:id=`"$rFullBleed`" s:par=`"$($cp -f 'dark','N')`" s:ph=`"headless-main`" />"

# Content component inside a Full Bleed:
"<r uid=`"$($uid[N])`" s:ds=`"local:/Data/DatasourceName`" s:id=`"$rComponent`" s:par=`"$($rp -f 'dark','N')`" s:ph=`"/headless-main/container-fullbleed-{parentId}`" />"

# Split 50/50 container inside Full Bleed (Full Bleed at id=3, 50/50 at id=4):
"<r uid=`"$($uid[4])`" s:id=`"$rContainer5050`" s:par=`"$($rp -f 'light','4')`" s:ph=`"/headless-main/container-fullbleed-3`" />"
# Left child (id=5):
"<r uid=`"$($uid[5])`" s:ds=`"local:/Data/Name`" s:id=`"$rVxaRichText`" s:par=`"$($rp -f 'light','5')`" s:ph=`"/headless-main/container-fullbleed-3/container-fifty-left-4`" />"
# Right child (id=6):
"<r uid=`"$($uid[6])`" s:ds=`"local:/Data/Name`" s:id=`"$rVxaRichText`" s:par=`"$($rp -f 'light','6')`" s:ph=`"/headless-main/container-fullbleed-3/container-fifty-right-4`" />"

# Write the completed layout XML to the page:
$deviceId = "{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}"
$layoutXml = "<r xmlns:p=`"p`" xmlns:s=`"s`" p:p=`"1`"><d id=`"$deviceId`">" +
    # ... rendering rows ...
    "</d></r>"
Set-SitecoreFields -ItemId $targetPageId -Fields @(
    [ordered]@{ name="__Final Renderings"; value=$layoutXml }
)
```

---

## Global Navigation Layout Patterns

### `headless-header` and `headless-footer` are static placeholders, not SXA partial designs

`headless-header` and `headless-footer` are hardcoded in `Layout.tsx` as fixed placeholder slots — they are NOT SXA partial designs and do NOT use the SXA partial design system. Key implications:

- Each accepts exactly one rendering (Global Header and Global Footer respectively).
- They are added via `__Final Renderings` patch (PowerShell `Add-RenderingToPageLayout`), NOT via `add_component_on_page` (MCP). The MCP Agent API has no mechanism for static placeholders.
- Renderings in these slots use **rendering-specific params only** — no `DynamicPlaceholderId`, no `GridParameters`. Example footer `s:par`: `footerNavColorScheme=dark&amp;footerSubnavColorScheme=dark`
- The `headless-footer` and `headless-header` placeholders are **shared across all pages** via the layout template — the rendering must be added to each page's `__Final Renderings` individually. There is no site-wide global partial configuration available via scripting.

### Datasource must be explicit `{braced-GUID}` — `DatasourceLocation` query is UI-only

The `DatasourceLocation` query on a rendering definition (e.g., `query:$site/*[@@name='Data']/*[@@templatename='VXA Global Footer Root']`) is **Experience Editor UI only**. It tells the editor where to look for datasource candidates. It does NOT resolve at render time when layout XML is written directly via scripting.

When patching `__Final Renderings` via PowerShell, always set `s:ds` to the **explicit `{braced-GUID}`** of the datasource item:

```xml
<r uid="{...}" s:ds="{162D81B0-9223-4419-9ACD-48C6FF43CB38}" s:id="{68B9AC48-0D6B-4F9C-8C3C-1C5566ADC671}"
   s:par="footerNavColorScheme=dark&amp;footerSubnavColorScheme=dark"
   s:ph="headless-footer" />
```

**Datasource location:** Global nav datasources live at `{site}/Data/` (the site-root Data folder), NOT under per-page `Data/` folders. Use `local:/Data/...` paths for per-page content; use absolute GUIDs for site-level shared datasources like the footer.

### `Add-RenderingToPageLayout` — append pattern for `__Final Renderings`

This pattern non-destructively adds a rendering to an existing page layout without overwriting its content renderings. Confirmed working on all 4 Velir POC pages (2026-04-04).

```powershell
function Add-RenderingToPageLayout {
    param(
        [string]$PagePath,       # e.g. "/sitecore/content/Velir/Velir/Home"
        [string]$RenderingXml    # single <r ... /> string to append
    )
    # 1. Read current __Final Renderings
    $q = '{ item(where:{database:"master",path:"' + $PagePath + '"}) { field(name:"__Final Renderings") { value } } }'
    $existing = (Invoke-Gql $q).data.item.field.value

    # 2. Append before the closing </d>
    $updated = $existing -replace '</d>', "$RenderingXml`n</d>"

    # 3. Write back
    Set-SitecoreFields -ItemId (Get-SitecoreItemId -Path $PagePath) -Fields @(
        [ordered]@{ name = "__Final Renderings"; value = $updated }
    )
}
```

Invoke once per page. The function is defined in `Build-GlobalFooter.ps1` and should be promoted to `Shared-SitecoreHelpers.ps1` for future reuse.

---

## `updateItem` / `Set-SitecoreFields` — All-or-Nothing Behavior

The `updateItem` GraphQL mutation processes the fields array as a single unit. If **any** field name in the array is invalid (e.g. uses the wrong machine name), the **entire mutation fails** — all fields, including valid ones, go unset.

The response emits a `WARNING: GQL: Cannot find a field with the name X` but does **not** throw a terminating error in PowerShell. The script continues silently while the item retains its placeholder/default values.

**Confirmed (2026-04-03):** A `Set-SitecoreFields` call on a VXA Hero item that included `primaryLink` (the Promo field name) in the same array as `title`, `description`, and `image` caused all four fields to go unset — the item rendered with default "Hero Title" text even though `title` was valid.

**Rules:**
- Before calling `Set-SitecoreFields`, verify every field machine name against `VXA_COMPONENT_SPECS.md` for that component.
- After a build script run, always take a screenshot to confirm fields rendered — don't trust "Updated: ItemName" in the output alone. The `~ Updated:` message only confirms the mutation was sent, not that all fields were written.
- A fast way to spot field name errors: check the terminal output for `WARNING: GQL:` lines after each `Set-SitecoreFields` call.

**VXA Hero field names (confirmed 2026-04-03):**
- `title` — Single-Line Text
- `description` — Single-Line Text (no HTML)
- `link` — General Link ← **NOT `primaryLink`** (that is Promo's field name)
- `image` — Image
- `imageMobile` — Image

---

## Agent Terminal Patterns

Patterns for running PowerShell commands reliably from the Copilot agent. These avoid the most common failure modes.

### Use `await_terminal` — never `Start-Sleep` for waiting

`Start-Sleep` in a foreground terminal will time out the tool call and get moved to background. To wait for async operations (e.g. Experience Edge propagation after publish), use `isBackground: true` + `await_terminal`:

```
# Wrong — times out the tool call:
Start-Sleep -Seconds 45; Write-Host "Ready"

# Right — fire the wait as background, then await it:
run_in_terminal(isBackground=true): Start-Sleep -Seconds 45; Write-Host "Ready"
await_terminal(id: <backgroundId>)
```

### Check result variables in a separate command

When a multi-line block assigns `$r` and then immediately checks `$r`, the terminal can buffer output causing the check to evaluate a stale `$r` from a prior command. Split into two tool calls:

```
# Call 1: run the mutation and assign $r
# Call 2: check $r.errors / $r.data separately
```

### Truncated terminal output is NOT a failure signal

The `run_in_terminal` tool can return a partial or empty output (e.g., just the PS prompt or the last character of the previous line like `io"`) while the command has already completed successfully. **Do not interpret truncated output as command failure.** This has led to double-running mutations which creates duplicate Sitecore items.

**Rule:** After any inline GQL mutation or variable assignment, confirm the result by reading the variable explicitly in a follow-up `run_in_terminal` call (`Write-Host "Result: $pageId"`). Never retry a mutation just because the prior output was short or empty — check the variable first.

### Terminal state persists across calls — intentionally exploit this

`$TOKEN`, `$hdrs`, `$uri`, and result variables like `$r` persist in the same terminal session. Exploit this:
- Set `$hdrs` once after token refresh; reuse in subsequent inline mutations.
- Store `$pageId` / `$dataId` from early steps; reference them later without re-querying.
- Do **not** re-declare `$hdrs` with a stale `$TOKEN` — always refresh the token before setting `$hdrs`.

### `dotnet sitecore publish item` fails silently when CLI session is expired

Error message: `Make sure the GraphQL service is installed and available` (exit code 1).  
This is a CLI auth problem, not a GraphQL problem. Switch to the `publishItem` mutation (see Sitecore CLI section above).

### Long-running `powershell.exe -File` invocations

When running a full build script via `powershell.exe -File`, set `timeout: 300000` (5 min) to prevent premature termination. Multi-step scripts creating many items can take 2-3 minutes on this instance.

### Write temp `.ps1` files for complex inline commands

If the terminal gets confused with multiline input (here-strings, multi-statement blocks) and prints `"The terminal is getting confused with multiline input"`, write the logic to a temp `.ps1` file and run it:

```
# Create the file:
create_file(filePath: "C:/Users/.../AppData/Local/Temp/my-script.ps1", content: ...)

# Run it:
run_in_terminal: powershell -File "C:\...\AppData\Local\Temp\my-script.ps1"
```

This is always more reliable than sending multi-line blocks inline.

---

## Playwright Layout Screenshots

Playwright is used during Phase 1 of POC page generation to take a full-page screenshot of the source URL, resolving visual layout ambiguities that `fetch_webpage` cannot.

### Environment (confirmed 2026-04-03)

| Item | Value |
|---|---|
| Node.js | v24.4.1 |
| Playwright | 1.59.1 at `C:\Users\danield\AppData\Local\Temp\node_modules\playwright` |
| Chromium | Downloaded to `C:\Users\danield\AppData\Local\ms-playwright\chromium-1217` |

### Standard screenshot script pattern

Write to a `.js` file in `$env:TEMP` and run with `node` (avoids PowerShell here-string quoting issues):

```powershell
cd "$env:TEMP"
@"
const { chromium } = require('./node_modules/playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1440, height: 900 });
  try {
    await page.goto('https://example.com/page', { waitUntil: 'domcontentloaded', timeout: 30000 });
  } catch(e) { console.log('goto warning:', e.message); }
  await new Promise(r => setTimeout(r, 3000));
  await page.screenshot({ path: 'page-full.png', fullPage: true });
  await browser.close();
  console.log('Done');
})().catch(e => { console.error(e); process.exit(1); });
"@ | Set-Content "screenshot.js"
node screenshot.js
Copy-Item "$env:TEMP\page-full.png" "scripts\page-full.png"
```

### Why `domcontentloaded` not `networkidle`

`networkidle` fails on velir.com with `net::ERR_ABORTED` — analytics/tracking scripts prevent the network from going idle. Use `domcontentloaded` + a 3-second fixed wait instead.

### What screenshots resolve

- **50/50 vs. stacked** — the single biggest source of Phase 1 errors; visible in pixels, invisible in text
- **Promo image side** — left (Default) vs. right (ImageRight variant)
- **Color scheme per section** — white/light/dark/vibrant confirmed visually
- **Card images loaded or not** — lazy-loaded images may appear blank in screenshot; cross-reference with HTML scrape to confirm they exist

---

## Performance Patterns

### Why this matters

A naive build script for a 29-item fresh page makes ~87 GQL calls:
- 29 existence checks (`Get-SitecoreItemId`)
- 29 creates (`createItem`)
- 29 field writes (`updateItem`)

The three patterns below reduce that to ~29 calls on a fresh page — a ~67% reduction — with no change to idempotent re-run correctness.

---

### Pattern 1: Fold Fields into `createItem` (`-Fields` on `Get-OrCreate-SitecoreItem`)

`createItem` accepts a `fields` array in its input. Pass `-Fields` to `Get-OrCreate-SitecoreItem` to write fields inline during creation, skipping the separate `Set-SitecoreFields` call.

**Old pattern (2 calls per new item):**
```powershell
$heroId = Get-OrCreate-SitecoreItem -Path "$dataPath/Hero 1" -Name "Hero 1" `
    -TemplateId $tVxaHero -ParentId $dataId
Set-SitecoreFields -ItemId $heroId -Fields @(
    [ordered]@{ name="title"; value="Our Work" }
)
```

**New pattern (1 call per new item):**
```powershell
$heroId = Get-OrCreate-SitecoreItem -Path "$dataPath/Hero 1" -Name "Hero 1" `
    -TemplateId $tVxaHero -ParentId $dataId `
    -Fields @(
        [ordered]@{ name="title"; value="Our Work" }
    )
```

**Behavior on re-runs (idempotent):** When the item already exists, `Get-OrCreate-SitecoreItem` detects it and calls `Set-SitecoreFields` internally — still 2 calls on re-run, correct.

**Rule:** Always use `-Fields` for datasource creation in new scripts. The standalone `Set-SitecoreFields` is only needed for special cases like writing `__Final Renderings` (layout XML).

---

### Pattern 2: Skip Existence Check on Known-Fresh Pages (`-ForceCreate`)

On a page that was just created empty (Phase 0 of POC generation), all Data items are guaranteed absent. Use `-ForceCreate` to skip the `Get-SitecoreItemId` round trip entirely.

```powershell
$heroId = Get-OrCreate-SitecoreItem -Path "$dataPath/Hero 1" -Name "Hero 1" `
    -TemplateId $tVxaHero -ParentId $dataId -ForceCreate `
    -Fields @(
        [ordered]@{ name="title"; value="Our Work" }
    )
```

**Safety:** If the item already exists, Sitecore returns an error on duplicate name. This is fail-fast — no data corruption. Only use on a script that creates its own page in Phase 0 and never re-uses item names across runs.

**Call savings:** On a 29-item fresh page, `-ForceCreate` saves 29 additional calls on top of Pattern 1.

| Scenario | Calls per item | Total (29 items) |
|---|---|---|
| Baseline (old pattern) | 3 (check + create + update) | 87 |
| Pattern 1 only (-Fields) | 2 (check + create-with-fields) | 58 |
| Pattern 1 + 2 (-Fields -ForceCreate) | 1 (create-with-fields) | 29 |
| Re-run (item exists, Pattern 1) | 2 (check + update) | 58 |

---

### Pattern 3: Batch Media Existence Check (`Get-MediaItemIds`)

Upload scripts that check N media items one by one make N sequential GQL calls. Replace them with a single batch call using `Get-MediaItemIds`, which uses GQL aliases to check all paths in one request.

`Get-MediaItemIds` is defined in `Shared-SitecoreHelpers.ps1`. Upload scripts must dot-source Shared to use it.

**Old pattern (N calls):**
```powershell
foreach ($img in $images) {
    $existing = Get-SitecoreItemId $img.mediaPath  # 1 call each
    if ($existing) { ...; continue }
    # upload...
}
```

**New pattern (1 call):**
```powershell
# Build path map -- run once before the loop
$checkPaths = [ordered]@{}
foreach ($img in $images) { $checkPaths[$img.name] = $img.mediaPath }
$existingMedia = Get-MediaItemIds -Items $checkPaths  # 1 call for all N paths

foreach ($img in $images) {
    $existing = $existingMedia[$img.name]  # hashtable lookup, no GQL call
    if ($existing) { ...; continue }
    # upload...
}
```

**Returns:** `[hashtable]{ name -> itemId | $null }` — `$null` means the item is absent.

**Savings:** N=20 images → 20 calls reduced to 1. On all-present (idempotent re-run): 20 → 1 call AND the loop exits early for every image.
