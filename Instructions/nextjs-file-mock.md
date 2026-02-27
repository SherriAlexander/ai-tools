
# Next.js Mock File Generation
The mock file should reference the props file and use the props object to provide example data for the component to run.

## Best Practices for Mock Data Values
- Always use UUID zeros for mock rendering.uid: '{00000000-0000-0000-0000-000000000000}'
- Use descriptive, realistic sample content that represents real usage scenarios
- For images, use picsum.photos with consistent IDs for reproducibility across environments
- Ensure field names match exactly what is specified in Jira ticket specifications
- Properly mark required vs. optional fields in TypeScript (no ? for required fields)
- For links, use semantic paths like '/learn-more' or '/contact' rather than meaningless placeholders
- When color schemes are used, default to 'ColorScheme.DEFAULT' unless specified otherwise
- Always implement proper error handling for missing or malformed data
- Create meaningful TypeScript interfaces that document the purpose of each field
- Use JSDoc comments to explain field purposes and constraints

## Import Statements
The most commonly used imports for mock files are enumerations for parameters. The available enumerations are located in the `/src/enumerations` folder.

### Example : Required Import
```typescript
import { ComponentNameProps } from './ComponentName.props';
```

### Example : Optional Enumeration Imports
```typescript
import { ColorScheme } from '@/enumerations/ColorScheme.enum';
import { EnumValues } from '@/enumerations/generic.enum';
import { IconName } from '@/enumerations/Icon.enum';
import { IconPosition } from '@/enumerations/IconPosition.enum';
```

## Mock Data Structure
The mock data structure should define a default mock data object that populates all required fields and parameters. Additional mock data variations should be created to cover all color scheme variations for testing in Storybook. The structure should follow the component props interface which depends on the data source type (Layout Service or GraphQL).

### Default Props

#### Example : Layout Service Default Mock Data
```typescript
export const defaultMockData: ExampleComponentProps = {
  rendering: {
    uid: '{00000000-0000-0000-0000-000000000000}',
    componentName: 'ExampleComponent',
    dataSource: '/',
  },
  fields: {
    title: {
      value: 'Example Title'
    },
    description: {
      value: '<p>This is an example rich text description.</p>'
    },
    image: {
      value: {
        src: 'https://picsum.photos/id/123/800/600',
        alt: 'Example image',
        width: 800,
        height: 600
      }
    },
    link: {
      value: {
        href: '/learn-more',
        text: 'Learn More',
        target: '_self'
      }
    }
  }
};
```

#### Example : GraphQL Default Mock Data
```typescript
export const defaultMockData: ExampleComponentProps = {
  rendering: {
    uid: '{00000000-0000-0000-0000-000000000000}',
    componentName: 'ExampleComponent',
    dataSource: '/',
  },
  fields: {
    data: {
      datasource: {
        title: {
          jsonValue: {
            value: 'Example Title'
          }
        },
        description: {
          jsonValue: {
            value: '<p>This is an example rich text description.</p>'
          }
        },
        image: {
          jsonValue: {
            value: {
              src: 'https://picsum.photos/id/123/800/600',
              alt: 'Example image',
              width: 800,
              height: 600
            }
          }
        },
        link: {
          jsonValue: {
            value: {
              href: '/learn-more',
              text: 'Learn More',
              target: '_self'
            }
          }
        }
      },
      externalFields: {
        pageTitle: {
          jsonValue: {
            value: 'Page Title'
          }
        }
      }
    }
  },
  isPageEditing: false
};
```

### Special Case Field Props : Link Lists

#### Example : Layout Service Link Lists
```typescript
{
  linkList: {
    items: [
      { 
        href: 'https://example.com',
        text: 'Learn More',
        target: '_blank',
      },
      {
        href: '/contact',
        text: 'Contact Us',
        target: '_self',
      }
    ],
  }
}
```

#### Example : GraphQL Link Lists
```typescript
{
  data: {
    datasource: {
      linkList: {
        jsonValue: {
          items: [
            { 
              href: 'https://example.com',
              text: 'Learn More',
              target: '_blank',
            },
            {
              href: '/contact',
              text: 'Contact Us',
              target: '_self',
            }
          ],
        }
      }
    }
  }
}
```

### Special Case Field Props : Video Fields
For video fields, use LinkField with YouTube URLs:

#### Example : Layout Service Video Fields
```typescript
{
  video: {
    value: {
      href: 'https://www.youtube.com/watch?v=example',
      text: 'Watch Video',
      target: '_blank',
    }
  }
}
```

#### Example : GraphQL Video Fields
```typescript
{
  data: {
    datasource: {
      video: {
        jsonValue: {
          value: {
            href: 'https://www.youtube.com/watch?v=example',
            text: 'Watch Video',
            target: '_blank',
          }
        }
      }
    }
  }
}
```

### Special Case Field Props : Enumerations
```typescript
export const PrimarySchemeMockData: ComponentNameProps = {
  ...defaultMockData,
  rendering: { 
    ...defaultMockData.rendering, 
    params: { ...defaultMockData.rendering.params, colorScheme: ColorScheme.PRIMARY }
  },
};

export const SecondarySchemeMockData: ComponentNameProps = {
  ...defaultMockData,
  rendering: { 
    ...defaultMockData.rendering, 
    params: { ...defaultMockData.rendering.params, colorScheme: ColorScheme.SECONDARY }
  },
};

export const AccentSchemeMockData: ComponentNameProps = {
  ...defaultMockData,
  rendering: { 
    ...defaultMockData.rendering, 
    params: { ...defaultMockData.rendering.params, colorScheme: ColorScheme.ACCENT }
  },
};
```

