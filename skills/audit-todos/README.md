# audit-todos

Detect and prioritize technical debt markers, stale TODOs, and forgotten FIXMEs.

Use this skill to surface invisible debt before a release, during a sprint retro, or when you want a prioritized list of known issues in the codebase.

## Example usage

```
/audit-todos
```

## What it checks

| Marker | Meaning | Default Priority |
|--------|---------|-----------------|
| `TODO` | Planned improvement | Medium |
| `FIXME` | Known bug, needs fix | High |
| `HACK` | Temporary workaround | High |
| `XXX` | Dangerous/problematic | High |
| `BUG` | Confirmed defect | Critical |
| `OPTIMIZE` | Performance issue | Medium |
| `REFACTOR` | Code quality debt | Low |
| `DEPRECATED` | Scheduled for removal | Medium |

Also flags: TODOs with no explanation or owner, references to already-closed issues, and debt in high-traffic code paths.

## Related skills

- `/audit-dead-code` — remove abandoned code that often lives near old TODOs
- `/audit-jira PROJ-123` — cross-reference TODOs against an open ticket before closing it
