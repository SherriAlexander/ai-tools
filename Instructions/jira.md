# JIRA TICKETS
Jira is a system that organizes a project based on a project code and within that project work and requirements are defined in tickets. There are a large variety of Jira ticket types. You are to focus on tickets with a feature type and ignore bug, task and uat type tickets. Within the feature tickets there will still be a variety of sub-topics that define enumerations, taxonomies, page types, component types and integrations with 3rd party APIs. 

## Requirements Extraction
Jira feature tickets contain the requirements for components, pages and enumerations that need to be created in the project. When creating components and pages based on Jira tickets, you will often find data tables in the ticket summary that outline the fields required for the component or page template. Use these tables to define the objects and entities in the code you will write. The following sections provide examples of the data tables and which values to extract for the code.

### Example : Data Table for Component Fields
When creating components based on Jira tickets, You will often find one or more data tables in the ticket summary that outlines the fields required for the component. Below is an example of such a table:

| Section | Display Name      | Machine Name    | Field Type       | Required | Default Value | Mapping                                      |
|---------|-------------------|-----------------|------------------|----------|---------------|----------------------------------------------|
|         | Title             | title           | Single Line Text | true     | $name         |                                              |
|         | Link              | link            | General Link     | false    |               |                                              |
| Styling | Number of Columns | numberOfColumns | Droplink         | false    | 4             | https://velir.atlassian.net/browse/DRXMC-45  |
|         | Theme             | theme           | Droplink         | false    | Default       | https://velir.atlassian.net/browse/DRXMC-109 |


### Example : Data Table for Page Creation
When creating pages based on Jira tickets, you will often find a data table in the ticket description that outlines the fields required for the page template. These are often but not always more complex than component data and contain many more fields that are related to the overall view of a web page to a visitor, search crawler and author. Below is an example of such a table:

| Section       | Display Name               | Machine Name        | Field Type               | Required | Default Value | Mapping                                       |
|---------------|----------------------------|---------------------|--------------------------|----------|---------------|-----------------------------------------------|
| Image         | Primary Image              | primaryImage        | Image                    | false    |               | Maps to current “Generic Primary Image” field |
| Title         | Title                      | title               | Single Line Text         | true     | $name         |                                               |
|               | Short Title                | shortTitle          | Single Line Text         | false    | $name         |                                               |
|               | Header Title               | headerTitle         | Single Line Text         | false    | $name         |                                               |
|               | Subtitle                   | subtitle            | Single Line Text         | false    |               |                                               |
| Multimedia    | Background Image           | backgroundImage     | Image                    | false    |               | Used to primarily display current background  |
| Text          | Excerpt                    | excerpt             | Rich Text                | false    |               |                                               |
|               | Copy                       | copy                | Rich Text                | false    |               |                                               |
| Taxonomy      | General Tagging            | generalTagging      | Multi-Select with search | false    |               | DRXMC-62: TAX: General Ready for QA           |
| Navigation    | Suppress in Sub-Navigation | suppressInSubNav    | Checkbox                 | false    |               |                                               |
| Index         | No Index                   | noIndex             | Checkbox                 | false    |               |                                               |
|               | No Follow                  | noFollow            | Checkbox                 | false    |               |                                               |
|               | Exclude from Sitemap       | excludefromSitemap  | Checkbox                 | false    |               |                                               |
| Page Metadata | Metadata Title             | metadataTitle       | Single Line Text         | false    |               |                                               |
|               | Metadata Keywords          | metadataKeywords    | text                     | false    |               |                                               |
|               | Metadata Description       | metadataDescription | text                     | false    |               |                                               |
|               | Metadata Image             | metadataImage       | text                     | false    |               |                                               |
| Custom Code   | Javascript                 | javascript          | Multi Line Text          | false    |               |                                               |
|               | CSS                        | css                 | Multi Line Text          | false    |               |                                               |

## Data Field Interpretation
When interpreting Jira tickets for component creation, expect a data table in the description with the following columns:
- Name: Display name of the field (e.g., "Title", "Description")
- Machine Name: condensed and camel-cased machine friendly name for component (e.g., "title", "description")
- Field Type: Sitecore field type (e.g., "Single-line Text", "Rich Text", "Image")
- Required: Whether the field is required to have a value ("Yes"/"No")
- Type: Additional type information or constraints
- Default Value: what the value should be set to as a default when it's first created
- Mapping: Links to related tickets or documentation for field implementation and indicates how a field source should be populated.

### Sitecore Content SDK Field Type Mapping Table

| Jira Field Type    | Content SDK Type     | Layout Service | GraphQL |
|--------------------|----------------------|----------------|---------|
| Single-line Text   | TextField            | `{ value: 'Example text' }` | `{ jsonValue: { value: 'Example text' } }` |
| Rich Text          | RichTextField        | `{ value: '<p>Rich text</p>' }` | `{ jsonValue: { value: '<p>Rich text</p>' } }` |
| Image              | ImageField           | `{ value: { src: 'https://picsum.photos/id/123/800/600', alt: 'Alt text', width: 800, height: 600 } }` | `{ jsonValue: { value: { src: 'https://picsum.photos/id/123/800/600', alt: 'Alt text', width: 800, height: 600 } } }` |
| General Link       | LinkField            | `{ value: { href: '/example', text: 'Link text', target: '_self' } }` | `{ jsonValue: { value: { href: '/example', text: 'Link text', target: '_self' } } }` |
| Checkbox           | Field\<boolean>      | `{ value: '1' }` | `{ jsonValue: { value: '1' } }` |
| Number             | Field\<number>       | `{ value: '42' }` | `{ jsonValue: { value: '42' } }` |
| Dropdown           | Field\<string>       | `{ value: 'option1' }` | `{ jsonValue: { value: 'option1' } }` |
| Date               | DateField            | `{ value: '2023-10-01T00:00:00Z' }` | `{ jsonValue: { value: '2023-10-01T00:00:00Z' } }` |

## Sitecore Field Types
The field types referenced in Jira tickets may not exactly match the names of field types used in Sitecore. For example, a ticket may say "Single Line Text" when it should be "Single-Line Text" or  "Multi Line Text" instead of "Multi-Line Text". You should always use the exact naming convention used by Sitecore and interpret the value provided in the ticket by looking up the one in the following list of approved Sitecore field types:

- Checkbox
- Checklist
- Date
- Datetime
- Droplink
- Droplist
- Droptree
- File
- General Link
- General Link with Search
- GraphQL
- Grouped Droplink
- Grouped Droplist
- Image
- Integer
- Internal Link
- Language Droplist
- Multi-Line Text
- Multilist
- Multilist with Search
- Multiroot Treelist
- Name Lookup Value List
- Name Value List
- Number
- Password
- Redirect Map
- Rendering Datasource
- Rich Text
- Rules
- Single-Line Text
- Site Droplist
- Treelist
- Treelist with Search
- TreelistEx

## Component Variant Determination
Component variants should be created based on:
- Image orientation parameters
- Layout variations mentioned in ticket
- Content display options
- Specific variant names in Jira or Figma

## Field Implementation From Jira
Always implement proper field validation:
- Check if required fields exist
- Provide fallbacks for optional fields
- Handle empty/null states gracefully
- Use appropriate field types from the JSS library

## Next.js Data Structure Determination
When creating components based on Jira tickets, follow these steps to determine the data structure to use:
- Layout Service
    - "Data Structure: Layout Service" indicates using the Layout Service pattern
    - If not specified in Jira defer to what is written in prompt, if nothing is mentioned assume Layout Service unless otherwise noted
    - Traditional Content SDK rendering approach used in most Content SDK implementations
    - Optimized for page-level component rendering and simpler components
    - Best for most component implementations and simpler projects
    - Delivers content for a specific route with all component data pre-assembled
    - **Use when datasource has NO fields and only managed items have fields (datasource with children scenario)**
    - **Use when datasource has fields but NO managed items**
- GraphQL
    - "Data Structure: GraphQL" indicates using the GraphQL pattern
    - Enables more advanced data operations like pagination, filtering, and sorting
    - Recommended for data-intensive components and complex content relationships
    - **Use when datasource has BOTH fields AND managed items (requires complex parent-child queries)**

## Enumerations
Extract any enumeration values defined in the Jira ticket data tables. Look for fields with a "Droplink", "Droplist", or "Multi-Select" field type. Use the mapping links to find related tickets that define the enumeration values. Enumerations are used to determine the source of a field to look for values but also on a component field to handle specific display options for a provided list of values.

## Variants
Extract variant names from a Jira ticket. Look for any mention of "variants", "layouts", or "display options" in the 'Authoring Considerations' section of a Jira ticket. Variants are used to create different versions of a component based on layout

## Containers
Look for any placeholder settings or containers that will support the component in the 'Authoring Considerations' section of the Jira ticket. Containers are used to define areas within a component where other components can be placed by an author.