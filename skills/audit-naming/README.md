# audit-naming

Detect vague, inconsistent, and confusing identifier names that hurt code comprehension.

Use this skill during code review, after onboarding to a codebase, or when names feel unclear and you want a systematic pass.

## Example usage

```
/audit-naming
```

## What it checks

| Pattern | Description |
|---------|-------------|
| Vague generic names | `data`, `info`, `item`, `thing`, `handler`, `manager` |
| Single-letter variables | Non-idiomatic use of `x`, `i` outside loops or math |
| Missing boolean prefixes | `loading` instead of `isLoading` |
| Negative booleans | `isNotDisabled`, `hasNoErrors` causing double-negation |
| Casing inconsistency | Mixed `camelCase`/`snake_case` in the same codebase |
| Abbreviation inconsistency | Both `btn` and `button` in the same codebase |

## Related skills

- `/audit-best-practices` — broader code health check alongside naming
- `/audit-abstractions` — poorly-named wrappers are often a sign of unnecessary abstraction
