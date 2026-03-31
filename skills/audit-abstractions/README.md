# audit-abstractions

Detect premature, hollow, and over-engineered abstractions that add complexity without value.

Use this skill when code feels over-engineered, when you suspect wrappers or interfaces that don't pull their weight, or as a post-feature cleanup pass.

## Example usage

```
/audit-abstractions
```

## What it checks

| Pattern | Description |
|---------|-------------|
| Pass-through functions | Wrappers that forward calls without adding logic |
| Single-method classes | Classes that should just be functions |
| Single-implementation interfaces | Speculative generality with no real polymorphism |
| Middle man | Classes that delegate most work elsewhere |
| Prop/config drilling | Unchanged parameters passed through many layers |
| God utils | Catch-all classes with unrelated static methods |

## Related skills

- `/audit-boundaries` — check if architectural layers are properly separated
- `/audit-naming` — confirm any new identifiers are clear and consistent
- `/audit-dead-code` — remove unused exports and orphaned files alongside hollow wrappers
