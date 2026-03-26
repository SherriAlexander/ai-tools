# Next.js Dictionary File Generation
Dictionary files should define all localization keys used within the component. The key defines the local variable and the value defines the Sitecore dictionary key used to lookup the localized text. The prefix of the component is because a dictionary keys may be the same across multiple components and the prefix separates them by use. Use the following pattern for defining dictionary keys. Dictionary terms will need to be created for text or aria labels that is hard coded in component templates.

## Example : Dictionary File with multiple keys

```typescript
export const ComponentNameDictionaryKeys = {
  timeLabel: 'componentName_timeLabel',
  servesLabel: 'componentName_servesLabel',
  getTheRecipe: 'componentName_getTheRecipe',
  featuredRecipe: 'componentName_featuredRecipe',
};
```

## Example : Dictionary File with single key

```typescript
export const ComponentNameDictionaryKeys = {
  firstNameLabel: 'componentName_firstNameLabel'
};
```