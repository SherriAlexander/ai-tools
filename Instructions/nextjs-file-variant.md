
# Next.js Variant File Generation

## Heading Statements
Specific types of components will require a heading statement indicating it that it will have javascript that should run in the client environment. This occurs when the component uses React hooks (useState, useEffect, useId, etc.), Event handlers (onClick, onSubmit, etc.), Browser-only APIs, Interactive components, or Third-party libraries that require client-side JS. If any of these cases are indicated, the file must include the 'use client' directive at the top of the file.

## Import Statements
Variants are where the core functionality is and as a result use the widest variety of imports statements including for enumerations, parameters, fallbacks, fields and functions. All imports should be included at the top of the file. Here are some examples of common import statements used within variants and when to use them.

### Example : Required Import
```typescript
import React from 'react';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { ComponentNameProps } from '../ComponentName.props';
```

### Example : Required Import for Managed Items
```typescript
import React from 'react';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { ComponentNameItemProps } from '../ComponentNameItem.props';
```

### Example : Required Import for Sub Components
```typescript
import React from 'react';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { SubComponentNameProps } from '../SubComponentName.props';
```

### Example : Required Import with additional React functions
The additional functions from React should be included when they are used within the variant. Any not needed imports should be omitted.
```typescript
import React, { useId, useRef, useEffect, useState, JSX } from 'react';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { ComponentNameProps } from '../ComponentName.props';
```

### Example : Optional Import for cn utility
The cn function is a utility for conditionally merging CSS class names. If a component needs to merge groups of CSS classes or CSS classes with conditions then this will be needed.

```typescript
import { cn } from '@/lib/utils';
```

### Example : Optional Import for fields from Sitecore Content SDK
If the component uses fields from Sitecore Content SDK such as Text or RichText, these imports should be included as needed. Any not needed imports should be omitted.
```typescript
import { Text } from '@sitecore-content-sdk/nextjs';
import { RichText } from '@sitecore-content-sdk/nextjs';
import { withDatasourceCheck } from '@sitecore-content-sdk/nextjs';
import { Link as JssLink, LinkField, TextField } from '@sitecore-content-sdk/nextjs';
import { Field, ImageField } from '@sitecore-content-sdk/nextjs';
```

### Example : Optional Import for fields from Sitecore Content SDK
If the component uses Head from Next.js for SEO or other head management, this import should be included.
```typescript
import Head from 'next/head';
```

### Example : Optional Import for other libraries and components
Depending on the functionality of the component, various other libraries and components may be needed. Here are some examples:
```typescript
import client from 'lib/sitecore-client';
import { ComponentProps } from 'lib/component-props';
```

### Example : Optional Import for VXA components and utilities
If the component uses VXA components or utilities, these imports should be included as needed. Any not needed imports should be omitted.
```typescript
import { AnimatedSection } from '@/components/vxa/ui/animated-section/AnimatedSection';
import { ImageWrapper } from '@/components/vxa/image/ImageWrapper';
import { MediaEditor } from '@/components/vxa/ui/editing/MediaEditor';
import { VideoPlayer } from '@/components/vxa/video/parts/VideoPlayer';
import { ButtonBase } from '@/components/vxa/button/VXAButton';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
```

### Example : Optional Import for component specific sub components and utilities
If the component uses specific sub components or utilities, these imports should be included as needed. Any not needed imports should be omitted.
```typescript
import { EntityName } from '../EntityNme';
import { functionNameData } from '../FunctionFile.utils';
```

### Example : Optional Import for 3rd party libraries
If the component uses 3rd party libraries for animations, state management, or other functionalities, these imports should be included as needed. Any not needed imports should be omitted.
```typescript
import { motion, useScroll, useTransform } from 'framer-motion';
```

### Example : Optional Import for enumerations
If the component uses enumerations for parameters or configurations, these imports should be included as needed. Any not needed imports should be omitted.
```typescript
import { EnumValues } from '@/enumerations/generic.enum';
import { ComponentProps } from '@/lib/component-props';
import { ColorScheme } from '@/enumerations/ColorScheme.enum';
import { TextOrientation } from '@/enumerations/TextOrientation.enum';
import { Orientation } from '@/enumerations/Orientation.enum';
```

### Example : Optional Import for useTranslate (Localization)
Include localization for component translations. Each variant handles its own translation keys independently using the `useTranslate` hook.
```typescript
import { useTranslate } from '@/hooks/use-translate';
```

#### Usage
Call `useTranslate` at the top of your variant component for each translation key. Pass the translation key and a fallback text to display if the translation is not found.

```typescript
const myLabel = useTranslate('componentName_myLabelKey', 'Default Label Text');
const myPlaceholder = useTranslate('componentName_placeholderKey', 'Enter text...');
```

#### Best Practices
- Use consistent key naming: `componentName_fieldOrFeatureName` (e.g., `video_openInModalLabel`, `eventHeader_eventTypeAriaLabel`)
- Define translation keys at the top of the variant component before JSX
- Use meaningful fallback text that describes the field or purpose
- Always use `useTranslate` for all text strings that need to be localized, as this makes dictionary keys and their default values discoverable throughout the codebase
- Each variant is responsible for its own translations; do not pass translations as props from the main component

## Color Scheme Implementation
The color scheme should be applied using the CVA (Class Variance Authority) utility function `getColorClassNamesCva()` which returns appropriate Tailwind classes based on the color scheme. Always use existing `ColorScheme` enum from '@/enumerations/ColorScheme.enum'. You should never create a custom theme enumeration. There will be one supplied by the core architecture.

### Example : color scheme property definition within a variant
```typescript
// Extract color scheme from rendering params.
const colorScheme = props?.params?.colorScheme;
```

### Example : applying color scheme within a variant 
```typescript
const { bgClass, textClass } = getColorClassNamesCva(colorScheme);
...
<section data-component="ComponentName"  className={cn('@container', bgClass, textClass)}>
```

## Field Validation Patterns
The fields object will depend on what props structure is being used (Layout Service or GraphQL). See the respective sections below for details on accessing field values in each structure. The fields should be validated at two levels: the fields object itself and individual fields within the fields object. If it fails validation at either level, appropriate fallbacks should be used to ensure a good user experience and proper functioning within Sitecore's authoring experience.

The fields object should be validated at the start of the component. If the fields object is null, meaning no fields are available, the component should return the `NoDataFallback` component from `@/components/vxa/ui/fallback/NoDataFallback`.

If an individual field within the fields object is optional, create a check for the field object to determine if it is null or if the page is in editing mode before rendering the field. Provide fallback values for the fields when the value is null with the double pipe `||` so a value is available and there aren't runtime errors. This ensures that content authors can see and edit the field even if it has no value or has a value indicating where they can enter a value. 

### Example : Fields Fallback
```typescript
if (!fields) {
  return <NoDataFallback componentName="ComponentNameDefault" isPageEditing={isPageEditing} />;
}
```

### Layout Service Data Structure Validation
Field values are accessed via `.value` property. For example: `fields.title.value`.

#### Example : Individual Field Validation for Layout Service
```typescript
{fields.image?.value?.src && (
  <img src={fields.image.value.src} alt={fields.image.value.alt || ''} />
)}
```

### GraphQL Fields Data Structure Validation
Field values are accessed via `.jsonValue.value` property. For example: `fields.data.datasource.title.jsonValue.value`. This also supports external fields via `fields.data.externalFields`.

#### Example : Individual Field Validation for GraphQL
```typescript
{fields.data.datasource.image?.jsonValue?.value?.src && (
  <img 
    src={fields.data.datasource.image.jsonValue.value.src} 
    alt={fields.data.datasource.image.jsonValue.value.alt || ''} 
  />
)}
```

## Page Editing Mode
When the page is in editing mode, indicated by the `isPageEditing` prop being true, all fields should be iterated through and rendered whether they have values or not. This allows content authors to see and edit all fields in the Sitecore Experience Editor or Pages editor.

### Critical Rule: Single Render Path for Pages Compatibility
**NEVER use early returns that bypass editable fields in editing mode.** Sitecore Pages relies on the rendered markup to attach editing handles and field chrome. When you short-circuit with an early return (e.g., returning a "no content" fallback), Pages sees only that fallback markup and loses the editing context for the real fields.

**Anti-pattern (DO NOT DO THIS):**
```typescript
// ❌ WRONG - Early return bypasses editable fields
if (isPageEditing && (!items || items.length === 0)) {
  return (
    <section data-component="MyComponent">
      <p>No items available</p>  {/* Title/Link fields are NOT rendered! */}
    </section>
  );
}
```

**Correct pattern:**
```typescript
// ✅ CORRECT - Single render path, empty state shown INSIDE the component
return (
  <section data-component="MyComponent">
    {(title?.value || isPageEditing) && (
      <Text tag="h2" field={title} editable={isPageEditing} />
    )}
    {!items || items.length === 0 ? (
      <p>No items available. Component will be hidden on the live site.</p>
    ) : (
      <div>{/* Render items */}</div>
    )}
  </section>
);
```

This ensures that:
1. Editable fields (title, link, etc.) are always rendered when in editing mode
2. Pages can attach editing handles to those fields
3. Empty state messages appear within the same render path

### Decision : Does it need special handling to support authoring?
In some cases, there needs to be an if / else condition to handle the display of the fields or managed items in the authoring experience. The if should check the `isPageEditing` variable to display the fields in a unique way. The else should render the fields as you would otherwise. Use the following cases to determine when to create a condition where the page editing is handled differently from a regular rendering of the component fields. Then use the guidance below to implement the page editing handling. 

#### Case 1: Managed Items with React Control
If the component has managed items and they are controlled by react for a user interaction like a carousel or tabs. This can also be indicated if the managed item variant needs a 'key' attribute for React to use.

##### Guidance for Case 1
In this case, then the items should be listed in a simple list or grid without the react control. This allows authors to see and edit all items. If the page is not in editing mode, then the react control should be used to display the items as intended. Also add a ternary condition to the first condition so that if none of the items are present and the page is in editing mode, a message is displayed to indicate no items are available to display.

#### Case 2: Links Wrapping other fields
The other case is when a component has a link wrapping a field or multiple fields. The authors can't select the sub-fields to edit them if they are wrapped in a link. 

##### Guidance for Case 2
In this case, the link should be placed below the other fields so it can be selected and edited. If not in page editing mode then the link can wrap the other fields as intended.

#### Case 3: Components with Dynamic/External Data (Empty State Handling)
If the component displays data from external sources, APIs, or computed results (e.g., related content, search results, filtered listings) that may be empty, but also has editable Sitecore fields (title, link, description, etc.).

##### Guidance for Case 3
**Keep a single render path.** Show the empty-state message **inside** the main component structure rather than returning early. This ensures that:
- Editable fields always render and remain selectable in Pages
- Authors can configure the component even when no dynamic data is present
- The component metadata stays attached to the DOM for Pages to recognize

```typescript
// ✅ CORRECT pattern for components with dynamic data
return (
  <section data-component="MyListingComponent">
    {/* Editable fields always render */}
    {(title?.value || isPageEditing) && (
      <Text field={title} editable={isPageEditing} />
    )}
    
    {/* Dynamic content with inline empty state */}
    {!dynamicItems || dynamicItems.length === 0 ? (
      <p className="text-muted-foreground">
        No items found. Component will be hidden on the live site.
      </p>
    ) : (
      <div>{/* Render dynamic items */}</div>
    )}
  </section>
);
```

**Note:** If the component should be completely hidden on the live site when there's no content, handle that logic in the parent/main component file that wraps the variant, not inside the variant itself.

### Example : Page Editing Handler
```typescript
{(!!fields.description?.value || isPageEditing) && (
  <Text field={fields.description} className="mb-6" />
)}
```

## Variant Composition

### Example : Default Variant
```typescript
import { Text, RichText } from '@sitecore-content-sdk/nextjs';
import React from 'react';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { ColorScheme } from '@/enumerations/ColorScheme.enum';
import { ComponentNameProps } from '../ComponentName.props';
import { cn } from '@/lib/utils';

export const ComponentNameDefault: React.FC<ComponentNameProps> = (props) => {
  const { params, fields, isPageEditing = false } = props;

  // if component data structure includes colorScheme
  const colorScheme = params?.colorScheme;
  const { bgClass, textClass } = getColorClassNamesCva(colorScheme);

  if (!fields) {
    return <NoDataFallback componentName="ComponentNameDefault" isPageEditing={isPageEditing} />;
  }

  return (
    <section
      data-component="ComponentNameDefault"
      className={cn(
        '@container max-w-240 rounded-default mx-auto p-6 w-full bg-background text-foreground',
        bgClass, textClass, params?.styles
      )}
    >
      {/* Component fields and structure */}
    </section>
  );
};
```

### Example : Additional Variants
```typescript
import { Text, RichText } from '@sitecore-content-sdk/nextjs';
import React from 'react';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { ColorScheme } from '@/enumerations/ColorScheme.enum';
import { ComponentNameProps } from '../ComponentName.props';
import { cn } from '@/lib/utils';

export const ComponentNameVariantName: React.FC<ComponentNameProps> = (props) => {
  const { params, fields, isPageEditing = false } = props;
  
  // if component data structure includes colorScheme
  const colorScheme = params?.colorScheme;
  const { bgClass, textClass } = getColorClassNamesCva(colorScheme);

  if (!fields) {
    return <NoDataFallback componentName="ComponentNameVariantName" isPageEditing={isPageEditing} />;
  }

  return (
    <section
      data-component="ComponentNameVariantName"
       className={cn(
        '@container w-full text-foreground',
        bgClass, textClass, params?.styles
      )}
    >
      {/* Component fields and structure */}
    </section>
  );
};
```

### Example : Managed Items Variant
```typescript
const ComponentName: React.FC<ComponentNameProps> = (props) => {
  const { fields, params, isPageEditing = false } = props;
  
  // Early validation of required fields
  if (!fields) {
    return <NoDataFallback componentName="ComponentName" isPageEditing={isPageEditing} />;
  }
  
  // Destructure fields for cleaner access in JSX
  const { items } = fields;
  
  return (
    <section className={cn("@class-1 class-2", params?.styles)} data-component="ComponentName">
      {isPageEditing ? (
        fields.items.length === 0 ? (
          <div className="p-4 border border-dashed rounded-default border-muted/40">
            <p className="text-muted-foreground text-vxa-sm">
              No items available to display.
            </p>
          </div>
        ) : (
          fields.items.map((item) => (
            <ManagedItem 
              fields={fields}
              params={params}
              isPageEditing={isPageEditing}
            />
          ))
        )
      ) : (
        fields.items.map((item, index) => (
          <ManagedItem 
            key={index}
            fields={fields}
            params={params}
            isPageEditing={isPageEditing}
          />
        ))
      )}
    </section>
  );
};
```

### Example : Link Wrapper Variant
```typescript
export const ComponentName: React.FC<ComponentNameProps> = (props) => {
  const { fields, isPageEditing } = props;
  
  if (!fields) {
    return <NoDataFallback componentName="ComponentName" isPageEditing={isPageEditing} />;
  }

  // Destructure fields for cleaner access and better TypeScript inference
  const { title, image, link } = fields;
  
  return (
    <div
      data-component="ComponentName"
      className="class-1 class-2"
    >
      {(isPageEditing) ? (
        <div className="text-center">
          <Text
            tag="div"
            field={description}
            className="sm:text-lg @lg:text-2xl leading-relaxed mb-6 @sm:mb-7"
            editable={isPageEditing}
          />
        </div>
        <div class="text-center"> 
          <ImageWrapper
            field={image}
            className="w-full h-full overflow-hidden aspect-square"
            wrapperClass="w-full h-full flex items-center justify-center"
            isPageEditing={isPageEditing}
          />
        </div>
        <div className="text-center">
          <Link field={link} />
        </div>
      ) : (
        <Link field={link}>
          {(title) && (
            <div className="text-center">
              <Text
                tag="div"
                field={description}
                className="sm:text-lg @lg:text-2xl leading-relaxed mb-6 @sm:mb-7"
                editable={isPageEditing}
              />
            </div>
          )}
          {(image) && (
            <div class="text-center"> 
              <ImageWrapper
                field={image}
                className="w-full h-full overflow-hidden aspect-square"
                wrapperClass="w-full h-full flex items-center justify-center"
                isPageEditing={isPageEditing}
              />
            </div>
          )}
        </Link>
      )}
    </div>
  );
};
```

## Fields and Structure

### Example : Layout Service 
```typescript
const MyComponent: React.FC<MyComponentProps> = (props) => {
  const { fields, params, isPageEditing = false } = props;
  
  // Early validation of required fields
  if (!fields) {
    return <NoDataFallback componentName="MyComponent" isPageEditing={isPageEditing} />;
  }
  
  // Destructure fields for cleaner access in JSX
  const { title, description, image, link } = fields;
  
  // Use Content SDK components that handle field objects directly
  return (
    <section className={cn("@container w-full", params?.styles)} data-component="MyComponent">
      {/* Required fields don't need conditional checks */}
      <Text field={title} className="text-2xl font-bold mb-4" />
      
      {/* Conditional rendering for optional fields */}
      {(!!description?.value || isPageEditing) && (
        <Text field={description} className="mb-6" />
      )}
      
      {(!!image?.value?.src || isPageEditing) && (
        <ImageWrapper 
          field={image}
          className="w-full h-auto object-cover rounded-lg shadow-md"
        />
      )}
      
      {!!link?.value?.href && (
        <ButtonBase buttonLink={link} />
      )}
    </section>
  );
};
```

### Example : GraphQL
```typescript
import React from 'react';
import { Text, RichText } from '@sitecore-content-sdk/nextjs';
import { NoDataFallback } from '@/components/vxa/ui/fallback/NoDataFallback';
import { MyComponentProps } from './MyComponent.props';
import { ButtonBase } from '@/components/vxa/button/VXAButton';
import { ImageWrapper } from '@/components/vxa/image/ImageWrapper';
import { cn } from '@/lib/utils';

const MyComponent: React.FC<MyComponentProps> = (props) => {
  const { fields, params, isPageEditing = false } = props;
  const datasource = fields?.data?.datasource;
  
  // Early validation of required fields
  if (!fields) {
    return <NoDataFallback componentName="MyComponent" isPageEditing={isPageEditing} />;
  }
  
  // For GraphQL fields, we need to create compatible field objects for Content SDK components
  const titleField = datasource.title.jsonValue;
  const descriptionField = datasource.description?.jsonValue;
  const imageField = datasource.image?.jsonValue;
  const linkField = datasource.link?.jsonValue;
  
  // Optional: Get external fields if needed
  const pageTitle = fields?.data?.externalFields?.pageTitle?.jsonValue;
  
  return (
    <section className={cn("@container w-full", params?.styles)} data-component="MyComponent">
      {/* Required fields don't need conditional checks */}
      <Text field={titleField} className="text-2xl font-bold mb-4" />
      
      {/* Conditional rendering for optional fields */}
      {(!!descriptionField?.value || isPageEditing) && (
        <Text field={descriptionField} className="mb-6" />
      )}
      
      {(!!imageField?.value?.src || isPageEditing) && (
        <ImageWrapper 
          field={imageField}
          className="w-full h-auto object-cover rounded-lg shadow-md"
        />
      )}
      
      {!!linkField?.value?.href || isPageEditing && (
        <ButtonBase buttonLink={linkField} />
      )}
      
      {/* External fields */}
      {!!pageTitle?.value && (
        <small>From page: <Text field={pageTitle} /></small>
      )}
    </section>
  );
};
```
