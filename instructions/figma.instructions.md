---
name: 'VXA Figma Design System Reference'
description: 'Reference for mapping Figma design tokens to CSS variables and Tailwind utility classes in the Velir Experience Accelerator (VXA) project. Use this reference when creating or modifying components to ensure consistency with the design system.'
applyTo: '**/*.css, **/*.scss'
---
# Figma Design System for a Velir Experience Accelerator (VXA) Project

The VXA design system implements a token-based approach where:

- Figma design tokens are mapped to CSS variables with the `--vxa-*` prefix
- These CSS variables are then mapped to Tailwind utility classes through the `inline.css` file
- When creating components, use the Tailwind utility classes to apply design tokens

## Styling Guide
This document outlines the styling conventions and best practices for implementing Figma designs in a Velir Experience Accelerator (VXA) project using Tailwind CSS and CSS variables.

### Styling Approaches
- This project uses Tailwind v4+ with CSS-only configuration
- Prefer Tailwind for styling, some projects may use CSS modules but should rarely be needed
- Use design system tokens defined as CSS variables
- Implement responsive designs using Tailwind container queries
- Follow mobile-first approach for all components

### Tailwind and CSS Configuration
- This project uses Tailwind v4.0+ and PostCSS v8.0+
- All theme configuration is done in the `/styles` directory
- Use CSS variables defined in `/styles` directory for:
  - Color schemes (`.bg-primary .text-primary-foreground`, `.bg-secondary .text-secondary-foreground`, `.bg-accent .text-accent-foreground` etc.)
  - Typography scales, Figma font sizes map to a custom vxa class named `.text-vxa-*`
  - Spacing units follow Tailwind's spacing scale (e.g., `p-4`, `m-2`, `space-y-4`)
- Apply Tailwind classes that reference these CSS variables following the shadcn/UI pattern
  - example: `bg-primary text-primary-foreground` for background color
- Follow mobile-first responsive approach using Tailwind breakpoint prefixes

### Container Queries
- Use container queries for responsive elements with `@container` class
- Define appropriate breakpoints for component-specific responsive behavior
- Nested components should use their own container query context

### Responsive Design Best Practices
- Start with mobile layout and progressively enhance for larger screens
- Use Tailwind's responsive prefixes (sm:, md:, lg:, xl:) consistently
- Ensure all components function and look good across all breakpoints
- Test on various device sizes and orientations

### Component-Specific Styling
- Use Tailwind's utility classes for component-specific style
- Ensure sufficient contrast for accessibility

### Animation & Transitions
- Use CSS variables for animation durations and timing functions
- Keep animations subtle and performance-oriented
- Use `prefers-reduced-motion` media query for accessibility
- Implement animation with Tailwind's transition utilities when possible

### Accessibility Color Requirements
- Maintain a minimum color contrast ratio of 4.5:1 for text
- Use the design system's color tokens which are designed for accessibility
- Avoid conveying information through color alone
- Test color combinations with accessibility tools

## Bootstrapping Tailwind Configuration from Figma
1. Provide Copilot with a Figma URL (must include filekey and nodeid) or a design token JSON file.
2. For a more thorough tailwind css configuration, provide additional nodeids as needed.
3. Copilot will generate the required Tailwind CSS files.
   - **Best Practice:** Use the Tailwind Theme Architect agent for this task.
4. This process can be repeated at any time to re-bootstrap or update the theme.

!important: Only use CSS-based Tailwind config. Do not generate or use tailwind.config.js or .cjs files.

## Figma Variable Sync During Component Generation
- Every time a Figma file (with filekey and nodeid) is referenced ask if I would like to sync my tailwind config.
  Steps to sync tailwind css with figma:
    1. Copilot must run the `get_variable_defs` Figma MCP tool to extract all defined variables.
    2. Copilot must check that all variables are present in the Tailwind configuration.
    3. Any missing variables should be flagged or added to ensure the Tailwind config is always up to date with Figma.
- This ensures design fidelity and reduces drift between design and implementation.

## Color System

### Primary Colors

These colors are used for primary UI elements, CTAs, and key interaction points.

| Figma Token       | Figma Value      | CSS Variable                | Tailwind Class            | OKLCH Value                  | Usage                   |
|-------------------|-----------------|-----------------------------|--------------------------|-----------------------------|-----------------------|
| primary           | #D1563C         | `--vxa-color-primary`       | `bg-primary`             | `oklch(57.71% 0.2152 27.33)` | Primary backgrounds     |
| primaryForeground | #FFFFFF         | `--vxa-color-primary-foreground` | `text-primary-foreground` | `oklch(100% 0 0)`         | Text on primary bg      |
| primaryHover      | #B84C34         | `--vxa-color-primary-hover` | `hover:bg-primary-hover` | `oklch(50.54% 0.1905 27.52)` | Primary hover state     |
| secondary         | #EDEFF3         | `--vxa-color-secondary`     | `bg-secondary`           | `oklch(92.88% 0.0126 255.51)` | Secondary backgrounds   |
| secondaryForeground | #000000       | `--vxa-color-secondary-foreground` | `text-secondary-foreground` | `oklch(0% 0 0)`  | Text on secondary bg    |

### Accent Colors

These colors are used for accents, highlights, and supporting UI elements.

| Figma Token       | Figma Value      | CSS Variable                | Tailwind Class            | OKLCH Value                  | Usage                   |
|-------------------|-----------------|-----------------------------|--------------------------|-----------------------------|-----------------------|
| accent            | #EAB588         | `--vxa-color-accent`        | `bg-accent`              | `oklch(80.77% 0.1035 19.57)` | Accent backgrounds      |
| accentForeground  | #000000         | `--vxa-color-accent-foreground` | `text-accent-foreground` | `oklch(0% 0 0)`       | Text on accent bg        |
| accent2           | #000000         | `--vxa-color-accent-2`      | `bg-accent-2`            | `oklch(0% 0 0)`              | Secondary accent bg     |
| accent2Foreground | #FFFFFF         | `--vxa-color-accent-2-foreground` | `text-accent-2-foreground` | `oklch(100% 0 0)` | Text on accent-2 bg     |

### UI Colors

These colors are used for backgrounds, cards, borders, and other UI elements.

| Figma Token       | Figma Value      | CSS Variable                | Tailwind Class            | OKLCH Value                  | Usage                   |
|-------------------|-----------------|-----------------------------|--------------------------|-----------------------------|-----------------------|
| background        | #FFFFFF         | `--vxa-color-background`    | `bg-background`          | `oklch(100% 0 0)`            | Page backgrounds        |
| foreground        | #000000         | `--vxa-color-foreground`    | `text-foreground`        | `oklch(0% 0 0)`              | General text            |
| card              | #FFFFFF         | `--vxa-color-card`          | `bg-card`                | `oklch(100% 0 0)`            | Card backgrounds        |
| cardForeground    | #000000         | `--vxa-color-card-foreground` | `text-card-foreground`  | `oklch(0% 0 0)`            | Text on cards           |
| border            | #E6E6E6         | `--vxa-color-border`        | `border-border`          | `oklch(92.19% 0 0)`          | Borders                 |
| muted             | #E6E6E6         | `--vxa-color-muted`         | `bg-muted`               | `oklch(92.19% 0 0)`          | Muted backgrounds       |
| mutedForeground   | #717171         | `--vxa-color-muted-foreground` | `text-muted-foreground` | `oklch(71.55% 0 0)`      | Muted text              |

### Feedback Colors

These colors are used for alerts, notifications, and feedback.

| Figma Token       | Figma Value      | CSS Variable                | Tailwind Class            | OKLCH Value                  | Usage                   |
|-------------------|-----------------|-----------------------------|--------------------------|-----------------------------|-----------------------|
| destructive       | #D1563C         | `--vxa-color-destructive`   | `bg-destructive`         | `oklch(57.71% 0.2152 27.33)` | Error states            |
| alert1            | #4C8BF5         | `--vxa-color-alert-1`       | `bg-alert-1`             | `oklch(68.47% 0.1479 237.32)` | Information alerts      |
| alert2            | #FFAA42         | `--vxa-color-alert-2`       | `bg-alert-2`             | `oklch(75.76% 0.159 55.93)`  | Warning alerts          |
| alert3            | #E64A19         | `--vxa-color-alert-3`       | `bg-alert-3`             | `oklch(63.68% 0.2078 25.33)` | Error alerts            |

## Typography

### Font Sizes

VXA uses a responsive text size system with the `text-vxa-*` utility classes. These map to different text sizes at different breakpoints.

| Figma Token    | Figma Value | CSS Variable            | VXA Class          | Mobile (<768px)   | MD (≥768px)      | XL (≥1280px)     |
|----------------|-------------|-------------------------|--------------------|--------------------|------------------|------------------|
| fontSize.2xs   | 12px        | `--vxa-font-size-2xs`   | `text-vxa-2xs`     | 12px (0.75rem)     | 12px (0.75rem)   | 14px (0.875rem)  |
| fontSize.xs    | 14px        | `--vxa-font-size-xs`    | `text-vxa-xs`      | 14px (0.875rem)    | 14px (0.875rem)  | 16px (1rem)      |
| fontSize.sm    | 16px        | `--vxa-font-size-sm`    | `text-vxa-sm`      | 16px (1rem)        | 16px (1rem)      | 16px (1rem)      |
| fontSize.base  | 20px        | `--vxa-font-size-base`  | `text-vxa-base`    | 16px (1rem)        | 20px (1.25rem)   | 24px (1.5rem)    |
| fontSize.lg    | 24px        | `--vxa-font-size-lg`    | `text-vxa-lg`      | 20px (1.25rem)     | 24px (1.5rem)    | 28px (1.75rem)   |
| fontSize.xl    | 28px        | `--vxa-font-size-xl`    | `text-vxa-xl`      | 24px (1.5rem)      | 28px (1.75rem)   | 32px (2rem)      |
| fontSize.2xl   | 32px        | `--vxa-font-size-2xl`   | `text-vxa-2xl`     | 28px (1.75rem)     | 32px (2rem)      | 36px (2.25rem)   |
| fontSize.3xl   | 36px        | `--vxa-font-size-3xl`   | `text-vxa-3xl`     | 32px (2rem)        | 36px (2.25rem)   | 40px (2.5rem)    |
| fontSize.4xl   | 40px        | `--vxa-font-size-4xl`   | `text-vxa-4xl`     | 36px (2.25rem)     | 40px (2.5rem)    | 48px (3rem)      |
| fontSize.5xl   | 48px        | `--vxa-font-size-5xl`   | `text-vxa-5xl`     | 40px (2.5rem)      | 48px (3rem)      | 56px (3.5rem)    |
| fontSize.6xl   | 56px        | `--vxa-font-size-6xl`   | `text-vxa-6xl`     | 48px (3rem)        | 56px (3.5rem)    | 64px (4rem)      |
| fontSize.7xl   | 64px        | `--vxa-font-size-7xl`   | `text-vxa-7xl`     | 56px (3.5rem)      | 64px (4rem)      | 72px (4.5rem)    |
| fontSize.8xl   | 72px        | `--vxa-font-size-8xl`   | `text-vxa-8xl`     | 56px (3.5rem)      | 72px (4.5rem)    | 80px (5rem)      |
| fontSize.9xl   | 80px        | `--vxa-font-size-9xl`   | `text-vxa-9xl`     | 56px (3.5rem)      | 80px (5rem)      | 88px (5.5rem)    |
| fontSize.10xl  | 88px        | `--vxa-font-size-10xl`  | `text-vxa-10xl`    | 56px (3.5rem)      | 88px (5.5rem)    | 88px (5.5rem)    |

**IMPORTANT**: Always use the `text-vxa-*` classes instead of standard Tailwind `text-*` classes to ensure proper responsive behavior.

### Font Weights

| Figma Token    | Figma Value | CSS Variable                | Tailwind Class       | Value  |
|----------------|-------------|-----------------------------|--------------------|--------|
| fontWeight.light| Light      | `--vxa-font-weight-light`   | `font-light`       | 300    |
| fontWeight.normal| Regular   | `--vxa-font-weight-normal`  | `font-normal`      | 400    |
| fontWeight.medium| Medium    | `--vxa-font-weight-medium`  | `font-medium`      | 500    |
| fontWeight.semibold| Semibold| `--vxa-font-weight-semibold`| `font-semibold`    | 600    |
| fontWeight.bold| Bold        | `--vxa-font-weight-bold`    | `font-bold`        | 700    |
| fontWeight.extrabold| ExtraBold| `--vxa-font-weight-extrabold`| `font-extrabold`| 800    |

### Line Heights

| Figma Token      | Figma Value | CSS Variable              | REM Value | Pixel Value |
|------------------|-------------|---------------------------|-----------|-------------|
| lineHeight.xs    | 18px        | `--vxa-line-height-xs`    | 1.125rem  | 18px        |
| lineHeight.sm    | 22px        | `--vxa-line-height-sm`    | 1.375rem  | 22px        |
| lineHeight.base  | 28px        | `--vxa-line-height-base`  | 1.75rem   | 28px        |
| lineHeight.lg    | 32px        | `--vxa-line-height-lg`    | 2rem      | 32px        |
| lineHeight.xl    | 36px        | `--vxa-line-height-xl`    | 2.25rem   | 36px        |
| lineHeight.2xl   | 44px        | `--vxa-line-height-2xl`   | 2.75rem   | 44px        |
| lineHeight.3xl   | 48px        | `--vxa-line-height-3xl`   | 3rem      | 48px        |
| lineHeight.4xl   | 56px        | `--vxa-line-height-4xl`   | 3.5rem    | 56px        |
| lineHeight.5xl   | 64px        | `--vxa-line-height-5xl`   | 4rem      | 64px        |
| lineHeight.6xl   | 72px        | `--vxa-line-height-6xl`   | 4.5rem    | 72px        |

## Spacing

Spacing values for margin, padding, gap, etc.

| Figma Token   | Figma Value | CSS Variable       | Tailwind Class   | REM Value | Pixel Value |
|---------------|-------------|-------------------|-----------------|-----------|-------------|
| spacing.0     | 0px         | `--vxa-height-0`   | `p-0`, `m-0`     | 0         | 0px         |
| spacing.1     | 4px         | `--vxa-height-1`   | `p-1`, `m-1`     | 0.25rem   | 4px         |
| spacing.2     | 8px         | `--vxa-height-2`   | `p-2`, `m-2`     | 0.5rem    | 8px         |
| spacing.3     | 12px        | `--vxa-height-3`   | `p-3`, `m-3`     | 0.75rem   | 12px        |
| spacing.4     | 16px        | `--vxa-height-4`   | `p-4`, `m-4`     | 1rem      | 16px        |
| spacing.5     | 20px        | `--vxa-height-5`   | `p-5`, `m-5`     | 1.25rem   | 20px        |
| spacing.6     | 24px        | `--vxa-height-6`   | `p-6`, `m-6`     | 1.5rem    | 24px        |
| spacing.8     | 32px        | `--vxa-height-8`   | `p-8`, `m-8`     | 2rem      | 32px        |
| spacing.10    | 40px        | `--vxa-height-10`  | `p-10`, `m-10`   | 2.5rem    | 40px        |
| spacing.12    | 48px        | `--vxa-height-12`  | `p-12`, `m-12`   | 3rem      | 48px        |
| spacing.16    | 64px        | `--vxa-height-16`  | `p-16`, `m-16`   | 4rem      | 64px        |
| spacing.20    | 80px        | `--vxa-height-20`  | `p-20`, `m-20`   | 5rem      | 80px        |
| spacing.24    | 96px        | `--vxa-height-24`  | `p-24`, `m-24`   | 6rem      | 96px        |

## Border Radius

Border radius values for rounded corners.

| Figma Token     | Figma Value | CSS Variable                | Tailwind Class        | Value    |
|-----------------|-------------|----------------------------|---------------------|----------|
| radius.none     | 0px         | `--vxa-border-radius-none` | `rounded-none`      | 0        |
| radius.sm       | 2px         | `--vxa-border-radius-sm`   | `rounded-sm`        | 0.125rem |
| radius.default  | 4px         | `--vxa-border-radius-default` | `rounded-default` | 0.25rem |
| radius.md       | 6px         | `--vxa-border-radius-md`   | `rounded-md`        | 0.375rem |
| radius.lg       | 8px         | `--vxa-border-radius-lg`   | `rounded-lg`        | 0.5rem   |
| radius.xl       | 12px        | `--vxa-border-radius-xl`   | `rounded-xl`        | 0.75rem  |
| radius.2xl      | 16px        | `--vxa-border-radius-2xl`  | `rounded-2xl`       | 1rem     |
| radius.3xl      | 24px        | `--vxa-border-radius-3xl`  | `rounded-3xl`       | 1.5rem   |
| radius.full     | 9999px      | `--vxa-border-radius-full` | `rounded-full`      | 9999px   |

## Usage in Components

When creating components, use the Tailwind utility classes that correspond to the design tokens:

```tsx
// Example component using design tokens
<div className="bg-primary text-primary-foreground p-6 rounded-default">
  <h2 className="text-vxa-2xl font-semibold">Heading</h2>
  <p className="text-vxa-base">Description text</p>
  <button className="bg-secondary text-secondary-foreground px-4 py-2 rounded-md">
    Click Me
  </button>
</div>
```

### Common Patterns

1. **Text Styling**:
   ```tsx
   <h1 className="text-vxa-3xl font-bold text-foreground">
     Main Heading
   </h1>
   ```

2. **Button Styling**:
   ```tsx
   <button className="bg-primary text-primary-foreground hover:bg-primary-hover px-4 py-2 rounded-md">
     Submit
   </button>
   ```

3. **Card Styling**:
   ```tsx
   <div className="bg-card text-card-foreground p-6 rounded-lg shadow-md">
     Card Content
   </div>
   ```

4. **Container and Spacing**:
   ```tsx
   <div className="max-w-150 mx-auto p-6 gap-4">
     Container Content
   </div>
   ```

## Task: Adding or Updating a Tailwind Theme
When the user asks to add or modify themes and provides a link to figma:
1. Ask for additional nodeIds to build a more thorough stylesheet.
2. Use Figma MCP to get variables defined in each design (nodeId) provided.
3. Regenerate CSS into headapps/nextjs-content-sdk/src/styles following the existing pattern set up.

## Task: Figma Token Sync
When working with design tokens:
- Use token JSON as the source of truth
- Extract design tokens
- Regenerate CSS into headapps/nextjs-content-sdk/src/styles

## Task: Updating This Reference
This design system reference should be updated whenever:

1. New design tokens are added to Figma
2. CSS variables are modified in the theme files
3. Tailwind configuration changes

To update this file:

1. Extract the latest design tokens from Figma
2. Update the CSS variables in the theme files (e.g., `brand-a.css`)
3. Update the `inline.css` file to map CSS variables to Tailwind utility classes
4. Update this reference document with the new mappings

Always keep this reference in sync with the actual design system implementation to ensure consistent component development.

## Task: Incremental Design System Updates
Whenever a component is generated with a Figma Link get the variables used in the component design with Figma MCP and ensure they are accurately reflected in the stylesheet following the VXA theming pattern.