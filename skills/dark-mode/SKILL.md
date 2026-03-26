---
name: dark-mode
description: Design and implement comfortable dark mode interfaces. Use when creating dark themes, choosing dark mode colors, implementing theme switching, or reviewing dark mode contrast and accessibility.
---

# Dark Mode Design

Create dark mode interfaces that are comfortable for extended use. The key principle: **avoid pure black (#000) backgrounds and pure white (#FFF) text**.

## Quick Reference Values

| Element | Recommended Range | Examples |
|---------|-------------------|----------|
| Background | #0F0F10 to #1E1E2E | VS Code: #1E1E1E, GitHub: #0D1117 |
| Elevated surface | 5-16% lighter than bg | Cards: #1E1E1E, Dialogs: #272727 |
| Primary text | #CCCCCC to #E6EDF3 | Or white at 87% opacity |
| Secondary text | #8B949E to #B5BAC1 | Or white at 60% opacity |
| Borders | #30363D to #454545 | Or rgba(255,255,255,0.12) |
| Accent colors | Desaturate 20-30 points | #0066CC → #66B3FF |

## Why Not Pure Black/White

Pure white text on pure black creates **halation**—text appears to glow and blur. This affects ~50% of people (those with astigmatism). The 21:1 contrast ratio exceeds what's comfortable. Aim for **7:1 to 10:1** for extended reading.

Material Design's #121212 uses only 0.3% more battery than pure black on OLED—the battery argument for true black is largely moot.

## Creating Depth Without Shadows

Shadows become invisible on dark backgrounds. Instead, **elevated surfaces become progressively lighter**:

| Elevation | White Overlay | Example Color |
|-----------|---------------|---------------|
| Base (0dp) | 0% | #121212 |
| 1dp | 5% | ~#1E1E1E |
| 4dp | 9% | ~#232323 |
| 8dp | 12% | ~#272727 |
| 24dp (dialogs) | 16% | ~#2D2D2D |

Use subtle borders (`rgba(255,255,255,0.12)` or #333333-#454545) to define boundaries.

## Accent Color Adjustment

Saturated colors that work on white create optical vibrations on dark backgrounds. Shift accent colors:

- **Reduce saturation** by 20-30 points
- **Increase lightness** slightly
- Use Material Design **tonal value 200** instead of 500-600

Examples:
- Light mode #0066CC → Dark mode #66B3FF
- Discord blurple: #5865F2
- GitHub accent: #58A6FF
- Linear indigo: #5E6AD2

## Real-World Palettes

| App | Background | Surface | Text | Muted | Accent |
|-----|------------|---------|------|-------|--------|
| VS Code | #1E1E1E | #252526 | #CCCCCC | #BBBBBB | #007ACC |
| GitHub | #0D1117 | #161B22 | #E6EDF3 | #8B949E | #58A6FF |
| Discord | #313338 | #2B2D31 | #DBDEE1 | #B5BAC1 | #5865F2 |
| Linear | #0F0F10 | #151516 | #EEEFF1 | — | #5E6AD2 |
| Slack | #1A1D21 | #222529 | #D1D2D3 | #818385 | #1D9BD1 |

## Code/Terminal Themes

Code interfaces need extended viewing comfort:

- **Backgrounds**: #1A1B26 to #282C34
- **Foreground**: #ABB2BF to #D8DEE9
- **Limit syntax colors** to 8-12 distinct hues
- Keywords: purple/pink (prominent)
- Strings: green/yellow (differentiated)
- Comments: gray/muted blue (receded)

Popular themes: Dracula (#282A36), Nord (#2E3440), Catppuccin Mocha (#1E1E2E)

**Typography adjustment**: Light text on dark appears bolder. Consider reducing font weight or increasing letter-spacing by 0.5-1.5%.

## CSS Implementation

```css
:root {
  --color-background: #ffffff;
  --color-surface: #ffffff;
  --color-surface-elevated: #f5f5f5;
  --color-text: #1a1a1a;
  --color-text-muted: #666666;
  --color-border: #e5e5e5;
  --color-primary: #0066cc;
}

[data-theme="dark"] {
  --color-background: #121212;
  --color-surface: #1e1e1e;
  --color-surface-elevated: #2a2a2a;
  --color-text: #e0e0e0;
  --color-text-muted: #a0a0a0;
  --color-border: #333333;
  --color-primary: #66b3ff;
}
```

### Theme Detection + Toggle

```javascript
// Load before page renders (in <head>)
const stored = localStorage.getItem('theme');
const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
document.documentElement.setAttribute('data-theme',
  stored || (systemDark ? 'dark' : 'light'));
```

### Tailwind CSS

Use `darkMode: 'selector'` in config, then:
```html
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
```

Tailwind neutral scales for dark mode:
- **gray-900** (#111827) or **zinc-900** (#18181B) for backgrounds
- **800** step for elevated surfaces
- **700** step for borders

## WCAG Contrast Requirements

| Element | Minimum Ratio |
|---------|---------------|
| Normal text | 4.5:1 |
| Large text (18pt+ or 14pt bold) | 3:1 |
| UI components | 3:1 |
| Comfortable reading | 7:1 to 10:1 |

On #121212 background:
- #E0E0E0 → ~12:1 (comfortable, exceeds AAA)
- #FFFFFF → 15.8:1 (accessible but harsh)
- #B0B0B0 → ~7.5:1 (good for secondary text)

## Checklist

When implementing or reviewing dark mode:

- [ ] Background is dark gray (#121212-#1E1E2E), not pure black
- [ ] Text is off-white (#E0E0E0 or 87% opacity), not pure white
- [ ] Elevated surfaces are lighter than background
- [ ] Accent colors are desaturated 20-30 points from light mode
- [ ] Borders are visible but subtle (~12% white opacity)
- [ ] Contrast ratios meet WCAG (4.5:1 minimum, 7:1+ preferred)
- [ ] System preference detection works (`prefers-color-scheme`)
- [ ] User override persists (localStorage)
- [ ] No harsh contrast causing eye strain

## Common Mistakes

1. **Pure black backgrounds** — Use #121212-#1E1E2E instead
2. **Pure white text** — Use #E0E0E0 or 87% opacity white
3. **Same accent colors as light mode** — Desaturate and lighten
4. **Relying on shadows for depth** — Use lighter elevated surfaces
5. **Maximum contrast** — Aim for 7:1-10:1, not 21:1
6. **Ignoring font weight** — Light-on-dark text appears bolder
