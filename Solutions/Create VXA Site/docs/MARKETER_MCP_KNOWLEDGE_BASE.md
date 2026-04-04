# Marketer MCP Knowledge Base

Last updated: 2026-04-02 (MCP CRUD validation pass — all operations confirmed)  
Environment: `standard` site / SitecoreAI (Velir Studios org)

---

## Setup

**Server URL:** `https://marketer.sitecorecloud.io/mcp/marketer-mcp-prod`  
**Auth:** OAuth browser-based (authorization code flow). No static token needed.  
**VS Code config:** Added to `%APPDATA%\Code\User\mcp.json` as HTTP server type.  
**Activation:** Requires full VS Code restart (not just window reload) to initialize new HTTP MCP servers.  
**Re-auth:** Token is stored per tenant. If it expires, VS Code prompts to re-authorize.

---

## Sites in Our Environment

| Site name | ID | Notes |
|-----------|-----|-------|
| `standard` | `1aec4b6e-4f86-43a3-925c-074118a9537f` | Our site — contains Home and Velir-POC |
| `qa` | `a6c35727-1a28-4f11-9bdb-0a51cf256e8d` | Shared QA site — many test pages from other team members |
| `clarity` | `7a1f3097-5e27-4126-a548-eb0a66ab81cd` | No pages |

**Home page ID:** `9dc3828e-91a7-4e5d-a4fd-e622ea089d54`  
**Home page path:** `/sitecore/content/dev-demos/standard/Home`

---

## What Works ✅

### Adding Content Components to Inner Container Placeholders
- `add_component_on_page` with `placeholderPath: /headless-main/container-fullbleed-9` (inner path) → **✅ PROVEN**
- Tool requires `componentRenderingId` (not `renderingId`) — check schema carefully
- Auto-creates a blank datasource item with the `componentItemName` as its path segment
- Returns: `{ componentId, pageId, placeholderId, datasourceId }` — use `datasourceId` for subsequent `update_content` calls
- If the placeholder already has a component, a second instance is added (no guard against duplicates)
- **Test details:** Added CTA Banner (`0dcb68f2`) to `/headless-main/container-fullbleed-9`, datasource `0fa9e7c3` auto-created at `local:/Data/MCP_Test_CTA_Banner`

### Site & Page Discovery
- `list_sites` — returns all sites with IDs, hostnames, root paths. Fast and reliable.
- `get_all_pages_by_site` — takes `siteName` (not siteId). Returns full page list with IDs and paths.
- `get_page` — returns page details including templateId, path, insertOptions.
- `get_all_languages` — lists available language codes.

### Component Inspection
- `get_components_on_page` — returns full component tree including placeholder paths, DynamicPlaceholderIds, datasource references, and rendering definition details. **Extremely useful for auditing.**
- `list_components` — takes `site_name`. Returns all available components grouped by category (Containers, Promos, Headers, Media, etc.) with rendering IDs and componentNames.
- `get_allowed_comps_by_placeholder` — takes `pageId` + `placeholderName`. For `headless-main`, only containers are allowed. Use `*` to get all components across all placeholders.

### Content Read/Write
- `get_content_item_by_path` — takes `itemPath` (URL-encoded). Returns itemId, all fields, template info. **Proven reliable.** ✅
- `get_content_item_by_id` — takes `itemId`. **Proven reliable.** ✅
- `update_content` — takes `itemId`, `fields` (key-value map), `siteName`. **Proven live.** Returns full updated field map. ✅
- `update_fields_on_item` — same as `update_content` but does NOT require `siteName`. **Proven live — interchangeable with `update_content`.** ✅
- `create_content_item` — takes `templateId`, `name`, `parentId`, optional `fields`. **Proven live — creates item, fields written atomically.** ✅
- `delete_content` — takes `itemId`. Deletes across all language versions. **Proven live — returns `{success:true, deletedId}`.** ✅

### Page Screenshots & Preview
- `get_page_screenshot` — **✅ PROVEN**. Returns base64-encoded PNG in `screenshot_base64` field. Other response fields: `type`, `fullPage`, `encoding`, `timestamp`. Requires `version` (integer). Width/height configurable. ⚠️ **Always check which item version you are working in and pass that version number.** During the Velir POC build we created item version 2 and worked in that version — so screenshots required `version: 2`. If you're on version 1 (never created a new version), use `version: 1`. If you have created additional versions, use the correct current working version. Query item version via Authoring GraphQL before issuing screenshots if unsure.
- **Important:** Screenshots render from the **published** version of the page, not master. Changes written via Authoring GraphQL (`__Final Renderings` on master) will NOT appear in screenshots until the page is published. Plan verification flows around publish state, not authoring state.
- Decoded PNG is ~1.2MB for a full-page viewport screenshot at default width.
- `get_page_preview_url` — returns the preview URL for a page.
- `get_page_html` — returns raw HTML of the rendered page. Also reads from published state — same limitation as `get_page_screenshot`.

### Asset Management
- `search_assets` — search by query, type (image/video/document), language.
- `get_asset_information` — returns asset metadata including dimensions, URL.
- `update_asset` — update alt text, name, metadata fields.
- `upload_asset` — ❌ **DOES NOT WORK** — `fs.readFile is not implemented yet` error. The MCP runtime has no filesystem access. This tool is a non-functional stub. **Use PowerShell `uploadMedia` GraphQL + `curl.exe` instead** (see Scripting Conventions).

### Personalization
- `create_perso_version` — creates a personalization variant for a page.
- `get_perso_ver_by_page` — lists all personalization variants on a page.
- `get_perso_cond_tmpls` / `get_perso_cond_tmpl_by_id` — retrieve condition templates for targeting rules.

### Brand & Briefs
- `list_brandkits` / `get_brandkit_by_id` — access brand kit content (colors, typography, guidelines).
- `list_brief_types` / `generate_brief` / `save_brief` — generate AI marketing briefs using brand kit context.

---

## What Doesn't Work ❌

### Adding Containers (anywhere, any placeholder)
**Error:** `404 — No datasource template found for component`  
**Root cause:** The Agent API calls `get_component` on the rendering ID before adding any component. Containers have no datasource template registered — they are **completely invisible to the Agent API** (`get_component` also returns 404 for containers). This is a component-type limitation, not a placeholder restriction. Containers cannot be added via MCP regardless of target placeholder.  
**Evidence:** `get_component` on `Full Bleed Container` (id `e80c2a78-...`) → 404. Same call on `VXA Video` (id `3a96ecf8-...`) → full datasource metadata. Containers appear in `list_components` catalog output but are not operable.  
**No explicit Sitecore documentation** covers this — the limitation is inferred from API behavior and the OpenAPI schema treating `datasourceTemplateId` as required on all operable components.  
**Workaround:** Always use PowerShell + Authoring GraphQL `updateItem` mutation to write layout XML for containers. This is a permanent architectural limitation of the Agent API design.

### Adding Content Components Directly to `headless-main`
**Error:** `500 — Internal Server Error`  
**Root cause:** `headless-main` only accepts container components. Content components (Hero, Multi Promo, CTA Banner, etc.) must go inside an inner placeholder like `/headless-main/container-fullbleed-1`.  
**Note:** The 500 response is a bug in the API — it should return 422 Validation Error. The constraint itself is correct.

**Retrospective note:** An earlier attempt to add a content component to an inner placeholder (`/headless-main/container-fullbleed-9`) also returned 500. This was initially suspected to be an API limitation, but was later proven to be a **wrong parameter name** — `renderingId` was used instead of `componentRenderingId`. The same call with the correct parameter succeeded immediately. Always verify exact parameter names from the MCP tool schema before diagnosing a 500 as a real failure.

### `get_allowed_comps_by_placeholder` with Inner Placeholder Paths
**Error:** `404 — Not Found`  
**Root cause:** Inner container placeholders (e.g. `/headless-main/container-fullbleed-1`) are SXA dynamic placeholders with path-based IDs, not fixed UUIDs. The endpoint expects a UUID. Use `*` as the placeholder name to get all allowed components across all placeholders.

### `get_component` by component instance ID
**Error:** `404 — Component not found by id`  
**Root cause:** The `component_id` parameter expects the **rendering definition ID** (e.g. `3a96ecf8-20ce-4f57-a9a6-d2d25f952a1e`), not the component instance ID from `get_components_on_page` (e.g. `3f72c0db-d8b1-44e4-9b2d-c5f5c9c49957`). These are different GUIDs.

---

## Partially Tested / Untested ⚠️

### `remove_component_on_page`
**Error:** `404 — Not Found` in all tested variants.  
**Tested with:** rendering instance `id` (`c97f54be`), rendering item ID (`0dcb68f2`), datasource ID (`0fa9e7c3`) — all 404.  
**Also tested (2026-04-02):** fresh instance ID returned by `get_components_on_page` immediately after `add_component_on_page` (`dc3522fd-ad26-4e81-a756-8d8f009400ec`) — also 404. Confirms the issue is not a stale ID problem.  
**Strict schema:** Tool does NOT accept a `language` parameter — passing it returns `"must NOT have additional properties"`. Valid params are `componentId`, `pageId`, `placeholderId` only.  
**Status:** Consistently 404 regardless of which ID is used or how fresh the instance is. Root cause unclear. Use the PowerShell build script (which rewrites the full layout XML) as the cleanup/reset mechanism.

### `create_component_ds`
Creates a datasource for a component by rendering ID. Untested. Could be an alternative to `create_content_item` for component-specific datasources.

### `set_component_datasource`
Sets an existing datasource onto a component instance. **Proven live (2026-04-02).** ✅  
Takes `componentId` (instance ID from `get_components_on_page`), `datasourceId`, `pageId`.  
Returns `{success, message, componentId, datasourceId}`. Message also reminds you to use `update_content` with the `datasourceId` to populate fields.  
**Key pipeline use:** after `add_component_on_page` auto-creates a blank datasource, call `set_component_datasource` if you want to swap to a different (pre-populated) datasource.

### `add_language_to_page`
Adds a language version to a page. Untested — out of scope for current project.

---

## Headless Variants — How They Work ✅

Variants are named exports in a component's `.tsx` file (e.g. `export const ImageRight`, `export const Animated`). The Content SDK selects the correct export based on a `FieldNames` rendering parameter in the layout XML.

### Mechanism

1. **Variant definitions** live as Sitecore items under:  
   `/sitecore/content/dev-demos/standard/Presentation/Headless Variants/<ComponentName>/<VariantName>`
2. **Activating a variant** in layout XML = adding `FieldNames={GUID}` to `s:par`, where the GUID is the variant definition item ID (braced, URL-encoded):  
   `FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D`
3. **No `FieldNames`** = `Default` export is used.
4. **Component map registration:** `VxaPromo` is registered as a namespace (`import * as VxaPromo from '...'`), so all named exports (`Default`, `ImageRight`, `Animated`, `ImageRightAnimated`) are available automatically — no extra registration needed.
5. **Docs reference:** [Create a variant for a component](https://doc.sitecore.com/sai/en/developers/sitecoreai/create-a-variant-for-a-component.html)

### Live Variant GUID Reference (`standard` site, queried 2026-04-02)

Path: `/sitecore/content/dev-demos/standard/Presentation/Headless Variants/`

| Component | Variant | GUID | URL-encoded for s:par |
|---|---|---|---|
| LinkList | Default | `ed038b11-6ae4-4a39-854b-6c73db0b7585` | `%7BED038B11-6AE4-4A39-854B-6C73DB0B7585%7D` |
| Navigation | Default | `70bbbafe-b2c8-4fda-8cc6-050685b12092` | `%7B70BBBAFE-B2C8-4FDA-8CC6-050685B12092%7D` |
| PageContent | Default | `da5ef38a-2195-4df4-ac9d-3f9d528a6fde` | `%7BDA5EF38A-2195-4DF4-AC9D-3F9D528A6FDE%7D` |
| Promo (SXA) | Default | `076dde73-5712-41da-8619-058d6f464d50` | `%7B076DDE73-5712-41DA-8619-058D6F464D50%7D` |
| RichText | Default | `19d98bc2-a072-4944-bcf9-ef41f1ce5668` | `%7B19D98BC2-A072-4944-BCF9-EF41F1CE5668%7D` |
| Title | Default | `06c731ac-5b01-4c9f-a95a-0c9cc11559d3` | `%7B06C731AC-5B01-4C9F-A95A-0C9CC11559D3%7D` |
| VXA Event Header | Default | `97f82fbc-a13b-4558-871d-add8b01f0305` | `%7B97F82FBC-A13B-4558-871D-ADD8B01F0305%7D` |
| VXA Event Header | ImageBelow | `32113470-68f7-4edc-8b79-54ee9b47ef4f` | `%7B32113470-68F7-4EDC-8B79-54EE9B47EF4F%7D` |
| VXA Image | Default | `4d5a49f5-506a-4884-b267-2ac56b70fa8b` | `%7B4D5A49F5-506A-4884-B267-2AC56B70FA8B%7D` |
| VXA Image | Animated | `4618830a-9033-4dd9-89cc-5c6786c14a9c` | `%7B4618830A-9033-4DD9-89CC-5C6786C14A9C%7D` |
| VXA Multi Promo | Default | `2554a4bc-bac2-4e19-b76b-4490371d5807` | `%7B2554A4BC-BAC2-4E19-B76B-4490371D5807%7D` |
| VXA Multi Promo | Animated | `9cd60945-32fe-4d64-9896-08ee7c15db90` | `%7B9CD60945-32FE-4D64-9896-08EE7C15DB90%7D` |
| VXA Site Search | Default | `05235276-148c-41f5-8e47-a7e3c230cea4` | `%7B05235276-148C-41F5-8E47-A7E3C230CEA4%7D` |
| VXA Site Search | LoadMore | `56b3bee3-47e5-40e7-98ab-93774614673d` | `%7B56B3BEE3-47E5-40E7-98AB-93774614673D%7D` |
| VXA Struct. Content PH | Default | `743bafc3-3f46-4997-99e6-ab59c2933d3c` | `%7B743BAFC3-3F46-4997-99E6-AB59C2933D3C%7D` |
| VXA Struct. Content PH | Animated | `691fb007-2ea6-487c-864c-a0cc0f9351ab` | `%7B691FB007-2EA6-487C-864C-A0CC0F9351AB%7D` |
| VXA Struct. Content PH | ImageBelow | `3bda9ac9-ae4a-4b91-bdee-829c2fa203cf` | `%7B3BDA9AC9-AE4A-4B91-BDEE-829C2FA203CF%7D` |
| VXA Struct. Content PH | ImageBelowAnimated | `6fc03008-14ed-48e4-98d8-75bbf72bd4a6` | `%7B6FC03008-14ED-48E4-98D8-75BBF72BD4A6%7D` |
| VxaPageHeader | Default | `621cbc64-886c-47a0-ad5e-3fecd8ba300d` | `%7B621CBC64-886C-47A0-AD5E-3FECD8BA300D%7D` |
| VxaPageHeader | ImageBehind | `d72484d4-c1ad-47ad-a805-f30698b4476d` | `%7BD72484D4-C1AD-47AD-A805-F30698B4476D%7D` |
| VxaPromo | Default | `3e5ff577-b999-49c0-8366-b651d4bdfde8` | `%7B3E5FF577-B999-49C0-8366-B651D4BDFDE8%7D` |
| VxaPromo | Animated | `e83ccadf-81d4-4797-ba9f-97e3381a8822` | `%7BE83CCADF-81D4-4797-BA9F-97E3381A8822%7D` |
| VxaPromo | **ImageRight** | `65c44a3b-df9c-4f4a-bd13-12b572d4fc24` | `%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D` |
| VxaPromo | ImageRightAnimated | `2ab11065-5ebc-46c9-bc90-83218dd30bfb` | `%7B2AB11065-5EBC-46C9-BC90-83218DD30BFB%7D` |

> **Note:** `VxaHero`, `VxaVideo`, `CTABanner`, `VxaRichText` are not in the Headless Variants folder — they have no variant system and always use the `Default` export (or rendering params like `ambient`).

### Usage pattern in layout XML
```xml
s:par="colorScheme=default&amp;FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D&amp;GridParameters=...&amp;DynamicPlaceholderId=10"
```
See `$ppr` in `Build-VelirPocPage.ps1` for a live example.

---

## Architecture: Hybrid Pipeline Model

Based on testing, the recommended pipeline architecture is:

```
Phase 1 — Structural (PowerShell + Authoring GraphQL)         [PROVEN]
  └─ Create containers in headless-main (writes __Final Renderings XML)
  └─ Assign DynamicPlaceholderIds to containers
  └─ Tool: Build-VelirPocPage.ps1 (full layout reset / source of truth)

Phase 2 — Inspect (sitecore-layout-inspect skill)             [PROVEN ✅]
  └─ Token refresh + query __Final Renderings + render readable table
  └─ Confirms current DynamicPlaceholderId counter and placeholder names

Phase 3 — Components (Marketer MCP add_component_on_page)     [PROVEN ✅]
  └─ Add content components to inner placeholder paths
  └─ Auto-creates a blank datasource item
  └─ Returns { componentId, pageId, placeholderId, datasourceId }
  └─ NOTE: does NOT guard against duplicates — check layout state first

Phase 4 — Content (Marketer MCP update_content)               [PROVEN ✅]
  └─ Populate all datasource fields using returned datasourceId
  └─ Set links, images, text
  └─ Source policy: all values must come from a live URL fetch — no invented content

Phase 5 — Sync (Build-VelirPocPage.ps1)                       [REQUIRED]
  └─ After MCP-adding a section, update the build script to include it
  └─ Build script is the canonical layout definition — drives all resets

Phase 6 — Verify (Marketer MCP get_page_screenshot)           [PROVEN ✅]
  └─ Screenshots render from PUBLISHED state — changes on master won't appear until published
```

**Key implication:** Phase 1 (containers) is always PowerShell. Phases 2–4 are fully MCP-driven. `remove_component_on_page` is broken — use the build script to reset layout.

## Skills Reference

| Skill | Trigger phrases | What it does |
|---|---|---|
| `sitecore-token-refresh` | token expired, 401 error, need to refresh token, starting new session | Refreshes CM token via client credentials or browser login |
| `sitecore-layout-inspect` | inspect layout, what's on the page, audit layout, check placeholders, compare layout | Queries live `__Final Renderings` and renders a readable component table |
| `poc-add-section` | add section, add component, new section on home, add CTA/Multi Promo/Video/Hero | MCP-first workflow: add component + populate datasource + sync to build script |

---

## Key Observed Behaviors

- **`get_all_pages_by_site` returns duplicates** — Home appeared twice in the `standard` site list. Safe to dedupe on `id`.
- **`update_content` requires `siteName`** — omitting it returns a validation error even though it's listed as optional in the OpenAPI spec.
- **`list_components` requires `site_name`** — uses underscore, not camelCase. Inconsistent with other tools that use camelCase.
- **`get_components_on_page` does not require `siteName`** — works with just `pageId`.
- **Re-auth triggers silently** — if the session token expires, VS Code shows no visible error; the MCP call simply fails. Restarting VS Code re-triggers the OAuth flow.

---

## Parameter Naming Inconsistencies (Gotchas)

| Tool | Parameter | Name used |
|------|-----------|-----------|
| `list_components` | site name | `site_name` (snake_case) |
| `get_all_pages_by_site` | site name | `siteName` (camelCase) |
| `get_allowed_comps_by_ph` | placeholder | `placeholderName` (camelCase) |
| `update_content` | site name | `siteName` (camelCase) |
| `get_component` | component ID | `component_id` (snake_case) |
| `add_component_on_page` | rendering ID | `componentRenderingId` (camelCase) |
| `add_component_on_page` | placeholder | `placeholderPath` (camelCase) |
| `remove_component_on_page` | placeholder | `placeholderId` (camelCase) |

Always check the actual MCP tool schema before calling — parameter names are inconsistent across tools.

**`add` vs `remove` asymmetry:** `add_component_on_page` uses `placeholderPath`; `remove_component_on_page` uses `placeholderId`. Different names, same conceptual parameter.
