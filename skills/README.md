
# Skills for AI Agents

## Introduction

This repository contains a collection of modular "skills" for AI agents, designed to enhance the capabilities of agentic systems such as Github CoPilot. Each skill is a focused, reusable prompt or workflow that can be invoked to perform a specific type of reasoning, research, or code manipulation task.

Once installed, skills can be used by running a "slash command" (like `/finalize`) in your CoPilot agent chat.

Skills with names starting in `cc-` are specific to Claude Code only.

These skills are a starting point!  Ideally, we want to customize and update these skills to suit our needs, and create new ones to share here.

Have a new skill to share?  Make a pull request!

## Current List of Skills

- `/ascii`: Create ASCII diagrams for flows, architectures, and processes.
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


# Installing Skills

For instructions on how to install skills for CoPilot in VSCode, visit this [Agent Skills page](https://code.visualstudio.com/docs/copilot/customization/agent-skills).


# Using Skills

Coming soon!
