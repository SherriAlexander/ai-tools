# audit-errors

Detect error handling inconsistencies, anti-patterns, and silent failures.

Use this skill after implementing new features, before a PR, or when debugging hard-to-reproduce failures that may be swallowed exceptions.

## Example usage

```
/audit-errors
```

## What it checks

| Pattern | Description |
|---------|-------------|
| Empty catch blocks | Exceptions caught and silently ignored |
| Overly broad catches | Catching `Exception`, `Throwable`, or `BaseException` |
| Lost exception chains | Re-throwing without preserving the original cause |
| Unhandled promise rejections | Promises without `.catch()` or `try/await` |
| Inconsistent error strategy | Mixed use of exceptions, result types, and error codes |
| Pointless rethrow | Catch block that only rethrows unchanged |

Works across languages: TypeScript/JavaScript, Python, Java, C#, Go, PHP, Rust, and more.

## Related skills

- `/audit-best-practices` — broader code quality check for the detected stack
- `/audit-state-drift` — catch impossible error states and flag mismatches
