# audit-jira

Verify that recent work satisfies all requirements, technical specs, and acceptance criteria defined in a Jira ticket.

Use this skill when wrapping up a feature, preparing a PR, or doing a pre-QA completeness check.

## Example usage

```
/audit-jira PROJ-123
/audit-jira https://your-org.atlassian.net/browse/PROJ-123
```

## Prerequisites

This skill works best with the [Atlassian MCP server](https://github.com/atlassian/mcp-atlassian) installed and running.

### Installing the Atlassian MCP server

Follow the directions for your coding IDE or AI platform:
- [VS Code](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server)

OR

Copy the relevant JSON from the `/.vscode/mcp.json` file into the corresponding file in your project's repository.

## Related Skills

After a clean audit, consider running other `audit-*` skills, like:

- `/audit-best-practices` — verify your code follows best practices
- `/audit-errors` — check for silent or inconsistent error handling
- `/audit-dead-code` — ensure no abandoned experiments were left behind
- `/audit-naming` — confirm variable names are clear and consistent
