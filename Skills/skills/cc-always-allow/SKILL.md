---
name: cc-always-allow
description: Add a permission rule to global Claude settings so it's always allowed.
disable-model-invocation: true
---

# Always Allow Permission

Add a permission rule to global Claude settings so it's always allowed.

## Arguments
- $ARGUMENTS: The permission pattern to allow (e.g., "Bash(docker:*)", "mcp__server__tool", "WebFetch(domain:example.com)")

## Instructions

1. Read the current settings from `~/.claude/settings.json`
2. Parse the permission pattern from the arguments: `$ARGUMENTS`
3. Add the pattern to the `permissions.allow` array if it doesn't already exist
4. Write the updated settings back to the file
5. Confirm what was added

## Permission Pattern Examples

Common patterns the user might want to allow:
- `Bash(command:*)` - Allow a bash command with any arguments
- `Bash(command)` - Allow exact bash command
- `mcp__servername__*` - Allow all tools from an MCP server
- `mcp__servername__toolname` - Allow specific MCP tool
- `WebFetch(domain:example.com)` - Allow fetching from a domain
- `Task` - Allow the Task tool

## Important

- Preserve all existing settings (hooks, statusLine, etc.)
- Keep the JSON properly formatted
- Don't add duplicates
- Report success with the exact pattern added
