# Copilot Instructions — {{PROJECT_NAME}}

## Project Overview

{{PROJECT_DESCRIPTION}}

## Behavior Rules

### 1. Proactive Documentation

After every meaningful operation — making a decision, completing a step, running an analysis, or surfacing important context — update `README.md` and/or `docs/CONTEXT.md` with all relevant information. Do this proactively, without asking the user.

Use the following guidelines:
- `README.md` — update only if high-level purpose, status, or getting-started info changes
- `docs/CONTEXT.md` — update for decisions, rationale, background, findings, and evolving context

### 2. Ticket Generation Workflow

When generating Jira tickets from Figma designs, always follow the workflow defined in `.github/instructions/generate-tickets.instructions.md`. Key rules:

- **Never create tickets in Jira without first presenting drafts for review.**
- All ticket content goes in the `description` field as markdown — there are no custom Jira fields.
- Functional Requirements must be ordered numbered lists, not prose or bullets.
- Responsive design sections must use Large / Medium / Small viewport labels — never phone/tablet/desktop.

### 3. Model Recommendations

Match model capability to task complexity:
- If a task would clearly benefit from deeper reasoning (architecture decisions, complex debugging, evaluating tradeoffs), recommend switching to a more powerful model within the current AI brand (e.g., Claude Sonnet → Claude Opus).
- If a task is straightforward and a lighter model would suffice, recommend switching down to conserve tokens.
- Always recommend within the same model brand first.

### 4. Standards and Conventions

Follow established conventions for naming, organizing, and structuring files:
- `README.md` — root level, brief and high-level
- `CHANGELOG.md` — standard for tracking changes over time
- `docs/CONTEXT.md` — living context document (project-specific convention, not a universal standard)
- `docs/figma/` — Figma design context and reference files
- `.github/instructions/generate-tickets.instructions.md` — ticket generation workflow and templates
