# Velir POC Site Context

_Last updated: 2026-04-03_

Active site build: Velir.com → `dev-demos/standard` XM Cloud instance.

---

## Environment

| Key | Value |
|---|---|
| CM URL | `https://xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io` |
| Org | Velir Studios, Inc. |
| Site name | `standard` |
| Site root | `/sitecore/content/dev-demos/standard` |
| Home page path | `/sitecore/content/dev-demos/standard/Home` |
| Home page ID | `9dc3828e-91a7-4e5d-a4fd-e622ea089d54` |
| Source website | `https://www.velir.com` |

## Local Environment

- Node v24 and Playwright 1.59.1 at `C:\Users\danield\AppData\Local\Temp\node_modules\playwright`
- Chromium at `C:\Users\danield\AppData\Local\ms-playwright\chromium-1217`
- Playwright screenshots run from `$env:TEMP` via `node screenshot.js`
- VXA monorepo at `C:\Users\danield\OneDrive - Velir\2026 Initiatives\VXA\vxa`

---

## Completed Pages

| Page | Path | Page ID | Data Folder ID | Sections | DPIDs | Build Script | Status |
|---|---|---|---|---|---|---|---|
| Home | `.../Home` | `9dc3828e-91a7-4e5d-a4fd-e622ea089d54` | n/a | 7 | 22 | `Build-VelirPocPage.ps1` (archived) | ✅ Live |
| Who We Are | `.../Home/who-we-are` | `8a07b286-5dd1-4ba0-800b-6c430ecaa6ec` | — | 8 | 20 | `Build-WhoWeArePage.ps1` (archived) | ✅ Live |
| What We Do | `.../Home/what-we-do` | `de056beee64f443e937afc2585b6914f` | `eb07d540b409452fb890d063f9877394` | 8 | 22 | `Build-WhatWeDoPage.ps1` | ✅ Live |
| Work | `.../Home/work` | `c4740980-0a10-4b9c-bf95-1339cc4f3f88` | `500aa276-14fa-4aa6-8753-c0469c33c7b3` | 4 | 8 | `Build-WorkPage.ps1` | ✅ Live |

---

## Theming Status

**Blocked on deploy access.** Dan Solovay has deploy access to the VXA Next.js deployment.

Required changes:
- `brand-velir.css` — Velir color tokens
- `FontContext.tsx` — IBM Plex Sans font

Design token workflow: Figma → TokenSync CLI → theme CSS files. No code changes needed beyond those files for a new brand.

---

## Key Decisions (Velir-Specific)

| Date | Decision | Notes |
|---|---|---|
| 2026-03-31 | Smoke test confirmed live | All 5 tests green. CLI authenticated against **Velir Studios, Inc.** org. CM URL: `xmc-velirstudio0597-velirxmclouc5df-accelerator747b.sitecorecloud.io`. |
| 2026-03-31 | First full POC page rendered on Home | Hero + Multi Promo (4 cards) + CTA Banner. Velir.com homepage mirror proof-of-concept complete. |
| 2026-03-31 | Build script fully codified | `Build-VelirPocPage.ps1` — idempotent, targets Home, correct DPIDs, external links, ASCII-only content. |
| 2026-03-31 | Theming blocked on deploy access | VXA brand theming requires Next.js CSS deploy. Dan Solovay has access. Handoff needed. |
| 2026-04-01 | Homepage layout complete | Video (ambient) → 50/50 Promo "Digital Transformation Never Stops" → Services MultiPromo → Work MultiPromo → Stats → CTA. 22 DPIDs total. |
| 2026-04-01 | Velir hero video URL | Self-hosted MP4: `https://www.velir.com/-/media/files/hero-videos/velir-hero-video-updated.mp4` — not in page DOM, requires fetching raw page source. |
| 2026-04-01 | Promo for "Digital Transformation" 50/50 section | Without an image set, left column renders as empty space — acceptable for POC. |
| 2026-04-02 | "We are proud" + logo wall added to Home | Two Full Bleed sections: 50/50 RichText (heading left, body+CTA right) + Multi Promo 12 logos (`light` colorScheme). |
| 2026-04-02 | 12 client logos uploaded | GUIDs encoded in `Build-VelirPocPage.ps1`. Filenames scraped from raw HTML (e.g. `johnnieo.png`, `aba.png`, `northwestern-kellogg.png`, `the-met.png` — differ from URL slugs). |
| 2026-04-02 | Home layout at 22 DPIDs | Video(1-2) → 50/50 Digital Transformation(3-6) → Services MultiPromo(7-8) → Brooklyn Data Promo ImageRight(9-10) → 50/50 We are Proud(11-14) → Logo Wall MultiPromo(15-16) → Ideas RichText header(17) → Ideas MultiPromo(18-19) → CTA(20-22). |
| 2026-04-02 | Promo ImageRight applied to "Brooklyn Data" section | GUID sourced from `/Presentation/Headless Variants/VxaPromo/ImageRight` on the live `standard` site. |
| 2026-04-02 | "Our latest ideas" section complete | Full-width Rich Text header (centered) + Multi Promo (3 article cards). All 3 thumbnails uploaded and rendering. |
| 2026-04-03 | `who-we-are` page complete | Page ID `8a07b286-5dd1-4ba0-800b-6c430ecaa6ec`. 8 sections, 20 DPIDs. Build script: `Build-WhoWeArePage.ps1` (archived). |
| 2026-04-03 | `what-we-do` page complete (recreated) | Page ID `e2bf2f141a3340cc983a4f3b736e19ab`. 8 sections, 22 DPIDs. 20 media items: hero, 6 service images, Wendy Karlyn headshot, 12 client logos. Build script: `Build-WhatWeDoPage.ps1`. |
| 2026-04-03 | `work` page complete (session 4) | Page ID `c4740980-0a10-4b9c-bf95-1339cc4f3f88`. 4 sections, 8 DPIDs. Featured: Suncoast Credit Union (Promo ImageRight). 8-card grid. Build script: `Build-WorkPage.ps1`. |

---

## Media Library

All media under `/sitecore/media library/dev-demos/standard/`.

| Folder | Contents | Last Verified |
|---|---|---|
| `work/` | 8 case study thumbnails (og:image per card) | 2026-04-03 |
| `what-we-do/` | Hero, 6 service images, Wendy Karlyn headshot, 12 client logos | 2026-04-03 |
| `who-we-are/` | 6 section images | 2026-04-03 |

GUIDs are encoded in the respective `Build-*.ps1` scripts.

> ⚠️ Media GUIDs survive page deletion but do **not** survive environment resets. Always run an idempotency check before reusing GUIDs from a prior session.
| 2026-04-02 | "We are proud" + logo wall added to Home | 50/50 RichText (heading left, body+CTA right) + Multi Promo 12 logos (`light` colorScheme, image-only). |
| 2026-04-02 | 12 client logos uploaded | GUIDs encoded in `Build-VelirPocPage.ps1` (archived). Filenames scraped from raw HTML: `johnnieo.png`, `aba.png`, `northwestern-kellogg.png`, `the-met.png` (differ from URL slugs). |
| 2026-04-02 | Home layout at 22 DPIDs | Video(1-2) → 50/50 Digital Transformation(3-6) → Services MultiPromo(7-8) → Brooklyn Data Promo ImageRight(9-10) → 50/50 We are Proud(11-14) → Logo Wall MultiPromo(15-16) → Ideas RichText header(17) → Ideas MultiPromo(18-19) → CTA(20-22). |
| 2026-04-02 | Promo ImageRight on Brooklyn Data section | GUID for `ImageRight` variant sourced from `/Presentation/Headless Variants/VxaPromo/ImageRight` on the live `standard` site. |
| 2026-04-02 | "Our latest ideas" section complete | Full-width Rich Text header (centered) + Multi Promo (3 article cards). All 3 thumbnails uploaded. |
| 2026-04-03 | `who-we-are` page complete | Page ID `8a07b286-5dd1-4ba0-800b-6c430ecaa6ec`. 8 sections, 20 DPIDs. Script: `Build-WhoWeArePage.ps1` (archived). All 6 images in media library. |
| 2026-04-03 | `what-we-do` page complete (recreated) | Page ID `e2bf2f141a3340cc983a4f3b736e19ab`. 8 sections, 22 DPIDs. 20 media items: hero, 6 service images, Wendy Karlyn headshot, 12 client logos. Script: `Build-WhatWeDoPage.ps1`. |
| 2026-04-03 | `work` page complete | Page ID `c4740980-0a10-4b9c-bf95-1339cc4f3f88`. 4 sections, 8 DPIDs. Featured: Suncoast Credit Union (Promo ImageRight). 8-card grid with og:image per card. Script: `Build-WorkPage.ps1`. |

---

## Media Library

All media under `/sitecore/media library/dev-demos/standard/`.

| Folder | Contents | Confirmed |
|---|---|---|
| `work/` | 8 case study thumbnails (og:image per card) | 2026-04-03 |
| `what-we-do/` | Hero, 6 service images, Wendy Karlyn headshot, 12 client logos | 2026-04-03 |
| `who-we-are/` | 6 section images | 2026-04-03 |

GUIDs are encoded in the respective `Build-*.ps1` scripts.

> ⚠️ Media GUIDs survive page deletion but do NOT survive environment resets. Always run an idempotency check (`Get-SitecoreItemId`) before reusing GUIDs from a prior session.
