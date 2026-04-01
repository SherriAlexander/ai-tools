# Testing the "Pre-PR testing"

## Pre-requisites

VSCode + CoPilot
VSCode updated to the latest version

## Set-up

AIResources repo, branch `feature/pre-qa-testing`

In your project, look for a `/.github/copilot-instructions.md` file.  If it doesn't exist, run the `/init` command in your Copilot chat before proceeding.

Copy these skills (temporarily) into your project at /.github/skills/
  - All skills starting with `audit-*`
  - `pre-pr`

Install and start the Atlassian MCP server at /.vscode/mcp.json

Read through the README file in the `skills/pre-pr` directory

## Testing

Try running this command in Copilot chat, where PROJ-123 is your JIRA ticket:  
`/pre-pr PROJ-123` 

## Validation

You can run `/troubleshoot [describe the issue] #session` and then pick which session caused you problems.

Example: `/troubleshoot why the pre-pr skill didn't run in #session`

### For all scenarios
- Skill should stay limited to recently changed files.
- The JIRA audit should act as a gate, and other tests should not run if it fails
- The `--skip-jira` flag should skip the JIRA audit, and the rest of the tests should then run
- Tests after the JIRA audit should run as parallel sub-agents/processes

### On a bug branch

- After JIRA audit, should only run these skills:
  - `audit-errors`
  - `audit-state-drift`
  - `audit-dead-code`

### On a feature branch

- For a smaller feature, these skills should run after the JIRA audit:
  - `audit-errors`
  - `audit-naming`
  - `audit-best-practices`

- For a larger feature, these skills should run after the JIRA audit:
  - `audit-errors`
  - `audit-naming`
  - `audit-best-practices`
  - `audit-boundaries`
  - `audit-abstractions`
  - `audit-dead-code`
  - `audit-state-drift`
  - `audit-todos`

## We'd love to know...

- How long did it take the scripts to run?
- How many tokens did the scripts use?
- How accurate were the test results?
- How helpful were the test results?
- What worked well?
- What didn't work well?