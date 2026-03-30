---
name: dsa-project-setup
description: 'Set up a Figma-to-Jira ticket generation project with MCP configuration, folder structure, and a configured generate-tickets.instructions.md. Collects Jira cloud ID, project key, issue type, and Figma URL. Optionally extracts Figma design context. Triggered by: dsa project setup, figma to jira setup, setup ticket generation, ticket generator setup, scaffold ticket project, set up ticket gen.'
argument-hint: 'Optional: project name, Atlassian cloud ID, Jira project key, Figma file URL'
---

# DSA Ticket Generator Setup

Scaffolds a complete Figma-to-Jira ticket generation project. Builds on the standard project-bootstrap structure with MCP prerequisite documentation, a configured `generate-tickets.instructions.md`, and optional Figma design context extraction.

## When to Use

- Starting a project where the workflow is: analyze Figma designs → generate Jira tickets using AI
- Need a `generate-tickets.instructions.md` pre-configured for a specific Jira project and Figma file
- Setting up a workspace from scratch for a DSA ticket generation engagement

---

## Procedure

### Step 1: Gather project info

Use `vscode_askQuestions` to collect all necessary information in one step if the tool is available. Otherwise ask sequentially.

**Project basics:**
1. "What is the project name?" (e.g., "Massport AI Restaurant Search Tickets")
2. "Briefly describe what this project is for. One sentence is fine." (e.g., "Generate Jira tickets from Figma designs for the Massport airport dining app")

**Jira configuration:**
3. "What is your Jira project URL?" (e.g., `https://velir.atlassian.net/jira/software/projects/ASHRR/boards`). Extract the project key and org subdomain from this URL. Then use `getVisibleJiraProjects` to look up the cloud ID and `getJiraProjectIssueTypesMetadata` to retrieve available issue types.
4. "What Jira issue type should be used for component tickets?" — present the options found in the previous step. (Typical answers: `Feature`, `Task`, `Story`)

**Figma configuration:**
5. "Do you have a Figma file URL for the designs? If so, paste it here." (Format: `https://www.figma.com/design/{fileKey}/...?node-id={nodeId}`)

Store all answers. If a Figma URL is provided, extract `fileKey` and `nodeId` from it now.

---

### Step 2: Check MCP prerequisites

Inform the user which MCPs this workflow requires:

> "Before continuing, please confirm these two MCP servers are active in your VS Code MCP panel:
>
> 1. **Atlassian MCP** (`com.atlassian/atlassian-mcp-server`) — for creating Jira issues
> 2. **Figma MCP** (`figma`) — for reading Figma designs
>
> If Figma MCP is not yet set up, add this entry to your global VS Code `mcp.json` (at `%APPDATA%\Code\User\mcp.json` on Windows):
> ```json
> "figma": {
>   "type": "http",
>   "url": "https://mcp.figma.com/mcp"
> }
> ```
> Then authenticate via OAuth at `https://www.figma.com/settings` → Developer → MCP.
>
> Reply **'ready'** when both servers are active."

Wait for user confirmation before proceeding.

---

### Step 3: Create project scaffolding

Create the following files. Use the templates in this skill's `assets/` folder. Replace every `{{PLACEHOLDER}}` before writing.

#### `.github/copilot-instructions.md`

Template: `assets/copilot-instructions.md`

| Placeholder | Value |
| --- | --- |
| `{{PROJECT_NAME}}` | Project name |
| `{{PROJECT_DESCRIPTION}}` | Project description |

#### `README.md`

Template: `assets/README.md`

| Placeholder | Value |
| --- | --- |
| `{{PROJECT_NAME}}` | Project name |
| `{{PROJECT_DESCRIPTION}}` | Project description |
| `{{CLOUD_ID}}` | Atlassian cloud ID |
| `{{JIRA_PROJECT_KEY}}` | Jira project key |
| `{{FIGMA_FILE_URL}}` | Figma file URL (or `TBD` if not provided) |

#### `docs/CONTEXT.md`

Template: `assets/docs/CONTEXT.md`

| Placeholder | Value |
| --- | --- |
| `{{PROJECT_NAME}}` | Project name |
| `{{PROJECT_DESCRIPTION}}` | Project description |
| `{{CLOUD_ID}}` | Atlassian cloud ID |
| `{{JIRA_PROJECT_KEY}}` | Jira project key |
| `{{JIRA_ISSUE_TYPE}}` | Issue type (Feature / Task / Story) |
| `{{JIRA_REFERENCE_PROJECT}}` | Reference project key (or `N/A` if none given) |
| `{{FIGMA_FILE_KEY}}` | Figma file key (or `TBD`) |
| `{{FIGMA_FILE_URL}}` | Full Figma URL (or `TBD`) |

#### `.github/instructions/generate-tickets.instructions.md`

Template: `assets/github/instructions/generate-tickets.instructions.md`

| Placeholder | Value |
| --- | --- |
| `{{CLOUD_ID}}` | Atlassian cloud ID |
| `{{JIRA_PROJECT_KEY}}` | Jira project key |
| `{{JIRA_ISSUE_TYPE}}` | Issue type |
| `{{JIRA_REFERENCE_PROJECT}}` | Reference project key (or `TBD`) |

Also create the directory `docs/figma/` with a `.gitkeep` file inside so the folder is preserved in version control.

---

### Step 4: Optionally extract Figma design context

If a Figma URL was provided in Step 1, ask:

> "Would you like me to extract the design context from the Figma file now? This generates a `docs/figma/design-context.md` file with color tokens, typography, component names, node IDs, and deep links — useful as a reference when writing tickets. It usually takes a few seconds."

If yes:

1. Load and call the `mcp_figma_get_design_context` tool with the extracted `fileKey` and `nodeId` (default to `0:1` if no node ID was in the URL)
2. Analyze the design context response:
   - Identify all named color tokens and their hex values
   - Identify typography styles (font, weight, size, usage)
   - Inventory all components and containers with their node IDs
3. Create `docs/figma/design-context.md` containing:
   - **File metadata** (file name, file key, extraction date)
   - **Design Tokens — Colors** table: Token Name | Hex | Usage
   - **Design Tokens — Typography** table: Style | Font | Weight | Size | Usage
   - **Components** section: one entry per component with node ID and brief description
   - **Key Figma Frame Links** table: Frame | Node ID | Figma Link (format: `https://www.figma.com/design/{fileKey}/?node-id={nodeId}`)

---

### Step 5: Confirm completion

Print a summary of everything created and what to do next:

```
✅ .github/copilot-instructions.md
✅ README.md
✅ docs/CONTEXT.md
✅ .github/instructions/generate-tickets.instructions.md
✅ docs/figma/ (ready for design context files)
[✅ docs/figma/design-context.md — extracted from Figma]

Configured for:
  Jira project : {JIRA_PROJECT_KEY}  (cloud: {CLOUD_ID})
  Issue type   : {JIRA_ISSUE_TYPE}
  Figma file   : {FIGMA_FILE_URL or "not provided yet"}

What's next:
  1. Share any Figma frame URL and say "generate tickets from this frame"
  2. I'll identify components, propose the ticket list, and draft all tickets for your review
  3. After you approve, I'll create them directly in {JIRA_PROJECT_KEY}
```

---

## Maintenance

**Source of truth:**
`https://github.com/Velir/AIResources` — find the skill in the `skills/dsa-project-setup/` folder

**In use:**
The skill is placed directly inside the project folder at `.github/skills/dsa-project-setup/`. VS Code discovers it there automatically — no global installation required.

To update, re-download from the GitHub repo and replace the `.github/skills/dsa-project-setup/` folder in the project.
