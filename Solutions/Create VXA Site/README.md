# AI-Powered Sitecore POC Generator

A tool that ingests a potential client's existing website and automatically generates a Sitecore POC site that mirrors their look, feel, and content structure — demonstrating rapid time-to-value using Velir's SitecoreAI quickstart/acceleration toolkit (VXA).

**Output goal:** Homepage, a couple of landing pages, sample navigation, and a few internal pages — enough to show a client "this is what your site could look like on Sitecore, and we stood it up fast."

**Primary audience:** Pre-sales / business development (demos to prospective clients).

---

## Roadmap

| Status | Step |
|--------|------|
| ✅ | Project initiated |
| ✅ | Authoring GraphQL validated as primary integration path |
| ✅ | Sitecore CLI installed and authenticated against live XM Cloud instance |
| ✅ | End-to-end smoke test passing (auth, read, create, update, verify) against `xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io` |
| ✅ | First POC page rendered — Velir.com homepage mirror live on `Home` (Hero + Multi Promo 4 cards + CTA Banner) |
| ✅ | Hero image uploaded from velir.com via `uploadMedia` mutation + `curl.exe` |
| ✅ | `Build-VelirPocPage.ps1` fully codified — idempotent, end-to-end verified |
| 🔜 | Theming handoff to Dan Solovay — `brand-velir.css` + `FontContext.tsx` for Velir blue/green/dark palette + IBM Plex Sans font |
| ⬜ | Add more homepage sections (Work, Stats, Client Logos) using existing VXA components |
| ⬜ | Define input format (client URL, brand assets, sitemap, etc.) |
| ⬜ | Inventory VXA components, templates, and content models |
| ⬜ | Design generation pipeline (client site → VXA component selection → theme tokens → content) |
| ⬜ | Build first end-to-end POC run against a real or sample client site |
| ⬜ | Deploy generated POC to Vercel via Vercel MCP |

---

## Stack

- **CMS:** SitecoreAI / XM Cloud — content authored via the Authoring GraphQL API (`/sitecore/api/authoring/graphql/v1`)
- **Front-end:** Next.js (VXA `headapps/nextjs-content-sdk`) on `@sitecore-content-sdk/nextjs`
- **Theming:** Tailwind CSS 4 + CSS custom properties (`--vxa-*`) — brand tokens flow from Figma → TokenSync CLI → theme CSS, no code changes needed per brand
- **Deployment:** Vercel (Vercel MCP available for automated deploys + log monitoring)
- **API integration tooling:** Sitecore CLI (XM Cloud plugin) for authentication

---

## Prerequisites

- .NET SDK (for Sitecore CLI)
- PowerShell 5.1+ (smoke test script)
- Access to the Velir Studios, Inc. Sitecore Cloud org

---

## Initial Setup

If setting up this project folder for the first time, run these from the project root:

```powershell
dotnet new tool-manifest
dotnet nuget add source -n Sitecore https://nuget.sitecore.com/resources/v3/index.json
dotnet tool install Sitecore.CLI
dotnet sitecore init
dotnet sitecore plugin add --name Sitecore.DevEx.Extensibility.XMCloud
```

Then authenticate:

```powershell
dotnet sitecore cloud login
```

A browser window will open. Log in and select **Velir Studios, Inc.** (the third option).

---

## Getting a Token

After `dotnet sitecore cloud login`, your token is stored at:

```
.sitecore\user.json  →  .endpoints.xmCloud.accessToken
```

To extract it in PowerShell:

```powershell
$token = (Get-Content ".\.sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud.accessToken
```

Tokens expire. If you get 401 errors, re-run `dotnet sitecore cloud login` and extract the new token.

---

## Running the Smoke Test

The smoke test confirms the Authoring GraphQL API is reachable and fully operational before starting any generation work.

```powershell
$token = (Get-Content ".\.sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud.accessToken
.\scripts\Invoke-SitecoreSmoke.ps1 `
    -CmUrl "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io" `
    -ApiKey $token
```

Expected output: **5/5 tests pass** (T1 Auth, T2 Read, T3 Create, T4 Update, T5 Verify). The script creates and deletes a temporary item — no persistent changes are made.

See [`scripts/SMOKE_TEST_README.md`](scripts/SMOKE_TEST_README.md) for full parameter reference.

---

## Docs

| File | Purpose |
|------|---------|
| [`docs/CONTEXT.md`](docs/CONTEXT.md) | Full project context, key decisions, open questions, and resource inventory |
| [`docs/SITECORE_SCRIPTING_CONVENTIONS.md`](docs/SITECORE_SCRIPTING_CONVENTIONS.md) | API and scripting gotchas (GUID formats, encoding, StrictMode, etc.) |
| [`docs/SITECORE_MCP_TEST_LESSONS_LEARNED.md`](docs/SITECORE_MCP_TEST_LESSONS_LEARNED.md) | Lessons from validating MCP and GraphQL tooling against XM Cloud |
| [`scripts/SMOKE_TEST_README.md`](scripts/SMOKE_TEST_README.md) | Smoke test usage, parameters, and local Docker instructions |
