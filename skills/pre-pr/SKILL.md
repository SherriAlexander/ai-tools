---
name: pre-pr
description: Run a gated sequence of code quality audits before submitting a PR. Verifies ticket completeness first, then dispatches ticket-appropriate parallel audits scoped to changed files.
argument-hint: "PROJ-123"
---

# Pre-PR Audit

Verify your work satisfies the Jira ticket AND meets code quality standards before submitting a PR. Runs `audit-jira` as a completeness gate, then dispatches the appropriate parallel quality audits scoped to changed files only.

## Setup

The `$ARGUMENT` is the Jira ticket identifier — either a ticket ID (e.g. `PROJ-123`) or a full Jira URL. If not provided, ask the user before proceeding.

An optional `--skip-jira` flag may be appended to bypass the `audit-jira` completeness gate (e.g. `PROJ-123 --skip-jira`). Use this when the audit result is known to be unreliable or the user has confirmed the ticket requirements are met. When the flag is present, skip Phase 1 entirely, note the bypass in the Phase 4 summary, and proceed directly to Phase 2.

An optional `--hook` flag signals that the skill is being invoked by an automated caller (e.g. Husky, a git hook). When present, auto-select **Quick** depth in Phase 2 without prompting.

---

## Phase 0: Scope Changed Files

Ask the user which base branch name to diff against under `origin`.

Prompt:
> Enter a base branch name for the initial diff under `origin/` (default: `main`).
>
> Examples: `main`, `develop`, `support`, `project-branchname`

If the user presses enter, use `main`.

Run the following to identify files changed in this branch:

```bash
git diff --name-only origin/<base-branch>...HEAD
```

If `origin/<base-branch>` fails, try in order: `origin/main...HEAD`, `origin/master...HEAD`, `origin/develop...HEAD`. Use whichever succeeds first and record the one that worked as `resolved-base-branch`.

If git is unavailable or returns no files:
- **Warn the user**: "No changed files detected — audits will run against the full codebase. This costs significantly more tokens."
- Ask: "Do you want to continue unscoped, or cancel?"
  - If **cancel** → stop with: "Cancelled. Re-run `/pre-pr` from a branch with detectable changes."
  - If **continue** → skip Phase 0b and proceed to Phase 1. Record scope as `full codebase (no changed files detected)`.

Capture the changed file list. Carry it into Phase 0b.

---

## Phase 0b: Confirm Scope

Display the detected file count and list:

- If ≤20 files, show all of them.
- If >20 files, show the first 20 and append:
  > … and N more files — reply "show all" to see the full list.
  
  If the user replies "show all", display the complete list, then re-present the scope options below.

**Always pass the full file list to audits regardless of what is displayed.**

Then ask the user how to proceed:

> **How would you like to scope the audits?**
> - **Proceed with all N files** — continue with the detected list
> - **Scope to recent commits** — narrow to files changed in a specific commit range
> - **Change base branch** — diff against a different branch name under `origin/`
> - **Specify files manually** — enter paths or glob patterns

**If "Scope to recent commits":**
Run `git log --oneline -15` and display the output. Then prompt:

> Select a base commit. Files changed from that commit onward will be included in the audit.
>
> Enter the short SHA (e.g. `d8e004a` to audit only your last 3 commits).
>
> 💡 _Tip: choose the commit just **before** your first change on this branch._

Once the user provides a SHA, run:
```bash
git diff --name-only <sha>...HEAD
```
Replace the file list with the result. Record scope as `commit range <sha>...HEAD`.

**If "Change base branch":**
Ask the user for a branch name under `origin/` (e.g. `develop`, `support`, `project-branchname`). Run:
```bash
git diff --name-only origin/<branch>...HEAD
```
Replace the file list with the result. Record scope as `origin/<branch>...HEAD`.

**If "Specify files manually":**
Ask the user for comma-separated paths or glob patterns. Replace the file list with the result. Record scope as `manually specified`.

**If "Proceed with all N files":**
Record scope as `origin/<resolved-base-branch>...HEAD`.

After any re-scoping, confirm the final file count:
> Scope confirmed: **N files**. Proceeding with audits.

---

## Phase 1: Completeness Gate (audit-jira)

> **Skip this phase** if `--skip-jira` was passed. Proceed directly to Phase 2 and record `Jira gate: bypassed (--skip-jira)` in the Phase 4 summary.

Run `audit-jira $ARGUMENT`.

Read the `## Summary` block of the result:

- **Issue Type**: Extract and record (Bug, Story, Task, Feature, Epic, etc.)
- **Status**:
  - If `Incomplete` → Surface the "Items Needing Attention" section verbatim, then **STOP**:
    > "The ticket has unmet requirements. Address the items above before running `/pre-pr` again."
  - If `Complete` or `Nearly Complete` → Continue to Phase 2.

---

## Phase 2: Select Audit Depth

**If `--hook` is present in `$ARGUMENT`:** Auto-select **Quick** without prompting. Skip the menu and proceed directly to Phase 3 with the Quick skill list.

**Otherwise, ask the user:**

> **Which audit depth would you like to run?**
> 1. **Quick** (default) — `audit-best-practices`
> 2. **Medium** — `audit-best-practices`, `audit-errors`, `audit-naming`, `audit-todos`
> 3. **In-depth** — all 8 audit skills
> 4. **Custom** — choose individual audits

If the user selects **Custom**, present a checklist of all available audits (default on: `audit-best-practices`):
- [x] `audit-best-practices`
- [ ] `audit-errors`
- [ ] `audit-naming`
- [ ] `audit-todos`
- [ ] `audit-boundaries`
- [ ] `audit-abstractions`
- [ ] `audit-dead-code`
- [ ] `audit-state-drift`

**Audit sets:**

| Depth | Skills |
|-------|--------|
| Quick | `audit-best-practices` |
| Medium | `audit-best-practices`, `audit-errors`, `audit-naming`, `audit-todos` |
| In-depth | `audit-best-practices`, `audit-errors`, `audit-naming`, `audit-todos`, `audit-boundaries`, `audit-abstractions`, `audit-dead-code`, `audit-state-drift` |
| Custom | user-selected subset |

Record the selected depth label. Resolve to a flat skill list and carry it into Phase 3.

---

## Phase 3: Parallel Quality Audits

**Launch all skills from the Phase 2 skill list simultaneously** using `Task` with `subagent_type=Explore`.

For each subagent, provide:

1. **The changed files list** from Phase 0b — each audit must restrict analysis to these files only, per its "File Scope" instructions.
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
Jira gate:     [Complete | Nearly Complete | bypassed (--skip-jira)]
Audit depth:   [Quick | Medium | In-depth | Custom]
Files scoped:  X changed files ([scope method])

✅ Ready for PR — 0 issues found
```

or

```
## Pre-PR Summary

Ticket:        [TICKET-ID] — [Title]
Issue type:    [Bug | Feature | etc.]
Jira gate:     [Complete | Nearly Complete | bypassed (--skip-jira)]
Audit depth:   [Quick | Medium | In-depth | Custom]
Files scoped:  X changed files ([scope method])

⚠️  N issues need attention before PR
Critical: X  |  High: X  |  Medium: X  |  Low: X
```

`[scope method]` values:
- `origin/<resolved-base-branch>...HEAD` — initial selected/resolved diff base
- `commit range <sha>...HEAD` — after commit selection
- `origin/<branch>...HEAD` — after base branch change
- `manually specified` — after manual entry
- `full codebase (no changed files detected)` — unscoped fallback
