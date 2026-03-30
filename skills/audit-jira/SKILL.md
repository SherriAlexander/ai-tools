---
name: audit-jira
description: Verify that recent work satisfies all requirements, technical specs, and acceptance criteria defined in a Jira ticket. Use when wrapping up a feature, preparing for a PR, or doing a pre-QA completeness check. Accepts a Jira ticket ID or URL as an argument (e.g. "PROJ-123" or a full Jira URL).
---

# Jira Ticket Verification

Cross-reference recent work against a Jira ticket to confirm all requirements, technical specs, and acceptance criteria have been satisfied.

## Setup

The `$ARGUMENT` is the Jira ticket identifier — either a ticket ID (e.g. `PROJ-123`) or a full Jira URL. If not provided, check the conversation for a recently mentioned ticket. If none is available, ask the user for it before proceeding.

---

## Phase 1: Fetch the Jira Ticket

Retrieve the full ticket content. Try in this order:

1. **MCP Jira tool** — if a Jira MCP server is available in the current workspace, use it to fetch the ticket by ID.
   - If no Jira MCP server is found, offer to help the user install one before continuing:
     > "No Jira MCP server was detected in your workspace. Would you like help setting one up? The [Atlassian MCP server](https://github.com/atlassian/mcp-atlassian) is the official option and supports Jira Cloud and Data Center. I can walk you through installing and configuring it."
   - If the user declines, fall through to the next option.
2. **fetch_webpage** — if a URL was provided, fetch the page directly.
3. **Ask the user** — if neither option is available, ask the user to paste the ticket content or share a readable export.

Once retrieved, confirm the ticket ID and title back to the user before proceeding.

---

## Phase 2: Extract All Requirements

Parse the ticket and collect every verifiable requirement. Capture all of the following when present:

### 2a. Acceptance Criteria
- Every line in the "Acceptance Criteria" or "AC" section
- Any "Given / When / Then" or BDD-style scenarios
- Any explicit "Definition of Done" checklist items

### 2b. Technical Specifications
- Field definitions and data tables (see column mappings below)
- API contracts, endpoints, or payload shapes described in the ticket
- Stated constraints (e.g. max length, required vs. optional, allowed values)
- Architectural notes or decisions
- Integration points with 3rd-party services

### 2c. Functional Requirements
- Described behaviors ("the component should...", "when the user clicks...")
- Named variants, states, or modes
- Error handling requirements
- Responsive / accessibility requirements

### 2d. Sub-tasks and Linked Tickets
- List any sub-tasks or child tickets and note whether they are included in scope
- Flag any blocking or linked tickets that must be resolved first

### 2e. Out of Scope Notes
- Record anything explicitly marked out of scope so it isn't flagged as missing

**Data Table Column Reference** (for Jira field tables):

| Column | What to Extract |
|---|---|
| Display Name / Name | Human-readable field label |
| Machine Name | Programmatic key to look for in code |
| Field Type | Expected data type or widget |
| Required | Whether the field must be present |
| Default Value | Verify the default is implemented |
| Mapping / Notes | Cross-ticket references; check if those tickets are also resolved |

---

## Phase 3: Analyze Recent Work

Gather evidence of what has actually been implemented:

1. **Review the conversation** — summarize what was built or changed in this session.

2. **Check git for modified files**:
   ```
   git status
   git diff --stat HEAD
   git diff --name-only HEAD~10  # broader recent history if needed
   ```

3. **Read key changed files** — for each modified file relevant to the ticket:
   - Scan for field machine names from the data table
   - Look for acceptance criteria keywords (component names, behaviors, states)
   - Check for required fields, default values, and any constraints mentioned in the ticket

4. **Check for tests** — confirm test coverage exists for ticket-specified behaviors when the ticket or team conventions require it.

5. **Check for related config or schema changes** — e.g. content type definitions, GraphQL schema, migration files, Sitecore templates, or CMS renderings if applicable.

---

## Phase 4: Cross-Reference Requirements Against Implementation

For each extracted requirement, assess its status:

| Status | Meaning |
|---|---|
| ✅ Complete | Clear evidence in code that this is satisfied |
| ⚠️ Partial | Some evidence, but missing edge cases, defaults, or a variant |
| ❌ Missing | No evidence found in the recent changes |
| ⬜ Out of Scope | Explicitly excluded in the ticket |
| ❓ Cannot Verify | Requires runtime, environment, or external context to confirm |

---

## Phase 5: Generate Verification Report

Output a structured report:

```markdown
# Jira Ticket Verification: [TICKET-ID] — [Ticket Title]

## Summary
- **Status**: [Complete / Nearly Complete / Incomplete]
- **Requirements checked**: X
- **Complete**: X | **Partial**: X | **Missing**: X | **Out of Scope**: X | **Cannot Verify**: X

---

## Acceptance Criteria

| # | Criterion | Status | Notes |
|---|---|---|---|
| 1 | [criterion text] | ✅ / ⚠️ / ❌ | [evidence or gap] |

---

## Technical Specifications

| Requirement | Status | Notes |
|---|---|---|
| Field: `machineName` (FieldType, required) | ✅ / ⚠️ / ❌ | [evidence or gap] |
| Default: `machineName` = `value` | ✅ / ⚠️ / ❌ | |

---

## Functional Requirements

| # | Requirement | Status | Notes |
|---|---|---|---|

---

## Sub-tasks / Linked Tickets

| Ticket | Summary | Status | Notes |
|---|---|---|---|

---

## Items Needing Attention

[Bullet list of anything ⚠️ Partial or ❌ Missing with actionable context]

---

## Out of Scope (Not Checked)

[List anything explicitly excluded]
```

---

## Phase 6: Recommend Next Steps

After the report, provide a prioritized list of what remains:

1. **Must fix before PR** — any ❌ Missing items that are core to the acceptance criteria
2. **Should address** — ⚠️ Partial items that may cause QA failures
3. **Nice to have** — minor gaps that could be deferred
4. **Needs clarification** — ❓ items requiring product or design input

If everything is ✅ Complete, confirm the ticket is ready for review and suggest one or more of the following audit skills as a next step depending on the nature of the work:

- `audit-best-practices` — verify the implementation follows conventions for the detected stack
- `audit-errors` — check for silent failures or inconsistent error handling in new code
- `audit-dead-code` — ensure no abandoned experiments or unreachable code were left behind
- `audit-naming` — confirm any new identifiers are clear and consistent with the codebase
