---
name: 'VXA Next.js Storybook File Generation'
description: 'Stories in a VXA Next.js project reference variant component directly. Mock data is imported from a separate mock data file. Each story represents a different variant of the component, allowing for easy visualization and testing of various states and themes.'
applyTo: '**/*.stories.tsx'
---

# VXA Next.js Storybook File Generation

## Import Statements

### Example : Required Imports
The story files needs to import the necessary types from Storybook as well as the specific component variant being showcased.
```typescript
import type { Meta, StoryObj } from '@storybook/nextjs-vite';
import { ComponentNameDefault } from './variants/ComponentNameDefault';
```

### Example : Mock Data Imports
Each story imports mock data from a dedicated mock data file. This keeps the story definitions clean and focused on the component variants.
```typescript
import {
  defaultMockData,
  primarySchemeMockData,
  secondarySchemeMockData,
  accentSchemeMockData,
  noDescriptionMockData,
} from './ComponentName.mock';
```

## Story Definition
Stories are defined using the `Meta` and `StoryObj` types from Storybook. The `meta` object contains metadata about the component, including its title, the component itself, and any parameters such as layout settings.

### Example: Story Structure
```typescript
const meta: Meta<typeof ComponentNameDefault> = {
  title: 'Components/ComponentName',
  component: ComponentNameDefault,
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<typeof ComponentNameDefault>;
```

## Story Variants
Each story variant is created by exporting a constant that defines the arguments (`args`) for that specific variant. This allows for easy customization and testing of different component states.

### Example: Stories with Theme Variations
```typescript
// Include all color scheme variations
export const Default: Story = { args: { ...defaultMockData } };
export const PrimaryTheme: Story = { args: { ...primarySchemeMockData } };
export const SecondaryTheme: Story = { args: { ...secondarySchemeMockData } };
export const AccentTheme: Story = { args: { ...accentSchemeMockData } };
export const NoDescription: Story = { args: { ...noDescriptionMockData } };
```