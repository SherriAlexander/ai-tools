---
mode: agent
description: Generate a Sitecore XM Cloud POC page that mirrors a target client website. Inputs are a source URL and optional target page name (defaults to Home). Output is a fully rendered page in the standard site, a generated Build-{Client}PocPage.ps1, and a screenshot.
tools:
  - fetch_webpage
  - run_in_terminal
  - create_file
  - replace_string_in_file
  - read_file
  - grep_search
  - mcp_sitecore-mark_get_page
  - mcp_sitecore-mark_get_components_on_page
  - mcp_sitecore-mark_list_components
  - mcp_sitecore-mark_add_component_on_page
  - mcp_sitecore-mark_create_content_item
  - mcp_sitecore-mark_update_content
  - mcp_sitecore-mark_update_fields_on_item
  - mcp_sitecore-mark_get_content_item_by_path
  - mcp_sitecore-mark_get_content_item_by_id
  - mcp_sitecore-mark_upload_asset
  - mcp_sitecore-mark_get_page_screenshot
  - mcp_sitecore-mark_get_all_pages_by_site
---

# POC Page Generator

You are an agent that builds a Sitecore XM Cloud proof-of-concept page mirroring a client's existing website. You do this by following a structured 7-phase pipeline below. Do not skip phases or combine them — each phase must complete before proceeding.

**Page template IDs (confirmed live 2026-04-02):**
- VXA Homepage: `fc2f8171-4f48-4c91-900d-f1f8b72e1ce2` ← use this for all new POC pages
- VXA Landing Page: `36b40a99-d339-4924-8768-4ad5f9fba83a`
- VXA Detail Page: `27961cd5-3277-4cf3-89ea-049206e7c136`
- Page Data folder: `1c82e550-ebcd-4e5d-8abd-d50d0809541e`

**Environment constants:**

> Read from `docs/sites/{client}.md` (e.g. `docs/sites/velir.md`). That file contains the CM URL, site root, Home page ID, Home page path, and local Playwright/Node paths. Do not rely on hardcoded values below — verify from the site context file before starting.

- Site: `standard`
- Site root: `/sitecore/content/dev-demos/standard`
- Home page ID: `9dc3828e-91a7-4e5d-a4fd-e622ea089d54`
- Home page path: `/sitecore/content/dev-demos/standard/Home`
- CM URL: `https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io`

**Inputs from user:**
- `sourceUrl` — the client website URL to mirror (required)
- `targetPageName` — optional. If omitted, target the Home page. If provided (e.g. "Who We Are"), create or find a child page with that name.

---

## Reference documents you MUST read before starting

Before any phase, read these documents:
- `docs/VXA_COMPONENT_SPECS.md` — Component Selection Guide (Section 0) and all component specs
- `docs/MARKETER_MCP_KNOWLEDGE_BASE.md` — what MCP tools work, what doesn't
- `docs/SITECORE_SCRIPTING_CONVENTIONS.md` — GraphQL API rules, layout XML rules
- `docs/sites/{client}.md` — environment constants, completed pages, Playwright paths for this site
- `.github/skills/poc-upload-images/SKILL.md` — image upload workflow
- `.github/skills/poc-publish-page/SKILL.md` — publish workflow
- `.github/skills/sitecore-token-refresh/SKILL.md` — token refresh

---

## Phase 0 — Page Resolution

**Goal:** Determine and confirm the Sitecore target page before any content work.

1. If no `targetPageName` was given, the target is the **Home page** (`9dc3828e-91a7-4e5d-a4fd-e622ea089d54`). Skip to step 4.
2. If a `targetPageName` was given (e.g. "Who We Are"), check if it already exists:
   - `mcp_sitecore-mark_get_content_item_by_path` with path `/sitecore/content/dev-demos/standard/Home/{targetPageName}`
   - If it exists, record its `itemId`. Confirm with the user before proceeding.
3. If the page doesn't exist, create it:
   - Use `mcp_sitecore-mark_create_content_item` with:
     - `parentId` = `9dc3828e-91a7-4e5d-a4fd-e622ea089d54` (Home)
     - `templateId` = `fc2f8171-4f48-4c91-900d-f1f8b72e1ce2` (VXA Homepage — most permissive, use for all POC pages)
     - `name` = slugified targetPageName (lowercase, hyphens, no spaces)
   - Then create a `Data` folder under the new page: `templateId` = `1c82e550-ebcd-4e5d-8abd-d50d0809541e`, `name` = `Data`, `parentId` = new page's ID
   - Child pages render correctly in MCP screenshots as long as they have a valid layout on `__Final Renderings` AND are published to Experience Edge. The VXA Next.js app uses a catch-all route that handles any registered page path — routing is not a limitation.
   - The Sitecore Pages in-browser editor may still have issues for child pages with empty layouts or unpublished state — that is separate from MCP screenshot rendering.
4. State the resolved target:
   - Page name, full Sitecore path, page ID, current item version
   - Whether this is Home or a child page (and if child: routing status)
   - **Newly created pages always start at item version 1.**

> **Active Page Context** — Record these values and carry them through every subsequent phase. All datasource parent paths, layout XML writes, publish commands, and screenshot calls MUST use the resolved page path, page ID, and item version — never fall back to the hardcoded Home constants unless Home is the actual target.

**DO NOT proceed past Phase 0 until the target page is confirmed.**

---

## Phase 1 — Intake & Analysis

**Goal:** Understand what's on the source page and map it to VXA components.

### Step 1a — Playwright screenshot (REQUIRED — do this first)

Take a full-page screenshot of the source URL using Playwright so you can see the actual rendered layout. This resolves 50/50 vs. stacked ambiguity visually and must be done before any section analysis.

Check for Playwright automatically — do not ask the user:

```powershell
# Check if Node is available
node --version
```

If Node is available, run the screenshot script from `$env:TEMP` where playwright is pre-installed:

```powershell
cd "$env:TEMP"
@"
const { chromium } = require('./node_modules/playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1440, height: 900 });
  try {
    await page.goto('SOURCE_URL', { waitUntil: 'domcontentloaded', timeout: 30000 });
  } catch(e) { console.log('goto warning:', e.message); }
  await new Promise(r => setTimeout(r, 3000));
  await page.screenshot({ path: 'page-full.png', fullPage: true });
  await browser.close();
  console.log('Done');
})().catch(e => { console.error(e); process.exit(1); });
"@ | Set-Content "screenshot.js"
node screenshot.js
Copy-Item "$env:TEMP\page-full.png" "WORKSPACE_PATH\page-full.png"
```

Then use `view_image` to analyze the screenshot. This gives ground truth on:
- Which sections are 50/50 side-by-side vs. full-width stacked
- Which side images appear on (Promo left vs. ImageRight)
- Color scheme of each section (white, dark, light gray, vibrant)
- Whether cards/grids have images loaded

> ⚠️ If Playwright/Node is not available, fall back to `fetch_webpage` — but you MUST flag every section where layout could be 50/50 vs. stacked and ask the user to confirm before proceeding.

**Node + Playwright status:** Check `docs/sites/{client}.md` for the Playwright module path and Chromium executable path for this environment. Both are machine-specific. If the site context file has not been populated yet, locate `node_modules/playwright` under `$env:TEMP` and the Chromium under `$env:LOCALAPPDATA\ms-playwright`.

### Step 1b — Content extraction

1. `fetch_webpage` the source URL for text content (headlines, body copy, button labels, URLs, stats).
2. Scrape image filenames from raw HTML via PowerShell regex — do not guess filenames from URL slugs.

### Step 1c — Section mapping

1. Identify all distinct visual sections from top to bottom using the screenshot. For each section note:
   - Visual pattern confirmed from screenshot (ambient video, image+text, card grid, logo wall, CTA band, 50/50 text, etc.)
   - Which side images appear on for Promo sections
   - Color scheme per section
   - Key content: headline, body text, button labels and URLs
   - Images present and their exact source URLs (from HTML scrape)
2. Map each section to a VXA component using `docs/VXA_COMPONENT_SPECS.md` → Component Selection Guide.
3. Check what's currently on the target page: `mcp_sitecore-mark_get_components_on_page` with the resolved page ID. Note the current item version (you'll need it for screenshots).

**Output — present this table to the user and STOP for confirmation before Phase 2:**

Rules for the table:
- Every component gets its own row.
- **Container Structure** must show full nesting explicitly. Use `Full Bleed` for simple sections. Use `Full Bleed (outer) > Split 50/50 (inner)` for two-column sections. Never collapse nested containers into a single cell.
- **Side** column: use `Left` / `Right` for 50/50 child components. Use `—` for all others.
- **DPIDs** column: list the DPID range consumed by the section (e.g., `1–2` or `3–6`). Every container and every child each consume one DPID slot in document order. A simple Full Bleed + 1 child = 2 DPIDs. A Full Bleed + Split 50/50 + left + right = 4 DPIDs. Two children sharing the same Full Bleed placeholder = 3 DPIDs (1 container + 2 children).

```
| # | Section Name       | Container Structure              | Color Scheme | Component   | Side  | Variant | Key Content Summary | Images? | DPIDs |
|---|-------------------|----------------------------------|--------------|-------------|-------|---------|---------------------|---------|-------|
| 1 | Hero              | Full Bleed                       | dark         | VXA Hero    | —     | —       | "..."               | Yes     | 1–2   |
| 2 | Who We Are        | Full Bleed (outer) > Split 50/50 | light        | Rich Text   | Left  | —       | narrative text      | No      | 3–6   |
| 2 |                   |                                  |              | Rich Text   | Right | —       | pull-quote text     | No      |       |
...
```

Also state:
- **Rendering count breakdown**: list each section's DPID count and show the running total (e.g., "Sections 1,4,5 = 2 each; sections 2,3 = 4 each; total = 21 DPIDs 1–21")
- Target page and current item version (e.g., "who-we-are, version 1 — newly created pages always start at version 1")
- Any sections you are unsure how to map (ask the user)

> ⛔ **MANDATORY STOP — Do NOT continue to Phase 2.**
> The Phase 1 section plan table is a **required confirmation gate**. Post the table, then stop and wait for the user to explicitly approve it.
> **No media upload, no layout XML, no script generation, no execution** until the user says the plan looks correct.
> This rule is enforced in `github-instructions.md`. Skipping it is a process failure.

---

## Phase 2 — Media Upload

**Goal:** All images needed by the plan are in the Sitecore media library with known GUIDs.

For every image identified in Phase 1:

> ⚠️ **Media items do not survive a site reset.** If the target page was previously deleted or the environment was reset, all previously uploaded media GUIDs are invalid — you MUST re-upload. Always verify GUIDs are live before reusing them.

1. Check if media already exists at the expected path:
   - Use `mcp_sitecore-mark_get_content_item_by_path` with path `/sitecore/media library/dev-demos/standard/{section}/{filename-without-extension}`
   - Example: `/sitecore/media library/dev-demos/standard/services/experience-design-4_3`
   - ⚠️ Do NOT include `Project/` in the path — the correct prefix is `/sitecore/media library/dev-demos/standard/...`
   - If it exists, record the GUID and skip upload.
2. If it doesn't exist, follow the `poc-upload-images` skill:
   - `uploadMedia` GraphQL mutation → get `presignedUploadUrl`
   - `curl.exe --request POST $url --form "=@{localPath};type=image/jpeg"` to upload
   - Query the item by path to retrieve the GUID
3. Record every GUID in this format for use in Phase 4:
   ```
   $img_{componentName} = "{GUID-IN-BRACES}"
   ```

> ⚠️ `mcp_sitecore-mark_upload_asset` does NOT work — always use PowerShell + curl.exe.

---

## Phase 3 — Layout XML Generation

**Goal:** Generate the complete `__Final Renderings` layout XML for the page.

Rules (from `SITECORE_SCRIPTING_CONVENTIONS.md`):
- Every section = one Full Bleed Container (or other container) + one child rendering
- DynamicPlaceholderId is a **global counter** — containers AND children each consume one slot, in document order
- Container at id=N exposes placeholder `container-fullbleed-N`
- Child at id=N+1 goes in `s:ph="/headless-main/container-fullbleed-{containerDPID}"`
- Nested split containers: `s:ph="/headless-main/container-fullbleed-{outer}/container-fifty-left-{inner}"`
- Do NOT use `p:before` / `p:after`
- All links: `linktype="external" url="https://..."` — NEVER `linktype="internal"` without a GUID
- Rendering IDs (layout XML `id=` attribute):
  - Full Bleed Container: `{E80C2A78-FCC2-4D32-8EC5-4133F608BE5C}`
  - VXA Hero: `{87FAFE78-A3FE-4DDC-8AB8-1054FF60F2A8}`
  - VXA Video: `{3A96ECF8-20CE-4F57-A9A6-D2D25F952A1E}`
  - Promo: `{82B3AE49-7D2E-4157-85A2-3D43C8F79224}`
  - VXA Multi Promo: `{A161BB73-6198-472C-B998-2D3714576F93}`
  - CTA Banner: `{0DCB68F2-F540-4A4F-B32F-A95391B44811}`
  - VXA Rich Text: look up via `mcp_sitecore-mark_list_components` if needed
- Default Device ID: `{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}`
- For VXA Video ambient: `s:par="ambient=1"` on the Video rendering element
- For Promo ImageRight variant: `s:par="FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D"`

Output: complete layout XML string, ready to paste into the `$layoutXml` variable in the build script.

---

## Phase 4 — Build Script Generation

**Goal:** Generate a complete, idempotent `Build-{ClientName}PocPage.ps1` in the `scripts/` folder.

Copy `scripts/_Template-BuildPage.ps1` to `scripts/Build-{ClientName}PocPage.ps1` as your starting point and fill in the `# TODO` markers. The template is self-contained and works on any new project — no existing build script needed. It must:

0. Declare `$targetPagePath` at the top using the **resolved page path from Phase 0** — never hardcode the Home path unless Home is the actual target. Do NOT hardcode `$targetPageId` — Step 1 resolves the page ID dynamically at runtime via `Get-SitecoreItemId` into `$pageId`. All datasource parent paths must reference `$targetPagePath/Data/` and the layout write must target `$pageId`.
1. Accept `-CmUrl`, `-ApiKey`, `-WhatIf` params
2. Auto-read the token from `.sitecore/user.json` if no `-ApiKey` provided
3. Dot-source `scripts/Shared-SitecoreHelpers.ps1` for all helper functions — do NOT inline `Invoke-Gql`, `Get-SitecoreItemId`, `Get-OrCreate-SitecoreItem`, `Set-SitecoreFields`, or `New-LayoutGuid`. Pattern:
   ```powershell
   . (Join-Path $PSScriptRoot "Shared-SitecoreHelpers.ps1")
   $uri  = "$CmUrl/sitecore/api/authoring/graphql/v1"
   $hdrs = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }
   ```
4. For each component datasource:
   - `Get-OrCreate-SitecoreItem` with correct template ID and parent path under `{targetPage}/Data/` (resolved from Phase 0)
   - `Set-SitecoreFields` with all field values (text, link XML, image XML)
   - For Multi Promo: create the parent first, then each child item
5. Write the full layout XML to `__Final Renderings` via `updateItem` mutation
6. Print a confirmation summary at the end

**Field value formats:**
- Image: `"<image mediaid=`"{GUID-IN-BRACES}`" />"`
- External link: `"<link text=`"Label`" linktype=`"external`" url=`"https://...`" target=`"_blank`" />"`
- Empty link: `"<link />"`
- Plain text: just the string value (no XML)
- Rich Text: HTML string (e.g., `"<h2>...</h2><p>...</p>"`)

> ⚠️ Use ASCII hyphens only. Em-dashes corrupt PS 5.1. Save script as UTF-8 with BOM via `[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)` if needed.

---

## Phase 5 — Execute

**Goal:** Run the script, publish, and verify.

1. **Token refresh** — follow `sitecore-token-refresh` skill before running any script
2. Run: `powershell.exe -File "scripts\Build-{ClientName}PocPage.ps1"`
3. Verify no errors. If there are errors, diagnose and fix before continuing.
4. **Publish** — use the GraphQL `publishItem` mutation directly (do NOT attempt `dotnet sitecore publish item` — the CLI session expires independently of the bearer token and produces a misleading error). Replace the path with the resolved target page path from Phase 0:
   ```powershell
   $TOKEN = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud.accessToken
   $uri = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io/sitecore/api/authoring/graphql/v1"
   $hdrs = @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" }
   $mut = '{ "query": "mutation { publishItem(input: { rootItemPath: \"/sitecore/content/dev-demos/standard/Home/PAGE-SLUG\" languages: \"en\" targetDatabases: \"experienceedge\" publishItemMode: SMART publishRelatedItems: true publishSubItems: true }) { operationId } }" }'
   $r = Invoke-RestMethod -Uri $uri -Method POST -Headers $hdrs -Body $mut
   Write-Host "operationId: $($r.data.publishItem.operationId)"
   ```
5. Wait ~45 seconds for Edge propagation before screenshotting

---

## Phase 6 — Verify

**Goal:** Confirm the page looks correct.

> ⚠️ **Playwright is Phase 1 (source site analysis) only.** Do NOT attempt to use Playwright against any Sitecore preview or editing URL — those endpoints are behind a Cloudflare auth gate and Playwright will receive a login page, not the rendered POC. MCP `get_page_screenshot` is the sole POC page verification method.

1. Get a screenshot: `mcp_sitecore-mark_get_page_screenshot` with:
   - `pageId`: the resolved target page ID from Phase 0 — NOT the hardcoded Home ID unless Home is the target
   - `version`: the item version from Phase 0 — **newly created pages always start at version 1; do not assume 2**
   - `width`: 1440
   - `height`: **900** — never use 5000px or similar for full-page capture. At that size the base64 image exceeds the context window and only the top of the page will be visible inline. Instead, take multiple 900px screenshots by scrolling.
2. The screenshot tool renders only the top `height` pixels of the page viewport. **Only the sections visible in that viewport can be confirmed.** Explicitly state which sections you can see and which you cannot. Do NOT declare the full page correct based on a partial viewport.
3. To verify sections below the fold, take additional screenshots. You cannot scroll the screenshot tool, but you can open the saved PNG: save to disk via `[IO.File]::WriteAllBytes(...)` and run `Start-Process` to open it in the user's image viewer. Then ask the user to confirm what they see.
4. Compare screenshot to the source page. For each **confirmed visible** section:
   - Section is present and in the right order
   - Text content rendered (not blank)
   - Images rendered (not broken)
   - No layout errors (spinner, [object Object], missing sections)
5. If issues found: diagnose → fix in the build script → re-run Phase 5 → re-screenshot
6. Report final status to the user with the screenshot. State clearly which sections were confirmed inline vs. which require the user to review the saved PNG.

---

## Error handling

| Issue | Resolution |
|---|---|
| Script fails with auth error | Run sitecore-token-refresh skill, then retry |
| `add_component_on_page` 404 for a container | Containers must be written via layout XML in the build script — not MCP |
| `add_component_on_page` 500 | Verify parameter name is `componentRenderingId` not `renderingId` |
| Screenshot shows wrong content | Check item version; confirm page was published; wait for Edge propagation |
| Image field renders broken | Verify GUID format is `{GUID-IN-BRACES}` with braces, not N-format |
| Link causes rendering crash | Verify `linktype` — never use `internal` without a valid item GUID |
| Em-dashes in content cause script failure | Replace all em-dashes with plain ASCII hyphens `--` |
