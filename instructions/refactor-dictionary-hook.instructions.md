---
name: 'Refactor Component Dictionary Usage to useTranslate Hook'
description: 'Instructions for refactoring a component from using a dictionary file to the new useTranslate hook pattern in a VXA Next.js project.'
applyTo: '**/*.tsx, **/*.dictionary.ts'
---

# Refactor Guide: Migrating Component Dictionary Usage to useTranslate Hook

This guide outlines the step-by-step process for refactoring component dictionary usage to the new `useTranslate` hook pattern. Follow these instructions for **one component at a time** to ensure safe, testable, and incremental changes.

---

## 1. Identify Existing Dictionary Keys
- Review the component's dictionary file (e.g., `ComponentName.dictionary.ts`).
- **Preserve all existing dictionary keys.** Do not change key names (e.g., keep `backToTop_backToTopLabel`).
- Note the keys used in the component for later reference.

## 2. Locate Dictionary Lookups in Component Variant
- Open the main variant implementation file (e.g., `ComponentNameDefault.tsx`).
  - Move dictionary lookups to the top of the component function, immediately after props destructuring.
  - Use the `useTranslate` hook for each key, importing from `src/hooks/use-translate.ts`:
    ```typescript
    import { useTranslate } from '@/hooks/use-translate';
    const label = useTranslate('componentName_key', 'Default fallback text');
    ```
- **Do not call hooks conditionally.** All `useTranslate` calls must be at the top level of the component function.

## 3. Remove Dead Dictionary Code
- Remove references to dictionary objects from:
  - Component props files (e.g., `dictionary` prop, dictionary types)
  - Component mock files (e.g., mock dictionary data)
  - Component main files (e.g., dictionary imports, dictionary creation logic)
  - Component stories (e.g., dictionary-related args)
- **Do not remove shared dictionary resources** (e.g., utility functions, shared hooks). These will be cleaned up at the end of the refactor effort.

## 4. Update Usage in JSX
- Replace all usages of dictionary values with the corresponding variable from `useTranslate`:
  ```typescript
  <span>{label}</span>
  ```
- **Fallback text must be pulled from the original implementation.**
  - Do not generate or make up fallback text.
  - If the fallback text cannot be determined from the original code, alert the user and stop the refactor for that component. **Do not make up output.**

## 5. Remove Component Dictionary File
- Delete the component's dictionary file (e.g., `ComponentName.dictionary.ts`).
- **This step must be completed before running TypeScript validation** to ensure there are no lingering references to the removed dictionary.
- Verify that no other components import from this dictionary file before deletion.

## 6. Test the Component
- Run the component locally and verify:
  - All dictionary lookups work as expected
  - No runtime errors from hook usage
  - Fallback text appears if translation is missing

## 7. Validate TypeScript
- Run `npx tsc --noEmit` to ensure:
  - No references to the deleted dictionary file remain
  - All types are correct
  - No import errors

## 8. Commit Changes
- Commit the refactor for **one component only**.
- Repeat the process for each additional component.

---

## Example Migration (BackToTop)

**Before:**
```typescript
// BackToTop.props.ts
export type BackToTopProps = { ...; dictionary?: BackToTopDictionary };

// BackToTopDefault.tsx
const { dictionary } = props;
<span>{dictionary?.backToTopLabel || 'Back to top'}</span>
```

**After:**
```typescript
// BackToTop.props.ts
export type BackToTopProps = { ... };

// BackToTopDefault.tsx
const label = useTranslate('backToTop_backToTopLabel', 'Back to top');
<span>{label}</span>
```

---

## Notes
- Always keep dictionary keys unchanged to avoid breaking localization.
- Place all `useTranslate` calls at the top of the component function.
- Only refactor one component at a time for easier testing and review.
- Leave shared resources in place until all components are migrated.
- **Fallback text must always be sourced from the original implementation. Never invent fallback text. If it cannot be determined, notify the user and do not proceed.**
