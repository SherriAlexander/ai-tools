# pre-pr

Run a gated, ticket-aware sequence of code quality audits before submitting a PR.

## Example usage

```
/pre-pr PROJ-123
```

To bypass the `audit-jira` completeness gate (e.g. when the audit result is unreliable but requirements are confirmed met):

```
/pre-pr PROJ-123 --skip-jira
```

For automated callers (Husky, git hooks) — auto-selects Quick depth without prompting:

```
/pre-pr PROJ-123 --hook
```

## What it does

| Phase | What happens |
|-------|--------------|
| 0. Scope | Prompts for a base branch name under `origin/` (default: `main`), then detects changed files via `git diff` — all audits run against these files only |
| 1. Gate | Runs `audit-jira` — stops if ticket requirements are incomplete (skipped with `--skip-jira`) |
| 2. Select depth | Prompts for Quick / Medium / In-depth / Custom (auto-selects Quick if `--hook`) |
| 3. Audit | Runs selected audits in parallel, scoped to changed files |
| 4. Report | Consolidates findings with a `✅ Ready` or `⚠️ N issues` verdict |

## Audit depths

| Depth | Audits run |
|-------|------------|
| Quick (default) | `audit-best-practices` |
| Medium | `audit-best-practices`, `audit-errors`, `audit-naming`, `audit-todos` |
| In-depth | All 8 audit skills in parallel |
| Custom | User-selected subset |

## Why scoped to changed files?

Running audits against the entire codebase for a targeted PR creates noise and wastes tokens. By scoping to `git diff origin/<branch>...HEAD` (or a re-scoped variant), each audit focuses only on what changed — results are faster and more relevant.

## Related skills

- `/audit-jira PROJ-123` — run the completeness gate on its own
- `/audit-errors` — run the error handling audit standalone
- `/audit-best-practices` — run the best practices audit standalone
