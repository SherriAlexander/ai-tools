

# Next.js Props File Generation
Props follow the three-part pattern (Params, Fields, Props). This pattern should be followed for all components to ensure consistency unless it is specified to be a sub-component or part of a larger component, in that case use a simpler props structure. Params, props and fields may not be necessary.

## Import Statements
Not all imports are required for every props file, but the most commonly used imports are shown below. Decide which imports are necessary based on the fields and parameters defined for the component.

### Example : Required Import
```typescript
import { ComponentProps } from '@/lib/component-props';
```

### Example : Optional Enumeration Imports
```typescript
import { EnumValues } from '@/enumerations/generic.enum';
import { IconName } from '@/enumerations/Icon.enum';
import { IconPosition } from '@/enumerations/IconPosition.enum';
import { BottomMargin } from '@/enumerations/BottomMargin.enum';
import { Gap } from '@/enumerations/Gap.enum';
```

### Example : Optional Field Imports
```typescript 
import { TextField, RichTextField, ImageField, LinkField } from '@sitecore-content-sdk/nextjs';
```

### Example : Optional React Import
```typescript 
import { ReactNode } from 'react';
```

## Props Data Structure
The props should define each of the three parts: Params, Fields, and Props. If a part is not needed, it can be omitted. The export statement at the end should combine all parts into a single Props type. The individual parts should follow the naming convention of `ComponentNameParams`, `ComponentNameFields`, and `ComponentNameProps` and the inner structure of the fields should match the data structure being used (Layout Service or GraphQL). All fields and parameters may have a required or optional designation based on the component's needs. This requirement comes from the data table in the Jira ticket and should be followed exactly.

### Example : Params
```typescript
export type ComponentNameParams = {
  params: {
    colorScheme?: EnumValues<typeof ColorScheme>;
    styles?: string;
    [key: string]: any; // eslint-disable-line @typescript-eslint/no-explicit-any
  };
};
```

### Example : Layout Service Fields
Fields are nested under the `fields` property
```typescript
export type ComponentNameFields = {
  fields?: {
    title?: TextField;
    description?: RichTextField;
    image?: ImageField;
    link?: LinkField;
    // Add other fields as needed
  };
};
```

### Example : GraphQL Fields
Fields are nested under `fields.data.datasource`
```typescript
export type ComponentNameFields = {
  fields?: {
    data: {
      datasource: {
        title?: {
          jsonValue: Field<string>;
        };
        description?: {
          jsonValue: RichTextField;
        };
        image?: {
          jsonValue: ImageField;
        };
        link?: {
          jsonValue: LinkField;
        };
        // Add other fields as needed
      };
      externalFields?: {
        // Page-level fields that the component needs access to (if specified)
        pageTitle?: {
          jsonValue: Field<string>;
        };
        // Add other external fields if needed
      };
    };
  }
};
```

### Example : Layout Service Export Statement
```typescript
export type ComponentNameProps = ComponentProps & ComponentNameFields & ComponentNameParams;
```