# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Prerequisites

This project uses two MCP servers. Both must be active in your VS Code MCP panel before generating tickets.

| MCP Server | Purpose | Config |
| --- | --- | --- |
| **Atlassian MCP** (`com.atlassian/atlassian-mcp-server`) | Create and read Jira issues | OAuth — authenticate at velir.atlassian.net |
| **Figma MCP** (`figma`) | Read Figma design context | Add to `mcp.json`, authenticate via Figma OAuth |

### Figma MCP Setup (if not already configured)

Add the following to your global VS Code `mcp.json` (`%APPDATA%\Code\User\mcp.json` on Windows):

```json
"figma": {
  "type": "http",
  "url": "https://mcp.figma.com/mcp"
}
```

Then authenticate: `https://www.figma.com/settings` → Developer → MCP.

Full setup reference: [Figma MCP documentation](https://help.figma.com/hc/en-us/articles/32132100875159-Guide-to-the-Figma-MCP-Server)

## Project Configuration

| Setting | Value |
| --- | --- |
| Atlassian Cloud ID | `{{CLOUD_ID}}` |
| Jira Project | `{{JIRA_PROJECT_KEY}}` |
| Figma File | [Open in Figma]({{FIGMA_FILE_URL}}) |

## How to Generate Tickets

1. Share a Figma frame URL (e.g., `https://www.figma.com/design/{fileKey}/...?node-id=1-6`)
2. Say: **"Generate tickets from this frame"**
3. The agent will identify components, propose a ticket list for your approval, draft all tickets, then create them in Jira after you confirm

Ticket generation behavior is governed by `.github/instructions/generate-tickets.instructions.md`.

## Documentation

- [Project Context](docs/CONTEXT.md) — decisions, configuration, and evolving context
- [Figma Design Context](docs/figma/) — extracted tokens, components, and node IDs
- [Ticket Generation Instructions](.github/instructions/generate-tickets.instructions.md) — workflow, templates, and quality rules
