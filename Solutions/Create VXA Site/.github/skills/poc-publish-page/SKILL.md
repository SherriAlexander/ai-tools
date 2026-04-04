---
name: poc-publish-page
description: 'Publish a POC page and its related items (datasources, media) to Sitecore Experience Edge. Applies to Home or any child page — always use the resolved target page path/ID from Phase 0, never assume Home. Use when: content looks correct in CM but the live site or screenshot is stale, needing to push changes from master to Edge, post-build-script publish, or post-MCP-update publish.'
argument-hint: 'Required: the resolved target page path from Phase 0 (e.g. /sitecore/content/dev-demos/standard/Home or /sitecore/content/dev-demos/standard/Home/who-we-are)'
---

# POC Publish Page

## When to Use
- After running `Build-VelirPocPage.ps1` to push the new layout to Edge
- After updating datasource content via MCP (`update_content`) and the live site is stale
- After adding a new section via the `poc-add-section` skill
- Screenshots in the MCP `get_page_screenshot` tool — these render from the **published** state, so the page must be published before screenshots reflect recent changes

## Important Facts
- **Always publish the resolved target page** — use the actual page path and ID from Phase 0 in all commands below. If working on a child page (e.g. `Home/who-we-are`), use that path — never default to Home unless Home is the actual target.
- **Publishing pushes from `master` to Experience Edge** — the CDN/delivery layer.
- Items must be published to show on the live site. Changes exist in CM master until then.
- The CLI environment name for this project is `xmCloud` (key in `.sitecore/user.json`).
- If the token is expired, follow the `sitecore-token-refresh` skill first.

---

## Procedure

### Option A — GraphQL publishItem Mutation (Preferred)

> **Use this every time.** The CLI publish command (`dotnet sitecore publish item`) requires a live CLI session that expires independently of the bearer token — it fails with a misleading `Make sure the GraphQL service is installed` error when expired. The GraphQL mutation uses the same bearer token as all other API calls, so it works reliably after any token refresh.

Requires a valid CM token (run `sitecore-token-refresh` skill if needed).

```powershell
$TOKEN = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud.accessToken
$CM = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io"
$ENDPOINT = "$CM/sitecore/api/authoring/graphql/v1"

# Replace rootItemPath with the resolved target page path from Phase 0:
$mutation = '{ "query": "mutation { publishItem(input: { rootItemPath: \"/sitecore/content/dev-demos/standard/Home/work\" languages: \"en\" targetDatabases: \"experienceedge\" publishItemMode: SMART publishRelatedItems: true publishSubItems: true }) { operationId } }" }'
$r = Invoke-RestMethod -Method POST -Uri $ENDPOINT `
    -Headers @{ Authorization = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
    -Body $mutation
Write-Host "Publish operationId: $($r.data.publishItem.operationId)"
```

The `operationId` is returned immediately — publishing is async. Wait ~30–60 seconds for Edge sync.

#### Verify

Wait ~30–60 seconds for Edge to propagate, then take a screenshot via MCP:

```
Tool: mcp_sitecore-mark_get_page_screenshot
Parameters:
  pageId:   <resolved target page ID from Phase 0 — NOT always the Home ID>
  version:  <item version from Phase 0 — newly created pages always start at version 1>
```

---

### Option B — CLI Publish (Fallback — unreliable in practice)

> ⚠️ **Avoid unless you are certain the CLI session is active.** Fails with `Make sure the GraphQL service is installed` (exit 1) when the CLI session has expired — this error is misleading, it means the CLI is not authenticated. Use Option A (GraphQL mutation) instead.

Use this only if you know the CLI session was recently refreshed via `dotnet sitecore cloud login`.

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
dotnet sitecore publish item --path '/sitecore/content/dev-demos/standard/Home/work' -sub -rel -n xmCloud
```

- `-sub` publishes all child items (datasource items in `/Data/`)
- `-rel` publishes all related items (media, referenced templates)
- `-n xmCloud` specifies the environment

---

### Option C — Full Site Publish via CLI

If datasources outside of Home were changed (e.g., shared items, templates):

```powershell
dotnet sitecore publish --pt Edge -n xmCloud
```

⚠️ This publishes the entire database to Edge. Use only when needed.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| CLI fails with `401 Unauthorized` | Run token refresh (sitecore-token-refresh skill), then re-run |
| CLI says `not connected to environment` | Run `dotnet sitecore cloud login --client-credentials` or `dotnet sitecore cloud login` |
| Screenshot unchanged after publish | Wait 60s and retry — Edge CDN has a propagation delay |
| `operationId` returned but live site unchanged | Publishing is async; give it 60–90 seconds |
