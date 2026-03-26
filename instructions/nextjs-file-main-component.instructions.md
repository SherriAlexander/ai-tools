---
name: 'VXA Next.js Main Component File Generation'
description: 'Instructions for generating main component files in a VXA Next.js project. Main component files control which variant to display, the props, dictionary and component state.'
applyTo: '**/*.tsx'
---

# VXA Next.js Main Component File Generation
Main components are where the variant references are governed. This is also the primary export interface for the consumers of the component. The names here are what are surfaced to the Sitecore system. These files are less about the detailed structure and interaction of the fields and more about which variant to display, when to display and what to display. The props, dictionary and component state are managed in this file. 

The component index will export each of the component variants. The main component should export as the `Default` function with a property for isPageEditing. Any additional variants should be exported as named exports.

## Import Statements
All imports should be included at the top of the file. Here are some examples of common import statements used within variants as well as when and how to use them.

### Example : Required Import useSitecore
Include Sitecore page context to determine editing mode.
```typescript
import { useSitecore } from '@sitecore-content-sdk/nextjs';
```

#### Usage
```typescript 
const { page } = useSitecore();
const isPageEditing = page?.mode?.isEditing ?? false;
```

### Example : Optional Import Props
Include the props for the component if they exist.
```typescript
import { ComponentNameProps } from './ComponentName.props';
```

### Example : Import Component Default Variant
Import the component variants to be used in the main component.
```typescript
import { ComponentNameDefault } from './variants/ComponentNameDefault';
```

### Example : Import Component Multiple Variants
Import the component variants to be used in the main component.
```typescript
import { ComponentNameDefault } from './variants/ComponentNameDefault';
import { ComponentNameVariantName } from './variants/ComponentNameVariantName';
```

## Main Component

### Example : Main Component with Page Context
```typescript
/**
 * Component description
 */
export const Default: React.FC<ComponentNameProps> = (props) => {
  const { page } = useSitecore();
  const isPageEditing = page?.mode?.isEditing ?? false;

  return <ComponentNameDefault {...props} isPageEditing={isPageEditing} />;
};
```

### Example : Main Component with Multiple Variants and Page Context
```typescript
/**
 * Component description
 */
export const Default: React.FC<ComponentNameProps> = (props) => {
  const { page } = useSitecore();
  const isPageEditing = page?.mode?.isEditing ?? false;

  return <ComponentNameDefault {...props} isPageEditing={isPageEditing} />;
};

// Variant
export const VariantName: React.FC<ComponentNameProps> = (props) => {
  const { page } = useSitecore();
  const isPageEditing = page?.mode?.isEditing ?? false;
 
  return <ComponentNameVariantName {...props} isPageEditing={isPageEditing} />;
};
```

## Component Map Update
After the main component file is created, ensure that the the component map, `component-map.ts`, which is located in the global lib folder, is updated with the new component reference. 

### Example : Component Map Update
```typescript
import * as ComponentName from '@/components/vxa/component-name/ComponentName';
```

### Example : Component Map Entry
```typescript

['ComponentName', ComponentName],
