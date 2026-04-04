---
name: sitecore-apply-variant
description: 'Apply a Headless Variant to a VXA component in Build-VelirPocPage.ps1. Use when: a component needs a non-default variant (image-right, animated, etc.), reversing image/text layout on a Promo, using ImageRight on a promo component, adding animated entrance on a section.'
argument-hint: 'Describe the component and which variant you want to apply (e.g. "Brooklyn Data Promo — ImageRight")'
---

# Sitecore Apply Variant

## When to Use
- A Promo section needs image on the right instead of the left → `ImageRight` variant
- A section needs animated entrance effects → `Animated` or `ImageRightAnimated` variant
- A Page Header needs the image overlaid behind the text → `ImageBehind` variant
- Any component where the default layout isn't what the design calls for

## Key Facts
- **Variants = named TSX exports.** `Default`, `ImageRight`, `Animated`, etc. are named exports in the component `.tsx` file.
- **How they activate:** Variant Definition items live at `/sitecore/content/dev-demos/standard/Presentation/Headless Variants/<ComponentName>/<VariantName>`. The active variant is selected by setting `FieldNames=%7BGUID%7D` (braced, URL-encoded) in the `s:par` layout XML attribute.
- **No FieldNames → Default.** If no `FieldNames` param is present, the `Default` export is always used.
- **Only works in `Build-VelirPocPage.ps1`.** MCP tools do not support setting rendering params; variants must be applied via the build script layout XML.
- **These components have NO variant system:** `VxaHero`, `VxaVideo`, `CTABanner`, `VxaRichText`, all containers.

---

## Variant GUID Quick Reference

> All GUIDs confirmed against live `standard` site, 2026-04-02. ✅

| Component | Variant | GUID (hyphenated) | URL-encoded for `s:par` |
|---|---|---|---|
| VxaPromo | Default | `3e5ff577-b999-49c0-8366-b651d4bdfde8` | `%7B3E5FF577-B999-49C0-8366-B651D4BDFDE8%7D` |
| VxaPromo | **ImageRight** | `65c44a3b-df9c-4f4a-bd13-12b572d4fc24` | `%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D` |
| VxaPromo | Animated | `e83ccadf-81d4-4797-ba9f-97e3381a8822` | `%7BE83CCADF-81D4-4797-BA9F-97E3381A8822%7D` |
| VxaPromo | ImageRightAnimated | `2ab11065-5ebc-46c9-bc90-83218dd30bfb` | `%7B2AB11065-5EBC-46C9-BC90-83218DD30BFB%7D` |
| VXA Multi Promo | Default | `2554a4bc-bac2-4e19-b76b-4490371d5807` | `%7B2554A4BC-BAC2-4E19-B76B-4490371D5807%7D` |
| VXA Multi Promo | Animated | `9cd60945-32fe-4d64-9896-08ee7c15db90` | `%7B9CD60945-32FE-4D64-9896-08EE7C15DB90%7D` |
| VXA Image | Default | `4d5a49f5-506a-4884-b267-2ac56b70fa8b` | `%7B4D5A49F5-506A-4884-B267-2AC56B70FA8B%7D` |
| VXA Image | Animated | `4618830a-9033-4dd9-89cc-5c6786c14a9c` | `%7B4618830A-9033-4DD9-89CC-5C6786C14A9C%7D` |
| VxaPageHeader | Default | `621cbc64-886c-47a0-ad5e-3fecd8ba300d` | `%7B621CBC64-886C-47A0-AD5E-3FECD8BA300D%7D` |
| VxaPageHeader | ImageBehind | `d72484d4-c1ad-47ad-a805-f30698b4476d` | `%7BD72484D4-C1AD-47AD-A805-F30698B4476D%7D` |
| VXA Event Header | Default | `97f82fbc-a13b-4558-871d-add8b01f0305` | `%7B97F82FBC-A13B-4558-871D-ADD8B01F0305%7D` |
| VXA Event Header | ImageBelow | `32113470-68f7-4edc-8b79-54ee9b47ef4f` | `%7B32113470-68F7-4EDC-8B79-54EE9B47EF4F%7D` |
| VXA SC Page Header | Default | `743bafc3-3f46-4997-99e6-ab59c2933d3c` | `%7B743BAFC3-3F46-4997-99E6-AB59C2933D3C%7D` |
| VXA SC Page Header | Animated | `691fb007-2ea6-487c-864c-a0cc0f9351ab` | `%7B691FB007-2EA6-487C-864C-A0CC0F9351AB%7D` |
| VXA SC Page Header | ImageBelow | `3bda9ac9-ae4a-4b91-bdee-829c2fa203cf` | `%7B3BDA9AC9-AE4A-4B91-BDEE-829C2FA203CF%7D` |
| VXA SC Page Header | ImageBelowAnimated | `6fc03008-14ed-48e4-98d8-75bbf72bd4a6` | `%7B6FC03008-14ED-48E4-98D8-75BBF72BD4A6%7D` |
| VXA Site Search | Default | `05235276-148c-41f5-8e47-a7e3c230cea4` | `%7B05235276-148C-41F5-8E47-A7E3C230CEA4%7D` |
| VXA Site Search | LoadMore | `56b3bee3-47e5-40e7-98ab-93774614673d` | `%7B56B3BEE3-47E5-40E7-98AB-93774614673D%7D` |

---

## Procedure

### Step 1 — Look up the variant GUID

Find the component and desired variant in the table above. Copy the URL-encoded value (right column) — you will paste it directly into `s:par`.

If the component/variant you need isn't in the table, query the live site:

```powershell
# Refresh token first (sitecore-token-refresh skill)
$CM = "https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io"
$ENDPOINT = "$CM/sitecore/api/authoring/graphql/v1"
$query = '{ item(path: "/sitecore/content/dev-demos/standard/Presentation/Headless Variants", language: "en") { children { nodes { name itemId children { nodes { name itemId } } } } } }'
$result = Invoke-RestMethod -Method POST -Uri $ENDPOINT `
    -Headers @{ Authorization = "Bearer $TOKEN"; "Content-Type" = "application/json" } `
    -Body (@{ query = $query } | ConvertTo-Json)
$result.data.item.children.nodes | ForEach-Object { $comp = $_.name; $_.children.nodes | ForEach-Object { [PSCustomObject]@{ Component=$comp; Variant=$_.name; Id=$_.itemId } } } | Format-Table
```

Add any new GUIDs to `VXA_COMPONENT_SPECS.md` → Headless Variants Reference.

### Step 2 — Create a variant param string in the build script

Open `scripts/Build-VelirPocPage.ps1`. Find the existing param string variables near the top (e.g. `$pp`, `$mp`, `$ct`). Add a new variable for the variant:

```powershell
# VxaPromo with ImageRight variant
$ppr = "colorScheme={0}&amp;FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"
```

Pattern: take the base param string for that component type, then insert `&amp;FieldNames=<URL-encoded-GUID>` before or after the other params.

### Step 3 — Apply the variant param to the rendering

In the layout XML string (`$layout`) inside the build script, change the rendering's `s:par` to reference the new variant param variable instead of the base one:

```powershell
# Before (Default variant):
"<r uid=`"$($uid[10])`" s:ds=`"local:/Data/Brooklyn Data Promo 1`" s:id=`"$rPromo`" s:par=`"$($pp -f 'default','10')`" s:ph=`"...`" />"

# After (ImageRight variant):
"<r uid=`"$($uid[10])`" s:ds=`"local:/Data/Brooklyn Data Promo 1`" s:id=`"$rPromo`" s:par=`"$($ppr -f 'default','10')`" s:ph=`"...`" />"
```

### Step 4 — Run the build script

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
.\scripts\Build-VelirPocPage.ps1 -ApiKey $TOKEN
```

Verify all steps complete green. Then publish:

```powershell
dotnet sitecore publish item --path '/sitecore/content/dev-demos/standard/Home' -sub -rel -n xmCloud
```

### Step 5 — Verify via screenshot

```
Tool: mcp_sitecore-mark_get_page_screenshot
Parameters:
  pageId:   9dc3828e-91a7-4e5d-a4fd-e622ea089d54
  version:  <current version number>
```

Confirm the layout change is visible (image/text order, animation, etc.).
