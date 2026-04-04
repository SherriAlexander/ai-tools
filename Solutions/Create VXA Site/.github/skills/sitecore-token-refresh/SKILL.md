---
name: sitecore-token-refresh
description: 'Refresh the Sitecore XM Cloud CM access token and optionally re-run the build script. Use when: token is expired, getting 401 errors, script fails with auth errors, need to refresh sitecore token, re-authenticate sitecore, token expired, run build script.'
argument-hint: 'Optional: also run build script after refreshing'
---

# Sitecore Token Refresh

## When to Use
- 401 / Unauthorized errors from Authoring GraphQL
- Build script fails mid-run with auth errors
- Starting a new session and the stored token may have expired (CM tokens expire in 15 min)
- Any time you need a fresh token before running a script

## Token Facts
- **CM token** (`endpoints.xmCloud.accessToken` in `.sitecore/user.json`): expires in **15 minutes**
- **Scope:** Authoring GraphQL mutations (`/sitecore/api/authoring/graphql/v1`)
- Client-credentials token refresh only works when `clientSecret` is present in `user.json` (CI/automation). Browser-auth sessions do not store the secret.

---

## Procedure

### Step 1 — Try client-credentials refresh (non-interactive)

Run this first. If `user.json` has a `clientSecret`, it will succeed silently.

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
$ep = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud
$body = "client_id=$([uri]::EscapeDataString($ep.clientId))" +
        "&client_secret=$([uri]::EscapeDataString($ep.clientSecret))" +
        "&audience=$([uri]::EscapeDataString($ep.audience))" +
        "&grant_type=client_credentials"
$result = Invoke-RestMethod -Method POST -Uri "$($ep.authority)/oauth/token" `
    -ContentType "application/x-www-form-urlencoded" -Body $body
$TOKEN = $result.access_token
Write-Host "Token acquired (expires_in=$($result.expires_in)s)" -ForegroundColor Green
```

If this succeeds (no error), skip to Step 3.

### Step 2 — Browser login (fallback)

If Step 1 fails with `client_secret is required`, the session was established via browser. **Run this command yourself — do NOT ask the user to do it:**

```powershell
dotnet sitecore cloud login
```

A browser window opens for the user to complete. **Do not ask the user to confirm — poll automatically** by watching `user.json` for a token change (1-second intervals, up to 120 seconds):

```powershell
$oldToken = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud.accessToken
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 1
    $newToken = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud.accessToken
    if ($newToken -ne $oldToken) { $TOKEN = $newToken; Write-Host "Token refreshed" -ForegroundColor Green; break }
}
if (-not $TOKEN) { throw "Browser login timed out after 120s" }
```

The user typically completes login before you would even think to ask — extract as soon as the token changes.

### Step 3 — Run the build script

Pass the fresh token explicitly (avoids re-reading the potentially-stale `user.json`):

```powershell
.\scripts\Build-VelirPocPage.ps1 -ApiKey $TOKEN
```

---

## Combined One-Liner (attempts CC before falling back to stored token)

This is what we typically run to refresh + rebuild in one go:

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
$ep = (Get-Content ".sitecore\user.json" | ConvertFrom-Json).endpoints.xmCloud
$body = "client_id=$([uri]::EscapeDataString($ep.clientId))&client_secret=$([uri]::EscapeDataString($ep.clientSecret))&audience=$([uri]::EscapeDataString($ep.audience))&grant_type=client_credentials"
$result = Invoke-RestMethod -Method POST -Uri "$($ep.authority)/oauth/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$TOKEN = if ($result.access_token) { $result.access_token } else { $ep.accessToken }
Write-Host "Token ready" -ForegroundColor Green
.\scripts\Build-VelirPocPage.ps1 -ApiKey $TOKEN
```

If the CC call fails, `$TOKEN` falls back to the stored `accessToken`. If that too is expired, you'll see 401 errors and need `dotnet sitecore cloud login`.
