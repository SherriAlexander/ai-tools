# VXA Component Specifications

Sourced from VSCPD Jira project (Velir - Sitecore Platform Definition), all 539 issues reviewed.  
Last updated: 2026-04-02

**Key:**
- ✅ = Verified live against XM Cloud instance
- 📋 = Spec only (not yet tested in this project)
- ⚠️ = Known issue or limitation

---

## Contents

0. [Component Selection Guide](#component-selection-guide) ← **Start here when planning a POC page**
1. [Headless Variants Reference](#headless-variants-reference)
2. [Containers](#containers)
3. [Headers](#headers)
4. [Promos](#promos)
5. [Body Content](#body-content)
6. [Media](#media)
7. [Listings](#listings)
8. [Navigation](#navigation)
9. [Global Partials (Header / Footer)](#global-partials)
10. [Enumerations Reference](#enumerations-reference)
11. [Taxonomy Reference](#taxonomy-reference)
12. [Components Without Specs](#components-without-specs)

---

## Component Selection Guide

> **Purpose:** When analyzing a source website to build a POC, use this guide to map what you see on screen to the correct VXA component and configuration. Always use this guide before writing any layout or creating any datasource items.

---

### Step 1 — Container selection (every section needs one)

Almost every section goes inside a **Full Bleed Container**. Use variants only when needed:

| Layout need | Container | Placeholder(s) exposed |
|---|---|---|
| Full-width section (default — 99% of cases) | Full Bleed Container | `container-fullbleed-{id}` |
| Centered narrow content (editorial, rich text headers) | Center 70 Container | `container-center70-{id}` |
| Two full-width columns side-by-side (two full component instances) | Split 50/50 Container (nested inside Full Bleed) | `container-fifty-left-{id}` / `container-fifty-right-{id}` |
| Asymmetric columns (narrow + wide) | Split 70-30 or 30-70 (nested inside Full Bleed) | `container-seventy-left-{id}` / etc. |
| Edge-to-edge, no bleed | Full Width Container | `container-fullwidth-{id}` |

**Container `colorScheme` selection:**

| Visual background on source page | `colorScheme` value |
|---|---|
| White or very light gray | `Default` |
| Light gray (distinct from white) | `light` |
| Dark / charcoal / navy | `dark` |
| Brand accent / vibrant color | `vibrant` |
| Placing dark-colored logos/icons, need light backdrop | `light` |

> All containers also accept `topMargin`, `bottomMargin`, `gap` (default: `Small (24px)` for all).

---

### Step 2 — Content component selection

#### Hero / Page-top sections

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| Full-bleed video playing on loop in the background, text overlay | **VXA Video** + `ambient` rendering param | `video` field = external General Link (YouTube URL or direct MP4 URL). Falls back to `image` for reduced-motion users — set image too. ✅ |
| Large static image with headline + optional subtitle + CTA button | **VXA Hero** | `description` = Single-Line Text (no HTML). Requires `image`. ✅ |
| Animated parallax hero with floating decorative images | **VXA Hero Parallax** | Requires `backgroundImage` + at least one `floatingImage*`. Use only if source page has a complex parallax effect. 📋 |
| Full-bleed video with title, caption, and play controls (not ambient) | **VXA Video** (no `ambient` param) | Poster image optional. Transcript link optional. 📋 |
| Video that expands from small to full-bleed on scroll | **VXA Video Promo** | Requires an uploaded file (FileField — NOT an external URL). Only use if you can upload the video file. 📋 |

#### Side-by-side / Promo sections

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| Image on left, text (heading + body + CTA) on right | **Promo** (Default / ImageLeft variant) | `description` = Multi-Line Text, plain text only (no HTML). Primary + Secondary link buttons. ✅ |
| Image on right, text on left | **Promo** + ImageRight variant | Same fields. Apply `FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D` to `s:par`. ✅ |
| Two distinct content block columns (each with their own heading/image/CTA) | Split 50/50 Container → Promo in each side | Use when both columns are structurally independent promos. |
| Text-only 50/50 (heading in one column, body+CTA in other) | Split 50/50 Container → Rich Text in each side | Use when no images; both sides are text blocks. |

#### Grid / card sections

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| Grid of 2–4 cards with image, title, description, optional CTA link | **Multi Promo** | 2 or 3 columns. Each card = Multi Promo Item datasource. ✅ |
| Grid of logos / brand marks (images only, no text) | **Multi Promo**, all items with `title=""`, `eyebrow=""`, `description=""` | Set `image` field only. Use `light` container colorScheme for dark logos. ✅ |
| Grid of article/blog/news cards (thumbnail + content type + title) | **Multi Promo** with `eyebrow` = content type, `title` = article title, leave `description` empty | Or use Manual Content Listing if the articles are actual Sitecore pages. ✅ |
| Grid of stat blocks (large number + label) | **Multi Promo** with `title` = stat number/value, `description` = stat label | Leave image blank if source has no images per stat. |
| Expanding FAQ list (accordion) | **Accordion** | Each question/answer = Accordion Item. 📋 |

#### Call-to-action / standalone bands

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| Full-width band: headline + short text + one button | **CTA Banner** | `description` = Multi-Line Text (plain). Single `link` field. Use `vibrant` or `dark` container. ✅ |

#### Text / editorial sections

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| Standalone rich text block (paragraph, heading, lists, no surrounding image) | **Rich Text** | `text` = Rich Text (CKEditor). Use Center 70 or Full Bleed container. |
| Section intro header (centered heading above a card grid) | **Rich Text** | Use `<h2>` + center alignment. Place in same container as the card grid OR in its own Full Bleed/Center 70 above it. ✅ |
| Ordered/unordered list, editorial body text | **Rich Text** | Supports 4 heading styles, 3-level bullets. |
| Body content from the page itself (no standalone datasource) | **Body Text** | References the page's Body Content field directly — no datasource. 📋 |

#### Media sections

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| A single image (standalone, with optional caption) | **VXA Image** | Use Animated variant for scroll-reveal effect. 📋 |
| Embedded YouTube video with poster image | **VXA Video** (without `ambient`) | `video` field = external General Link (YouTube URL). 📋 |

#### Listings (content-driven sections — only use if Sitecore content pages exist)

| What you see on source page | VXA Component | Key notes |
|---|---|---|
| Auto-populated list of article cards filtered by taxonomy | **Dynamic Content Listing** | Requires Sitecore Search integration. Phase 3. |
| Hand-picked list of up to 3 content pages | **Manual Content Listing** | Card format auto-determined by page type. Phase 2. |
| "Related articles" below a piece of content | **Related Content Listing** | Powered by Sitecore Search. Up to 3 cards. |

> For POC builds against external sites, listings are generally not usable — there are no Sitecore content pages to draw from. Use **Multi Promo** with manually populated cards as the POC stand-in for listing sections.

---

### Step 3 — Configuration checklist for every section

Before writing layout XML or creating datasource items:

- [ ] Every section wrapped in a container (Full Bleed is default)
- [ ] Container `colorScheme` set to match source page background
- [ ] DynamicPlaceholderId counter tracked globally (containers and children each consume one slot)  
- [ ] Child `s:ph` references parent container's DynamicPlaceholderId (not the child's own id)
- [ ] All link fields use `linktype="external"` with full URL (NEVER `linktype="internal"` without a GUID)
- [ ] All image fields populated from the source site (follow `poc-upload-images` skill — no blank images if source has one)
- [ ] `description` fields on Hero and CTA Banner are plain text (no HTML)
- [ ] For Promo: `description` is Multi-Line Text (no HTML tags)
- [ ] For Rich Text: `text` field accepts HTML (CKEditor format)
- [ ] Item version tracked — use correct version number for screenshots

---

## Component Registry

> **Quick-reference for all confirmed VXA components.** Copy these values directly into build scripts — no live lookup needed. All IDs confirmed against live `standard` site, 2026-04-03.

### Global Constants

```powershell
$deviceId   = "{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}"   # Standard Device
$gridParams = "%7B7465D855-992E-4DC2-9855-A03250DFA74B%7D" # GridParameters (URL-encoded braced GUID)
```

### Rendering IDs (`s:id` in layout XML)

| Component | Variable name | Rendering ID (braced) | Notes |
|---|---|---|---|
| Full Bleed Container | `$rFullBleed` | `{E80C2A78-FCC2-4D32-8EC5-4133F608BE5C}` | Exposes `container-fullbleed-{id}` |
| Split 50/50 Container | `$rContainer5050` | `{1D2998C5-170A-433A-B1EF-90ADB86BB594}` | Exposes `container-fifty-left-{id}` / `container-fifty-right-{id}` |
| VXA Hero | `$rVxaHero` | `{87FAFE78-A3FE-4DDC-8AB8-1054FF60F2A8}` | |
| VXA Video | `$rVxaVideo` | `{3A96ECF8-20CE-4F57-A9A6-D2D25F952A1E}` | Add `ambient=1` to `s:par` for background video mode |
| VXA Rich Text | `$rVxaRichText` | `{7246EF71-352F-4C0E-BE90-FB643FCCA413}` | |
| VXA Image | `$rVxaImage` | `{BEAD2829-BFB1-41C9-9233-8B17D65047E3}` | |
| Promo | `$rPromo` | `{82B3AE49-7D2E-4157-85A2-3D43C8F79224}` | Default=image left; ImageRight variant adds `FieldNames` to `s:par` |
| Multi Promo | `$rMultiPromo` | `{A161BB73-6198-472C-B998-2D3714576F93}` | Child cards = Multi Promo Item datasources |
| CTA Banner | `$rCtaBanner` | `{0DCB68F2-F540-4A4F-B32F-A95391B44811}` | |

### Datasource Template IDs (`templateId` in `createItem` mutations)

**N format** (no hyphens, no braces) as required by the Authoring GraphQL API.

| Component | Variable name | Template ID (N format) |
|---|---|---|
| VXA Hero datasource | `$tVxaHero` | `4579b39145b746a987b20456c66bf807` |
| VXA Video datasource | `$tVxaVideo` | `14490dcb06554d24b44428c955d790d3` |
| VXA Rich Text datasource | `$tVxaRichText` | `82462949f3754363a4e21224f16f7311` |
| VXA Image datasource | `$tVxaImage` | `4a1cf144249d438da82471e7341d1e19` |
| Promo datasource | `$tVxaPromo` | `d100f089a4d34d229d1de7ab0e721f81` |
| Multi Promo datasource | `$tMultiPromo` | `380ffba85f494abca903d069a0add3ec` |
| Multi Promo Item datasource | `$tMultiPromoItem` | `b81775e545b54238961b8b2996ff2503` |
| CTA Banner datasource | `$tCtaBanner` | `5486c1debf464bc2b4fb9faf59903b29` |
| Data Folder | `$tFolder` | `a87a00b1e6db45ab8b54636fec3b5523` |

### Confirmed Field Names per Datasource Template

> ⚠️ **Critical:** `Set-SitecoreFields` (and the underlying `updateItem` mutation) is ALL-OR-NOTHING. One invalid field name silently clears every field on the item. Always use ONLY the field names listed here. Confirmed against live `standard` site, 2026-04-03.

| Component | Valid field names | Notes |
|---|---|---|
| VXA Hero | `title`, `description`, `link`, `image` | `description` = Single-Line Text (no HTML). `link` = General Link XML. No `eyebrow`, no `primaryLink`. |
| VXA Video | `title`, `description`, `video`, `image` | `video` = General Link (external URL or MP4). `image` = fallback for reduced-motion. |
| VXA Rich Text | `text` | `text` = Rich Text (accepts HTML). Single field. |
| VXA Image | `image` | `image` = Image field. Single field. |
| Promo | `eyebrow`, `title`, `description`, `primaryLink`, `secondaryLink`, `image` | **CTA link is `primaryLink` — NOT `link`**. `description` = Multi-Line Text (plain text, no HTML). |
| Multi Promo (parent) | `title`, `link` | **Only 2 fields. `numberOfColumns` does NOT exist.** `link` = General Link XML for "view all" CTA. |
| Multi Promo Item (child) | `eyebrow`, `title`, `description`, `link`, `image` | `link` = General Link XML (card CTA). Leave blank with `<link />` if no CTA needed. |
| CTA Banner | `title`, `description`, `link` | `description` = Multi-Line Text (plain text, no HTML). `link` = General Link XML. |

---



> **How variants work:** Each component can expose multiple named exports in its `.tsx` file (`Default`, `ImageRight`, `Animated`, etc.). The active variant is selected by adding `FieldNames=%7BGUID%7D` (braced, URL-encoded item GUID) to `s:par` in layout XML. No `FieldNames` = `Default` export is used.  
> Full explanation: see `MARKETER_MCP_KNOWLEDGE_BASE.md` → Headless Variants section.  
> GUIDs confirmed against live `standard` site, 2026-04-02. ✅

| Component | Variant | GUID (hyphenated) | URL-encoded for `s:par` |
|---|---|---|---|
| VxaPromo | Default | `3e5ff577-b999-49c0-8366-b651d4bdfde8` | `%7B3E5FF577-B999-49C0-8366-B651D4BDFDE8%7D` |
| VxaPromo | **ImageRight** ✅ | `65c44a3b-df9c-4f4a-bd13-12b572d4fc24` | `%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D` |
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
| VXA Structured Content Page Header | Default | `743bafc3-3f46-4997-99e6-ab59c2933d3c` | `%7B743BAFC3-3F46-4997-99E6-AB59C2933D3C%7D` |
| VXA Structured Content Page Header | Animated | `691fb007-2ea6-487c-864c-a0cc0f9351ab` | `%7B691FB007-2EA6-487C-864C-A0CC0F9351AB%7D` |
| VXA Structured Content Page Header | ImageBelow | `3bda9ac9-ae4a-4b91-bdee-829c2fa203cf` | `%7B3BDA9AC9-AE4A-4B91-BDEE-829C2FA203CF%7D` |
| VXA Structured Content Page Header | ImageBelowAnimated | `6fc03008-14ed-48e4-98d8-75bbf72bd4a6` | `%7B6FC03008-14ED-48E4-98D8-75BBF72BD4A6%7D` |
| VXA Site Search | Default | `05235276-148c-41f5-8e47-a7e3c230cea4` | `%7B05235276-148C-41F5-8E47-A7E3C230CEA4%7D` |
| VXA Site Search | LoadMore | `56b3bee3-47e5-40e7-98ab-93774614673d` | `%7B56B3BEE3-47E5-40E7-98AB-93774614673D%7D` |

> `VxaHero`, `VxaVideo`, `CTABanner`, `VxaRichText`, containers — **no variant system**. Always use `Default` (or rendering params like `ambient`).

---

## Containers

> **Critical note:** Containers CANNOT be added via Marketer MCP (`add_component_on_page` returns 404 — no datasource template). Use PowerShell + Authoring GraphQL `updateItem` mutation to write layout XML directly. ✅

All containers share these base fields:

| Display Name | Machine Name | Field Type | Default |
|---|---|---|---|
| Top Margin | `topMargin` | Droplink | Small (24px) |
| Bottom Margin | `bottomMargin` | Droplink | Small (24px) |
| Gap | `gap` | Droplink | Small (24px) |

Margin/Gap values: `No Margin (0px)`, `Small (24px)`, `Medium (48px)`, `Large (80px)`

### Full Bleed Container (VSCPD-18) ✅
**Placeholder exposed:** `container-fullbleed-{DynamicPlaceholderId}`  
**Allowed everywhere in `headless-main`.**

Additional fields:

| Display Name | Machine Name | Field Type | Default |
|---|---|---|---|
| Color Scheme | `colorScheme` | Droplink | Default |
| Inset | `inset` | Checkbox | false |

### Full Width Container (VSCPD-19) 📋
**Placeholder exposed:** `container-fullwidth-{id}`

No additional fields beyond base.

### Center 70 Container (VSCPD-20) 📋
**Placeholder exposed:** `container-center70-{id}`

No additional fields beyond base.

### Split Container 50-50 (VSCPD-21) 📋
**Placeholders exposed:** `container-fifty-left-{id}` and `container-fifty-right-{id}`  
Nested path format: `/headless-main/container-fullbleed-{outerId}/container-fifty-left-{innerId}`

No additional fields beyond base.

### Split Container 70-30 (VSCPD-22) 📋
**Placeholders exposed:** `container-seventy-left-{id}` and `container-thirty-right-{id}`

No additional fields beyond base.

### Split Container 30-70 (VSCPD-23) 📋
**Placeholders exposed:** `container-thirty-left-{id}` and `container-seventy-right-{id}`

No additional fields beyond base.

---

## Headers

### Hero (VSCPD-50) ✅
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local only (auto-created under page `Data/` folder)  
**Allowed in:** Full Bleed Container on Homepage and Landing Page

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | ✓ | |
| Image Mobile | `imageMobile` | Image | | |
| Title | `title` | Single Line Text | ✓ | Hero Title |
| Description | `description` | Single Line Text | | |
| Link | `link` | General Link | | |
| Color Scheme | `colorScheme` | Droplink | | Default |
| Text Orientation | `textOrientation` | Droplink | | Center Aligned |

> ⚠️ `description` is **Single-Line Text** — do not wrap in `<p>` tags.  
> H1 is on the **page template**, not this component.  
> Mobile image falls back to desktop image if not set.  
> `textOrientation` values: `Center Aligned`, `Left Aligned`  
> ⚠️ The CTA link field is **`link`** — not `primaryLink`. There is **no `eyebrow`** field on this template. Using nonexistent field names in `Set-SitecoreFields` silently clears all fields on the datasource item.

### Hero Parallax (VSCPD-435) 📋
**Phase:** 3+ | **Status:** UAT Accepted  
**Datasource location:** Local only  
**Allowed in:** Full Bleed Container on Homepage and Landing Page

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Floating Image Top Left | `floatingImageTopLeft` | Image | ✓ | |
| Floating Image Bottom Left | `floatingImageBottomLeft` | Image | | |
| Floating Image Top Right | `floatingImageTopRight` | Image | | |
| Floating Image Bottom Right | `floatingImageBottomRight` | Image | | |
| Background Image | `backgroundImage` | Image | ✓ | |
| Foreground Image | `foregroundImage` | Image | | |
| Title | `title` | Rich Text | ✓ | Hero Title |
| Description | `description` | Rich Text | | |
| Link | `link` | General Link | | |

> 4 floating images move on scroll; CTA revealed mid-scroll. H1 handled at page template level.

### Page Header (VSCPD-51) 📋
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local only  
**Variants:** Image Right (default), Image Behind (VSCPD-190)

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | | |
| Color Scheme | `colorScheme` | Droplink | | Default |

> Title (H1) and Subtitle sourced from **page template fields** (`headerTitle` → fallback `title`, `subtitle`).  
> **Image Behind variant:** image renders behind text, color overlay applied, text centered.

### Structured Content Page Header (VSCPD-62) 📋
**Phase:** 2 | **Status:** UAT Accepted  
**Datasource location:** Local only  
**Variants:** Image Right (default), Image Below (VSCPD-247), Animated (VSCPD-439)

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Eyebrow Text | `eyebrowText` | Single Line Text | | |
| Image | `image` | Image | | |
| Color Scheme | `colorScheme` | Droplink | | Default |

> Title (H1), Subtitle, Display Date sourced from page fields.  
> Up to 3 People (Person taxonomy items) can be linked; renders Profile Image, Prefix, First/Last Name, Suffix, Title.  
> **Animated variant:** hero image gradually fills page width on scroll; supports `.webp`.

### Event Header (VSCPD-67) 📋
**Phase:** 2 | **Status:** Deploy for UAT  
**Variants:** Image Right (default), Image Below (VSCPD-281)

No unique datasource fields — all data from **Event Detail Page template**: Header Image, Header Title (H1), Subtitle, Start/End Date, Time Zone, Virtual Event, Address, City, State/Province, Postal Code, Map Link, Registration Link, Event Type.

> Registration Link button auto-hides when End Date has passed.

---

## Promos

### Promo (VSCPD-49) ✅
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Promos"  
**Variants:** Image Left (default), Image Right (VSCPD-192), Animated (VSCPD-436)

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | ✓ | |
| Eyebrow Text | `eyebrow` | Single Line Text | | |
| Title | `title` | Single Line Text | ✓ | Promo title |
| Description | `description` | Multi Line Text | | |
| Primary Link | `primaryLink` | General Link | | |
| Secondary Link | `secondaryLink` | General Link | | |
| Color Scheme | `colorScheme` | Droplink | | Default |

> Primary Link = primary button style. Secondary Link = text button style.  
> **Animated variant:** eases in on scroll; supports `.webp` rollover animation (plays on hover, max 3s loop).

#### Variant GUIDs (live — `standard` site, confirmed 2026-04-02) ✅
Variants live at `/sitecore/content/dev-demos/standard/Presentation/Headless Variants/VxaPromo/`.  
To activate a variant, add `FieldNames=%7BGUID%7D` (braced, URL-encoded) to `s:par` in layout XML.

| Variant Name | Item GUID |
|---|---|
| Default | `3e5ff577-b999-49c0-8366-b651d4bdfde8` |
| Animated | `e83ccadf-81d4-4797-ba9f-97e3381a8822` |
| ImageRight | `65c44a3b-df9c-4f4a-bd13-12b572d4fc24` |
| ImageRightAnimated | `2ab11065-5ebc-46c9-bc90-83218dd30bfb` |

URL-encoded ImageRight for `s:par`: `FieldNames=%7B65C44A3B-DF9C-4F4A-BD13-12B572D4FC24%7D`  
See `$ppr` in `Build-VelirPocPage.ps1` for the full promo param string with this variant applied.

### CTA Banner (VSCPD-52) ✅
**Phase:** 1 | **Status:** UAT Accepted  
**Rendering ID (live):** `0dcb68f2-...` (check Marketer MCP `list_components` for full ID)  
**Datasource location:** Local or "Shared CTA Banners"

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `title` | Single Line Text | ✓ | |
| Description | `description` | Multi-line Text | | |
| Link | `link` | General Link | ✓ | |
| Color Scheme | `colorScheme` | Droplink | | Default |

> Title renders as H2. Link renders as primary button.

### Multi Promo (VSCPD-53) ✅
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Multi Promos"  
**Animated variant:** VSCPD-438 (cards ease in left-to-right on scroll; `.webp` rollover support)

**Multi Promo (parent datasource):**

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `title` | Single Line Text | | Header Title |
| Link | `link` | General Link | | |
| Number of Columns | `numberOfColumns` | Droplink | | 3 |

> `numberOfColumns` values: `2`, `3` — ⚠️ we have been hardcoding 4 items but spec says 2 or 3 columns.  
> ⚠️ The Multi Promo **parent** datasource has only `title`, `link`, and `numberOfColumns` — it does **NOT** have `eyebrow` or `description`. Using nonexistent fields silently clears all fields.  
> ⚠️ Multi Promo Items **must be created as children of the Multi Promo parent datasource item** (set `ParentId` to the parent GUID). Creating them as siblings under `Data/` means the component cannot auto-discover them.

**Multi Promo Item (Managed Item — child under parent datasource):**

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | | |
| Eyebrow Text | `eyebrow` | Single Line Text | | |
| Title | `title` | Single Line Text | ✓ | Promo Title |
| Description | `description` | Multi Line Text | | |
| Link | `link` | General Link | | |

> 3 items pre-created by branch template. 3:2 image aspect ratio enforced.

**Sourced Multi Promo Item (VSCPD-229) — On Hold:**  
Generates a card by sourcing content from a referenced page (Thumbnail Image, Content Type, Short Title, Summary auto-populated). Link text = "Read More" (Dictionary item).

### Video Promo (VSCPD-437) 📋
**Phase:** 3+ | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Video Promos"  
**Allowed in:** Full Bleed Container on Homepage and Landing Page

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `videoPromoTitle` | Single Line Text | | |
| Video | `videoPromo` | File | ✓ | |
| Caption | `videoPromoCaption` | Single Line Text | | |
| Link | `videoPromoLink` | General Link | | |
| Dark Pause Icon | `darkPauseIcon` | Checkbox | | false |

> Web-optimized MP4/WebM, loops, starts at 50% width and expands to full bleed on scroll.  
> Title = H2, Caption = H3. Pause/play button for accessibility.

### Video Rollover Promo (VSCPD-491) 📋
**Status:** Open (not yet in UAT)  
**Datasource location:** Local or "Shared Video Rollover Promos"  
**Variant:** Image Right (default)

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | ✓ | |
| Video Rollover | `videoRollover` | File | ✓ | |
| Eyebrow Text | `eyebrow` | Single Line Text | | |
| Title | `title` | Single Line Text | ✓ | Promo title |
| Description | `description` | Multi Line Text | | |
| Primary Link | `primaryLink` | General Link | | |
| Secondary Link | `secondaryLink` | General Link | | |
| Color Scheme | `colorScheme` | Droplink | | Default |

> Video plays muted + looped on hover, fades in/out. Formats: MP4, WebM.

### Video Rollover Multi Promo (VSCPD-492) 📋
**Status:** Open  
**Datasource location:** Local or "Shared Video Rollover Multi Promos"

**Parent datasource:**

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `title` | Single Line Text | | Header Title |
| Link | `link` | General Link | | |
| Number of Columns | `numberOfColumns` | Droplink | | 3 |

**Item (Managed Item):**

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | | |
| Video Rollover | `videoRollover` | File | ✓ | |
| Eyebrow Text | `eyebrow` | Single Line Text | | |
| Title | `title` | Single Line Text | ✓ | Promo Title |
| Description | `description` | Multi Line Text | | |
| Link | `link` | General Link | | |

---

## Body Content

### Rich Text (VSCPD-54) 📋
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Rich Text"

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Text | `text` | Rich Text | |

> CKEditor. 4 heading styles, 3-level bullets. No embedded media.

### Button (VSCPD-55) 📋
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local only (auto-created)

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Link | `link` | General Link | | |
| Button Style | `buttonStyle` | Droplink | ✓ | Primary |

> `buttonStyle` values: `Primary`, `Secondary`  
> Icon auto-appended by link type: internal=→, external=↗, file=⬇.  
> Left-aligned. Multiple buttons render side-by-side.

### Body Text (VSCPD-63) 📋
**Phase:** 2 | **Status:** UAT Accepted

No unique datasource fields. References the page's **Body Content** field (Rich Text on page template).

### Accordion (VSCPD-77) 📋
**Phase:** 2 | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Accordions"

**Accordion (parent):**

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Title | `title` | Single Line Text | |

**Accordion Item (Managed Item):**

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `title` | Single Line Text | ✓ | Accordion Item |
| Text | `text` | Rich Text | ✓ | |

> All items collapsed by default. Multiple can be open simultaneously. No item limit.

---

## Media

### Image (VSCPD-56) 📋
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Images"  
**Interactive variant:** VSCPD-440 (eases in on scroll; `.webp` auto-plays on scroll)

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Image | `image` | Image | ✓ |
| Caption | `caption` | Single Line Text | |

### Video (VSCPD-57) ✅
**Phase:** 1 | **Status:** UAT Accepted  
**Datasource location:** Local or "Shared Videos"

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Image | `image` | Image | | |
| Video | `video` | General Link | ✓ | YouTube share URL |
| Title | `title` | Single Line Text | | |
| Transcript | `transcript` | General Link | | |
| Dark Play Icon | `darkPlayIcon` | Checkbox | | false |

> YouTube only (external General Link format). Poster image optional; falls back to YouTube thumbnail.  
> Title renders as H2. Transcript = PDF link only.  
> **`ambient` rendering parameter** (in layout XML `params` attribute): controls background/ambient display styling.  
> ⚠️ Ambient video does NOT auto-resume after manual pause. Not rendered for users with reduced motion (falls back to image).

---

## Listings

### Dynamic Content Listing (VSCPD-64) 📋
**Phase:** 3 | **Status:** QA Rejected  
**Datasource location:** Local only (auto-created)  
**Powered by:** Sitecore Search

| Section | Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|---|
| Title | Title | `title` | Single Line Text | | |
| Taxonomy | Content Type | `taxContentType` | Multi-list | ✓ | |
| | Topic | `taxTopic` | Multi-list | | |
| Results | Number of Items | `numberOfItems` | Droplink | ✓ | 6 |
| | Sort Order | `sortOrder` | Droplink | ✓ | Reverse Chronological |
| Filters | Filters Displayed | `filtersDisplayed` | Multi-list | | |
| Styling | Hide Dates | `hideDates` | Checkbox | | false |
| | Hide Content Type Label | `hideContentTypeLabel` | Checkbox | | false |
| | Hide Summaries | `hideSummaries` | Checkbox | | false |
| | Hide Images | `hideImages` | Checkbox | | false |
| | Color Scheme | `colorScheme` | Droplink | | Default |

> List View (default) + Grid View toggle. Load More pagination. `numberOfItems` values: 3, 6, 9, 10, 12, 15.  
> Filters: OR within group, AND between groups.

### Manual Content Listing (VSCPD-65) 📋
**Phase:** 2 | **Status:** UAT Rejected  
**Datasource location:** Local only

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `title` | Single Line Text | | $Name |
| Pages | `pages` | Treelist | ✓ | |
| Link | `link` | General Link | | |
| Hide Thumbnails | `hideThumbnails` | Checkbox | | false |

> Shows up to 3 cards. Card format varies by page type.

### Related Content Listing (VSCPD-66) 📋
**Phase:** 3 | **Status:** Deploy for UAT  
**Datasource location:** Local only  
**Powered by:** Sitecore Search

| Section | Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|---|
| Title | Title | `title` | Single Line Text | | |
| Taxonomy | Content Types | `relatedContentTypes` | Multi-list | | |
| Link | Link | `relatedContentLink` | General Link | | |
| Styling | Color Scheme | `colorScheme` | Droplink | | Default |
| | Hide Thumbnail Images | `hideThumbnails` | Checkbox | | false |

> Up to 3 cards. Does NOT render if no matching content found.

### Site Search (VSCPD-71) 📋
**Phase:** 3 | **Status:** Deploy for UAT  
**Datasource location:** Local only  
**Powered by:** Sitecore Search  
**Variants:** Pagination (default), Load More (VSCPD-468)

| Section | Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|---|
| Data | Number of Items | `numberOfItems` | Droplink | ✓ | 10 |
| | Filters Displayed | `filtersDisplayed` | Multi-list | ✓ | Content Type, Topics |

> Faceted filtering. Sort options: Relevance, Date, Alphabetical. Load More variant: max 500 items, query string pagination.  
> Facet list limited to 5 items by default (Show more/less control).

---

## Navigation

### Breadcrumb Navigation (VSCPD-68) 📋
**Phase:** 2 | **Status:** UAT Accepted

No unique datasource fields. Dynamically built from content tree.

> Shows 3 parent levels. >3 levels collapse to ellipsis (expandable). Current page NOT shown.  
> Collapses to "back button" on mobile.

### Jump Link Navigation (VSCPD-69) 📋
**Phase:** 2 | **Status:** UAT Accepted

**Anchor Link (Managed Item — placed inline on page):**

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Title | `title` | Single Line Text | ✓ | Jump Link Title |

> Jump nav is dynamically generated from all Anchor Link components on the page.  
> Sticky. Overflows to droplist when too wide. Mobile: all links collapse to dropdown.

### Secondary Navigation (VSCPD-60) 📋
**Phase:** 2 | **Status:** Deploy for UAT  
**Datasource location:** Local only

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Parent | `parent` | Treelist | ✓ | root |
| Color Scheme | `colorScheme` | Droplink | | Default |

> Max 3 nav levels. Uses page `shortTitle`. Collapses to droplist on mobile.  
> Pages suppressed via page-level `suppressInSubNav` checkbox.

### Skip Link Navigation (VSCPD-75) 📋
**Phase:** 2 | **Status:** UAT Accepted

No datasource. Part of Global Header. Tab-triggered only; jumps to main content.  
Text editable via Dictionary item.

### Back-to-Top Navigation (VSCPD-76) 📋
**Phase:** 2 | **Status:** UAT Accepted

No datasource. Global JS plugin. Shows when page height > 2× viewport; triggers at 1× scroll depth.

### Language Selector (VSCPD-525) 📋
**Status:** Front-End Development  
**Location:** Inside Global Header partial design (added to Global Header datasource)

| Display Name | Machine Name | Field Type | Required | Default |
|---|---|---|---|---|
| Selected Languages | `selectedLanguages` | Multilist | | |

> Auto-hides when fewer than 2 published languages available.  
> Admin-only editing on Global Header partial design.

---

## Global Partials

### Global Header (VSCPD-27) 📋
**Phase:** 1 | **Status:** UAT Accepted

**Global Header datasource:**

| Section | Display Name | Machine Name | Field Type | Required |
|---|---|---|---|---|
| Image | Logo | `logo` | Image | ✓ |
| | Logo Mobile | `logoMobile` | Image | |
| Styling | Sticky | `sticky` | Checkbox | |

**Utility Navigation Item (Managed Item):**

| Display Name | Machine Name | Field Type |
|---|---|---|
| Utility Link | `utilityLink` | General Link |
| Button | `isButton` | Checkbox |
| Icon | `buttonIcon` | Image |

**Individual theming (VSCPD-389 — UAT Accepted):**

| Display Name | Machine Name |
|---|---|
| Primary Navigation Color Scheme | `colorScheme` (Primary Nav section) |
| Utility Navigation Color Scheme | `colorScheme` (Utility Nav section) |

> Logo links to site root (coded). Collapses to hamburger on mobile. Logo Mobile fallback = Logo.

### Primary Navigation (VSCPD-32) 📋
**Status:** UAT Accepted  
**Datasource:** Centralized Primary Navigation Root node

**Primary Navigation Item:**

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Title | `title` | Single Line Text | ✓ |
| Link | `link` | General Link | |
| Promo Image | `promoImage` | Image | |
| Promo Title | `promoTitle` | Single Line Text | |
| Promo Link | `promoLink` | General Link | |

**Primary Navigation Subheader:**

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Title | `title` | Single Line Text | ✓ |
| Link | `link` | General Link | |

> Megamenu, up to 4 columns. Promo Image enforces 1:1 aspect ratio.  
> Mobile: hamburger → L1 → L2 drill-down.

### Global Footer (VSCPD-59) 📋
**Phase:** 1 | **Status:** UAT Accepted

**Global Footer datasource:**

| Section | Display Name | Machine Name | Field Type |
|---|---|---|---|
| Image | Footer Logo | `footerLogo` | Image |
| | Footer Logo Link | `footerLogoLink` | General Link |
| Text | Contact Header | `contactHeader` | Single Line Text |
| | Contact Address | `contactAddress` | Single Line Text |
| | Contact Phone Number | `contactPhone` | Single Line Text |
| | Copyright Statement | `copyright` | Single Line Text |
| Links | Social Links | `socialLinks` | Multilist |

**Column Header (Managed Item):** `columnHeader` (Single Line Text)  
**Column Link (Managed Item):** `link` (General Link)  
**Utility Navigation (Managed Item):** `utilityLink` (General Link)

**Individual theming (VSCPD-390 — Awaiting UAT Approval):**

| Display Name | Machine Name |
|---|---|
| Footer Navigation Color Scheme | `colorScheme` (Footer Nav section) |
| Footer Subnavigation Color Scheme | `colorScheme` (Subnavigation section) |

> Up to 3 nav columns. Copyright year auto-populates. Column nav collapses to accordions on mobile.  
> Social Links sourced from centralized folder. Current icons: Facebook, Instagram, YouTube, Twitter/X, LinkedIn.  
> Threads and BlueSky pending (VSCPD-356, in Requirements Gathering).

### Social Links (VSCPD-178) 📋
**Status:** UAT Accepted  
**Location:** `$sitenode/Data/Social Links`

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Link | `link` | General Link | ✓ |
| Icon | `socialIcon` | Droplink | ✓ |

---

## Enumerations Reference

These are the valid values for Droplink/Droplist rendering parameters and datasource fields.

| Name | VSCPD | Values |
|---|---|---|
| Color Scheme | VSCPD-173 | `Default`, `Primary`, `Secondary`, `Accent` |
| Top Margin | VSCPD-174 | `No Margin (0px)`, `Small (24px)`, `Medium (48px)`, `Large (80px)` |
| Bottom Margin | VSCPD-175 | `No Margin (0px)`, `Small (24px)`, `Medium (48px)`, `Large (80px)` |
| Gap | VSCPD-176 | `No Margin (0px)`, `Small (24px)`, `Medium (48px)`, `Large (80px)` |
| Button Style | VSCPD-182 | `Primary`, `Secondary` |
| Text Orientation | VSCPD-184 | `Center Aligned`, `Left Aligned` |
| Number of Columns | VSCPD-188 | `2`, `3` |
| Number of Items | VSCPD-228 | `3`, `6`, `9`, `10`, `12`, `15` |
| Time Zone | VSCPD-187 | `ET (UTC -5/-4)`, `CT (UTC -6/-5)`, `MT (UTC -7/-6)`, `PT (UTC -8/-7)` |
| State | VSCPD-185 | Full US 50-state list + DC and territories |

**Sub-theme names (VSCPD-424, migration in progress):**  
`primary`, `secondary`, `accent`, `ocean`, `ocean-dark`, `sunset`, `sunset-dark`, `forest`, `forest-dark`, `monochrome`, `monochrome-dark`, `purple-dream`, `purple-dream-dark`

**Multi-Theme Content Selection (VSCPD-403):**  
Site theme selectable from content at `{site}/Presentation/Site Theme` → `theme` (Droplink). Fallback = "Brand A". Themes defined at `{site}/Data/Enumerations/Themes`.

---

## Taxonomy Reference

| Name | VSCPD | Page field | Notes |
|---|---|---|---|
| Content Type | VSCPD-180 | `taxContentType` (Droplink) | Single-select. Values: custom per-site. |
| Topic | VSCPD-181 | `taxTopic` (Treelist) | Multi-select. |
| People (Person) | VSCPD-183 | `taxPeople` (Treelist) | Links pages to Person items for author/expert display. |
| Event Type | VSCPD-186 | (on Event Detail page) | Values: Annual Meeting, Webinar, Lecture, etc. |

**Person item fields (VSCPD-183):**

| Display Name | Machine Name | Field Type | Required |
|---|---|---|---|
| Profile Image | `profileImage` | Image | |
| Prefix | `prefix` | Single Line Text | |
| First Name | `firstName` | Single Line Text | ✓ |
| Middle Name | `middleName` | Single Line Text | |
| Last Name | `lastName` | Single Line Text | |
| Suffix | `suffix` | Single Line Text | |
| Email | `email` | Single Line Text | |
| Title | `personTitle` | Single Line Text | |
| Bio | `bio` | Rich Text | |

---

## Components Without Specs

The following components were referenced in VSCPD descriptions or linked tickets but do **not** have dedicated spec tickets in the VSCPD project (searched all 539 issues):

- **Statistics / Stat Counter** — not yet specced
- **Testimonial / Testimonial Listing** — not yet specced
- **Tabs** — not yet specced
- **Social Share** — not yet specced
- **People Profile / People Listing** — not yet specced (Person taxonomy template exists at VSCPD-183, but no listing/profile page component)
- **Event Listing / Event Cards** — not yet specced (Event Detail Page template exists at VSCPD-16)
- **Carousel / Slideshow** — not yet specced (VSCPD-128 referenced as "On Hold")

These may be planned for a future phase or may not be in scope for VXA v1.
