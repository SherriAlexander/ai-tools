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
- The `--hook` flag should auto-select Quick depth without prompting
- Tests after the JIRA audit should run as parallel sub-agents/processes

### Quick (default)

Run: `/pre-pr PROJ-123` and select **Quick** (or press Enter for default)

- Should prompt for depth selection
- After JIRA audit, should only run:
  - `audit-best-practices`

### Medium

Run: `/pre-pr PROJ-123` and select **Medium**

- After JIRA audit, should run:
  - `audit-best-practices`
  - `audit-errors`
  - `audit-naming`
  - `audit-todos`

### In-depth

Run: `/pre-pr PROJ-123` and select **In-depth**

- After JIRA audit, should run all 8 skills in parallel:
  - `audit-best-practices`
  - `audit-errors`
  - `audit-naming`
  - `audit-todos`
  - `audit-boundaries`
  - `audit-abstractions`
  - `audit-dead-code`
  - `audit-state-drift`

### Custom

Run: `/pre-pr PROJ-123` and select **Custom**

- Should present a checklist of all 8 audits with `audit-best-practices` checked by default
- Should run only the audits the user selects
- Should not run any audit that was not selected

### Hook / automated caller

Run: `/pre-pr PROJ-123 --hook`

- Should **not** prompt for depth selection
- Should automatically use Quick depth
- After JIRA audit, should only run:
  - `audit-best-practices`

## We'd love to know...

- How long did it take the scripts to run?
- How many tokens did the scripts use?
- How accurate were the test results?
- How helpful were the test results?
- What worked well?
- What didn't work well?