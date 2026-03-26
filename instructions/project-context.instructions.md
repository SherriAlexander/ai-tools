---
name: 'VXA Next.js Project Context'
description: 'Core instructions for GitHub Copilot to ensure consistent, high-quality code generation in a VXA Next.js project.'
applyTo: '**'
---

# Project Context
This file contains core instructions for GitHub Copilot to ensure consistent, high-quality code generation that aligns with our company's development standards. This is part of an instruction set to apply globally across all Copilot interactions.

## Primary Objective
You will be generating files for a web application that define utility functions, pages and sub-elements of pages called components. These components are built up from two ends. The back end is a combination of a user manageable data structures defined in Sitecore as renderings, datasources, rendering parameters, insert options, branch templates and site setup configurations. The front end is a Next.js application using React and TypeScript that consumes the data from Sitecore via the Sitecore Content SDK for Next.js. Your goal is to generate code that effectively bridges these two ends, and can compose pages with additional functionality from utility functions or custom routes within the application that return related data from external API sources. Components should be robust, maintainable, and adhere to best practices. 

### When Suggesting Code
- Prioritize readability over clever solutions
- In Next.js include error handling for all user interactions and data operations
- Consider edge cases (loading, error, empty states)
- Implement proper TypeScript typing (avoid `any` type)
- Write code that follows our ESLint and Prettier configurations
- Include appropriate unit tests when suggesting new components in Next.js
- Always use functional components with TypeScript

## Limitations
Do not relying on project context information or local file paths unless instructed to and in that case stick only to the paths mentioned. It's better to focus on the information from primary requirement sources like JIRA and FIGMA or the provided instructions. If you're unclear follow up with clarifying questions rather than making assumptions based on project context.

### Demeanor and Tone
- Maintain a professional and collaborative tone
- Be concise and to the point
- Avoid unnecessary jargon or complexity
- Don't be overly complementary and avoid excessive affirmations and flattery
- Be confident when you know what you're talking about, but indicate uncertainty when you don't
- Be realistic about what can be achieved within given constraints
- Avoid using emojis or emoticons in your responses

## Model Context Protocol (MCP) Tools

### Jira MCP Workflow
When provided with a ticket number in the format <project-code>-<ticket-number>, you should go to jira and lookup the details using that ticket number as the key and then follow this workflow to gather requirements that explain what is needed for the component:
1. First, check the Jira ticket via the mcp-atlassian interface
2. Use the Jira data as the primary source for component structure, fields, and variants
3. Only fall back to the project context guidelines below if the Jira data is insufficient or unavailable
4. Follow additional Jira linked tickets first to gather more context for the component

### Figma MCP Workflow
When provided with a Figma design link in a JIRA ticket, you should analyze the design to understand the visual, structural and functional requirements of the component being developed. Use this information to guide your code generation, ensuring that the output aligns with the intended user experience and design specifications. After all the related information from Jira links have been retrieved, use the links to Figma and follow the workflow for component styling and design:
1. Use the figma MCP to retrieve:
   - Exact styling details (padding, margin, colors, etc.)
   - Component visual specifications
   - Responsive behavior parameters
   - Visual variants
   - Icons used in the component
2. Map Figma design values directly to Tailwind classes and CSS variables
3. Ensure design tokens from Figma align with the CSS variables defined in the project
4. For responsive designs, prioritize Figma breakpoint information over project defaults
5. Pay special attention to translating Figma Auto Layout properties to appropriate Flexbox/Grid Tailwind classes
6. Compare figma design tokens to the CSS variables defined in the project and use the CSS variables in the component styles
7. Always verify that the implementation aligns with both the Figma specifications and the general project standards
8. If the Figma design is not available, use the project context guidelines below as a fallback for styling and design

## Technology Stack
Our technology stack includes:
- Next.js
- React (functional components with hooks)
- TypeScript
- Tailwind
- @sitecore-content-sdk/nextjs;
- Shadcn/UI
- Storybook for component documentation
- Sitecore Powershell Extensions script

### Sitecore Content SDK
This project is a Sitecore XM Cloud application using Next.js so we need to use the @sitecore-content-sdk/nextjs components where necessary. The library includes the following components/types: Image, ImageField, LinkField, Text, TextField, DateField, EditFrame, File, FileField, RichTextField, PlaceholderComponentProps, SitecoreProvider, withPlaceholder, and more.

**Content SDK 1.0.0 Update**: SitecoreProvider now uses a `page` prop instead of `layoutData`. Use `<SitecoreProvider page={page} ...>` rather than the deprecated `<SitecoreProvider layoutData={layoutData} ...>` pattern.

### Next.js Page Mode Detection Patterns
- **Content SDK 1.0.0 Update**: Use the new `page.mode` API for page state detection:
  ```typescript
  const { page } = useSitecore();
  
  // Page mode detection with proper null checking
  const isNormal = page?.mode?.isNormal ?? true;     // Default to true
  const isEditing = page?.mode?.isEditing ?? false;  // Default to false  
  const isPreview = page?.mode?.isPreview ?? false;  // Default to false
  const isDesignLibrary = page?.mode?.isDesignLibrary ?? false; // Default to false
  
  // Common usage patterns
  const isPageEditing = page?.mode?.isEditing ?? false;
  
  // For Sitecore JSS component rendering (images, rich text, etc.)
  const useSitecoreRendering = page?.mode?.isEditing || page?.mode?.isPreview;
  
  // For editing UI features (empty field placeholders, editing hints)
  const showEditingFeatures = page?.mode?.isEditing ?? false;
  ```

## File Settings and Structure

### File Locations
- Next.js component files should be located in `/headapps/nextjs-content-sdk/src/components/vxa/`
- Global Next.js hooks should be located in `/headapps/nextjs-content-sdk/src/hooks`
- Global Next.js utility files should be located in `/headapps/nextjs-content-sdk/src/lib/utils`
- Sitecore Powershell scripts should be located in `/spe/features/<project-code>-<ticket-number>.ps1`
- Global Next.js lib folder is `/headapps/nextjs-content-sdk/src/lib/`

### File Aliasing
- In the main app, `/nextjs-content-sdk` a general file alias will be used when importing files `@/*` will point to `/src/*` a common pattern in Next.js projects.
- Components and files within the same directory where they are being imported (e.g., sub components) can use relative path but when importing other site components use `@/components/vxa/some-component/SomeComponent` to import.

