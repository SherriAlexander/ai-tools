# Project Context: AI-Powered Sitecore POC Generator

_Last updated: 2026-04-03_

> **Site-specific context** (environment URLs, completed page IDs, media GUIDs, theming status) is in [`docs/sites/velir.md`](sites/velir.md). For a new client site, copy [`docs/sites/SITE.template.md`](sites/SITE.template.md).

## Vision

Build a tool that ingests a potential client's existing website and automatically generates a Sitecore POC site that mirrors their look, feel, and content structure — demonstrating rapid time-to-value using Velir's SitecoreAI quickstart/acceleration toolkit.

**Output goal:** Homepage, a couple of landing pages, sample navigation, a couple of internal pages — enough to show a client "this is what your site could look like on Sitecore, and we stood it up fast."

---

## Background & Context

- Velir has a **SitecoreAI quickstart/acceleration toolkit** with pre-built components and scaffolding.
- The POC generator would sit on top of that toolkit — feeding it client-specific content/design rather than building from scratch.
- Primary audience: pre-sales / business development (demos to prospective clients).

---

## Key Decisions

| Date | Decision | Notes |
|------|----------|-------|
| 2026-03-28 | Project initiated | Planning phase |
| 2026-03-30 | Authoring GraphQL validated as primary integration path | Community Sitecore MCP (`@antonytm`) had URL bugs and a `fetch failed` error on `presentation-add-rendering-by-path`; direct mutations confirmed working. Note: this was the community MCP, not Marketer MCP — see 2026-04-02 update. |
| 2026-04-02 | MCP-first approach adopted | Marketer MCP (`mcp_sitecore-mark_*`) is the primary integration path for all content component CRUD. Containers are the only known exception — they have no datasource template and return 404 from `add_component_on_page`. Container layout must still be written via PowerShell + Authoring GraphQL. See `MARKETER_MCP_KNOWLEDGE_BASE.md` for the full capability map and hybrid pipeline model. |
| 2026-04-02 | MCP CRUD fully validated | All basic operations confirmed: `get_content_item_by_path/id`, `create_content_item`, `update_content`, `update_fields_on_item`, `delete_content`, `add_component_on_page`, `set_component_datasource`. Only `remove_component_on_page` is broken (404 regardless of ID used). |
| 2026-04-02 | `set_component_datasource` confirmed working | Proven: swaps the datasource on an existing component instance. Use after `add_component_on_page` if you want to attach a pre-populated datasource instead of populating the auto-created blank one. |
| 2026-04-02 | Two new skills created | `sitecore-layout-inspect` — token refresh + live layout query + readable table. `poc-add-section` — MCP-first workflow for adding content components + populating datasource fields, including sync-back guidance for `Build-VelirPocPage.ps1`. |
| 2026-03-30 | Item Service ruled out | Legacy XM/XP only — not available on XM Cloud |
| 2026-03-31 | POC pages must target Home item, not child pages | **SUPERSEDED — see 2026-04-02 correction below.** Original finding: child pages caused 500 in the editing render host. Root cause was mis-diagnosed as routing; actual cause was an empty layout + unpublished page. |
| 2026-04-02 | Child page routing limitation was a false conclusion | `get_page_screenshot` (MCP) confirmed working on `/Velir-POC` child page today. MCP screenshots render from published Experience Edge — child pages work fine if they have a valid layout and are published. The 500 in March was caused by: (1) empty `__Final Renderings` on the child page, and/or (2) the page not being published (XM Cloud API `/live` endpoint returns 404 for unpublished items). The Sitecore Pages in-browser editor may still have issues rendering child pages that are unpublished or have empty layouts — that is a separate concern from MCP screenshot rendering. Child pages can be used for POC builds as long as they have a complete layout and are published before screenshotting. |
| 2026-03-31 | `__Final Renderings` is shared, not versioned | Cannot use item versions to isolate layout experiments. Use separate items instead. |
| 2026-03-31 | `local:` datasource paths confirmed working on Home | Hero + Multi Promo render successfully with `local:/Data/...` paths and datasource items under `Home/Data/`. |
| 2026-03-31 | DynamicPlaceholderIds use global counter | IDs increment across ALL renderings on a page, not per-component. Container 1=1, Hero=2, Container 2=3, Multi Promo=4, Container 3=5, CTA=6. Child renderings must reference their parent container's actual ID (e.g., `container-fullbleed-3` not `container-fullbleed-2`). |
| 2026-03-31 | Link fields with `linktype="internal"` require a GUID | Using `url="/path"` without `id="{GUID}"` crashes the rendering host. Use `linktype="external"` with full URL for POC content. |
| 2026-03-31 | `description` on VXA Hero is Single-Line Text, not Rich Text | Do not wrap in `<p>` tags; they render literally. |
| 2026-03-31 | Media upload confirmed working | `uploadMedia` GraphQL mutation returns a pre-signed URL; actual file upload done via `curl.exe` (PS 5.1 multipart is unreliable). See `poc-upload-images` skill for the full workflow. |
| 2026-04-01 | Token auto-refresh practice defined | CM access token (`user.json` → `accessToken`) expires in **15 min**. Scripts must re-request via OAuth client credentials at startup. Two scopes: `cm` (15 min, Authoring GraphQL) and `api` (24 hr, Pages/Sites REST). See `SITECORE_SCRIPTING_CONVENTIONS.md` → Token Auto-Refresh Practice for the `Get-SitecoreToken` PS function. |
| 2026-04-01 | Pages REST API documented | `https://xmapps-api.sitecorecloud.io` — REST endpoints for page CRUD, layout save (`POST /api/v1/pages/{pageId}/layout`), and field updates. Layout body is JSON (not XML). Not yet validated against live env; Authoring GraphQL remains primary path. |
| 2026-04-01 | CLI publish and ser push flags noted | `dotnet sitecore publish item --path ... -sub -rel` publishes via CLI. `dotnet sitecore ser push -p` adds publish step after serialization push. `dotnet sitecore cloud login --client-credentials` enables non-interactive auth. |
| 2026-04-01 | VXA Video component confirmed for ambient hero | Accepts `video` field as General Link (YouTube URL or direct MP4). `ambient` rendering param enables background-style playback. VXA VideoPromo requires an uploaded file (FileField) — not suitable for external URLs. For self-hosted MP4 sources, the direct media URL may not appear in page DOM — fetch raw page source to find it. |
| 2026-04-02 | `uploadMedia` mutation schema clarified | `UploadMediaPayload` has only `presignedUploadUrl` — `mediaItemId` does NOT exist on this type. The upload is always two steps: (1) get presigned URL, (2) `curl.exe` POST. To check if media already exists, query the item path separately before uploading. |
| 2026-04-02 | Promo ImageRight variant confirmed working | `ImageRight` variant specified via `FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D` in `s:par` layout XML. GUID sourced from `/Presentation/Headless Variants/VxaPromo/ImageRight` on the live site. `$ppr` param string pattern in `_Template-BuildPage.ps1`. See `VXA_COMPONENT_SPECS.md` for all Promo variant GUIDs. |
| 2026-04-02 | Multi Promo image-only display pattern | Set `title`, `eyebrow`, `description` to `""` on all Multi Promo Item datasources to suppress text. Result is a pure image grid with optional clickable links. Use `light` colorScheme container when logos are black-on-transparent PNG. |
| 2026-04-02 | Image sourcing rule established | All component image fields must be populated from the live source site — no blank images when the source has one. Workflow: fetch image URL from source HTML, upload via `uploadMedia` + `curl.exe`, record GUID in `Build-VelirPocPage.ps1`. |
| 2026-04-02 | `mcp_sitecore-mark_upload_asset` confirmed non-functional | Fails with `fs.readFile is not implemented yet` — MCP runtime has no filesystem access. This is a permanent limitation. PowerShell `uploadMedia` GraphQL + `curl.exe` is the only working upload path. Documented in `MARKETER_MCP_KNOWLEDGE_BASE.md`. |
| 2026-04-02 | `poc-upload-images` skill created | Codifies full image upload workflow: scrape source URLs, idempotency check, `uploadMedia` + `curl.exe`, GUID resolution, build script wiring. Registered in `github-instructions.md`. |
| 2026-04-02 | Browser token refresh must be triggered by agent | `dotnet sitecore cloud login` should always be run by the agent, not handed to the user. Noted in `sitecore-token-refresh` skill. || 2026-04-03 | Phase 1 plan table must show full container nesting, DPID ranges, and per-component rows | Original flat table format (`Container` + `Component` in same row) silently collapsed 50/50 sections — the nesting and DPID cost were invisible. New format: (1) `Container Structure` column uses explicit nesting notation (`Full Bleed (outer) > Split 50/50 (inner)`), (2) each component gets its own row with a `Side` column (`Left`/`Right`) for 50/50 children, (3) `DPIDs` column shows the range consumed per section. DPID cost rules: simple Full Bleed + 1 child = 2; Full Bleed + Split 50/50 + 2 children = 4; N children sharing one Full Bleed placeholder = 1 + N. `poc-generator.prompt.md` Phase 1 output section updated to enforce this format. |
| 2026-04-03 | `updateItem` all-or-nothing field write behavior confirmed | One invalid field name in the fields array silently fails the entire mutation — all fields including valid ones go unset. The script emits `WARNING: GQL: Cannot find a field with the name X` but does not throw. The item retains placeholder defaults. Always verify field machine names against `VXA_COMPONENT_SPECS.md` before calling `Set-SitecoreFields`. Always screenshot after a build run — `~ Updated:` only confirms the mutation was sent, not that fields were written. Documented in `SITECORE_SCRIPTING_CONVENTIONS.md`. |
| 2026-04-03 | Media library GUIDs do not survive site reset | When a page (or site) is deleted and recreated, content GUIDs change but media GUIDs survive if the media items were NOT deleted. On this rebuild: 19/20 media items were still present at original GUIDs; only Wendy Karlyn headshot (previously at `wendy-karlyn` flat path) needed re-upload with new GUID. Lesson: always run idempotency check (`Get-MediaItemId`) before reusing GUIDs from a previous session. |
| 2026-04-03 | `fetch_webpage` cannot reveal side-by-side layout | Text is returned in document order regardless of CSS layout, so you cannot tell from fetched content whether two text blocks are 50/50 (side-by-side) or two separate stacked sections. Playwright screenshot is now the required first step in Phase 1 to resolve this — see entry below. |
| 2026-04-03 | Playwright screenshot adopted as Phase 1 first step | Node v24 + Playwright required. Full-page 1440px screenshot with `domcontentloaded` wait resolves 50/50 vs. stacked ambiguity, image-left vs. image-right, and color schemes visually — no user confirmation needed. Script runs from `$env:TEMP` via `node screenshot.js`. See `poc-generator.prompt.md` Phase 1 for the full pattern. Machine-specific paths (node_modules, Chromium) in `docs/sites/{site}.md`. |
| 2026-04-03 | Screenshot context-window limit | `mcp_sitecore-mark_get_page_screenshot` with `height: 5000` produces a 3MB+ base64 that exceeds the inline rendering context window. Only the top viewport is visible. Use `height: 900` and save to disk + `Start-Process` for the user to verify lower sections. Never declare the full page correct from a partial viewport. |
| 2026-04-03 | Hero field names confirmed | Hero template fields: `title`, `description`, `link`, `image`. No `eyebrow` field exists. The CTA link is `link` not `primaryLink`. Using wrong field names silently clears all fields (updateItem all-or-nothing). |
| 2026-04-03 | Promo CTA field is `primaryLink` not `link` | Promo datasource fields: `eyebrow`, `title`, `description`, `primaryLink`, `secondaryLink`, `image`. **There is no `link` field** on the Promo template. Using `link` silently clears all fields due to updateItem all-or-nothing behavior. Always use `primaryLink` for Promo CTA buttons. Hero and CTA Banner use `link` (different templates). |
| 2026-04-03 | Multi Promo parent has only title + link | Multi Promo parent datasource fields: `title` and `link` only. `numberOfColumns` does NOT exist on this template (confirmed 2026-04-03 — GQL warning). No `eyebrow`, no `description`. Children use `eyebrow`, `title`, `description`, `link`, `image`. Children must be created with `ParentId` = the Multi Promo parent GUID — not the Data folder. |
| 2026-04-03 | `dotnet sitecore publish item` fails with misleading error | Fails with `Make sure the GraphQL service is installed` (exit 1) when CLI session is expired — misleading error, it's an auth problem. The `publishItem` GraphQL mutation is the reliable path: uses the same bearer token, returns an `operationId` immediately, async propagation ~30-60s. Documented in `SITECORE_SCRIPTING_CONVENTIONS.md`. |
| 2026-04-03 | Agent terminal patterns documented | `Start-Sleep` in a foreground terminal times out the tool call. Use `isBackground: true` + `await_terminal` for any wait. Check `$r` in a separate tool call to avoid stale variable reads. Exploit persistent terminal state: `$TOKEN`, `$hdrs`, item IDs. Use `timeout: 300000` for full build script runs. Documented in `SITECORE_SCRIPTING_CONVENTIONS.md` → Agent Terminal Patterns. |
| 2026-04-03 | Shared helper library and Component Registry established | Three new reference artifacts created this session: (1) `scripts/Shared-SitecoreHelpers.ps1` — canonical home for `Invoke-Gql`, `Get-SitecoreItemId`, `Get-OrCreate-SitecoreItem`, `Set-SitecoreFields`, `New-LayoutGuid`; all new build scripts must dot-source this file instead of inlining helpers. (2) `docs/VXA_COMPONENT_SPECS.md` Component Registry section — rendering IDs and datasource template IDs (N format) for all 9 confirmed components. (3) `docs/SITECORE_SCRIPTING_CONVENTIONS.md` Layout XML `s:par` Patterns section — `$cp`/`$rp`/`$vp`/`$ppr` pattern strings, which-to-use table, and complete layout row templates. `poc-generator.prompt.md` Phase 4 updated to dot-source `Shared-SitecoreHelpers.ps1` instead of inlining helpers. |
| 2026-04-03 | Three agent process rules added | (1) `scripts/archive/` is permanently off-limits — never copy from it. All reusable knowledge must be in `docs/` or `_Template-BuildPage.ps1`. If something is missing from those files, update them. (2) Phase 1 of poc-generator is a mandatory confirmation gate — agent must stop and wait for user approval before Phase 2. Enforced in `github-instructions.md` and `poc-generator.prompt.md`. (3) Truncated terminal output is not a failure signal — always check variable value in a follow-up call before retrying a mutation. Documented in `SITECORE_SCRIPTING_CONVENTIONS.md` → Agent Terminal Patterns. |

| 2026-04-03 | Card grid scraping rules established | Two content/planning rules added to `SITECORE_SCRIPTING_CONVENTIONS.md`: (1) Always fetch `og:image` from each card's individual page — never use images scraped from the listing page (which may contain carousel/hero images). (2) Visually verify the scraped slug list against a Playwright screenshot before writing cards — naive regex scrape of a listing page captures carousel slide slugs mixed in with grid slugs. |
| 2026-04-03 | `Remove-OrphanedSitecoreChildren` added to Shared helpers | New function in `Shared-SitecoreHelpers.ps1`. Takes `-ParentPath` and `-KeepNames`. Deletes any children of the parent not in the keep-list. Must be called after every Multi Promo card loop in build scripts — failing to do so leaves stale cards from previous runs visible on the rendered page. `Build-WorkPage.ps1` already calls it. All future page scripts with Multi Promo cards must call it too. |
| 2026-04-03 | `sitecore-pitfalls.md` rules migrated to project docs | All rules migrated to project docs: link field rules, `__Final Renderings` sharing, media upload rules, screenshot version rules → `SITECORE_SCRIPTING_CONVENTIONS.md`; browser login polling loop → `sitecore-token-refresh/SKILL.md`. Project is now self-contained — no agent-level memory dependency. |
---

## Open Questions

- What inputs will the tool accept? (URL only, or also brand assets, sitemaps, etc.)
- How much fidelity is expected? (Pixel-perfect vs. "spirit of the brand")
- ~~Which Sitecore product(s) are in scope?~~ **Resolved:** SitecoreAI / XM Cloud only. No legacy XM/XP.
- What does the SitecoreAI toolkit currently provide? (Components, themes, content models?)
- Where does the generated POC live? (Deployed automatically, or handed off as a code package?)
- How much human review/cleanup is expected before showing a client?

---

## Resources & Infrastructure

### 1. Velir Experience Accelerator (VXA)
- Monorepo (Turborepo): `authoring/` (Sitecore serialized items) + `headapps/nextjs-content-sdk/` (Next.js front-end) + `packages/` (CLI tooling)
- Built on Sitecore Content SDK (`@sitecore-content-sdk/nextjs`), **not** legacy JSS — this is the current SitecoreAI headless SDK
- Uses Tailwind CSS 4 + CSS custom properties (`--vxa-*`) for theming
- **Design token workflow:** Figma → TokenSync CLI → theme CSS files — theming is fully config-driven, no code changes needed for a new brand
- Local repo path and access details: see `docs/sites/velir.md`

### 2. Sitecore Docs MCP
- First-party MCP server for Sitecore documentation
- Available now in the agent environment
- Useful for: looking up content models, template structures, API usage during generation

### 3. Community Sitecore Operations MCP (`@antonytm/mcp-sitecore-server`)
- **Repo:** https://github.com/Antonytm/mcp-sitecore-server
- **Install:** `npx @antonytm/mcp-sitecore-server@latest` (stdio transport)
- **Auth:** Requires GraphQL API key + PowerShell Remoting credentials
- **Note:** Community-maintained (v1.3.5, 41 stars, Apache-2.0). Supports both legacy Sitecore XM/XP and modern SitecoreAI/XM Cloud — capability availability varies by platform (see validated findings below).
- **Key capability groups (XM Cloud scope):**
  - **GraphQL API** — Introspect schema, execute queries against edge/master/core schemas. ⚠️ `query-graphql-master` tool is broken on XM Cloud due to URL composition bug (appends `/master` as path segment → 404). Use Authoring GraphQL directly.
  - **Presentation** — Get/set/add/remove layouts, renderings, rendering parameters, placeholders. ⚠️ `presentation-add-rendering-by-path` fails with `TypeError: fetch failed` in this environment. **Note:** this is the community MCP only — the Marketer MCP `add_component_on_page` is proven working for content components (containers still require direct GraphQL).
  - **Sitecore PowerShell (SPE)** — Run arbitrary PowerShell scripts; XM Cloud availability unconfirmed.
  - **Common** — Templates, workflows, publishing, cloning, field management, references, versioning
  - **Security** — Users, roles, domains, item ACLs
  - **Indexing** — Search index management
  - **Logging** — Retrieve Sitecore logs
  - **Sitecore CLI** — Documentation tool for CLI context
  - ~~**Item Service API**~~ — Legacy XM/XP only. **Not applicable to this project.**
- **Key observation:** The Marketer MCP is the primary integration path for all content component operations (add, update, read, delete). Authoring GraphQL is required only for containers (which have no datasource template) and for bulk layout resets via `Build-VelirPocPage.ps1`. See `MARKETER_MCP_KNOWLEDGE_BASE.md` for the full hybrid pipeline model.
- **Validated GraphQL facts (2026-03-30):**
  - Endpoint: `/sitecore/api/authoring/graphql/v1` (not `/v1/master`)
  - Item query shape: `item(where: { path: "..." })` (not `item(path: "...")`)
  - Field access: `fields { nodes { name value } }`
  - Auth token: raw value in `GRAPHQL_API_KEY` — do not prefix with `Bearer`

### 4. SitecoreAI Portal (XM Cloud)
- **SitecoreAI is the current branding for XM Cloud** — this is the exclusively targeted platform
- No legacy XM/XP support in scope
- Access confirmed

### 5. Vercel MCP + Portal
- **Official Vercel MCP server** available at `https://mcp.vercel.com` (remote, OAuth-authenticated, Beta)
- Natively supported in VS Code with Copilot — add via MCP: Add Server → HTTP → `https://mcp.vercel.com`
- Project-specific endpoint: `https://mcp.vercel.com/<teamSlug>/<projectSlug>` (auto-injects project context)
- Access confirmed
- **Available tools:**
  - **Documentation:** `search_documentation` — search Vercel docs
  - **Project Management:** `list_teams`, `list_projects`, `get_project`
  - **Deployment:** `list_deployments`, `get_deployment`, `get_deployment_build_logs`, `get_runtime_logs` (filter by env, level, status code, time range, full-text)
  - **Domain Management:** `check_domain_availability_and_price`, `buy_domain`
  - **Access:** `get_access_to_vercel_url` (shareable links for protected deployments), `web_fetch_vercel_url` (fetch content from authenticated deployments)
  - **CLI:** `use_vercel_cli`, `deploy_to_vercel` — trigger deployments directly from the agent
- **Key insight for this project:** `deploy_to_vercel` + `get_deployment_build_logs` + `get_runtime_logs` means the agent can deploy the generated POC AND monitor/debug it autonomously — full deploy loop without human intervention
- Confirms the output stack is **JSS/Next.js deployed to Vercel** (standard XM Cloud headless pattern)

---

## VXA Component & Template Inventory

### VXA Components (33 total) — the POC generator's output palette

| Category | Components |
|----------|-----------|
| **Hero / Promo** | Hero, Hero Parallax, Promo (ImageLeft/ImageRight/Animated variants), Multi Promo, CTA Banner, Video Promo, Video Rollover Promo |
| **Navigation** | Global Header, Global Footer, Secondary Navigation, Breadcrumb, Jump Link Navigation, Anchor Link |
| **Page Structure** | Page Header, Structured Content Page Header, Event Header, Container (full-bleed/full-width/70/50-50/70-30/30-70 + colorScheme variants) |
| **Content** | Rich Text, Body Text, Accordion, Prose, Image (Default/Square/Video/Animated), Video |
| **Listings / Search** | Dynamic Content Listing, Manual Content Listing, Related Content Listing, Site Search, Search Metadata |
| **Utilities** | Back to Top, Button (Primary/Secondary/Ghost/Outline/Link/Tertiary variants) |
| **UI Primitives** | 40+ Radix UI components (dialogs, forms, etc.) in `src/components/vxa/ui/` |

**SXA OOTB components also available:** Image, Link List, Navigation, Page Content, Promo, Rich Text, Title, Container, Column/Row Splitter

### Key Sitecore Template IDs

**Page Templates** (confirmed live 2026-04-02 by walking content tree):

| Template | ID | Use when |
|---|---|---|
| VXA Homepage | `fc2f8171-4f48-4c91-900d-f1f8b72e1ce2` | POC page, homepage mirror, any general-purpose page |
| VXA Landing Page | `36b40a99-d339-4924-8768-4ad5f9fba83a` | Landing page (has `Data/` + `Detail Page` children) |
| VXA Detail Page | `27961cd5-3277-4cf3-89ea-049206e7c136` | Article/detail child under a Landing Page |
| VXA Search Page | `c9d3eb06-ca1d-4907-ba1f-473e4500972a` | Site search page |
| Page Data folder | `1c82e550-ebcd-4e5d-8abd-d50d0809541e` | The `Data/` folder created under every page |

> For POC builds: use **VXA Homepage** as the default page template for any new page. It is the most permissive — accepts the full VXA component palette with no structural constraints.

**Datasource / Component Templates**:

| Template | ID | Notes |
|---|---|---|
| VXA Body Content (folder) | `fd5bd203-b391-474d-bda0-4d4a32993329` | Groups body content datasource templates |
| VXA Containers | `10edf32e-94b5-4516-a3a8-f1d6769bbb81` | Container component template |
| VXA Headers | `f2f88964-ba4b-45fa-86f2-2ffe68d17b43` | Header component templates |
| VXA Media | `e73beeea-e35e-4792-ab6d-e0c631644ed4` | Media component templates |
| VXA Navigation | `fa811f88-4f1e-40e4-b96a-5811c54cd56a` | Navigation component templates |
| VXA Promos | `725941aa-249d-4b12-9398-2eb8beaf6d31` | Promo component templates |
| VXA Button datasource | `0eba87a2-f34e-4845-bfbf-e74f9449d28b` | Button: Link, Icon, Icon Position, Button Style |
| Feature Templates root | `91db67da-6df6-47b8-a172-7384e1444886` | `/sitecore/templates/Feature/Velir Experience Accelerator` |
| Project Templates root | `205760c1-4772-48d0-97d8-adc3a6ff3b54` | `/sitecore/templates/Project/Velir Experience Accelerator` |
| Foundation Layout | `7538c5e7-b86b-4ca4-a198-b490c280eff5` | The single master layout for all VXA pages |
| Sitecore Rendering template | `7ee0975b-0698-493e-b3a2-0b2ef33d0522` | Template type for all rendering registrations |

### Placeholder Keys
- `jss-main` — root placeholder (from config)
- `container-{DynamicPlaceholderId}` — dynamic placeholders inside Container components
- Standard SXA: `headless-header`, `headless-main`, `headless-footer`
- Project-level placeholder settings control which components are allowed where

### Rendering Group IDs
- VXA Body Content renderings: `efc27921-32da-45e5-9242-4262eca78718`
- VXA Containers renderings: `e1d9a357-06b6-497f-ae42-cb8a1fe9d0b1`
- All VXA renderings live under: `/sitecore/layout/Renderings/Feature/Velir Experience Accelerator/`

### Rendering Item IDs (for layout XML `id=` attribute — `{GUID}` format)

| Component | Rendering ID |
|-----------|-------------|
| Full Bleed Container | `{E80C2A78-FCC2-4D32-8EC5-4133F608BE5C}` |
| VXA Hero | `{87FAFE78-A3FE-4DDC-8AB8-1054FF60F2A8}` |
| VXA Video | `{3A96ECF8-20CE-4F57-A9A6-D2D25F952A1E}` |
| Promo | `{82B3AE49-7D2E-4157-85A2-3D43C8F79224}` |
| VXA Multi Promo | `{A161BB73-6198-472C-B998-2D3714576F93}` |
| CTA Banner | `{0DCB68F2-F540-4A4F-B32F-A95391B44811}` |

> These are the `id` attribute values used in `__Final Renderings` XML. The Default device ID is `{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}`.

### Component Datasource Template Schema (field-level)

> Extracted 2026-03-29 from `authoring/items/items/templatesFeature/`. These are the exact GUIDs and field names to use in `createItem()` calls.
>
> **Field name in createItem:** use the camelCase key shown (e.g. `title`, `description`, `primaryLink`)
> **Template ID:** the GUID passed as `templateId` in `createItem()`
> **Container has no datasource** — it is configured entirely via rendering parameters.

---

#### VXA Hero
**Template ID:** `4579b391-45b7-46a9-87b2-0456c66bf807`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `82bcfc2d-dff6-4744-ad95-e3d8a7cbf636` |
| `description` | Single-Line Text | `628707ca-004d-4e09-a6c4-14474b234c3a` |
| `image` | Image | `76e57b70-981e-4a45-b67d-cb4c2d4be046` |
| `imageMobile` | Image | `849593f1-598e-4a09-ade9-32b670e2dd8a` |
| `link` | General Link | `4e1abf06-2cb2-4239-9bca-22de3d52dcad` |

Rendering parameters: `textOrientation` (Droplist) — `b342dd6e-8f94-40d9-8682-df31232a9321`

---

#### VXA Hero Parallax
**Template ID:** `5af1824f-d026-4b52-b17b-8cd27ffba6b3`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `372c6eb5-c0bb-43f0-9b02-83e848dc4580` |
| `description` | Single-Line Text | `a3b85517-6e56-46f5-a50a-29bbbcf798d9` |
| `link` | General Link | `6d1df8a4-f769-4337-a61f-1908bf5a8e87` |
| `backgroundImage` | Image | `4e81c9be-e0b3-4b0f-9f1f-a340a2ba4e82` |
| `foregroundImage` | Image | `3f80d6d1-9c00-469e-b1c8-b24029724da0` |
| `floatingImageTopLeft` | Image | `1e1ad7a5-1680-4cd9-903c-c22f4068890b` |
| `floatingImageTopRight` | Image | `337793d5-7092-408a-b522-863017e51a6e` |
| `floatingImageBottomLeft` | Image | `01f17947-6498-4afd-9981-904e804afbdc` |
| `floatingImageBottomRight` | Image | `3ee37011-ad54-43db-825b-26af25141da6` |

Rendering parameters: `textOrientation` (Droplist) — `22186867-7b23-435f-9bf9-4a99b09d21ec`

---

#### VXA Page Header
**Template ID:** `57bb2b7f-fa34-4762-b664-f58c1c3a17a6`

| Field | Type | Field GUID |
|-------|------|------------|
| `image` | Image | `79427300-72be-4f73-b492-f4db6435f8b5` |

> Note: title/heading derives from the page item name, not a datasource field.

---

#### VXA Structured Content Page Header
**Template ID:** `2e247e9d-1b3d-4a6d-b415-a3af2f537e74`

| Field | Type | Field GUID |
|-------|------|------------|
| `eyebrowText` | Single-Line Text | `78e1ca09-ffb7-47f7-bb79-fab887cf0289` |
| `image` | Image | `429dc917-5f6f-471d-a5e6-77b3f8c08b2c` |

---

#### Promo
**Template ID:** `d100f089-a4d3-4d22-9d1d-e7ab0e721f81`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `733abbaa-ac4d-4ee4-9aea-7325b2b712ae` |
| `eyebrow` | Single-Line Text | `9213fb91-7e3b-47ce-a0d9-b8a735708e1d` |
| `description` | Multi-Line Text | `d3b60964-9331-4599-a143-c214c72a942a` |
| `image` | Image | `0a2de64c-a550-4df6-9062-ee622d4f27c8` |
| `primaryLink` | General Link | `500ab388-ee99-4e5a-a71b-3726892d3add` |
| `secondaryLink` | General Link | `a7b6b2fc-2436-4dba-8f91-fc895aef498b` |

---

#### CTA Banner
**Template ID:** `5486c1de-bf46-4bc2-b4fb-9faf59903b29`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `cc284e62-69cf-4a23-833a-8563b75f542a` |
| `description` | Multi-Line Text | `d6bb5cb8-7170-4b15-b0fb-5ff2c91f88cb` |
| `link` | General Link | `609c10ea-b54b-4996-9acc-000664de6c60` |

---

#### VXA Multi Promo _(container — wraps Multi Promo Items)_
**Template ID:** `380ffba8-5f49-4abc-a903-d069a0add3ec`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `0ea7ad65-b151-463e-9267-d13e56e7b542` |
| `link` | General Link | `41f826f0-f372-4e86-8a31-b252b6ea1fd2` |

#### VXA Multi Promo Item _(individual cards; one per card in the listing)_
**Template ID:** `b81775e5-45b5-4238-961b-8b2996ff2503`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `18196071-dd22-42a6-af42-65dfcb8f1b35` |
| `eyebrow` | Single-Line Text | `d716869a-fa2b-4ba8-86db-8a56d7605ac8` |
| `description` | Multi-Line Text | `f1dab91e-fbb6-4a3f-a543-d53558ac1d98` |
| `image` | Image | `5e5117fb-bfe2-4abd-b4df-033fcaad5af8` |
| `link` | General Link | `73499342-d6b1-4f76-9d44-f5ab6fd38124` |

---

#### VXA Video Promo
**Template ID:** `f0640c38-0f0b-44ac-ba90-f58dbe9f2958`

| Field | Type | Field GUID |
|-------|------|------------|
| `videoPromoTitle` | Single-Line Text | `05542e84-2dd7-4e7d-9963-2fada511ce96` |
| `videoPromoCaption` | Single-Line Text | `1b6ebde9-19ea-4baf-9a0c-931d565cdb05` |
| `videoPromo` | File | `eb9de8fb-fe83-402b-a6d6-dc2d2db1eab6` |
| `videoPromoLink` | General Link | `8edcfcdf-1b38-44ca-a668-44cc9a33d601` |

Rendering parameters: `darkMode` (Checkbox) — `bd11743e-407d-47a6-96e8-4b5d7e819b4c`

---

#### VXA Accordion _(container)_
**Template ID:** `203d03df-8885-4781-98dc-cd615905d024`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `e114d6b9-6d68-4a92-a186-6586a96c288d` |

#### VXA Accordion Item _(one item per FAQ entry)_
**Template ID:** `fcc8af5f-a9a9-44c5-a0ac-b9388ffa219d`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `54ab6387-194a-465f-9716-eca767a6fc37` |
| `text` | Rich Text | `c300e4ef-023b-48d1-878e-d5cdc6cef392` |

---

#### VXA Rich Text
**Template ID:** `82462949-f375-4363-a4e2-1224f16f7311`

| Field | Type | Field GUID |
|-------|------|------------|
| `text` | Rich Text | `07613f8b-3e83-4ba8-ad63-1f4a2e89b5fa` |

---

#### VXA Button
**Template ID:** `0eba87a2-f34e-4845-bfbf-e74f9449d28b`

| Field | Type | Field GUID |
|-------|------|------------|
| `buttonLink` | General Link | `c263efe7-3675-4de6-9694-c00f75f08e9d` |

---

#### VXA Image
**Template ID:** `4a1cf144-249d-438d-a824-71e7341d1e19`

| Field | Type | Field GUID |
|-------|------|------------|
| `image` | Image | `1fb9ec03-1305-408e-bf33-29d8e34dcdf5` |
| `caption` | Single-Line Text | `88af2ea6-0a10-41ad-9ddc-4dbd36a49eb2` |

---

#### VXA Video
**Template ID:** `14490dcb-0655-4d24-b444-28c955d790d3`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `6483f65c-9d4e-4378-92fb-6d0cff3ea9ad` |
| `image` | Image | `42758bc5-bf13-4323-8fd5-6be44b4b3b32` |
| `video` | General Link | `93ce8723-1234-4ac8-9211-6f1b0c7804a1` |
| `transcript` | General Link | `351bcdfb-7a6c-485d-b404-e68634bc24aa` |

Rendering parameters: `darkPlayIcon` (Checkbox) — `150f0ea3-484c-4841-a13f-dad139c61004`

---

#### VXA Global Header _(rendering datasource — logo + nav configuration)_
**Template ID (Global Navigation/Header):** `7dc35bdc-a28b-480b-8774-659a1caa9be9`

| Field | Type | Field GUID |
|-------|------|------------|
| `logo` | Image | `77aeb1a3-b4c7-40eb-aece-8a97d1b755a9` |
| `logoMobile` | Image | `40cdc985-627f-415a-ae17-75d3cc0b9080` |

Rendering parameters: `sticky` (Checkbox) — `8c4a3f6f-7d18-4320-a0b3-cdd65ba78167`, `primaryNavColorScheme` (Droplist) — `782ee9a9-7162-46cc-8bd5-9b9ea2e65987`

#### VXA Primary Navigation Root _(nav tree container)_
**Template ID:** `22a8abd0-f489-47c7-b022-d7ecfa4c1d03`
> Container item only — no content fields.

#### VXA Primary Navigation Item _(top-level nav link + optional mega-menu promo)_
**Template ID:** `00c23ad1-b997-49bc-9c5a-10132cca9ccf`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `c98f1a8a-d804-47f3-8d28-2d9ea9365b89` |
| `link` | General Link | `400ff257-3861-4497-96f9-4386c48bfde0` |
| `promoTitle` | Single-Line Text | `613134a1-57fa-4779-a450-5a5a268a842a` |
| `promoImage` | Image | `31d125aa-fd25-404b-a07f-a232fab6f6c1` |
| `promoLink` | General Link | `a6f915cf-04cb-42d3-a3f2-b7ec21ad8de7` |

#### VXA Primary Navigation Subheader _(sub-nav group header)_
**Template ID:** `d64c8b84-3792-43bb-9294-c23df836760f`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `06a77e3e-5f83-487d-b5a4-5b345b4ebdfb` |
| `link` | General Link | `46299555-2ffd-40ad-9110-bcc369e2e31d` |

#### VXA Utility Navigation Item _(header utility links, e.g. Login, Search)_
**Template ID:** `f0290f61-7a11-4a16-baa3-f04a0d6d530a`

| Field | Type | Field GUID |
|-------|------|------------|
| `utilityLink` | General Link | `cebd6353-0437-4c7a-abbe-5eb8688552c9` |
| `isButton` | Checkbox | `8899a1f9-0d84-435f-ae26-f6afc98f3b08` |
| `buttonIcon` | Image | `230e4b7f-f3e0-456c-ab9b-ee46cde47b1c` |

---

#### VXA Global Footer Root _(footer datasource)_
**Template ID:** `3e97ce77-e29e-4540-a7f7-342b4eefc298`

| Field | Type | Field GUID |
|-------|------|------------|
| `footerLogo` | Image | `2a024f00-afeb-46a8-bb9e-3aa6501f652d` |
| `footerLogoLink` | General Link | `e7522025-c56e-41e7-af6e-49c747f08674` |
| `socialLinks` | Multilist | `5099a50a-f4d7-4d78-8bcf-54e72958807f` |
| `contactHeader` | Single-Line Text | `cac1d184-e582-47ab-a4a4-f30adfc56045` |
| `contactAddress` | Single-Line Text | `37bc528a-4ed4-4dc9-b1a8-867067aed52b` |
| `contactPhone` | Single-Line Text | `7f791c47-352b-4e8c-9991-1e6fe9610d6f` |
| `copyright` | Single-Line Text | `5b1521a7-c610-4453-ab4d-90b2de95977e` |

Rendering parameters: `footerNavColorScheme` (Droplist) — `74dfb002-6f39-4c98-98d4-86d5dbaf2335`

#### VXA Column Navigation Root _(footer column group container)_
**Template ID:** `aaa3550b-1ac9-45d9-91af-0c16fc529332`
> Container only — no content fields.

#### VXA Column Navigation Item _(footer column header + child links)_
**Template ID:** `cc85bda2-0c93-4e23-b689-737e9dfd9454`

| Field | Type | Field GUID |
|-------|------|------------|
| `columnHeader` | Single-Line Text | `325c2957-ea64-4ce9-bd6d-08555f112420` |

#### VXA Social Link
**Template ID:** `38dfd0e0-84ba-42ea-8994-1cdb91f2b121`

| Field | Type | Field GUID |
|-------|------|------------|
| `socialIcon` | Droplist | `37307b02-d82e-4ff3-bdf2-c8dcc737157f` |
| `link` | General Link | `75572b6e-0bf8-4fa8-82fd-7788804fd391` |

---

#### VXA Secondary Navigation
**Template ID:** `b629030e-0faa-485b-a60c-7a44b3809277`

| Field | Type | Field GUID |
|-------|------|------------|
| `parent` | Droptree | `efb36a7d-7e58-4ca1-a5ed-de65b6100bcd` |

#### VXA Anchor Link
**Template ID:** `08a92b6f-a1fd-42a2-95f7-c55fcb7bea4d`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `f6f4a6f8-933f-4d00-8094-d1a25045cbe8` |

---

#### VXA Manual Content Listing
**Template ID:** `a872f15f-8195-4c92-a106-d07adbf2274c`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `eb1cb258-3e71-45e7-87d7-fafb75d2e924` |
| `link` | General Link | `1d778bfd-080a-447d-bf88-4f999a78fb82` |
| `pages` | Treelist | `b23d8e51-ec28-4e54-9fa9-f8196a5c52a1` |

Rendering parameters: `hideThumbnails` (Checkbox) — `95597caa-e3d4-41db-9fa3-176c1dd1819d`

#### VXA Dynamic Content Listing
**Template ID:** `8ef88edb-e5f9-4f8a-9f50-5ca6453d8f16`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `833dc3ea-8fb7-4158-96fa-499afffe4207` |
| `numberOfItems` | Droplist | `5ae6439d-ddd2-4894-af40-6042e12b3795` |
| `sortOrder` | Droplist | `29e39096-b431-4ad0-917c-34eeb0a64340` |
| `taxContentType` | Multilist | `9900749f-2745-4db6-ba65-583695c91f94` |
| `taxTopic` | Multilist | `96876198-82d7-4284-b373-ec168e1569ba` |
| `filtersDisplayed` | Multilist | `cd15eaea-0df1-4235-8b2f-7a2aff89080d` |

#### VXA Related Content Listing
**Template ID:** `b50d5721-048b-4f2b-9f34-031329295179`

| Field | Type | Field GUID |
|-------|------|------------|
| `title` | Single-Line Text | `db27b982-2d8b-4555-9ff8-22131b83af14` |
| `relatedContentLink` | General Link | `3bcdf59b-8519-44ea-ad20-8dc410a851c1` |
| `relatedContentTypes` | Treelist | `42e2ef8d-3d3e-493f-b43c-99f0e7b98f7f` |

---

#### Container _(no datasource)_
**Template ID:** _N/A — Container has no datasource template._
Configured entirely via rendering parameters: `colorScheme` (Droplist), layout variant. No `createItem()` call needed for the Container itself.

---

### Theming Architecture
- **Approach:** CSS custom properties (`--vxa-color-*`, `--vxa-font-*`, `--vxa-spacing-*`, etc.) + Tailwind CSS 4
- **Color space:** OKLch (perceptually uniform — good for AI color matching)
- **Theme files:** `src/styles/themes/brand-a.css`, `brand-a-dark.css`, `brand-b.css`, `brand-b-dark.css`
- **AI theming path:** Extract client colors/fonts → write `--vxa-*` CSS variable overrides → no component code changes needed
- **TokenSync CLI:** `npm run vxa -- TokenSync` — ingests `tokens.json`, generates all theme CSS — designed for Figma but `tokens.json` can be authored by AI
- **Container `colorScheme` rendering param** — per-component color scheme override

### Module & Serialization Paths (vxa.module.json)
```
/sitecore/Templates/Foundation/Velir Experience Accelerator  → templatesfFoundation
/sitecore/Templates/Feature/Velir Experience Accelerator     → templatesFeature
/sitecore/Templates/Project/Velir Experience Accelerator     → templatesProject
/sitecore/templates/Branches/Project/VXA                     → branchesProject
/sitecore/templates/Branches/Feature/VXA                     → branchesFeature
/sitecore/layout/Layouts/Foundation/VXA                      → layoutsFoundation
/sitecore/layout/Renderings/Feature/VXA                      → renderingsFeature
/sitecore/layout/Placeholder Settings/Feature/VXA            → placeholderSettingsFeature
/sitecore/layout/Placeholder Settings/Project/VXA            → placeholderSettingsProject
```

### Minimum Items Required Before a Page Can Render
1. Site Collection + Site item
2. Foundation Layout (`7538c5e7-b86b-4ca4-a198-b490c280eff5`)
3. Page template (VXA Pages hierarchy)
4. Page item (instance of template)
5. Rendering tree assigned to page layout
6. Container rendering in `jss-main` placeholder
7. At least one component rendering in container
8. Component datasource item (if datasource-driven)
9. Placeholder settings (controlling allowed components)

### Key File Paths in VXA Repo
| Purpose | Path |
|---------|------|
| VXA React components | `headapps/nextjs-content-sdk/src/components/vxa/` |
| Theme CSS files | `headapps/nextjs-content-sdk/src/styles/themes/` |
| Component registration map | `headapps/nextjs-content-sdk/src/lib/component-map.ts` |
| Sitecore feature templates (serialized) | `authoring/items/items/templatesFeature/` |
| Sitecore renderings (serialized) | `authoring/items/items/renderingsFeature/` |
| Branch templates | `authoring/items/items/branchesFeature/`, `branchesProject/` |
| Module definition | `authoring/items/vxa.module.json` |
| Build config | `xmcloud.build.json` (rendering host: `contentsdk`, node 22.11.0) |

--- — Key Findings from Docs

### Platform Architecture
- **SitecoreAI = XM Cloud** — fully managed SaaS, headless-only, JSS + Next.js + Experience Edge
- Stack: CM instance → publishes to **Experience Edge** (geographically distributed GraphQL CDN) → Next.js app on Vercel reads from Edge
- **No Content Delivery servers** — all rendering is headless via Experience Edge GraphQL
- An internal **editing host** (managed by Sitecore) runs a Node server for the WYSIWYG Pages editor
- The **Context ID** (`SITECORE_EDGE_CONTEXT_ID`) is the single unified identifier for all resources — content, sites, files, forms, integrations. Critical env var for Vercel deployments

### JSS / Next.js / Vercel Deployment
- Vercel is the **recommended and validated** hosting for XM Cloud Next.js apps
- Required environment variables for Vercel: `SITECORE_EDGE_CONTEXT_ID`, `SITECORE_SITE_NAME` (or `NEXT_PUBLIC_DEFAULT_SITE_NAME`)
- **Webhook pattern for auto-redeploy:** XM Cloud publishes → Experience Edge webhook → triggers Vercel deploy hook → site rebuilds with new content. This is how the POC site would update after agent-generated content is published
- JSS version 21.6+ uses the **XM Cloud add-on** (`nextjs-xmcloud`) which auto-configures Context-based GraphQL, personalization, and analytics
- Starter kit: [`xmcloud-foundation-head`](https://github.com/sitecorelabs/xmcloud-foundation-head) — reference implementation for XM Cloud + SXA + Next.js

### Authoring & Management GraphQL API (THE key API for content creation)
- **Endpoint:** `https://<your-instance>/sitecore/api/authoring/graphql/v1/`
- **GraphQL IDE:** `https://<your-instance>/sitecore/api/authoring/graphql/playground/`
- Supports full CRUD via GraphQL mutations — this is the **primary API for the POC generator**:
  - `createItem(input: { name, templateId, parent, language, fields[] })` → returns `itemId`, `name`, `path`
  - `updateItem(input: { itemId, fields[] })` — update field values by name
  - `deleteItem(input: { path, permanently })` — cleanup
  - `item(where: { database, itemId })` — retrieve item with fields
- This API is available in SitecoreAI and is upgrade-safe (no in-process customizations needed)
- The `mcp-sitecore-server` `query-graphql-*` tools wrap this — meaning **the Sitecore Authoring API is accessible directly through the MCP server already connected to this workspace**

### Headless SXA (Sitecore Experience Accelerator) — Critical for Component Model
- All XM Cloud sites should use **Headless SXA** — it is the standard development model
- **OOTB XM Cloud components (the building blocks):** `Image`, `Link List`, `Navigation`, `Page Content`, `Promo`, `Rich Text`, `Title`, `Container`, `Column Splitter`, `Row Splitter`
- **Grid systems available:** Bootstrap 5 (default), Tailwind
- **Page structure:** Header → Content → Footer placeholders; static and dynamic placeholders supported
- **Page Designs + Partial Designs** — reusable layout compositions, analogous to page templates. Critical for defining consistent structure across POC pages
- **Creating new components:** Must clone either the `Promo` component (for datasource-driven components) or `PageContent` component (for non-datasource). VXA will have its own extended component library on top of these

### Sitecore Content Serialization (SCS) + CLI — Automation Path
- **Sitecore CLI** (`dotnet sitecore`) is the automation backbone for XM Cloud
- Items are stored as `.yml` files and pushed/pulled via `dotnet sitecore ser push/pull`
- Two deployment mechanisms:
  1. **Items as Resources (IAR)** via `xmcloud.build.json` `deployItems` — for developer-controlled items: templates, renderings, placeholder settings, layouts
  2. **Post-deploy actions** via `scsModules` — for content author items: Home page, data folders, dictionary
- Publishing to Edge: `dotnet sitecore publish --pt Edge -n <environment-name>`
- **Non-interactive CLI login** (for automation): uses client credentials flow with client ID + secret
- **Key insight:** The Sitecore CLI serialization + publish pipeline is an alternative (or complement) to using the Authoring GraphQL API for POC generation. Could generate `.yml` content files offline and push them in bulk, rather than making individual API calls.

### Sitecore Marketplace SDK
- `@sitecore-marketplace-sdk/xmc` package provides type-safe access to the Authoring GraphQL API, Pages REST API, Edge Token API, and Edge Admin API — useful if we build a Marketplace app extension to drive POC generation from within the CMS UI

### Important Constraints for POC Generator
- Only **headless SXA components** are available in XM Cloud (no MVC, no SXA themes, no Creative Exchange)
- New components must be **cloned from OOTB renderings** — can't create from scratch without scaffolding
- Content items must reference valid **templateId** GUIDs — the generator must know VXA template IDs ahead of time (or discover them via GraphQL introspection)
- Publishing to Edge is a **separate step** from creating items — must explicitly publish after content creation for it to appear on the live site

---

## Prerequisites — What Must Exist Before the Agent Runs

> **Revised assumption:** The developer runs VS Code locally, but the primary workflow targets the **cloud SitecoreAI CM directly** — no local Docker CM required. A local Sitecore environment is useful but optional (see Developer Workflow section for detail on local-first vs. cloud-direct).

This section covers what must exist before the agent runs, split into two phases.

---

### Phase 1 — Local Development & Testing

When the local environment is running, the prerequisites are minimal:

| Item | Value / Where to Find |
|------|----------------------|
| **Local CM URL** | `https://xmcloudcm.localhost/` (Docker-based, from VXA `local-containers/`) |
| **Local Authoring GraphQL endpoint** | `https://xmcloudcm.localhost/sitecore/api/authoring/graphql/v1/` |
| **Sitecore admin credentials** | From `local-containers/.env` (typically `admin` / `b` for local) |
| **Site name** | Whatever was configured during local site setup (in `.env.container.example`: `NEXT_PUBLIC_DEFAULT_SITE_NAME`) |
| **Local Sitecore API key** | From `local-containers/.env` (used for `NEXT_PUBLIC_SITECORE_API_KEY`) |
| **Client website URL** | The target site to mirror — provided per run |

For local testing, **no cloud credentials needed** — no Context ID, no automation client, no Vercel. The Next.js app runs on `localhost:3000` and reads from the local CM via the Layout Service API.

**mcp-sitecore-server config for local:**
```json
"Sitecore": {
  "type": "stdio",
  "command": "npx",
  "args": ["@antonytm/mcp-sitecore-server@latest"],
  "env": {
    "TRANSPORT": "stdio",
    "GRAPHQL_ENDPOINT": "https://xmcloudcm.localhost/sitecore/api/authoring/graphql/v1/",
    "GRAPHQL_SCHEMAS": "master",
    "GRAPHQL_API_KEY": "<local-api-key>",
    "ITEM_SERVICE_SERVER_URL": "https://xmcloudcm.localhost/",
    "ITEM_SERVICE_USERNAME": "admin",
    "ITEM_SERVICE_PASSWORD": "b"
  }
}
```

---

### Phase 2 — Cloud SitecoreAI Deployment (Client Demo)

These are needed when deploying the generated POC to a real SitecoreAI environment for a client-facing demo.

**In SitecoreAI Portal** — dependency order matters:

| # | What | Where | Notes |
|---|------|--------|-------|
| 1 | **Organization** | Sitecore Cloud Portal | Already exists if you have portal access |
| 2 | **Project** | Cloud Portal → Deploy app | Named container for environments (e.g. "Velir POC Demos"). One-time setup. |
| 3 | **Environment** | Cloud Portal → Deploy app → create environment | Provisions the CM instance + Edge tenant. Takes a few minutes. Reuse one shared demo environment OR create per-client — TBD decision. |
| 4 | **VXA deployed to the environment** | `dotnet sitecore ser push` + `dotnet sitecore publish --pt Edge` | All VXA templates/renderings/layouts must be deployed before content can be created. One-time per environment. |
| 5 | **Site Collection + Site item** | Created in the CM or via CLI | Content tree container for pages. Must exist before any page items can be created. |
| 6 | **Preview Context ID** | Cloud Portal → your environment → Context IDs | Used in Vercel env var (`SITECORE_EDGE_CONTEXT_ID`). The Preview ID includes unpublished content — use during generation. |
| 7 | **Cloud CM URL** | Cloud Portal → your environment | Format: `https://xmcloudcm-<id>.sitecorecloud.io` |
| 8 | **Automation client credentials** | Cloud Portal → organization → Automation clients | Client ID + Secret for non-interactive CLI login (`dotnet sitecore login --client-credentials true ...`). Needed for automated publish. |
| 9 | **Authoring GraphQL API key** | CM instance → API key item in Sitecore | For `createItem`/`updateItem` calls via mcp-sitecore-server. |

**In Vercel Portal:**

| # | What | Where | Notes |
|---|------|--------|-------|
| 1 | **Team** | vercel.com | Note the **team slug** (Settings → General) |
| 2 | **Project connected to VXA repo** | Vercel → New Project → import repo | Root directory: `headapps/nextjs-content-sdk`. Note the **project slug**. |
| 3 | **Environment variables** | Vercel project → Settings → Environment Variables | `SITECORE_EDGE_CONTEXT_ID` (Preview Context ID) + `NEXT_PUBLIC_DEFAULT_SITE_NAME` (site name from step 5) |
| 4 | **Deploy hook URL** | Vercel project → Settings → Git → Deploy Hooks | Registers with Experience Edge so publishing auto-triggers a Vercel rebuild. |
| 5 | **Vercel MCP authenticated** | VS Code → MCP: List Servers → Vercel → authorize | One-time OAuth. Enables `deploy_to_vercel`, `get_deployment_build_logs`, etc. |

---

### Summary: What to Collect Before a Cloud Demo Run

| Item | Where to Find It |
|------|-----------------|
| Client website URL | Sales/BD team |
| Cloud CM instance URL | Cloud Portal → environment |
| Preview Context ID | Cloud Portal → environment → Context IDs |
| Site name | Agreed on during environment setup |
| Automation client ID + secret | Cloud Portal → organization → Automation clients |
| Authoring GraphQL API key | CM instance |
| Vercel team slug | Vercel → team Settings → General |
| Vercel project slug | Vercel → project Settings → General |
| Vercel deploy hook URL | Vercel → project Settings → Git → Deploy Hooks |

---

### Open Design Decision: Shared vs. Per-Client Demo Environment

- **Shared environment:** VXA deployed once, reused for every client demo. Faster and cheaper. Content from previous demos visible unless cleaned up. Better for rapid iteration.
- **Per-client environment:** Fresh SitecoreAI environment per prospect. Clean isolation. Slower to stand up (~minutes) and has cost implications. Could be powerful as a leave-behind ("here's your actual Sitecore environment").

---

## Developer Workflow (End-to-End)

A developer kicks off this process locally in VS Code. The AI agent runs in their editor — hitting Sitecore and Vercel APIs remotely. The developer iterates, then shares a protected link with the client.

### Stage 1 — Develop & Iterate (developer-facing)

```
Developer runs VS Code agent locally
         ↓
Agent analyzes client's public website URL
         ↓
Agent creates/updates content in SitecoreAI cloud CM
  (via mcp-sitecore-server → Authoring GraphQL API)
         ↓
Developer previews result at Vercel Preview URL
  (auto-rebuilds triggered by publish → Experience Edge → Vercel webhook)
         ↓
Iterate: tweak prompts / remap components / adjust theme → regenerate
```

> **Local Docker CM is optional here.** The developer runs the VS Code agent locally, but the agent targets the cloud CM directly. No local Sitecore environment is required for this workflow — just VS Code + MCP servers configured + Sitecore CLI for publishing.
>
> **If a developer already has local containers running,** they can choose to generate locally first for faster iteration (no publish latency), then re-run the agent targeting the cloud CM when ready. The cleanest path is just re-running the generator pointed at cloud rather than trying to migrate local content.

### Stage 2 — Client Demo Delivery

```
Developer happy with the result
         ↓
Publish content to Experience Edge
  (dotnet sitecore publish --pt Edge  OR  use mcp-sitecore-server Common publish tools)
         ↓
Vercel auto-rebuilds via deploy hook webhook (no manual Vercel push needed)
         ↓
Developer generates protected client link via Vercel
         ↓
Shares link with prospect
```

**Important:** "Pushing to Vercel" does not mean deploying the Next.js app — VXA code is already deployed. What triggers a Vercel rebuild is publishing content in Sitecore (→ Experience Edge → deploy hook → Vercel rebuilds with new content). The developer does not need to touch Vercel directly in most cases.

### Protected Client Link

Vercel has two mechanisms depending on plan:
- **Deployment Protection (default on Pro/Enterprise):** Vercel Preview URLs require the viewer to have a Vercel account and be a team member. Not suitable for sharing with a client.
- **Password Protection (Pro/Enterprise):** A developer-set password gates the deployment. Anyone with the URL + password can view — no Vercel account needed. This is the right mechanism for client demos.
- **`get_access_to_vercel_url` (Vercel MCP tool):** Generates a time-limited shareable link that bypasses protection. Could be used to send a client a self-expiring link without giving them the password.

> **Action item:** Confirm Vercel plan (Pro/Enterprise) supports Password Protection for the team account.

### Iteration Model

The agent needs a deliberate strategy for re-runs:
- **Clean + regenerate:** Delete all previously generated content items (`deleteItem`) then recreate from scratch. Safest for full re-runs.
- **Update in place:** Use `updateItem` to patch field values on existing items. Faster for content tweaks, but can leave stale items if the page structure changes.
- **Recommendation:** Support both modes — flag in the agent invocation. Default to clean + regenerate for initial POC; offer update-in-place for minor content tweaks.

### Screenshot Validation & Automatic Iteration

After Vercel rebuilds, the agent performs a visual diff loop using AI vision:

```
Take screenshots of client's original pages (Playwright)
         ↓
Generate POC → Vercel rebuilds
         ↓
Take screenshots of generated POC pages (Playwright or web_fetch_vercel_url)
         ↓
AI vision comparison:
  - Layout structure (section count, section order)
  - Color palette fidelity
  - Content density
  - Rendering errors (blank sections, broken images, wrong colors)
         ↓
Agent produces structured diff report:
  "Homepage: client has 6 sections, POC has 4 — missing: testimonials block, stats bar"
         ↓
Developer reviews diff → directs agent to fix specific gaps → re-run targeted sections
```

The comparison is structural and tonal — not pixel-perfect. AI vision is well-suited to: "Does this feel like the same brand? Does the page flow match?" This surfaces gaps the developer would otherwise have to find manually and makes iterations targeted rather than guesswork.

### Component Gap Handling

**When no VXA component covers a section:**
1. **Nearest neighbor + flag** (default): Pick the closest VXA component, populate it as well as possible, add the section to the gap report. Developer reviews flags in the iteration phase.
2. **Generic fallback**: Container + Rich Text absorbs almost anything at low fidelity — always produces something, never breaks.
3. **Skip + document**: For truly unique interactive sections (calculators, maps, live feeds) — skip and note in the report. POC is not a pixel-perfect replica.

The agent should never halt on a gap. It always produces output and surfaces gaps as a report.

**When a VXA component is close but has a slightly different content model:**

The template fields are fixed — they cannot be extended without modifying VXA serialized items and redeploying. Strategies:
- **Drop the extra fields**: Client's hero has a subtitle, VXA Hero doesn't — fold it into Body or drop it. Acceptable POC fidelity.
- **Repurpose adjacent fields**: VXA templates often have optional/secondary fields (eyebrow text, secondary CTA, etc.) that can absorb extra content.
- **Use a different VXA component**: Sometimes a different component has the right field shape even if it renders slightly differently.

The field mapping ruleset (component → which source fields map to which template fields, what gets dropped) must be explicit and developer-reviewable. Repeated gaps across clients signal a candidate for extending VXA.

### POC Scope — Tiered Model

The agent targets a defined scope per run. Start at Tier 1 for the initial build.

| Tier | Pages | Use case |
|---|---|---|
| **Tier 1 — POC** | Homepage only | First run, proving the concept, validating mapping rules |
| **Tier 2 — Lite demo** | Homepage + 1 interior page + nav | Shows navigation and page hierarchy |
| **Tier 3 — Full demo** | Homepage + 3–4 interior pages + nav/footer | Compelling for serious pre-sales engagement |

Same agent, same process — scope is just a parameter. After a Tier 1 succeeds, the developer can say "now add the About page" and the agent extends the existing site.

**Resolved: initial scope = Tier 1 (homepage only).** This validates the full pipeline with minimum risk before scaling.

---

Based on docs research, the generation pipeline has two viable approaches:

### Option A — Live API Assembly (preferred for agent workflow)
```
Client Website URL
      ↓
[Scraper/Analyzer Agent]
  - Crawl pages, extract: nav structure, content blocks, color/font/imagery patterns
      ↓
[Mapping Agent]
  - Map page sections → VXA/SXA components (Hero→Promo, Nav→Navigation, etc.)
  - Generate AI-written, client-flavored content for each component
      ↓
[Sitecore Assembly Agent] (via Authoring GraphQL API + mcp-sitecore-server)
  - createItem() for each page and datasource item
  - presentation-add-rendering-by-path() to wire up layouts and components
  - dotnet sitecore publish --pt Edge to push to Experience Edge
      ↓
[Vercel Auto-Rebuild] (triggered via deploy hook, no manual push needed)
  - Experience Edge fires deploy hook → Vercel rebuilds automatically
  - web_fetch_vercel_url verifies pages rendered correctly
  - deploy_to_vercel available if a forced re-deploy is ever needed
```

### Option B — Offline Serialization (bulk content load)
```
[Same scraper/mapping steps]
      ↓
[Content Generator] — produces .yml SCS serialization files offline
      ↓
dotnet sitecore ser push → dotnet sitecore publish --pt Edge
      ↓
[Vercel Deploy]
```

**Recommendation:** Option A (live API) is better suited to an AI agent workflow — it's interactive, observable, and doesn't require a local Sitecore environment. Option B could be a faster bulk-load path for large content sets or for pre-seeding a fresh environment.

---

## Key Decisions

| Date | Decision | Notes |
|------|----------|-------|
| 2026-03-28 | Project initiated | Planning phase |
| 2026-03-28 | Target stack is SitecoreAI (XM Cloud) + JSS/Next.js + Vercel | SitecoreAI is the new XM Cloud branding; legacy XM/XP explicitly out of scope |
| 2026-03-28 | Will use community `mcp-sitecore-server` for Sitecore operations | No first-party operational MCP exists; GraphQL Authoring API confirmed available on XM Cloud |
| 2026-03-28 | Primary content creation API: Sitecore Authoring & Management GraphQL API | Supports createItem/updateItem mutations natively in SitecoreAI |
| 2026-03-28 | VXA repo analyzed — 33 custom components, CSS variable theming, Content SDK (not legacy JSS) | Theming is fully config-driven via `--vxa-*` CSS vars; no code changes needed for brand customization |
| 2026-03-28 | Theming approach: AI writes `tokens.json` → `TokenSync` CLI generates theme CSS | No need to edit component code for client branding |
| 2026-03-29 | Initial POC scope = homepage only (Tier 1) | Validates full pipeline; scales to more pages per run via scope parameter |
| 2026-03-29 | Component gap strategy: nearest-neighbor + flag, never halt | Agent always produces output; gaps surfaced in a report for developer review |
| 2026-03-29 | Content model mismatch strategy: drop/repurpose fields, no template extension | Template fields are fixed; mapping ruleset handles field-level decisions per component |
| 2026-03-29 | Validation approach: screenshot diff via AI vision | Playwright screenshots of client site + POC → structural/tonal comparison → targeted iteration |
| 2026-03-29 | Shared demo environment (not per-client) | Limited environment availability; VXA deployed once, content cleaned between POC runs |
| 2026-03-29 | Password protection deferred | Not needed for initial POC — not what we are proving |
| 2026-03-29 | Theming deferred | First agent run will prove core content + assembly pipeline; theming added after |

---

## Open Questions

- ~~What does VXA provide?~~ **Resolved: 33 VXA components (hero, promo, nav, listings, containers, etc.) + Headless SXA OOTB components. Content SDK-based Next.js. CSS variable theming. See VXA inventory section above.**
- ~~What are the VXA template IDs?~~ **Partially resolved: top-level folder IDs confirmed. Need to drill into individual component datasource template IDs (Hero, Promo, Container fields) from the serialized .yml files — next step.**
- What is the expected fidelity? (Pixel-perfect vs. "spirit of the brand")
- ~~How many pages minimum for a convincing POC?~~ **Resolved: Tier 1 = homepage only. Tiers 2–3 scale from there. See Scope — Tiered Model.**
- ~~Is the target always XM Cloud, or sometimes XP/XM on-prem?~~ **Resolved: SitecoreAI (XM Cloud) only. No legacy platforms.**
- Does the generated POC stay in a shared demo environment, or is it spun up fresh per client?
- Is there a review/approval step before showing the client, or is it meant to be fully automated?
- What client data is safe to ingest? (Public website only, or can we accept provided assets?)
- Does SPE (PowerShell Remoting) need to be enabled on the SitecoreAI CM? Or can we rely on Authoring GraphQL API alone?

---

## Proposed Phases / Roadmap

_To be refined once VXA repo is reviewed._

1. **Phase 0 — Foundation:** ✅ VXA repo analyzed; component inventory done; template folder IDs captured; architecture understood. _Remaining: extract field-level template IDs from `.yml` files; validate Presentation tools on XM Cloud; validate theme injection path._
2. **Phase 1 — Ingestion:** Crawl client URL (Playwright); extract nav structure, section patterns, brand tokens (colors, fonts). Produce structured page-section inventory.
3. **Phase 2 — Mapping:** Apply component mapping ruleset (section pattern → VXA component → field mapping). Generate AI-written, client-flavored content per field. Flag gaps.
4. **Phase 3 — Assembly:** `createItem()` for each page + datasource item via Authoring GraphQL API. Wire layouts and renderings via mcp-sitecore-server Presentation tools. Publish to Experience Edge.
5. **Phase 4 — Validate & Iterate:** Playwright screenshots of client site + POC. AI vision structural diff. Agent-generated gap report. Developer-directed targeted fixes. Re-publish. Repeat.
6. **Phase 5 — Deliver:** Generate password-protected Vercel link (or time-limited shareable link via Vercel MCP). Share with client.

---

## Next Steps

### Resolved
- [x] Gain access to VXA repo and review component library + content models
- [x] Define the "minimum viable POC" scope → Homepage only (Tier 1)
- [x] Choose primary generation approach → Option A (live Authoring GraphQL API)
- [x] Define component gap strategy → nearest-neighbor + flag, never halt
- [x] Define iteration approach → screenshot diff + AI vision

### Must resolve before building the agent (blockers)
- [ ] **Extract field-level template IDs from VXA `.yml` files** — `authoring/items/items/templatesFeature/` — need Hero, Promo, Container, Navigation, Rich Text field names + types. Required for all `createItem()` calls. _(Todo #2)_
- [ ] **Validate mcp-sitecore-server Presentation tools on XM Cloud** — `presentation-add-rendering-by-path` was built for classic Sitecore; must confirm it works against XM Cloud CM before relying on it for page assembly. _(Todo #1)_
- [ ] **Decide: shared vs. per-client demo environment** — affects everything about environment setup and cleanup strategy

---

## Site Contexts

Active site-specific context files live in `docs/sites/`. Each file contains environment constants, completed pages, theming status, and client-specific decisions.

| Site | File |
|---|---|
| Velir (velir.com) | [docs/sites/velir.md](sites/velir.md) |

> To start a new client site, copy `docs/sites/SITE.template.md` to `docs/sites/{client}.md` and fill in the details during Phase 0.
- [ ] **Confirm Vercel plan supports Password Protection** — required for client-shareable links

### Should resolve before agent is production-ready (non-blockers for initial build)
- [ ] **Validate theme file injection path** — does writing a theme CSS file get picked up on Vercel rebuild, or does it require a git commit? _(Todo #3)_
- [ ] **Confirm Authoring GraphQL API access on target SitecoreAI instance** — check playground URL is accessible + API key auth works
- [ ] **Determine SPE availability on XM Cloud CM** — if unavailable, remove SPE-dependent mcp-sitecore-server tools from agent's toolset
- [ ] **Choose client site ingestion approach** — Playwright crawl (handles JS-heavy SPAs) vs. fetch + parse HTML (simpler, faster). Playwright recommended as default.
- [ ] **Decide: cloud-direct vs. local-first workflow** — for documentation and onboarding purposes; cloud-direct is the recommended default
