# DSA Ticket Generator — New User Quickstart

A step-by-step walkthrough for setting up and running the Figma-to-Jira ticket generation workflow from scratch. Assumes you have an empty project folder open in VS Code with GitHub Copilot.

---

## What you'll end up with

By the end of this guide you will have:
- A folder scaffolded with all the structure and AI instructions needed to generate tickets from any Figma file
- Both MCP servers (Atlassian + Figma) active and authenticated
- A `generate-tickets.instructions.md` pre-configured for your specific Jira project
- Tickets created in Jira — drafted, reviewed, then pushed directly from VS Code — no copy/paste

---

## Prerequisites

Before you start, confirm you have:

- [ ] **VS Code** with the **GitHub Copilot** extension installed and signed in
- [ ] **Copilot Agent mode** available (the "Agent" option in the Copilot Chat model selector)
- [ ] Access to **velir.atlassian.net** with your Velir account
- [ ] Access to the target **Figma file** (you need at least Viewer access)
- [ ] Access to the **Velir AI Resources GitHub repo**: https://github.com/Velir/AIResources

---

## Part 1 — Add the Skill to Your Project Folder

The `dsa-project-setup` skill lives in the Velir AI Resources GitHub repository. Download it and place it in a `.github/skills/` folder inside your project — VS Code will discover it there automatically. No global installation needed.

### 1.1 Download the skill from GitHub

1. Go to **https://github.com/Velir/AIResources**
2. Click **Code → Download ZIP** to download the full repository
3. Extract the ZIP — inside, locate the `skills/dsa-project-setup/` folder

### 1.2 Copy the skill into your project folder

Inside your project folder, create a `.github/skills/` directory if it doesn't exist, then place the `dsa-project-setup` folder inside it:

```
your-project-folder/
└── .github/
    └── skills/
        └── dsa-project-setup/
            └── SKILL.md       ← if you see this, it's in the right place
```

You'll confirm the skill is working when you reach Part 7. If it doesn't activate there, see Troubleshooting at the bottom of this guide.

---

## Part 2 — Set Up the Atlassian MCP

If you already have `com.atlassian/atlassian-mcp-server` showing as **Running** in your VS Code MCP panel, skip to Part 3.

### 2.1 Add the Atlassian MCP via Copilot

Open Copilot Chat in **Agent mode** and paste this prompt:

```
Add the Atlassian MCP server to my VS Code mcp.json. The server entry should be:
{
  "com.atlassian/atlassian-mcp-server": {
    "type": "http",
    "url": "https://mcp.atlassian.com/v1/mcp"
  }
}
```

Copilot will locate your global VS Code `mcp.json` and add the entry. If the file doesn't exist, it will create it.

> **Where is mcp.json?**
> - **Windows:** `%APPDATA%\Code\User\mcp.json`
> - **Mac:** `~/Library/Application Support/Code/User/mcp.json`

### 2.2 Authenticate with Atlassian

1. Open the VS Code MCP panel — open the Command Palette and search **"MCP Servers"**
2. Find `com.atlassian/atlassian-mcp-server` and click **Start**
3. A browser window will open — sign in with your **Velir Atlassian account**
4. Once signed in, the server status should show **Running**

---

## Part 3 — Set Up the Figma MCP

If you already have `figma` showing as **Running** in your VS Code MCP panel, skip to Part 4.

### 3.1 Add the Figma MCP via Copilot

Open Copilot Chat in **Agent mode** and paste this prompt:

```
Add the Figma MCP server to my VS Code mcp.json. The server entry should be:
{
  "figma": {
    "type": "http",
    "url": "https://mcp.figma.com/mcp"
  }
}
```

Copilot will add the entry to your global VS Code `mcp.json`.

### 3.2 Authenticate with Figma

1. In the VS Code MCP panel, find `figma` and click **Start**
2. A browser OAuth prompt will open — authorize with your **Figma account**
3. The server status should show **Running**

---

## Part 4 — Get your Jira project URL

All you need is the URL to the Jira project. It looks like:

```
https://velir.atlassian.net/jira/software/projects/ASHRR/boards
```

Copilot will extract the project key from the URL and use the Atlassian MCP to look up the available issue types automatically — no manual digging required.

If you're just testing and don't have a real project, ask a team lead to set up a throwaway project and share the URL.

---

## Part 5 — Get your Figma URL

Navigate to your Figma file, select the frame you want to generate tickets from, and copy the URL from the browser bar. It will look like:

```
https://www.figma.com/design/vreFqCFftg52VoYXuaw55K/My-Project-Name?node-id=1-6
```

Keep this handy — you'll paste it into the setup flow in a moment.

---

## Part 6 — Open VS Code in your project folder

1. Open VS Code
2. **File → Open Folder** → select your project folder (the one containing `.github/skills/dsa-project-setup/`)
3. Open Copilot Chat — click the chat icon in the sidebar or use the keyboard shortcut
4. **Switch to Agent mode** — click the mode selector at the top of the chat panel and choose **Agent**

> The skill only activates when Copilot is in Agent mode, not in Ask or Edit mode.

---

## Part 7 — Run the setup skill

In the Copilot Chat panel, type:

```
dsa project setup
```

Copilot will recognize the skill and begin the setup interview. It will ask you for:

1. **Project name** — a short human-readable name (e.g., "Massport AI Restaurant Search Tickets")
2. **Project description** — one sentence (e.g., "Generate Jira tickets from Figma designs for the Massport airport dining app")
3. **Jira project URL** — paste the URL you found in Part 4 (e.g., `https://velir.atlassian.net/jira/software/projects/ASHRR/boards`). Copilot will extract the project key and look up available issue types via the Atlassian MCP.
4. **Issue type** — Copilot will present the options it found; confirm which one to use for component tickets (typically `Feature` or `Task`)
5. **Figma file URL** — paste the URL from Part 5

Answer each question. When asked to confirm MCPs are ready, reply **`ready`**.

---

## Part 8 — Let the skill scaffold your project

After you confirm MCPs are active, Copilot will create the following files automatically:

```
your-folder/
├── .github/
│   ├── copilot-instructions.md        ← Copilot behavior rules for this project
│   └── instructions/
│       └── generate-tickets.instructions.md  ← Ticket workflow + templates (pre-configured)
├── docs/
│   ├── CONTEXT.md                     ← Living context: config, decisions, notes
│   └── figma/                         ← Where design context files will live
└── README.md                          ← Project overview + MCP setup instructions
```

You don't need to do anything — just wait for Copilot to finish creating each file.

---

## Part 9 — Extract Figma design context (recommended)

After scaffolding, Copilot will ask:

> "Would you like me to extract the design context from the Figma file now?"

**Say yes.** This creates `docs/figma/design-context.md` with:
- Color tokens (names, hex values, usage)
- Typography styles
- An inventory of every component and container in the Figma frame with their node IDs
- Deep links to each frame

This file becomes the reference document when writing tickets. It's what lets Copilot name components accurately and link directly to the right Figma frame in each ticket description.

---

## Part 10 — Generate tickets from a Figma frame

Once setup is complete, generating tickets is a single prompt. You can identify the frame by URL or by node ID — either works:

**Option A — paste the full Figma frame URL:**
```
Generate tickets from this frame: https://www.figma.com/design/{fileKey}/...?node-id=1-6
```

**Option B — paste just the node ID** (if you already have it from `docs/figma/design-context.md`):
```
Generate tickets from node 1:6
```

Copilot will:

1. **Analyze the frame** — calls the Figma MCP to read design data, identifies every component and container
2. **Propose a ticket list** — shows you a list of component names and asks scoping questions (e.g., "Should action buttons be a standalone ticket or a sub-component?")
3. **Wait for your confirmation** — you approve, adjust, or cut the proposed list before anything is drafted

---

## Part 11 — Review ticket drafts

After you confirm the scope, Copilot drafts all tickets in the chat. Each draft includes:

- **Overview** — user story (who/what/why, 1–2 sentences)
- **Image** — Figma deep link to the specific component node
- **Functional Requirements** — numbered, independently verifiable
- **Data Sources** — field table (Display Name / Machine Name / Field Type / Required / Default)
- **Authoring Considerations** — CMS gotchas, QA NOTEs in bold
- **Responsive Design** — Large / Medium / Small viewports
- **Accessibility Guidelines**

Read through the drafts. If something looks wrong or incomplete, tell Copilot what to fix (e.g., "The Filter Chip ticket is missing the empty-state behavior" or "Change the issue type in ticket 3 to Story").

> **Nothing is created in Jira at this point.** The drafts are for your review only.

---

## Part 12 — Approve and create in Jira

When the drafts look good, type:

```
approved
```

Copilot will create all tickets in Jira in sequence:
1. Epic first (name only, no description)
2. Each component ticket linked to the Epic as a child

Each ticket is created with the full markdown description. When done, Copilot will print a summary table with ticket keys and links, for example:

| Key | Summary | Type |
|---|---|---|
| PROJ-2 | [Epic name] | Epic |
| PROJ-3 | Restaurant Card | Feature |
| PROJ-4 | Ask Beacon Search Bar | Feature |

Click the links to verify the tickets in Jira. Done.

---

## Troubleshooting

**Skill doesn't trigger**
- Confirm you're in **Agent mode**, not Ask or Edit mode
- Try a different trigger phrase: "set up ticket generation" or "figma to jira setup"
- Confirm the skill is at `.github/skills/dsa-project-setup/SKILL.md` inside your open project folder
- Try reloading VS Code: open the Command Palette → **Developer: Reload Window**

**MCP server shows "Error" or "Stopped" in the panel**
- Click the refresh button on the MCP panel
- For Atlassian: re-authenticate at `velir.atlassian.net`
- For Figma: re-authorize OAuth at `https://www.figma.com/settings` → Developer → MCP

**Figma design context is empty or missing components**
- Make sure you have at least Viewer access to the Figma file
- Try using the top-level frame node ID (e.g., `0:1` or the root frame) rather than a deeply nested node
- The Figma MCP reads published/saved file state — if the file has unsaved changes, they won't be reflected

**Ticket creation fails with "invalid project key"**
- Double-check the project key with `getVisibleJiraProjects` — ask Copilot to "list my Jira projects" and find the correct key
- Confirm the issue type name exactly matches what the project supports (e.g., `Feature` vs `feature` — it's case-sensitive)

**Tickets are created but missing description content**
- This can happen if the `generate-tickets.instructions.md` wasn't loaded. Confirm the file exists at `.github/instructions/generate-tickets.instructions.md`
- In a new chat session, Copilot re-loads the instructions file automatically via the `applyTo: "**"` frontmatter

---

## Updating the skill

If `dsa-project-setup` has been updated in the GitHub repo:

1. Go to **https://github.com/Velir/AIResources**
2. Download the repo ZIP and extract it
3. Replace your project's `.github/skills/dsa-project-setup/` folder with the updated version from the ZIP
4. Reload the VS Code window: open the Command Palette → **Developer: Reload Window**

---

*This quickstart reflects the workflow as of March 26, 2026. For the authoritative skill definition and templates, see `https://github.com/Velir/AIResources`.*
