---
name: 'VXA Next.js Tailwind CSS Architecture'
description: 'Instructions for the Tailwind v4 CSS architecture in a VXA Next.js project.'
applyTo: '**/*.css'
---

# Next.js Tailwind CSS Architecture

This document explains the Tailwind v4 CSS-only configuration used in the VXA project, including the structure of the `/styles` directory and how each piece fits together.

## Overview

The VXA project uses **Tailwind v4.0+** with a **CSS-only configuration** approach. This means:
- No `tailwind.config.js` or `.cjs` files are used
- All configuration is done through CSS files using `@theme` directives
- Design tokens from Figma are mapped to CSS variables with the `--vxa-*` prefix
- These CSS variables are then exposed as Tailwind utility classes

## Why This Approach?

1. **Design Token Integration**: Seamlessly integrate Figma design tokens into the codebase
2. **Theme Switching**: Enable runtime theme switching (e.g. brand-a, brand-b, light/dark modes)
3. **Maintainability**: Single source of truth for design values
4. **Type Safety**: CSS variables work well with TypeScript and component props
5. **Modern Standards**: Leverages Tailwind v4's native CSS configuration capabilities

## Directory Structure

```
/headapps/nextjs-content-sdk/src/styles/
├── globals.css          # Main entry point, imports all other CSS
├── text-vxa.css         # Custom responsive text utilities
└── themes/
    ├── brand-a.css      # Brand A light theme variables
    ├── brand-a-dark.css # Brand A dark theme variables
    ├── brand-b.css      # Brand B light theme variables
    ├── brand-b-dark.css # Brand B dark theme variables
    └── inline.css       # Maps VXA variables to Tailwind tokens
```
Note: brand-a, brand-b are theme names derived from the Figma Mode used to define them. 

## File Breakdown

### 1. globals.css (Entry Point)

**Purpose**: Main stylesheet that orchestrates all imports and base styles

**Key Responsibilities**:
- Imports Tailwind core (`@import "tailwindcss"`)
- Imports all theme files
- Imports custom utilities (`text-vxa.css`)
- Loads Tailwind plugins (e.g. `@tailwindcss/typography`, `tailwindcss-animate`)
- Defines custom variants (e.g. `@custom-variant dark`)
- Sets up inline theme overrides
- Applies base layer styles

**Structure**:
```css
@import "tailwindcss";
@import "./themes/brand-a.css";
@import "./themes/brand-a-dark.css";
@import "./themes/brand-b.css";
@import "./themes/brand-b-dark.css";
@import "./themes/inline.css";
@import "./text-vxa.css";

@plugin "@tailwindcss/typography";
@plugin "tailwindcss-animate";

@custom-variant dark (&:is(.dark *));

@theme inline {
  /* Project-specific overrides */
}

@layer base {
  /* Global base styles */
}
```

**Important Notes**:
- The order of imports matters - theme files must come before `inline.css`
- The `@custom-variant dark` enables dark mode using `.dark` class
- `@theme inline` section allows for project-specific CSS variable overrides
- `@layer base` applies default styles to elements

### 2. Theme Files (brand-a.css, brand-a-dark.css, etc.)

**Purpose**: Define theme-specific CSS variables mapped from Figma design tokens

**Naming Convention**: 
- All variables use the `--vxa-*` prefix
- Follow pattern: `--vxa-[category]-[name]`
  - Example: `--vxa-color-primary`, `--vxa-font-size-lg`, `--vxa-spacing-4`

**Structure**:
```css
/**
 * Do not edit directly, this file was auto-generated.
 */

.brand-a, html:has(.brand-a) {
  --vxa-color-primary: oklch(57.71% 0.2152 27.33);
  --vxa-color-primary-foreground: oklch(100% 0 0);
  --vxa-color-primary-hover: oklch(50.54% 0.1905 27.52);
  --vxa-font-size-base: 20px;
  --vxa-font-size-lg: 24px;
  --vxa-spacing-4: 1rem;
  --vxa-border-radius-default: 0.25rem;
  /* ...hundreds more variables */
}
```

**Key Points**:
- Files are **auto-generated** from Figma tokens (via TokenSync, manual process or Github Copilot)
- Uses class selector (`.brand-a`) for theme switching
- Uses `html:has(.brand-a)` to apply theme to portals/popovers outside main app
- Dark mode variants follow same pattern with `.dark` class
- Colors use OKLCH format for better perceptual uniformity

**Variable Categories**:
- `--vxa-color-*`: All color tokens (primary, secondary, accent, backgrounds, etc.)
- `--vxa-font-size-*`: Text size scale (2xs, xs, sm, base, lg, xl, 2xl, etc.)
- `--vxa-font-family-*`: Font family definitions (heading, body, accent, informational)
- `--vxa-font-weight-*`: Font weights (light, normal, medium, semibold, bold, extrabold)
- `--vxa-line-height-*`: Line height scale
- `--vxa-spacing-*`: Spacing scale (matches Tailwind's default scale)
- `--vxa-border-radius-*`: Border radius values (none, sm, default, md, lg, xl, 2xl, 3xl, full)
- `--vxa-blur-*`: Blur effect values
- `--vxa-border-width-*`: Border width values

### 3. inline.css (Token-to-Tailwind Bridge)

**Purpose**: Maps VXA CSS variables to Tailwind's internal token system

**Structure**:
```css
/**
 * Do not edit directly, this file was auto-generated.
 */

@theme inline {
  --color-primary: var(--vxa-color-primary);
  --color-primary-foreground: var(--vxa-color-primary-foreground);
  --color-secondary: var(--vxa-color-secondary);
  --font-size-base: var(--vxa-font-size-base);
  --font-size-lg: var(--vxa-font-size-lg);
  --spacing-4: var(--vxa-spacing-4);
  /* ...maps all VXA variables to Tailwind tokens */
}
```

**How It Works**:
1. VXA variables are defined in theme files (e.g., `--vxa-color-primary`)
2. `inline.css` maps them to Tailwind's expected token names (e.g., `--color-primary`)
3. Tailwind generates utility classes from these tokens (e.g., `.bg-primary`, `.text-primary`)

**Result**: You can use standard Tailwind utility classes that reference design system tokens:
```tsx
<div className="bg-primary text-primary-foreground">
  {/* Uses --vxa-color-primary and --vxa-color-primary-foreground */}
</div>
```

### 4. text-vxa.css (Custom Responsive Text Utilities)

**Purpose**: Provide responsive text sizing that scales across breakpoints

**Why Needed**: 
- Figma designs often specify different text sizes at different screen sizes
- Standard Tailwind text utilities are static (e.g., `text-lg` is always the same size)
- `text-vxa-*` utilities adapt automatically based on viewport width

## Common Issues & Solutions

### Issue: Theme doesn't apply to modal/popover
**Solution**: Ensure theme selector uses `html:has(.brand-a)` pattern in theme files

### Issue: Text size not responsive
**Solution**: Use `text-vxa-*` classes instead of `text-*` classes

### Issue: Color doesn't match Figma
**Solution**: Verify OKLCH value in theme file matches Figma's color space conversion

### Issue: New variable not working
**Solution**: Check all three locations:
1. Defined in `brand-*.css` as `--vxa-*`
2. Mapped in `inline.css` to Tailwind token
3. Used correctly in component

## Related Documentation

- [figma.instructions.md](./figma.instructions.md) - Complete design token reference and Figma integration guide
- [nextjs-guidelines.instructions.md](./nextjs-guidelines.instructions.md) - Component generation guidelines
- [nextjs-file-variant.instructions.md](./nextjs-file-variant.instructions.md) - Component styling patterns
