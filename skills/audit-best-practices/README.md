# audit-best-practices

Analyze a codebase and audit for best practice usage of detected languages and frameworks.

Use this skill for a general code health check, before a PR review, or when onboarding to an unfamiliar codebase to identify risky patterns.

## Example usage

```
/audit-best-practices
```

## What it does

1. **Detects your tech stack** automatically (Node, Python, PHP, Go, Rust, Java, etc.)
2. **Scans source files** for anti-patterns specific to that stack and framework
3. **Reports violations** with severity and actionable recommendations
4. **Notes any existing guidelines** in `.instructions.md` files that may override defaults

## Related skills

- `/audit-errors` — deeper dive into error handling patterns
- `/audit-abstractions` — check for over-engineered or hollow abstractions
- `/audit-boundaries` — verify architectural layer separation
- `/audit-naming` — flag vague or inconsistent identifiers
- `/audit-dead-code` — remove unused code alongside refactoring
- `/audit-jira PROJ-123` — verify recent work against a ticket before running this
