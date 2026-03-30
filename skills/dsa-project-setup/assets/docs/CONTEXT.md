# Project Context — {{PROJECT_NAME}}

## Overview

{{PROJECT_DESCRIPTION}}

---

## Configuration

### Atlassian / Jira

| Setting | Value |
| --- | --- |
| Cloud ID | `{{CLOUD_ID}}` |
| Target Project | `{{JIRA_PROJECT_KEY}}` |
| Issue Type | `{{JIRA_ISSUE_TYPE}}` |
| Reference Project | `{{JIRA_REFERENCE_PROJECT}}` |

> **How to find your Cloud ID:** Navigate to `https://{your-org}.atlassian.net/_edge/tenant_info` and copy the `cloudId` field.

### Figma

| Setting | Value |
| --- | --- |
| File Key | `{{FIGMA_FILE_KEY}}` |
| File URL | [Open in Figma]({{FIGMA_FILE_URL}}) |
| Design Context | See `docs/figma/design-context.md` |

---

## MCP Dependencies

This workflow requires two MCP servers. Both must be active in the VS Code MCP panel.

| Server | ID | Auth |
| --- | --- | --- |
| Atlassian MCP | `com.atlassian/atlassian-mcp-server` | OAuth |
| Figma MCP | `figma` (HTTP: `https://mcp.figma.com/mcp`) | OAuth |

---

## Decisions

_Document key decisions here as they are made._

---

## Background & Notes

_Contextual information, research findings, constraints, and other notes go here._

---

## Conventions

- `README.md` — brief, high-level entry point
- `docs/CONTEXT.md` — living document for all project context (project-specific convention)
- `docs/figma/` — extracted Figma design context, tokens, and component reference files
- `.github/instructions/generate-tickets.instructions.md` — AI instructions governing ticket generation behavior (`applyTo: "**"`)
