# Standard Init Workflow

This document defines the standard workflow for all `/init-*` commands. Individual init commands should reference this instead of duplicating these instructions.

## Core Principle: Simple File Overwrite

All init commands write to `.claude/rules/{name}.md`:
- Each init owns its own file completely
- Running an init **overwrites** its rules file with the latest content
- Safe to run repeatedly — designed for updating guidelines
- Path-specific rules use YAML frontmatter with `paths:` field

## Target Directory

**Location**: `.claude/rules/` in the project root

Each init command writes to a single file:
- `/init-react` → `.claude/rules/react.md`
- `/init-tailwind` → `.claude/rules/tailwind.md`
- `/init-laravel` → `.claude/rules/laravel.md`
- etc.

## File Structure

Each rules file should have:

1. **YAML frontmatter** (optional) — for path-specific rules
2. **Content** — the actual guidelines

**Example with path pattern:**
```markdown
---
paths: "**/*.{tsx,jsx}"
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

1. **Create directory**: Ensure `.claude/rules/` exists
2. **Write file**: Create/overwrite `.claude/rules/{name}.md` with the init content
3. **Report**: "Created/updated `.claude/rules/{name}.md`"

**Note**: Init commands do NOT add `@` imports to `CLAUDE.md`. Rules in `.claude/rules/` auto-load:
- With `paths:` frontmatter → loads for matching files only
- Without `paths:` → loads for all files

Explicit `@.claude/rules/*` imports are redundant and waste context. Use `/deimport` to remove any existing ones.

## Path Pattern Guidelines

Use `paths:` frontmatter when rules only apply to specific file types:

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

Omit `paths:` for rules that apply broadly (e.g., Inertia affects both PHP and JS).

## Escaping `@` in Rule Content

The `@` symbol at the start of a line is interpreted as a file import. Escape with `\@` in prose/headings:

```markdown
# Wrong - interpreted as import
### @theme Directive

# Correct
### \@theme Directive

# Code blocks are safe - no escaping needed
```

## Notes

- Ask before making changes (show what will be modified)
- Handle case where `.claude/` directory doesn't exist (create it)
- Individual init commands are simple: just write/overwrite their rules file
