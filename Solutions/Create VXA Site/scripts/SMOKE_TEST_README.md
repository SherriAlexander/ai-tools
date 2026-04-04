# Sitecore Authoring GraphQL Smoke Test

**Script:** `Invoke-SitecoreSmoke.ps1`  
**Purpose:** Quick health check to confirm the Sitecore Authoring GraphQL API is reachable and fully operational before starting a POC generation run.

---

## What It Tests

| Test | Operation |
|------|-----------|
| T1 | Auth — `currentUser` query (confirms token + endpoint are working) |
| T2 | Read — retrieve an item by path using the validated query shape |
| T3 | Create — `createItem` using the VXA Rich Text template |
| T4 | Update — `updateItem` patches a field value on the created item |
| T5 | Verify — re-reads the item by ID and confirms the field value matches |
| Cleanup | Deletes the temporary test item unconditionally |

The script creates one temporary item (`SmokeTest-Temp-<random>`) under `/sitecore/content` and removes it at the end regardless of test results. No persistent changes are made.

---

## Prerequisites

- **PowerShell 7+** — required for `-SkipCertificateCheck` support and `Invoke-RestMethod` behavior used in the script. Check your version: `$PSVersionTable.PSVersion`
- **Authoring GraphQL API key** — a raw Bearer token (no `Bearer` prefix). See the section below on how to get one.
- **CM instance URL** — the base URL for your Sitecore CM (cloud or local Docker).

---

## Getting an API Key

### Cloud (SitecoreAI / XM Cloud)
1. Run `dotnet sitecore cloud login` and follow the browser prompts.
2. Once logged in, open `./sitecore/user.json` in the VXA repo.
3. Copy the value of the `accessToken` property — this is your API key.

> The access token expires. If you get 401 errors, re-run `dotnet sitecore cloud login` to refresh it and copy the new `accessToken`.

### Local Docker
The authoring GraphQL API requires an OAuth **bearer token** — the same type obtained from `dotnet sitecore cloud login`. The delivery API keys in `local-containers/.env` (`SITECORE_API_KEY`, `NEXT_PUBLIC_SITECORE_API_KEY`) are Sitecore item GUIDs used for the Experience/Delivery GraphQL API and will **not** work here.

To get a bearer token for local Docker, log in with the Sitecore CLI pointed at your local environment:

```powershell
dotnet sitecore login --ref local
```

Then copy the `accessToken` from `./sitecore/user.json`. Local tokens do not expire while the container is running.

> If your local CLI environment is not configured, you may need to add it first: `dotnet sitecore env add --name local --cm https://xmcloudcm.localhost --allow-write true`

> **Note:** The authoring GraphQL endpoint (`/sitecore/api/authoring/graphql/v1`) is only available if the Sitecore GraphQL Authoring module is installed and enabled in your Docker image. If you get a 404, verify the module is included in your `cm` Dockerfile and that the endpoint is registered.

---

## Running the Script

### Cloud environment
```powershell
.\scripts\Invoke-SitecoreSmoke.ps1 `
    -CmUrl "https://xmc-yourorg-yourproject-abc123.sitecorecloud.io" `
    -ApiKey "eyJ..."
```

### Local Docker environment
```powershell
.\scripts\Invoke-SitecoreSmoke.ps1 `
    -CmUrl "https://xmcloudcm.localhost" `
    -ApiKey "your-local-api-key" `
    -SkipCertificateCheck
```

> `-SkipCertificateCheck` bypasses SSL validation. Use for local Docker only — never against a cloud instance.

### Optional parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `-ReadItemPath` | `/sitecore/content` | Sitecore path used for the T2 read test. Change if `/sitecore/content` doesn't exist in your environment. |
| `-CreateParentPath` | `/sitecore/content` | Parent path under which the temporary test item is created. Must already exist. |

---

## Expected Output

```
Sitecore Authoring GraphQL Smoke Test
Endpoint : https://xmc-yourorg-yourproject-abc123.sitecorecloud.io/sitecore/api/authoring/graphql/v1
Run time : 2026-03-30 14:22:01
------------------------------------------------------------

T1  Auth — currentUser query
  [PASS] currentUser — logged in as: admin

T2  Read — item by path (/sitecore/content)
  [PASS] Read item — path=/sitecore/content, name=content

T3  Create — temporary VXA Rich Text item under /sitecore/content
  [PASS] Create item — itemId={...}, path=/sitecore/content/SmokeTest-Temp-a1b2c3d4

T4  Update — patch text field on created item
  [PASS] Update item — text=<p>Smoke test — updated</p>

T5  Verify — re-read item and confirm field value
  [PASS] Verify field — value matches expected

Cleanup — deleting temporary test item
  [OK]   Temp item deleted (itemId={...})

------------------------------------------------------------
Result: PASS (5/5 tests passed)
```

---

## Troubleshooting Common Failures

| Failure | Likely cause | Fix |
|---------|-------------|-----|
| T1 FAIL — 401 / Unauthorized | Token expired or wrong value | Re-run `dotnet sitecore cloud login`, copy fresh `accessToken` from `user.json` |
| T1 FAIL — wrong API key type | Used a delivery key (`NEXT_PUBLIC_SITECORE_API_KEY` / `SITECORE_API_KEY`) instead of a bearer token | See **Getting an API Key** — the authoring API needs a CLI bearer token, not a Sitecore item GUID |
| T1 FAIL — 404 Not Found | Wrong CM URL or endpoint path | Verify `-CmUrl` — the script appends `/sitecore/api/authoring/graphql/v1` automatically. Cloud URLs follow the pattern `xmc-<org>-<project>-<env>.sitecorecloud.io` |
| T1 FAIL — 404 on local Docker | Authoring GraphQL module not installed/enabled | Confirm the GraphQL Authoring module is in your `cm` Dockerfile and the endpoint is registered; this endpoint is separate from the delivery/experience GraphQL |
| T2 FAIL — Item not found | `-ReadItemPath` doesn't exist in master DB | Use a path that exists, e.g. `/sitecore/content/<your-site>` |
| T3 FAIL — Template not found | VXA hasn't been deployed to this environment | Run `dotnet sitecore ser push` from the VXA repo first |
| T3 FAIL — Parent not found | `-CreateParentPath` doesn't exist | Use an existing path as `-CreateParentPath` |
| SSL errors (local only) | Self-signed cert on Docker CM | Add `-SkipCertificateCheck` |
| Cleanup WARN — item not deleted | `deleteItem` mutation signature mismatch | Delete the `SmokeTest-Temp-*` item manually in Sitecore; report the mutation error so the script can be updated |

---

## Background

The Authoring GraphQL endpoint has a specific query shape that differs from common examples. These are the validated patterns this script uses — keep them as the reference when writing other GraphQL operations against this environment:

- **Endpoint:** `/sitecore/api/authoring/graphql/v1` (no schema suffix — `/v1/master` returns 404)
- **Item query by path:** `item(where: { database: "master", path: "..." })`
- **Item query by ID:** `item(where: { database: "master", itemId: "..." })`
- **Field access:** `fields { nodes { name value } }`
- **Auth header:** `Authorization: Bearer <token>` — pass raw token to `-ApiKey`, no `Bearer` prefix
