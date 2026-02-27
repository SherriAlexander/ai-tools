# Next.js Component File Generation Guidelines
Components should always use TypeScript formatting and typing.  Below are the patterns and order that must be followed so that styling, theming, error handling, and Storybook integration are consistent across all components.

When generating Next.js components, the following guidelines must be adhered to for imports, styling, dictionary files, props files, mock files, variant files, main component files, and Storybook files.

## Import Statements
Import statements reference external objects that are used in the code. These external objects should be imported through import statements to allow a file to pass compilation. Imports may include the ComponentProps from core architecture, the defined props for the current object and any field types needed to define the fields uses in the current component object. Import statements should not be duplicated. Using them once is sufficient. If you're referencing multiple objects from the same source, group them into a single import statement with each object separated by a comma.

Fields defined in Jira should be interpreted to use the supported field types and imported with that chosen type. Here are the field types that should be used for common field definitions:
- **Text content**: Use `TextField`
- **Rich text/HTML content**: Use `RichTextField` (NOT TextField)
- **Links**: Use `LinkField`
- **Images**: Use `ImageField`

## NEVER Use These Imports
**CRITICAL 1.0.0 UPDATE**: The `@sitecore-jss/sitecore-jss-nextjs` and `@sitecore-jss/sitecore-jss-react` packages have been completely removed in Content SDK 1.0.0 and are no longer available. All functionality has been consolidated into the `@sitecore-content-sdk/nextjs` package.

### Example: Forbidden Import Statements
```typescript
import { ... } from '@sitecore-jss/sitecore-jss-nextjs';
import { ... } from '@sitecore-jss/sitecore-jss-react';
```

## Styling Requirements
When developing CSS class properties in code, implement responsive design with container queries. Also apply proper Tailwind classes based on design. These classes are mandatory unless a specific design requirement states otherwise. Here are some examples of mandatory and forbidden classes and how they would be defined.

### Example : Mandatory CSS Classes
```typescript
// Container queries - CRITICAL
className="@container"

// Typography - Use VXA classes
className="text-vxa-2xl font-semibold"    // For headings
className="text-vxa-base"                 // For body text

// Sizing - Use consistent widths
className="max-w-240"  // For full-width containers
className="max-w-150"  // For content containers

// Border radius - Use design system
className="rounded-default"

// Color application - Use CVA utilities for color schemes
const { bgClass, textClass } = getColorClassNamesCva(colorScheme);
className={cn("bg-background text-foreground", bgClass, textClass)}
```

### Example : Forbidden Classes
```typescript
// DON'T USE generic text sizes
className="text-4xl text-lg text-xl"  // Use text-vxa-* instead

// DON'T USE arbitrary values without design system
className="max-w-[800px] rounded-lg"  // Use max-w-240 rounded-default
```

## Filesystem
When a Jira ticket defines a component, you should adhere to the following file and script structure so that they are compliant as a Velir Experience Accelerator (VXA) component for Next.js. This will ensure consistency, proper integration and facilitate easier maintenance and scalability.

Components are made up of multiple files, in a folder, each serving a specific purpose. The name of the component should be extracted from the Jira ticket title and used to create files and script architecture within those files. The component name itself will be referenced throughout examples in different casing formats as the component name such as component name, component-name or ComponentName. A component may also have multiple display variations known as variants and will be referenced throughout examples as the variant name such as variant name, variant-name or VariantName. A component may also have reusable sections known as sub-components and will be referenced throughout examples as the sub component name such as sub component name, sub-component-name or SubComponentName. When you see any of those you should replace it with the actual component, variant name or sub-component name respectively. If a file doesn't meet the stated requirement condition, then it can be omitted. The parent component folder should be created using the component name in kebab-case format. 

Managed items, also known as insertable items or child items, mentioned in a Jira ticket should be placed in a `parts` subfolder within the main component folder. Managed items script structure should be generated following the variant format. They may also have their own props and mock files created alongside them.

Sub-components are smaller, reusable pieces of UI that are part of a larger component that are not defined by managed items. If the requirement condition is met, a sub-components folder named after the function of the sub-component, using kebab-case, should be created within the `parts` subfolder within the main component folder. Sub-component should follow variant file formats.They may also have their own props and mock file created alongside them. 

### File Types and Extensions
Below are the component files, conditions and their naming specifications:

- Props files
  - Purpose: Data type definitions
  - Requirement Condition: always required
  - Naming Convention: PascalCase
  - Extension: `.props.ts`
  - Example: `ComponentName.props.ts`
- Variant files
  - Purpose: Different visual or functional variations of the component
  - Requirement Condition: at least one variant (default) required, additional variants as needed
  - Naming Convention: PascalCase with variant name suffix
  - Extension: `.tsx`
  - Example: `ComponentNameDefault.tsx`, `ComponentNameVariantName.tsx`
- Managed Item files
  - Purpose: Separate parts of a component that can be reused and has it's own data structure
  - Requirement Condition: only if Jira ticket specifies managed items
  - Naming Convention: PascalCase with variant name suffix
  - Extension: `.tsx`
  - Example: `ComponentNameItem.tsx`
- Sub Component files
  - Purpose: Smaller reusable pieces of UI within a component
  - Requirement Condition: only if there are reusable sections of code that aren't managed items
  - Naming Convention: PascalCase with variant name suffix
  - Extension: `.tsx`
  - Example: `SubComponentName.tsx`
- Main Component files
  - Purpose: Exports with Sitecore page context
  - Requirement Condition: always required
  - Naming Convention: PascalCase
  - Extension: `.tsx`
  - Example: `ComponentName.tsx`
- Mock files
  - Purpose: Data type populate with realistic mock data for testing and Storybook
  - Requirement Condition: always required
  - Naming Convention: PascalCase
  - Extension: `.mock.tsx`
  - Example: `ComponentName.mock.tsx`
- Dictionary File
  - Purpose: Component dictionary items for localization
  - Requirement Condition: only if jira ticket specifies dictionary items
  - Naming Convention: PascalCase
  - Extension: `.dictionary.ts`
  - Example: `ComponentName.dictionary.ts`
- Story files
  - Purpose: Storybook stories for component visualization and testing
  - Requirement Condition: always required
  - Naming Convention: PascalCase
  - Extension: `.stories.tsx`
  - Example: `ComponentName.stories.tsx`
- Hooks
  - Purpose: Custom React hooks for component logic
  - Requirement Condition: only if logic requires custom hooks
  - Naming Convention: kebab-case with "use" prefix
  - Extension: `.ts`
  - Example: `use-product-data.ts`
- Utilities
  - Purpose: Helper functions for component logic 
  - Requirement Condition: only if logic is long or dense enough to be split out into utility functions
  - Naming Convention: kebab-case
  - Extension: `.ts`
  - Example: `format-currency.ts`

### File Creation Order
When creating a new component, files should be created in the following order to ensure proper dependencies and structure:
1. Dictionary file (if applicable)
2. Props file
3. Mock file
4. Managed Item files (if applicable)
5. Sub-component files (if applicable)
6. Variant files
   - 4a. Default variant (always required)
   - 4b. Additional variants as needed
7. Hooks (if applicable)
8. Utilities (if applicable)
9. Main Component file
10. Story files

### Example: Component Directory Structure with all files
```
component-name/
├── parts/
│   ├── ComponentNameItem.props.ts
│   ├── ComponentNameItem.tsx
│   └── sub-component-name/
│       ├── SubComponentName.props.ts
│       └── SubComponentName.tsx
├── variants/
│   ├── ComponentNameDefault.tsx
│   └── ComponentNameVariantName.tsx
├── ComponentName.dictionary.ts
├── ComponentName.mock.tsx
├── ComponentName.props.ts
├── ComponentName.stories.tsx
├── ComponentName.tsx
```

### Example: Component Directory Structure with default variant and custom styles
```
component-name/
├── variants/
│   ├── ComponentNameVariantName.tsx
│   └── ComponentNameDefault.tsx
├── ComponentName.dictionary.ts
├── ComponentName.mock.tsx
├── ComponentName.props.ts
├── ComponentName.stories.tsx
├── ComponentName.tsx
```

### Example: Component Directory Structure with a managed item
```
component-name/
├── parts/
│   ├── ComponentNameItem.props.ts
│   └── ComponentNameItem.tsx
├── variants/
│   └── ComponentNameDefault.tsx
├── ComponentName.dictionary.ts
├── ComponentName.mock.tsx
├── ComponentName.props.ts
├── ComponentName.stories.tsx
├── ComponentName.tsx
```

### Example: Component Directory Structure with a sub-component
```
component-name/
├── parts/
│   └── sub-component/
│       ├── SubComponent.props.ts
│       └── SubComponent.tsx
├── variants/
│   └── ComponentNameDefault.tsx
├── ComponentName.dictionary.tsx
├── ComponentName.mock.tsx
├── ComponentName.props.ts
├── ComponentName.stories.tsx
├── ComponentName.tsx
```

### Example: Component Directory Structure with minimal files
```
component-name/
├── variants/
│   └── ComponentNameDefault.tsx
├── ComponentName.mock.tsx
├── ComponentName.props.ts
├── ComponentName.stories.tsx
├── ComponentName.tsx
```

### Example: Use Product Data Hook
```
├── hooks/
    └── use-product-data.ts
```

### Example: Format Currency Utility
```
├── utils/
    └── format-currency.ts
```