# audit-dead-code

Detect and fix dead code, unused exports, unreachable code, orphaned files, and stale feature flags.

Use this skill before a release, after a large refactor, or any time you want to reduce bundle size and cognitive overhead.

## Example usage

```
/audit-dead-code
```

## What it checks

| Pattern | Confidence | Description |
|---------|------------|-------------|
| Unreachable code | High | Code after `return`, `throw`, or `break` |
| Unused imports | High | Imported but never referenced |
| Orphaned files | High | Files unreachable from any entry point |
| Unused exports | Medium | Exported but never imported elsewhere |
| Commented-out code | Medium | Old code left in comments |
| Stale feature flags | High | Flags hardcoded to 100% or 0% |

## Related skills

- `/audit-abstractions` — remove hollow wrappers alongside dead code
- `/audit-todos` — surface forgotten reminders near dead code
