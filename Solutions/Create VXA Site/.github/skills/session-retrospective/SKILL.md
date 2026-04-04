---
name: session-retrospective
description: >
  Review the current session for errors, failed commands, workarounds, and new
  learnings. Propose targeted additions to the project's knowledge base docs —
  then write them after explicit user confirmation. Use at the close of any
  session that involved API calls, script execution, MCP tool use, or debugging.
  Trigger phrases: session retrospective, log what we learned, update the docs,
  what broke, end of session, close out session.
argument-hint: 'Optional: name a specific doc to focus on (e.g. "SITECORE_SCRIPTING_CONVENTIONS.md"), or leave blank to review the full session.'
---

# Session Retrospective

## Purpose

Capture what worked, what broke, and what had to be worked around — and make
sure that knowledge lands permanently in the project's context files so future
sessions don't repeat the same mistakes.

This skill is **confirm-before-write**: it analyses the session, proposes
additions as a table, and only writes to files after you approve.

---

## When to Run

- At the close of any session involving script execution, terminal commands, or
  API/MCP calls
- After debugging a recurring issue that wasn't documented yet
- After discovering a new API behavior, field name rule, or tool limitation
- After a build script run that required mid-session corrections
- Any time you hear yourself say "I need to remember this"

---

## Step 1 — Review the Session

Scan the conversation history and terminal output for:

### Signals to look for

| Signal | Examples |
|--------|----------|
| **Failed commands** | Exit code ≠ 0, `NativeCommandError`, `not recognized`, `permission denied` |
| **API / GQL warnings** | `WARNING: GQL: Cannot find a field`, `404 Not Found`, `fetch failed`, `fs.readFile is not implemented` |
| **Workarounds applied** | "Instead of X, I used Y because…" |
| **Corrected assumptions** | Wrong field name used first, then corrected; wrong GUID format; wrong parameter name |
| **Retry patterns** | Same command run 2+ times with changes before it succeeded |
| **New confirmations** | A behavior or field name confirmed working for the first time |
| **Env / auth patterns** | Token expiry behaviour, clone auth issues, CLI session vs bearer token differences |
| **Tool limitations discovered** | An MCP tool, CLI command, or API endpoint that doesn't work as expected |

### What NOT to capture

- Things already documented in the project's context files (skip duplicates — check first)
- One-off typos or copy-paste mistakes with no generalizable lesson
- Things that only apply to a single run and won't recur

---

## Step 2 — Build the Proposal Table

For each candidate learning, produce a row:

```
| # | Learning | Category | Recommended doc | Section | Action |
|---|----------|----------|-----------------|---------|--------|
| 1 | `git push` exits with code 1 even on success when stderr contains remote tracking info | Dev tooling | (project CONTEXT.md or a new agent-patterns.md) | Agent Terminal Patterns | Add note |
| 2 | `gh repo clone` uses SSH by default; must set GH_PROTOCOL=https or use `gh auth setup-git` first | Dev tooling | (new or existing) | Git / GitHub Patterns | Add note |
| 3 | ... | | | | |
```

**Category values:** `API behavior`, `Field names`, `Tool limitation`, `Auth / tokens`, `CLI behavior`, `Dev tooling`, `Content rules`, `Layout / DPID`, `Media upload`, `Agent process`

**Action values:** `Add note`, `Add example`, `Correct existing entry`, `Create new section`, `Create new doc`

**Recommended doc** — choose the most appropriate existing doc first:
- Scripting / API / GraphQL patterns → `SITECORE_SCRIPTING_CONVENTIONS.md`
- MCP tool behavior, what works/doesn't → `MARKETER_MCP_KNOWLEDGE_BASE.md`
- Project decisions, milestones, open questions → `CONTEXT.md` (Key Decisions table)
- Component specs, field names, rendering IDs → `VXA_COMPONENT_SPECS.md`
- General dev tooling, git, terminal patterns → create `docs/DEV_PATTERNS.md` if it doesn't exist
- Cross-project / agent-level patterns → create `docs/AGENT_PATTERNS.md` if it doesn't exist

If the right doc doesn't exist yet, note that in the Action column.

---

## Step 3 — Present and STOP

Post the proposal table to the user. **Do not write anything yet.**

Also state:
- How many items were found
- Which docs would be modified or created
- Any items you are uncertain about (flag separately — do not include in the write batch without confirmation)

Then stop and wait for the user to:
- Approve all → proceed to Step 4
- Approve some → restate the approved subset, proceed
- Edit wording → incorporate edits, proceed
- Reject → skip and close

---

## Step 4 — Write Approved Items

For each approved item:

1. **If the target doc exists:** append to the appropriate section, or add a new
   subsection if needed. Do not reformat unrelated content.

2. **If the target doc does not exist:** create it with a minimal header and the
   new content block. Announce that you created a new file.

3. **Key Decisions table entries** (for `CONTEXT.md`): follow the existing table
   format exactly:
   ```
   | {today's date} | {one-line decision or finding} | {short notes} |
   ```

4. **Scripting conventions entries**: follow the existing H2/H3 structure. Add
   under the most relevant existing section, or add a new H2 if truly a new
   category.

5. **After writing each file:** briefly confirm what was added (file name +
   section heading). Do not summarize the content — just confirm it landed.

---

## Step 5 — Project Sync (if applicable)

If this skill is being run in a solution project that has a copy of this skill
under `.github/skills/`, and the canonical copy in `skills/` was not modified —
no sync needed.

If the project's `.github/skills/session-retrospective/SKILL.md` is a copy from
a prior version, note that a newer version exists in `skills/` and offer to sync.

---

## Step 6 — Close Out

Summarize:
- N items written to M files
- Any items skipped and why
- Reminder: commit the updated doc files to git before ending the session

---

## Notes for the Agent

- **Never write without confirmation.** This skill analyses and proposes; the user approves.
- **Check before writing.** Before adding an item, do a quick grep/search to confirm it isn't already in the target doc. Duplicates erode trust in the docs.
- **Be specific.** "Don't use X" is less useful than "Using X causes Y — use Z instead because..."
- **Date entries.** All Key Decisions table rows should be dated with today's date.
- **Don't over-capture.** 3 high-quality entries per session beats 15 vague ones. Prefer specificity over volume.
- **Hallucination guard.** If you are unsure whether something you observed is a real pattern or a one-time fluke, flag it as `(unconfirmed — 1 occurrence)` in the proposal table. Do not present it as established fact.
