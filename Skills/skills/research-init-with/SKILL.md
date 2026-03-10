---
name: research-init-with
description: Research URL for init guidelines and offer to update or add guidelines
---

# Research Init From URL

Research URL for init guidelines.

## Instructions

Fetch a URL and determine which `/init-*` command it applies to, then offer to update or add guidelines based on the content.

**Usage**: `/research-init-with {url}`

**Argument**: `$ARGUMENTS` — the URL to fetch and analyze

---

## Phase 1: Fetch the URL

1. Parse the URL from `$ARGUMENTS`
   - If no URL provided, ask the user for one
   - Validate it looks like a URL (starts with http:// or https://)

2. Use `WebFetch` to retrieve the content
   - Prompt: "Extract the main content, focusing on best practices, guidelines, patterns, code examples, and recommendations. Summarize what this page is about and what technology/framework it covers."

3. If the fetch fails, report the error and ask for an alternative URL

---

## Phase 2: Identify the Init Command

Based on the fetched content, determine which init command this relates to.

**Detection strategy:**

1. **Check the domain** for framework hints:
   | Domain pattern | Likely init |
   |----------------|-------------|
   | react.dev, reactjs.org | init-react |
   | vuejs.org | init-vue |
   | laravel.com | init-laravel-app |
   | drupal.org | init-drupal |
   | livewire.laravel.com | init-livewire |
   | inertiajs.com | init-inertia |
   | tauri.app | init-tauri |
   | tailwindcss.com | init-tailwind |
   | charm.sh | init-charm |
   | filamentphp.com | init-filament |
   | doc.qt.io, pyside | init-pyside6 |
   | swift.org, developer.apple.com/swift | init-swift |
   | reactnative.dev | init-reactnative |
   | tanstack.com/query | init-tanstack-query |

2. **Analyze content keywords** if domain doesn't match:
   - Look for framework names, imports, package names
   - Match against existing init commands

3. **List available inits** for reference:
   ```
   ls ~/.copilot/skills/init-*.md
   ```
   Read the list and match content to the most appropriate one

4. **If no clear match**:
   - Ask user which init this should apply to
   - Or offer to create a new init command

---

## Phase 3: Compare with Existing Content

1. Read the matched init file: `~/.copilot/skills/init-{name}/SKILL.md`

2. Compare the fetched content against what we already have:
   - **Already covered**: Topics/rules we already address
   - **New content**: Guidelines, patterns, or examples not in our init
   - **Conflicts**: Anything that contradicts our current advice

3. **Extract actionable additions**:
   - Code examples (prioritize these!)
   - Rules or guidelines
   - Common mistakes/pitfalls
   - Performance tips
   - TypeScript patterns

---

## Phase 4: Present Findings

Show the user:

```
## URL Analysis: {url}

**Detected framework**: {Name}
**Matched init**: `/init-{name}`

### Already Covered
- [things we already have]

### New Content Found
1. **{Topic}**
   - Description of the guideline
   ```typescript
   // Code example if available
   ```

2. **{Topic}**
   ...

### Conflicts with Current Init
- [any contradictions, if present]
```

---

## Phase 5: Offer to Update

Ask the user:

```
Would you like me to:
1. Add all new content to `/init-{name}`
2. Add selected items only (I'll ask which ones)
3. Skip — just keep this as research
```

If user chooses to update:
1. Integrate the new content into the init file
2. Format according to init conventions (see `/add-init` for template)
3. Preserve existing content structure
4. Report what was added

---

## Content Integration Guidelines

When adding content from the URL:

1. **Prioritize code examples** — extract and format them properly
2. **Match the style** of existing init content
3. **Place appropriately**:
   - Rules go in "Rules" or relevant subsection
   - Code examples near related rules
   - Mistakes in "Common Mistakes" section
4. **Keep it concise** — don't copy entire articles, extract key points
5. **Cite the source** — add a comment: `
