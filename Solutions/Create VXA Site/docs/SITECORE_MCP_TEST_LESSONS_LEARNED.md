# Sitecore MCP + Authoring GraphQL Test Report

Date: 2026-03-30  
Workspace: velir-xmcloud-accelerator

## Scope
This report summarizes what we tested while validating Sitecore MCP behavior and Authoring GraphQL operations against the XM Cloud/SitecoreAI instance.

## Executive Summary
- Authoring GraphQL endpoint access is working.
- **These tests were run against the community Sitecore MCP server (`@antonytm/mcp-sitecore-server`), not the Marketer MCP.** Findings below apply to that server only.
- Community MCP GraphQL tool calls to the `master` schema returned 404 due to endpoint shape mismatch.
- Community MCP presentation tool (`add-rendering-by-path`) failed with `TypeError: fetch failed` in this environment.
- Critical content and presentation operations were completed successfully through Authoring GraphQL mutations.
- **Later finding (2026-04-02):** The Marketer MCP (`mcp_sitecore-mark_*`) is proven for content component CRUD. The only known blocker is containers (no datasource template). See `MARKETER_MCP_KNOWLEDGE_BASE.md`.

## Lessons Learned
1. Endpoint shape matters more than expected for MCP schema routing.
   - `/sitecore/api/authoring/graphql/v1` worked.
   - `/sitecore/api/authoring/graphql/v1/master` returned 404.
2. The Authoring GraphQL schema in this environment differs from common examples.
   - `item(path: ...)` did not work.
   - `item(where: { path: ... })` worked.
   - `fields` are returned through `fields { nodes { name value } }`.
3. Community Sitecore MCP tool reliability can vary by capability.
   - GraphQL connectivity was available.
   - Presentation-specific function (`add-rendering-by-path`) failed. **This was the community MCP server, not the Marketer MCP.** The Marketer MCP `add_component_on_page` works for all components except containers (which have no datasource template and return 404).
4. Verification after each mutation is essential.
   - We validated both datasource field values and final layout XML after every update.
5. `mcp_sitecore-mark_upload_asset` does not work — ever. (2026-04-02)
   - The Marketer MCP runtime has no filesystem access. Calling `upload_asset` fails immediately with `fs.readFile is not implemented yet`.
   - This is a permanent limitation of the MCP runtime — not a configuration or auth problem.
   - The only working upload path is: `uploadMedia` GraphQL mutation → presigned URL → `curl.exe --request POST ... --form "=@file"`.
   - Do not attempt MCP-based file upload; go straight to the GraphQL + curl pattern.
6. Rich Text centering requires inline `style` attribute — no rendering parameter exists. (2026-04-02)
   - To center a Rich Text section header, the `text` field value itself must include `style='text-align:center'` on the `<h2>` and `<p>` tags.
   - There is no `textAlign` or similar rendering parameter on the VXA Rich Text component.
7. Multi Promo items have no "hide description" toggle — use empty string. (2026-04-02)
   - To suppress description text on Multi Promo Item cards, set `description` to `""`.
   - There is no rendering parameter to hide the field — the field value controls visibility.
8. `dotnet sitecore cloud login` must be triggered by the agent, not delegated to the user. (2026-04-02)
   - When browser auth is needed (no `clientSecret` in `user.json`), the agent must run `dotnet sitecore cloud login` directly — not ask the user to run it.
   - The command opens a browser window; the user just completes the login steps there.

## What Was Successful
- Confirmed GraphQL authentication and endpoint reachability.
- Retrieved `/sitecore/content` field values.
- Retrieved presentation details for `/sitecore/content/test/qa/Home`.
- Updated datasource text field to `MCP Test`.
- Ensured Rich Text rendering instance exists in final layout.
- Moved rendering placeholder from `jss-main` to `headless-main` and verified.

## What Was Not Successful
- `mcp_sitecore_query-graphql-master` calls returned `Not Found` (404) for both content and `currentUser` queries when schema-suffixed route was used.
- `mcp_sitecore_presentation-add-rendering-by-path` returned `TypeError: fetch failed`.
- Some terminal/script attempts were canceled/interrupted and had to be rerun in smaller or background steps.

## Test Matrix and Outcomes

| Test ID | Test | Method | Outcome | Notes |
|---|---|---|---|---|
| T01 | Query `currentUser` via MCP GraphQL tool | `mcp_sitecore_query-graphql-master` | Failed | 404 `Not Found` |
| T02 | Query `/sitecore/content` via MCP GraphQL tool | `mcp_sitecore_query-graphql-master` | Failed | 404 `Not Found` |
| T03 | Validate configured MCP endpoint | `mcp_sitecore_config` | Passed | Endpoint confirmed as Authoring GraphQL v1 |
| T04 | Probe endpoint variants | Direct HTTP POST | Mixed | `/v1` = 200, `/v1/master` = 404 |
| T05 | Query `/sitecore/content` using wrong GraphQL shape | Authoring GraphQL | Failed | Schema errors (`path` arg/field mismatch) |
| T06 | Query `/sitecore/content` using working shape | Authoring GraphQL (`item(where:{path})`) | Passed | Retrieved item + field values |
| T07 | Read presentation details for `/sitecore/content/test/qa/Home` | Authoring GraphQL | Passed | Retrieved `__Renderings` + `__Final Renderings` |
| T08 | Add rendering with MCP presentation tool | `mcp_sitecore_presentation-add-rendering-by-path` | Failed | `TypeError: fetch failed` |
| T09 | Update datasource text value | Authoring GraphQL mutation `updateItem` | Passed | `text` set to `<p>MCP Test</p>` |
| T10 | Ensure rendering exists in final layout | Authoring GraphQL mutation `updateItem` + verify | Passed | Rendering linked to `local:/Data/Test Rich Text` |
| T11 | Move rendering to `headless-main` | Authoring GraphQL + XML update in `__Final Renderings` | Passed | `VERIFY::HEADLESS=True;JSS=False` |

## Key Data Points Verified
- Rendering item: `/sitecore/layout/Renderings/Feature/Velir Experience Accelerator/VXA Body Content/VXA Rich Text`
- Rendering ID: `{7246EF71-352F-4C0E-BE90-FB643FCCA413}`
- Page: `/sitecore/content/test/QA/Home`
- Datasource: `/sitecore/content/test/QA/Home/Data/Test Rich Text`
- Datasource field `text`: `<p>MCP Test</p>`
- Final placeholder state: `headless-main` (not `jss-main`) for datasource `local:/Data/Test Rich Text`

## API Token Retrieval (Enabling and Authorizing)
1. Run `dotnet sitecore cloud login` and follow the prompts.
2. Once logged in, the token is at `.sitecore/user.json` under `endpoints.xmCloud.accessToken`.
   - PowerShell: `(Get-Content '.\.sitecore\user.json' | ConvertFrom-Json).endpoints.xmCloud.accessToken`

Use this token for Authoring GraphQL authorization when running direct API tests.

### MCP Configuration Notes
1. In `.vscode/mcp.json`, place the raw token value directly in `GRAPHQL_API_KEY`.
2. Do not include the word `Bearer` in `GRAPHQL_API_KEY`.
   - The MCP server adds the `Authorization` header format internally.
3. `ITEM_SERVICE_*` settings were required for MCP server startup in this environment, even though Item Service was not used for SitecoreAI communication.
4. Working dummy values used during testing:
   - `ITEM_SERVICE_SERVER_URL`: SitecoreAI CM URL
   - `ITEM_SERVICE_USERNAME`: `admin`
   - `ITEM_SERVICE_PASSWORD`: `b`

## Recommended Follow-Ups
1. Adjust or patch MCP GraphQL tool URL composition to avoid appending schema as a path segment when endpoint expects unsuffixed `/v1`.
2. Investigate `mcp_sitecore_presentation-add-rendering-by-path` transport/runtime issue (`fetch failed`) for this environment.
3. Keep a reusable Authoring GraphQL smoke test script for:
   - `currentUser`
   - read item fields
   - update datasource field
   - verify final layout placeholder bindings

---

## Session 2 Debugging: Velir-POC `[object Object]` Error (2026-03-31)

### Problem
Created a `Velir-POC` page item under `/sitecore/content/dev-demos/standard/Home/Velir-POC` with a full layout (Hero, Multi Promo, CTA Banner). The page showed `[object Object]` with a loading spinner in Sitecore Pages. Browser devtools showed:
- **500 Internal Server Error** from the Next.js editing render endpoint (`/api/editing/render?s=...%2FVelir-POC`)
- **404 Not Found** on XM Cloud authoring API (`/api/v1/pages/{itemId}/live`)
- Apollo Client `__typename`/`InMemoryCache` warnings

### Root Cause
**Original diagnosis (2026-03-31, now known to be incorrect):** The Next.js editing host could not resolve the `/Velir-POC` route.

**Corrected diagnosis (2026-04-02):** The real root cause was one or both of:
1. The `Velir-POC` page had an **empty or broken `__Final Renderings`** field — an empty layout causes the editing render host to crash with a 500
2. The page was **never published to Experience Edge** — the XM Cloud Pages API `/api/v1/pages/{itemId}/live` returns 404 for unpublished items, which breaks the editor

This was confirmed by successfully calling `get_page_screenshot` on the Velir-POC child page today (2026-04-02) — it returned a valid PNG without error. MCP screenshots render from published Experience Edge, not the editing host.

### Resolution (original)
Applied the layout directly to the `Home` item. This was a valid workaround but not the only option.

### What actually matters
- Child pages work for MCP screenshot rendering as long as they have a valid layout on `__Final Renderings` AND are published to Edge
- The Sitecore Pages in-browser editor may still have separate issues for child pages depending on environment setup — investigate if needed

### Key Lessons Learned

#### 1. `__Final Renderings` is a SHARED field — not versioned
Sitecore's `__Final Renderings` (layout XML) is a **shared field** on standard templates. Writing to it affects ALL versions of the item. You cannot use item versioning to isolate different layouts on the same item. The "velir v2" version in Pages saw the same layout as V1.

**Implication:** To test layout changes safely, use a separate page item — not versions.

#### 2. Child pages work — but they need a valid layout AND must be published
**Corrected 2026-04-02.** Original lesson was wrong — the problem was not routing, it was an empty/broken layout and/or an unpublished page.

- `get_page_screenshot` via MCP renders from **published Experience Edge**. Child pages render correctly here as long as they have content and are published.
- The Sitecore Pages in-browser editor uses `/api/editing/render`. An empty `__Final Renderings` or an unpublished page will cause 500 / `[object Object]` in the editor.
- The VXA Next.js app uses a catch-all route `[[...path]].tsx` that handles any Sitecore-registered path — routing is not the constraint.

**Rule:** Always ensure a child page has a complete layout and is published before screenshotting.

#### 3. Datasource paths: `local:` is relative to the page item
`local:/Data/VXA Hero 1` resolves relative to **the page item** that owns the layout, not relative to some global data folder. When moving layout XML from one page to another, either:
- Create matching datasource items under the new page's `Data` folder, OR
- Use absolute GUID references (N-format) instead of `local:` paths

**We chose `local:` paths** with new datasource items under `Home/Data/` — this is cleaner and more maintainable.

#### 4. Authoring API field syntax: `fields { nodes { name value } }`
The Authoring GraphQL API returns fields as a **connection type**. The correct query is:
```graphql
fields { nodes { name value } }
```
NOT:
```graphql
fields { name value }  # WRONG — "name does not exist on ItemFieldConnection"
```

#### 5. Authoring API `itemId` expects type `ID!`, not `String!`
When using `itemId` in a `where:` filter, the GraphQL variable must be typed as `ID!`:
```graphql
query($id: ID!) { item(where: { itemId: $id }) { ... } }
```
Using `String!` causes a runtime type mismatch error even though it passes validation.

#### 6. Authoring API version parameter for mutations
To write to a specific item version, include `version:` in the `updateItem` mutation input. Without it, the API writes to the **latest version**. To create a new version first, use `addItemVersion`.

#### 7. Sitecore Pages version dropdown may not match API versions
The "velir v2" label shown in the Pages UI was created through the Pages editor, but the Authoring API's `addItemVersion` is needed to create versions programmatically. Always verify version existence via the API before targeting a specific version in mutations.

#### 8. Items with spaces in names work via path queries
The Authoring API correctly resolves item names containing spaces when queried by path (e.g., `/sitecore/content/.../VXA Hero 1`). Earlier failures with space-containing paths were due to incorrect `ConvertTo-Json` serialization in PowerShell scripts, not an API limitation.

#### 9. Incremental rendering is the debugging strategy
When `[object Object]` appears, don't try to debug a complex multi-rendering layout all at once. Instead:
1. Strip to a single known-good rendering (e.g., just Hero)
2. Verify it renders
3. Add one rendering pair at a time (Container + Component)
4. Identify which specific rendering breaks the page

This approach quickly isolated the problem in this session.

#### 10. Link fields with `linktype="internal"` MUST reference a GUID — never a URL path
Sitecore `link` fields crash the Next.js rendering host if `linktype="internal"` is used **without a valid item GUID** in the `id` attribute. This was the root cause of persistent `[object Object]` errors even after restoring the original layout — the field data on the shared datasource was corrupted.

**Broken (causes 500 on editing host):**
```xml
<link text="Let's Talk" linktype="internal" url="/contact" />
```

**Safe alternatives:**
```xml
<!-- External link — no GUID needed -->
<link text="Let's Talk" linktype="external" url="https://example.com/contact" />

<!-- Internal link — must have id attribute with braced GUID -->
<link text="Let's Talk" linktype="internal" id="{GUID-HERE}" />

<!-- Empty — leave blank until a valid target exists -->
<link />
```

**Key insight:** Writing invalid link field values corrupts **shared datasource items** that are referenced by ALL versions and potentially by multiple pages. A single bad field value can break a previously working page because the datasource items are shared, not per-version. Always validate link field XML before writing.

#### 11. DynamicPlaceholderIds use a GLOBAL counter across all renderings
When a page has multiple Container (FullBleed) renderings, each rendering on the page consumes a sequential `DynamicPlaceholderId`, starting from 1. The counter increments for **every** rendering, not just containers.

Example with 3 FullBleed + 3 child components:
```
Container 1 (DynamicPlaceholderId=1) → creates placeholder "container-fullbleed-1"
Hero        (DynamicPlaceholderId=2) → sits in "container-fullbleed-1"
Container 2 (DynamicPlaceholderId=3) → creates placeholder "container-fullbleed-3"
Multi Promo (DynamicPlaceholderId=4) → sits in "container-fullbleed-3"
Container 3 (DynamicPlaceholderId=5) → creates placeholder "container-fullbleed-5"
CTA Banner  (DynamicPlaceholderId=6) → sits in "container-fullbleed-5"
```

Using wrong IDs (e.g., `container-fullbleed-2` instead of `container-fullbleed-3`) causes the child component to render in an empty/wrong placeholder — the section appears blank with just the dotted-outline container visible.

#### 12. VXA Hero `description` is Single-Line Text, not Rich Text
Do not wrap values in `<p>` tags. They render literally as visible text. Use plain text only for `description` fields of type Single-Line Text. Check the template inventory for field types before writing values.

#### 13. Media upload via Authoring GraphQL + `curl.exe` — three-step process
The Authoring GraphQL `uploadMedia` mutation returns a pre-signed upload URL. The actual file upload must be done as a multipart `POST` — use `curl.exe` (not PowerShell's `Invoke-RestMethod`, which fails to encode multipart correctly in PS 5.1).

Full flow:
```powershell
# Step 1 — get pre-signed upload URL
$mut = '{ "query": "mutation { uploadMedia(input: { itemPath: \"/sitecore/media library/your-folder/image-name\" }) { presignedUploadUrl mediaItemId } }" }'
$resp = Invoke-RestMethod -Uri $cmUrl/sitecore/api/authoring/graphql/v1 -Method Post -Headers @{ Authorization="Bearer $token"; "Content-Type"="application/json" } -Body $mut
$uploadUrl = $resp.data.uploadMedia.presignedUploadUrl
$mediaId   = $resp.data.uploadMedia.mediaItemId

# Step 2 — upload file with curl.exe (not Invoke-RestMethod)
curl.exe -s -X POST $uploadUrl -F "file=@C:\path\to\image.jpg"

# Step 3 — set image field on datasource item
$xml = "<image mediaid=`"{$mediaId}`" />"
# ... then use updateItem mutation to set the field value
```

**Important:** The `mediaItemId` returned in Step 1 is the GUID to use in the `<image mediaid="{GUID}" />` field value.

If the upload URL from Step 1 returns an error saying the item already exists, the media item was already created — reuse the `mediaItemId` and skip the upload.

#### 14. Image fields use `<image mediaid="{GUID}" />` format
Sitecore image fields expect XML in the format `<image mediaid="{GUID-IN-BRACES}" />`. The GUID must be in the `{...}` braced format. Passing a plain URL or a bare GUID will not work — the rendering host will fail to resolve the media item.
