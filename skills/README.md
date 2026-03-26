
# Skills for AI Agents

## Introduction

This repository contains a collection of modular "skills" for AI agents, designed to enhance the capabilities of agentic systems such as Github CoPilot. Each skill is a focused, reusable prompt or workflow that can be invoked to perform a specific type of reasoning, research, or code manipulation task.

Skills with names starting in `cc-` are specific to Claude Code only.

## Installing Skills

Currently, we recommend installing skills using the `npx skills` command.  This installs skills in one central location, then creates symlinks in either project or global directories for your use.  Allows for searching and updating skills as well!

Please use the `DISABLE_TELEMETRY=1` environment variable when running these commands, so that Vercel does not list our skills on its website.

To see the list of available skills:
`DISABLE_TELEMETRY=1 npx skills add velir/AIResources --list`

To install a specific skill into your current project:
`DISABLE_TELEMETRY=1 npx skills add velir/AIResources --skill skill-name`

To install a specific skill globally:
`DISABLE_TELEMETRY=1 npx skills add velir/AIResources --skill skill-name -g`

[More information on `npx skills`](https://github.com/vercel-labs/skills/)

Once installed, skills can be used by running a "slash command" (like `/finalize`) in your CoPilot agent chat.

## Adding Skills

These skills are a starting point!  Ideally, we want to customize and update these skills to suit our needs, and create new ones to share here.

Have a new skill to share?  Make a pull request!

## Current List of Skills

- `/ascii`: Create ASCII diagrams for flows, architectures, and processes.
- `/audit-abstractions`: Detect premature, hollow, and over-engineered abstractions that add complexity without value.
- `/audit-best-practices`: Analyze a codebase and audit for best practice usage of detected languages and frameworks.
- `/audit-boundaries`: Detect architectural layer violations and improper dependencies between modules.
- `/audit-dead-code`: Detect and fix dead code, unused exports, unreachable code, orphaned files, and stale feature flags.
- `/audit-errors`: Detect error handling inconsistencies, anti-patterns, and silent failures.
- `/audit-naming`: Detect vague, inconsistent, and confusing identifier names that hurt code comprehension.
- `/audit-state-drift`: Detect and fix state synchronization issues, impossible states, and state management anti-patterns.
- `/audit-todos`: Detect and prioritize technical debt markers, stale TODOs, and forgotten FIXMEs.
- `/cc-always-allow`: Add a permission rule to global Claude settings so a tool or pattern is always allowed.
- `/counselors`: Fan out a prompt to multiple AI coding agents in parallel and synthesize their responses.
- `/dark-mode`: Design and implement comfortable dark mode interfaces.
- `/deepproduct`: Generate a comprehensive deep research prompt for a product question, tailored to the current project's product context — its users, UI/UX patterns, domain, and existing design decisions.
- `/deepstack`: Generate a comprehensive deep research prompt for a provided topic (like performance, testing, accessibility, security...) tailored to the current project's technology stack.
- `/finalize`: Clean up recent feature or refactor work by removing false starts, experimental remnants, and consolidating logic.
- `/fix-ghactions`: Check GitHub Actions and fix any failures.
- `/refine-idea`: A thinking partner, to help you refine an incomplete idea into a clear spec.
- `/test`: Detect the test framework, run the test suite, and fix any failures.
- `/tests-new`: Identify and add tests for recent code changes.
- `/update-changelog`: Update CHANGELOG.md with changes since the last release.

## Using Skills

Coming soon!
