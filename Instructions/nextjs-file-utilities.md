# Next.js Utilities File 
Create helper functions for accessing deeply nested fields to reduce repetition. The decision to create a utility function should be based on the complexity of the data model and the frequency of access patterns. If multiple components or variants require similar access patterns, a utility function can help centralize the logic and improve maintainability.

## Utility Function Patterns

### Example : Layout Service Helper Function
```typescript
// Helper function to simplify access to Layout Service fields
const getFieldValue = <T>(
  fields: ExampleComponentFields,
  fieldName: string,
  defaultValue: T
): T => {
  if (!fields) return defaultValue;

  const field = fields[fieldName];
  return field?.value || defaultValue;
};
```

### Example : GraphQL Helper Function 
```typescript
// Helper function to simplify access to GraphQL fields
const getFieldValue = <T>(
  fields: ExampleComponentFields,
  fieldName: string,
  defaultValue: T
): T => {
  if (!fields?.data?.datasource) return defaultValue;
  
  const field = fields.data.datasource[fieldName];
  return field?.jsonValue?.value || defaultValue;
};
```

## Example : Utility Function Usage
```typescript
const title = getFieldValue<string>(props.fields, 'title', 'Default Title');
const isEnabled = getFieldValue<boolean>(props.fields, 'isEnabled', false);
const count = getFieldValue<number>(props.fields, 'count', 0);
```