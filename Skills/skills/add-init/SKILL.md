---
name: add-init
description: Create a new /init-* command
---

# Add New Init Command

Create a new /init-* command.

## Instructions

Create a new `/init-*` command following our established patterns. This command will guide you through the process interactively.

**Reference**: Follow the `/init-conventions` skill for the standard rules file workflow.

## Phase 1: Gather Information

**Ask the user these questions in order:**

1. **Name**: "What should the init command be called? (e.g., `nextjs`, `svelte`, `django`)"
   - This becomes `/init-{name}`
   - Use lowercase, no spaces

2. **Path pattern**: "What file types do these rules apply to? (e.g., `**/*.{tsx,jsx}` for React, or leave blank if rules apply broadly)"

3. **Content**: "Please provide the best practices content for {name}. Include:
   - Code examples (these are critical!)
   - Common mistakes
   - Performance tips
   - Any framework-specific patterns

   I'll format it according to our template."

## Phase 2: Create the Init Command

Create `~/.copilot/skills/init-{name}/SKILL.md`
 
Use this template:

```markdown
# Initialize {Name} Best Practices

Add {Name} best practices. **Follow `~/.copilot/skills/init-conventions.md` for standard file handling.**

## Target File

`.github/instructions/{name}.instructions.md`

## Path Pattern

`{PATH_PATTERN_OR_BLANK}`

## Content

<!-- RULES_START -->
---
applyTo: "{PATH_PATTERN}"
---

# {Name} Rules

{USER_PROVIDED_CONTENT}

### Common Mistakes

{EXTRACT_OR_ASK_FOR_COMMON_MISTAKES}
<!-- RULES_END -->
```

**Notes on the template:**
- `<!-- RULES_START -->` and `<!-- RULES_END -->` markers enable fast programmatic extraction
- Include YAML frontmatter with `applyTo:` if rules are file-type specific
- Omit the frontmatter section entirely if rules apply broadly
- Keep ALL code examples — these are the most valuable part

## Phase 3: Update /init-all

Add detection logic to `~/.copilot/skills/init-all/SKILL.md`

1. Find the "## Phase 1: Detect Stack" section
2. Add a new detection block for the framework:

```markdown
### {Name}
- {detection_indicators} (e.g., files, package.json entries, config files)
- **If found**: Queue `/init-{name}`
```

**Ask the user**: "How should I detect {name} in a project? What files or package.json entries indicate it's being used?"

## Phase 4: Summary

Report to the user:
```
Created:
  - /init-{name} command

Updated:
  - /init-all — added {Name} detection

You can now run `/init-{name}` in any project to add {Name} best practices.
The rules will be written to `.github/instructions/{name}.instructions.md`
```

## Guidelines for Content Formatting

When formatting the user's content:

1. **Keep ALL code examples** — these are the most valuable part
2. **Use tables** for quick reference where appropriate
3. **Structure with ### subheadings** for different topics
4. **Add "Common Mistakes" section** if not provided — ask user for common pitfalls
5. **Add "Quick Reference" table** if the content is substantial
6. Ensure code examples have proper syntax highlighting (```typescript, ```php, etc.)

## Notes

- Always ask for the name first, then path pattern, then content
- The user may provide raw notes — format them nicely
- If content seems incomplete, ask clarifying questions
- Test that the command name doesn't conflict with existing commands
- Rules files are idempotent — safe to run repeatedly to update
