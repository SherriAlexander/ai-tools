<#
.SYNOPSIS
    Smoke test for the Sitecore Authoring GraphQL API.

.DESCRIPTION
    Runs five checks against the Authoring GraphQL endpoint to confirm auth,
    read, create, update, and delete operations are all working before starting
    a POC generation run. Creates a temporary item and cleans it up on completion.

.PARAMETER CmUrl
    Base URL of the Sitecore CM instance, e.g. https://xmc-yourorg-yourproject-abc123.sitecorecloud.io
    No trailing slash. XM Cloud URLs follow the pattern xmc-<org>-<project>-<env>.sitecorecloud.io — NOT xmcloudcm-*.

.PARAMETER ApiKey
    Raw Authoring GraphQL API key (Bearer token). Do NOT include the word "Bearer".

.PARAMETER ReadItemPath
    Sitecore path to use for the read test. Defaults to /sitecore/content.

.PARAMETER CreateParentPath
    Sitecore path under which the temporary test item will be created.
    Defaults to /sitecore/content. Must already exist.

.PARAMETER SkipCertificateCheck
    Bypass SSL certificate validation. Use for local Docker environments only.

.EXAMPLE
    .\Invoke-SitecoreSmoke.ps1 `
        -CmUrl "https://xmc-yourorg-yourproject-abc123.sitecorecloud.io" `
        -ApiKey "eyJ..."

.EXAMPLE
    .\Invoke-SitecoreSmoke.ps1 `
        -CmUrl "https://xmcloudcm.localhost" `
        -ApiKey "local-api-key" `
        -SkipCertificateCheck
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CmUrl,

    [Parameter(Mandatory = $true)]
    [string]$ApiKey,

    [string]$ReadItemPath = "/sitecore/content",

    [string]$CreateParentPath = "/sitecore/content",

    [switch]$SkipCertificateCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Endpoint = "$CmUrl/sitecore/api/authoring/graphql/v1"
$Headers   = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type"  = "application/json"
}

# Template: VXA Rich Text (known-good, minimal field set)
$TestTemplateid = "82462949f3754363a4e21224f16f7311"
$TestItemName   = "SmokeTest-Temp-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"

$CreatedItemId  = $null
$PassCount      = 0
$FailCount      = 0

# -----------------------------------------------------------------------
# Helper
# -----------------------------------------------------------------------
function Invoke-Gql {
    param(
        [string]$Label,
        [string]$Query,
        [hashtable]$Variables = @{}
    )

    $body = @{ query = $Query; variables = $Variables } | ConvertTo-Json -Depth 10 -Compress

    $invokeParams = @{
        Uri     = $Endpoint
        Method  = "POST"
        Headers = $Headers
        Body    = $body
    }

    if ($SkipCertificateCheck) {
        $invokeParams["SkipCertificateCheck"] = $true
    }

    try {
        $response = Invoke-RestMethod @invokeParams
    }
    catch {
        return [PSCustomObject]@{ Success = $false; Data = $null; Error = $_.Exception.Message }
    }

    if ($response.PSObject.Properties['errors'] -and $response.errors) {
        $msg = ($response.errors | ForEach-Object { $_.message }) -join "; "
        # $response.data may be absent on error responses (valid per GraphQL spec); use $null to
        # avoid StrictMode throwing "property 'data' cannot be found".
        return [PSCustomObject]@{ Success = $false; Data = $null; Error = $msg }
    }

    return [PSCustomObject]@{ Success = $true; Data = $response.data; Error = $null }
}

function Write-Pass([string]$label, [string]$detail = "") {
    $script:PassCount++
    $suffix = if ($detail) { " — $detail" } else { "" }
    Write-Host "  [PASS] $label$suffix" -ForegroundColor Green
}

function Write-Fail([string]$label, [string]$detail = "") {
    $script:FailCount++
    $suffix = if ($detail) { " — $detail" } else { "" }
    Write-Host "  [FAIL] $label$suffix" -ForegroundColor Red
}

# -----------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "Sitecore Authoring GraphQL Smoke Test" -ForegroundColor Cyan
Write-Host "Endpoint : $Endpoint"
Write-Host "Run time : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ("-" * 60)

# T1 — Auth: currentUser
Write-Host ""
Write-Host "T1  Auth — currentUser query" -ForegroundColor Yellow
$t1 = Invoke-Gql -Label "T1" -Query "query { currentUser { name } }"
if ($t1.Success -and $t1.Data.currentUser.name) {
    Write-Pass "currentUser" "logged in as: $($t1.Data.currentUser.name)"
} else {
    Write-Fail "currentUser" $(if ($t1.Error) { $t1.Error } else { "No user data returned" })
}

# T2 — Read: item by path (known-good path)
Write-Host ""
Write-Host "T2  Read — item by path ($ReadItemPath)" -ForegroundColor Yellow
$readQuery = @"
query(`$path: String!) {
  item(where: { database: "master", path: `$path }) {
    itemId
    name
    path
    fields { nodes { name value } }
  }
}
"@
$t2 = Invoke-Gql -Label "T2" -Query $readQuery -Variables @{ path = $ReadItemPath }
$CreateParentId = $null
if ($t2.Success -and $t2.Data.item.path) {
    if ($ReadItemPath -eq $CreateParentPath) { $CreateParentId = $t2.Data.item.itemId }
    Write-Pass "Read item" "path=$($t2.Data.item.path), name=$($t2.Data.item.name)"
} else {
    Write-Fail "Read item" $(if ($t2.Error) { $t2.Error } else { "Item not found at $ReadItemPath" })
}

# T3 — Create: temporary test item
Write-Host ""
Write-Host "T3  Create — temporary VXA Rich Text item under $CreateParentPath" -ForegroundColor Yellow
if (-not $CreateParentId) {
    $parentLookup = Invoke-Gql -Label "T3-parent" -Query 'query($path:String!){item(where:{database:"master",path:$path}){itemId}}' -Variables @{ path = $CreateParentPath }
    if ($parentLookup.Success) { $CreateParentId = $parentLookup.Data.item.itemId }
}
$createMutation = @"
mutation(`$input: CreateItemInput!) {
  createItem(input: `$input) {
    item { itemId name path }
  }
}
"@
$createVars = @{
    input = @{
        name       = $TestItemName
        templateId = $TestTemplateid
        parent     = $CreateParentId
        language   = "en"
        fields     = @(@{ name = "text"; value = "<p>Smoke test - safe to delete</p>" })
    }
}
$t3 = Invoke-Gql -Label "T3" -Query $createMutation -Variables $createVars
if ($t3.Success -and $t3.Data.createItem.item.itemId) {
    $CreatedItemId = $t3.Data.createItem.item.itemId
    Write-Pass "Create item" "itemId=$CreatedItemId, path=$($t3.Data.createItem.item.path)"
} else {
    Write-Fail "Create item" $(if ($t3.Error) { $t3.Error } else { "No itemId returned" })
}

# T4 — Update: modify the field value we just created
Write-Host ""
Write-Host "T4  Update — patch text field on created item" -ForegroundColor Yellow
if ($CreatedItemId) {
    $updateMutation = @"
mutation(`$input: UpdateItemInput!) {
  updateItem(input: `$input) {
    item { itemId fields { nodes { name value } } }
  }
}
"@
    $updateVars = @{
        input = @{
            itemId   = $CreatedItemId
            language = "en"
            fields   = @(@{ name = "text"; value = "<p>Smoke test - updated</p>" })
        }
    }
    $t4 = Invoke-Gql -Label "T4" -Query $updateMutation -Variables $updateVars
    if ($t4.Success -and $t4.Data.updateItem.item.itemId) {
        $updatedField = $t4.Data.updateItem.item.fields.nodes | Where-Object { $_.name -eq "text" }
        Write-Pass "Update item" "text=$($updatedField.value)"
    } else {
        Write-Fail "Update item" $(if ($t4.Error) { $t4.Error } else { "Update returned no item" })
    }
} else {
    Write-Fail "Update item" "Skipped — no item was created in T3"
}

# T5 — Verify: re-read the item and confirm updated value
Write-Host ""
Write-Host "T5  Verify — re-read item and confirm field value" -ForegroundColor Yellow
if ($CreatedItemId) {
    $verifyQuery = @"
query(`$id: ID!) {
  item(where: { database: "master", itemId: `$id }) {
    name
    fields { nodes { name value } }
  }
}
"@
    $t5 = Invoke-Gql -Label "T5" -Query $verifyQuery -Variables @{ id = $CreatedItemId }
    if ($t5.Success -and $t5.Data.item.name) {
        $verifiedField = $t5.Data.item.fields.nodes | Where-Object { $_.name -eq "text" }
        $expected = "<p>Smoke test - updated</p>"
        if ($verifiedField.value -eq $expected) {
            Write-Pass "Verify field" "value matches expected"
        } else {
            Write-Fail "Verify field" "expected '$expected', got '$($verifiedField.value)'"
        }
    } else {
        Write-Fail "Verify field" $(if ($t5.Error) { $t5.Error } else { "Could not re-read item" })
    }
} else {
    Write-Fail "Verify field" "Skipped — no item was created in T3"
}

# -----------------------------------------------------------------------
# Cleanup — delete the temp item regardless of test outcomes
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "Cleanup — deleting temporary test item" -ForegroundColor Yellow
if ($CreatedItemId) {
    $deleteMutation = @"
mutation(`$input: DeleteItemInput!) {
  deleteItem(input: `$input) { successful }
}
"@
    $del = Invoke-Gql -Label "Cleanup" -Query $deleteMutation -Variables @{
        input = @{ itemId = $CreatedItemId; permanently = $true }
    }
    if ($del.Success -and $del.Data.deleteItem.successful) {
        Write-Host "  [OK]   Temp item deleted (itemId=$CreatedItemId)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [WARN] Could not delete temp item (itemId=$CreatedItemId) — delete manually" -ForegroundColor DarkYellow
        Write-Host "         Path would be: $CreateParentPath/$TestItemName" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  [OK]   No temp item to clean up" -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
Write-Host ""
Write-Host ("-" * 60)
$total = $PassCount + $FailCount
if ($FailCount -eq 0) {
    Write-Host "Result: PASS ($PassCount/$total tests passed)" -ForegroundColor Green
} else {
    Write-Host "Result: FAIL ($PassCount/$total tests passed, $FailCount failed)" -ForegroundColor Red
}
Write-Host ""
