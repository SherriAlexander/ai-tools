# pre-pr

Run a gated, ticket-aware sequence of code quality audits before submitting a PR.

## Example usage

```
/pre-pr PROJ-123
```

## What it does

| Phase | What happens |
|-------|--------------|
| 0. Scope | Detects changed files via `git diff` — all audits run against these files only |
| 1. Gate | Runs `audit-jira` — stops if ticket requirements are incomplete |
| 2. Classify | Detects ticket type and size to select the right audit set |
| 3. Audit | Runs selected audits in parallel, scoped to changed files |
| 4. Report | Consolidates findings with a `✅ Ready` or `⚠️ N issues` verdict |

## Audit sets

| Ticket type | Audits run |
|-------------|------------|
| Bug | `audit-errors`, `audit-state-drift`, `audit-dead-code` |
| Small feature (<15 files changed, no new directories) | `audit-errors`, `audit-naming`, `audit-best-practices` |
| Large feature (≥15 files or new directories) | All 8 audit skills in parallel |
| Epic | All 8 audit skills in parallel |

## Why scoped to changed files?

Running audits against the entire codebase for a targeted PR creates noise and wastes tokens. By scoping to `git diff`, each audit focuses only on what changed — results are faster and more relevant.

## Related skills

- `/audit-jira PROJ-123` — run the completeness gate on its own
- `/audit-errors` — run the error handling audit standalone
- `/audit-best-practices` — run the best practices audit standalone
