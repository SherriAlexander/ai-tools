# audit-boundaries

Detect architectural layer violations and improper dependencies between modules.

Use this skill when you suspect business logic leaking into controllers, UI code talking directly to the database, or domain logic depending on infrastructure concerns.

## Example usage

```
/audit-boundaries
```

## What it checks

| Pattern | Description |
|---------|-------------|
| UI → Database direct | Presentation layer accessing persistence directly |
| Domain → Infrastructure | Core business logic depending on external services |
| Business logic in controllers | Fat controllers doing too much |
| ORM outside repository | Database queries scattered across the codebase |
| Scattered environment variables | Config access outside a config module |
| Cross-bounded-context imports | DDD boundary violations |

## Related skills

- `/audit-abstractions` — check for hollow or unnecessary wrappers within layers
- `/audit-best-practices` — broader code health check for the detected stack
