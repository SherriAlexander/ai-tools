---
name: poc-add-section
description: 'Add a new content section (component + populated datasource) to a Sitecore XM Cloud POC page using the MCP-first approach. Use when: adding a new section to Home, adding Multi Promo, CTA Banner, Hero, Video, Rich Text, or any non-container VXA component. Containers (Full Bleed, 50/50, etc.) cannot use this skill — they require the build script.'
argument-hint: 'Describe the section to add: component type, content, color scheme, and which container placeholder to target'
---

# POC Add Section (MCP-first)

## When to Use
- Adding a content component to an existing container on the Home page
- Populating fields on a newly added component's datasource
- Extending the POC with a new section without rewriting the entire layout

## When NOT to Use
- Adding containers (Full Bleed, 50/50, etc.) — containers have no datasource template and return 404 from MCP. Use `Build-VelirPocPage.ps1` for structural container changes.
- Removing a component — `remove_component_on_page` returns 404. Use the build script to reset layout.
- Replacing an existing section's content — prefer `update_content` directly on the existing datasource ID.

## Key Facts
- **MCP tool:** `mcp_sitecore-mark_add_component_on_page` — adds component + auto-creates blank datasource
- **Returns:** `{ componentId, pageId, placeholderId, datasourceId }` — `datasourceId` is what you need for `update_content`
- **No duplicate guard:** if the placeholder already has a component, a second instance is added silently
- **Structural prerequisite:** the target container must already exist in the layout (check with `sitecore-layout-inspect` skill)
- **Source policy:** all field values must come from a live fetch of the source URL — no invented content
- **Home page ID:** `9dc3828e-91a7-4e5d-a4fd-e622ea089d54`

## Known Rendering IDs (for `componentRenderingId`)

| Component | Rendering ID |
|---|---|
| VXA Hero | `87fafe78-a3fe-4ddc-8ab8-1054ff60f2a8` |
| VXA Video | `3a96ecf8-20ce-4f57-a9a6-d2d25f952a1e` |
| Multi Promo | `a161bb73-6198-472c-b998-2d3714576f93` |
| CTA Banner | `0dcb68f2-f540-4a4f-b32f-a95391b44811` |
| VXA Rich Text | `7246ef71-352f-4c0e-be90-fb643fcca413` |
| VXA Promo | (look up via `list_components` if needed) |

---

## Before Picking a Component

Before choosing which VXA component to add, answer these questions:

1. **Does a variant already cover it?**  
   Check `VXA_COMPONENT_SPECS.md` → Headless Variants Reference. Image-right, animated, and image-right-animated layouts are all variants of `VxaPromo` — no different component needed. Using the right variant is always preferred over using a different component.

2. **Which container is the target?**  
   Run the `sitecore-layout-inspect` skill to confirm the container placeholder path and verify the structure hasn't drifted from the build script.

3. **Do you have the rendering ID?**  
   Check the Known Rendering IDs table below before calling MCP. If the component isn't listed, use `mcp_sitecore-mark_list_components` to look it up.

---

## Procedure

### Step 1 — Confirm the target placeholder exists

Run the `sitecore-layout-inspect` skill to see the current layout. Identify:
- Which container placeholder to target (e.g. `/headless-main/container-fullbleed-9`)
- The current highest DynamicPlaceholderId (the build script owns structural IDs; MCP-added components get auto-assigned IDs starting after the last known one)

### Step 2 — Fetch source content

Before writing any content, fetch the source URL and identify the exact copy, links, and images for this section. Do not invent any field values.

```
Fetch: https://www.velir.com  (or the relevant client URL)
```

### Step 3 — Add the component via MCP

```
Tool: mcp_sitecore-mark_add_component_on_page
Parameters:
  pageId:                9dc3828e-91a7-4e5d-a4fd-e622ea089d54
  componentRenderingId:  <rendering ID from table above>
  componentItemName:     <short unique name, e.g. "CTA-2" or "Multi-Promo-Clients">
  placeholderPath:       /headless-main/container-fullbleed-{N}
```

**Save the returned `datasourceId`** — you will need it in the next step.

### Step 4 — Populate the datasource

```
Tool: mcp_sitecore-mark_update_content
Parameters:
  itemId:    <datasourceId from Step 3>
  siteName:  standard
  fields:    { "title": "...", "description": "...", "link": "<link ... />", ... }
```

Field formats:
- **General Link:** `<link text="Label" linktype="external" url="https://..." target="_blank" />`  
  Never use `linktype="internal"` without a valid item GUID — crashes the rendering host.
- **Image:** `<image mediaid="{GUID-IN-BRACES}" />`
- **Plain text fields:** ASCII only — no em-dashes or smart quotes (PS 5.1 breaks on these if later written to script)

### Step 5 — Verify

```
Tool: mcp_sitecore-mark_get_content_item_by_id
Parameters:
  itemId: <datasourceId>
```

Confirm all fields are set correctly. Then optionally take a screenshot:

```
Tool: mcp_sitecore-mark_get_page_screenshot
Parameters:
  pageId:   9dc3828e-91a7-4e5d-a4fd-e622ea089d54
  version:  <current version number from get_components_on_page>
```

Note: screenshots render from the **published** version. Changes on master won't appear until published.

---

## Important: Sync back to Build-VelirPocPage.ps1

After successfully adding a section via MCP, **update `Build-VelirPocPage.ps1`** to include the new section in its layout XML. The build script is the source of truth for layout resets — if it doesn't know about the section, the next script run will wipe it.

Pattern for adding a new rendering to the layout XML string in the script:
```xml
<r uid="$($uid[N])"  s:id="$rComponentId"  s:ds="local:/Data/YourDatasource"  
   s:par="$($rp -f 'dark','N')"  s:ph="/headless-main/container-fullbleed-{parentId}" />
```

To use a **non-default variant**, add `FieldNames=%7BGUID%7D` to `s:par`:
```powershell
# Example: VxaPromo with ImageRight variant
$ppr = "colorScheme={0}&amp;FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D&amp;GridParameters=$gridParams&amp;Styles&amp;CSSStyles&amp;DynamicPlaceholderId={1}"
```

See `MARKETER_MCP_KNOWLEDGE_BASE.md` → Headless Variants section and `VXA_COMPONENT_SPECS.md` → Headless Variants Reference for all variant GUIDs.

Also add a datasource step (create + populate fields) above Step 8 in the script.

---

## Multi Promo: Image-Only Display

To render a Multi Promo as a pure image/logo grid (no text):
- Set `title`, `eyebrow`, `description` to `""` on every Multi Promo Item datasource
- Leave `link` populated if you want the images to be clickable (use `text=""`)
- **Color scheme matters for logo visibility:** black-on-transparent PNG logos are invisible on a `dark` container. Use `light` colorScheme on the Full Bleed container wrapping a logo wall.

---

## Cleanup If Something Goes Wrong

`remove_component_on_page` is broken (404). To reset:

```powershell
cd "c:\Users\danield\OneDrive - Velir\2026 Initiatives\Create Sitecore Site"
.\scripts\Build-VelirPocPage.ps1 -ApiKey $TOKEN
```

This overwrites `__Final Renderings` with the canonical layout, removing any MCP-added test components.
