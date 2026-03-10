---
name: reconcile-init
description: Reconcile local project rules with master init commands
---

# Reconcile Init Command

Reconcile local project rules with the master init commands. Performs a two-way comparison and synchronizes differences.

**Usage**: `/reconcile-init` or `/reconcile-init {name}`

**Argument**: `$ARGUMENTS` — optional init name (e.g., `react`, `laravel`). If omitted, prompts for selection.

---

## Phase 1: Detect Available Inits to Reconcile

1. **Check for local instructions directory**: Look for `.github/instructions/` in the current project
   - If it doesn't exist, report: "No `.github/instructions/` directory found. Run `/init-all` first to set up your project rules."
   - Exit

2. **Find reconcilable inits**: List all `.md` files in `.github/instructions/`
   - For each file, check if a corresponding master init exists at `~/.copilot/skills/init-{name}/SKILL.md`
   - Only include files that have a matching master init

3. **Handle argument** (from `$ARGUMENTS`):
   - If provided: validate it exists in both locations, proceed to Phase 2
   - If empty: proceed to selection

4. **Present selection** using `AskUserQuestion`:
   - **Question**: "Which init do you want to reconcile?"
   - **Options**: List each reconcilable init with format:
     - `{name}` — "{name} instructions (local ↔ master)"
   - Let user pick one

---

## Phase 2: Load Both Versions

1. **Read local instructions file**: `.github/instructions/{name}.instructions.md`
   - Extract the full content

2. **Read master init file**: `~/.copilot/skills/init-{name}/SKILL.md`
   - Locate content between `<!-- RULES_START -->` and `<!-- RULES_END -->`
   - This is the "master content"

3. **Normalize for comparison**:
   - Strip YAML frontmatter from both (store separately)
   - Trim whitespace

---

## Phase 3: Compare and Identify Differences

Perform a semantic comparison:

1. **Check if identical**: If normalized content matches exactly:
   - Report: "✓ {name} is already in sync — no differences found."
   - Exit

2. **Identify differences**:
   - **Added in local**: Content in local file not in master
   - **Added in master**: Content in master not in local
   - **Modified sections**: Sections with same heading but different content

3. **Present diff summary**:
   ```
   Comparing {name}:

   Local (.github/instructions/{name}.instructions.md):
     - [X] lines, last modified [date if available]

   Master (~/.copilot/skills/init-{name}/SKILL.md):
     - [Y] lines

   Differences found:
     - [Description of key differences]
   ```

4. **Show detailed diff**:
   - Display a side-by-side or unified diff of the changes
   - Highlight sections that differ

---

## Phase 4: Choose Reconciliation Strategy

Ask the user using `AskUserQuestion`:

**Question**: "How would you like to reconcile these differences?"

**Options**:
1. **Local → Master** — "Update master init with local changes (your edits become the new standard)"
2. **Master → Local** — "Update local rules from master (reset to standard, lose local edits)"
3. **Merge (interactive)** — "I'll show each difference and let you choose what to keep"
4. **View full diff** — "Show me the complete diff before deciding"

---

## Phase 5a: Local → Master

If user chose to push local changes to master:

1. **Extract and update master**:
   - Read `~/.copilot/skills/init-{name}/SKILL.md`
   - Replace content between `<!-- RULES_START -->` and `<!-- RULES_END -->` with local content
   - Preserve the init file structure (header, target file, path pattern sections)

2. **Confirm before writing**:
   - Show what will change in the master init
   - Ask: "Apply these changes to the master init?"

3. **Write if confirmed**:
   - Update `~/.copilot/skills/init-{name}/SKILL.md`
   - Report success

---

## Phase 5b: Master → Local

If user chose to reset local to master:

1. **Overwrite local file**:
   - Extract master content (between markers)
   - Write to `.github/instructions/{name}.instructions.md`

2. **Confirm before writing**:
   - Warn: "This will overwrite your local changes. Continue?"

3. **Write if confirmed**:
   - Update `.github/instructions/{name}.instructions.md`
   - Report success

---

## Phase 5c: Interactive Merge

If user chose interactive merge:

1. **Split into sections**: Parse both files by `###` headings

2. **For each differing section**, ask using `AskUserQuestion`:
   - **Question**: "Section: {heading} — which version do you want to keep?"
   - Show both versions
   - **Options**:
     - **Local version** — "[preview of local content]"
     - **Master version** — "[preview of master content]"
     - **Keep both** — "Combine both versions"
     - **Skip** — "Leave this section unchanged"

3. **Build merged result** based on choices

4. **Preview final merge**:
   - Show the complete merged content
   - Ask: "Apply this merged version to both local and master?"

5. **Write if confirmed**:
   - Update `.github/instructions/{name}.instructions.md`
   - Update `~/.copilot/skills/init-{name}/SKILL.md` (content between markers)
   - Report success

---

## Phase 5d: View Full Diff

If user chose to view full diff:

1. **Display complete unified diff**:
   ```diff
   --- Local: .github/instructions/{name}.instructions.md
   +++ Master: ~/.copilot/skills/init-{name}/SKILL.md

   [full diff output]
   ```

2. **Return to Phase 4**: Ask reconciliation strategy again

---

## Phase 6: Report Results

```
Reconciliation complete:

  {Strategy applied}:
    ✓ ~/.copilot/skills/init-{name}/SKILL.md — [updated/unchanged]
    ✓ ./.github/instructions/{name}.instructions.md — [updated/unchanged]

  Summary:
    - [Brief description of changes made]
```

---

## Notes

- The master init file structure is preserved — only content between `<!-- RULES_START -->` and `<!-- RULES_END -->` is modified
- YAML frontmatter (`applyTo:` field) is preserved in both files
- This command is bidirectional — changes can flow either direction
- For bulk reconciliation of multiple inits, run this command multiple times or implement a "reconcile all" option in the future
