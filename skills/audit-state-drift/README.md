# audit-state-drift

Detect and fix state synchronization issues, impossible states, and state management anti-patterns.

Use this skill when you see subtle UI bugs showing stale data, conflicting loading/error flags, or state that gets out of sync between frontend and backend.

## Example usage

```
/audit-state-drift
```

## What it checks

| Pattern | Description |
|---------|-------------|
| Boolean explosion | Multiple booleans creating impossible combinations (e.g. `isLoading && isError`) |
| Magic strings | String literals for status/state instead of enums or constants |
| Duplicated state | Same data stored in multiple locations |
| Derived state stored | Computed values saved instead of recalculated |
| Impossible states | "bags of optionals" instead of discriminated unions |
| Status mismatches | Database enums not matching code enums |
| Missing state machines | Ad-hoc transitions instead of an explicit FSM |
| Single source of truth violations | Multiple authoritative sources for the same data |

## Related skills

- `/audit-errors` — catch silent failures that contribute to state inconsistency
- `/audit-best-practices` — broader code health check for the detected stack
