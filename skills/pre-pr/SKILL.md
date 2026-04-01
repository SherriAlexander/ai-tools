---
name: pre-pr
description: Run a gated sequence of code quality audits before submitting a PR. Verifies ticket completeness first, then dispatches ticket-appropriate parallel audits scoped to changed files.
argument-hint: "PROJ-123"
---

# Pre-PR Audit

Verify your work satisfies the Jira ticket AND meets code quality standards before submitting a PR. Runs `audit-jira` as a completeness gate, then dispatches the appropriate parallel quality audits scoped to changed files only.

## Setup

The `$ARGUMENT` is the Jira ticket identifier — either a ticket ID (e.g. `PROJ-123`) or a full Jira URL. If not provided, ask the user before proceeding.

---

## Phase 0: Scope Changed Files

Run the following to identify files changed in this branch:

```bash
git diff --name-only origin/main
```

If `origin/main` fails, try in order: `main`, `master`, `develop`. Use whichever succeeds first.

If git is unavailable or returns no files:
- **Warn the user**: "No changed files detected — audits will run against the full codebase. This costs significantly more tokens."
- Continue unscoped.

Capture the changed file list. Pass it to every audit in Phase 3.

---

## Phase 1: Completeness Gate (audit-jira)

Run `audit-jira $ARGUMENT`.

Read the `## Summary` block of the result:

- **Issue Type**: Extract and record (Bug, Story, Task, Feature, Epic, etc.)
- **Status**:
  - If `Incomplete` → Surface the "Items Needing Attention" section verbatim, then **STOP**:
    > "The ticket has unmet requirements. Address the items above before running `/pre-pr` again."
  - If `Complete` or `Nearly Complete` → Continue to Phase 2.

---

## Phase 2: Classify Ticket

Use Issue Type and changed-files count to select the audit set:

| Condition | Audit Set |
|-----------|-----------|
| Issue Type = Bug | Bug |
| Issue Type = Epic | Large feature |
| Feature/Story/Task AND <15 changed files AND no new directories | Small feature |
| Feature/Story/Task AND (≥15 changed files OR new directories added) | Large feature |

If the classification is ambiguous (e.g., a "Task" with 18 changed files and no new directories), confirm with the user before proceeding.

**Audit sets:**

| Set | Skills |
|-----|--------|
| Bug | `audit-errors`, `audit-state-drift`, `audit-dead-code` |
| Small feature | `audit-errors`, `audit-naming`, `audit-best-practices` |
| Large feature | `audit-errors`, `audit-naming`, `audit-best-practices`, `audit-boundaries`, `audit-abstractions`, `audit-dead-code`, `audit-state-drift`, `audit-todos` |

---

## Phase 3: Parallel Quality Audits

**Launch all selected audit skills simultaneously** using `Task` with `subagent_type=Explore`.

For each subagent, provide:

1. **The changed files list** from Phase 0 — each audit must restrict analysis to these files only, per its "File Scope" instructions.
2. **The instruction**: "Use compact grouped output format. Omit groups with zero findings."

---

## Phase 4: Consolidate Results

Collect all subagent results and merge into a single report:

1. Group all findings across all audits by severity: Critical → High → Medium → Low
2. Prefix each finding with its source: `[audit-errors]`, `[audit-naming]`, etc.
3. List audits with zero findings on a single `✓ clean` line each

End with a verdict block:

```
## Pre-PR Summary

Ticket:        [TICKET-ID] — [Title]
Issue type:    [Bug | Feature | etc.]
Audit set:     [Bug | Small feature | Large feature]
Files scoped:  X changed files

✅ Ready for PR — 0 issues found
```

or

```
## Pre-PR Summary

Ticket:        [TICKET-ID] — [Title]
Issue type:    [Bug | Feature | etc.]
Audit set:     [Bug | Small feature | Large feature]
Files scoped:  X changed files

⚠️  N issues need attention before PR
Critical: X  |  High: X  |  Medium: X  |  Low: X
```
