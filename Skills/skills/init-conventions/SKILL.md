# Standard Init Workflow

This document defines the standard workflow for all `/init-*` commands. Individual init commands should reference this instead of duplicating these instructions.

## Core Principle: Simple File Overwrite

All init commands write to `.github/instructions/{name}.instructions.md`:
- Each init owns its own file completely
- Running an init **overwrites** its rules file with the latest content
- Safe to run repeatedly — designed for updating guidelines
- Path-specific rules use YAML frontmatter with `applyTo:` field
- Non-path-specific rules use YAML frontmatter with `applyTo: "**"` field

## Target Directory

**Location**: `.github/instructions/` in the project root

Each init command writes to a single file:
- `/init-react` → `.github/instructions/react.instructions.md`
- `/init-tailwind` → `.github/instructions/tailwind.instructions.md`
- `/init-laravel` → `.github/instructions/laravel.instructions.md`
- etc.

## File Structure

Each rules file should have:

1. **YAML frontmatter** (optional) — for path-specific rules
2. **Content** — the actual guidelines

**Example with path pattern:**
```markdown
---
applyTo: "**/*.{tsx,jsx}"
---

# React 19 + TypeScript Rules

[guidelines content here]
```

**Example without path pattern** (unconditional):
```markdown
# Inertia.js Rules

[guidelines content here]
```

## Workflow Steps

1. **Create directory**: Ensure `.github/instructions/` exists
2. **Write file**: Create/overwrite `.github/instructions/{name}.instructions.md` with the init content
3. **Report**: "Created/updated `.github/instructions/{name}.instructions.md`"

**Note**: Init commands do NOT add links to `.github/copilot-instructions.md`. Rules in `.github/instructions/` auto-load:
- With `applyTo:` frontmatter and a path pattern → loads for matching files only
- With `applyTo: "**"` → loads for all files

Explicit links to `.github/instructions/*.instructions.md` imports are redundant and waste context. Remove any existing ones in `.github/copilot-instructions.md` to avoid confusion.

## Path Pattern Guidelines

Use `applyTo:` frontmatter when rules only apply to specific file types:

| Framework | Path Pattern |
|-----------|--------------|
| React | `**/*.{tsx,jsx}` |
| Vue | `**/*.vue` |
| Tailwind | `**/*.{css,scss,vue,tsx,jsx}` |
| Laravel | `**/*.php` |
| Drupal | `**/*.{php,twig}` |
| Swift | `**/*.swift` |
| Go/Charm | `**/*.go` |
| Python | `**/*.py` |
| TypeScript | `**/*.{ts,tsx}` |

Omit `applyTo:` for rules that apply broadly (e.g., Inertia affects both PHP and JS).

## Notes

- Ask before making changes (show what will be modified)
- Handle case where `.github/` directory doesn't exist (create it)
- Individual init commands are simple: just write/overwrite their rules file
