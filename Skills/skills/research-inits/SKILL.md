# Research Init Commands for Updates

Research frameworks for best practices.

## Instructions

Research specified init commands to find updated best practices, new features, or guidelines we've missed. This command researches each framework's latest documentation and community guidelines.

**Usage**: `/research-inits tauri inertia react` — researches each specified init command

## Arguments

`$ARGUMENTS` — space-separated list of init command names (without the `init-` prefix)

## Workflow

### Phase 1: Parse Arguments

Extract the init names from `$ARGUMENTS`. For each name:
1. Verify that at least one of the following exists, depending on the agent's context:
   - `~/.claude/commands/init-{name}.md` for Claude Code
   - `~/.copilot/skills/init-{name}/SKILL.md` for GitHub Copilot
2. If not found, report which inits don't exist and skip them

### Phase 2: Research Each Init

For each valid init name, sequentially:

1. **Read the current init file** at `~/.claude/commands/init-{name}.md` or `~/.copilot/skills/init-{name}/SKILL.md`
2. **Research the web** using WebSearch for:
   - Official documentation updates (latest version features, breaking changes)
   - Best practices from official guides
   - Common patterns from community resources
   - Recent blog posts about gotchas or tips (2025-2026)
   - TypeScript integration improvements
   - Performance recommendations
   - Security considerations
3. **Compare findings** with current init content
4. **Document findings**:
   - What's already covered well
   - New features/APIs we're missing
   - Outdated advice that should be updated
   - Specific additions with code examples where possible

**Research approach for each init**:
```
Research updates for the `/init-{name}` command.

Current content is at: `~/.claude/commands/init-{name}.md` or `~/.copilot/skills/init-{name}/SKILL.md`

Read the current init file first, then search the web for:
1. Latest {Framework} documentation and release notes (v{X}.x if known)
2. Official best practices guides
3. Breaking changes from recent versions
4. Community-recommended patterns (2025-2026)
5. Performance tips and common mistakes
6. TypeScript/type safety improvements

Compare your findings to our current content and provide:
- **Already covered**: Brief summary of what we have
- **Missing content**: New APIs, patterns, or advice we should add (with code examples)
- **Outdated content**: Anything that needs updating
- **Priority items**: Most important updates to make

Be specific — include code snippets for any recommended additions.
```

### Phase 3: Present Findings

For each init researched, summarize:
```
## {Name} Research Results

### Already Covered
- [summary of good coverage]

### Recommended Additions
1. [specific addition with code example]
2. [another addition]

### Updates Needed
- [specific changes to existing content]

### Priority
- High/Medium/Low
```

### Phase 4: Offer Updates

Ask the user:
```
Would you like me to update any of these init commands with the findings?
- [ ] init-{name1} — {count} additions, {count} updates
- [ ] init-{name2} — {count} additions, {count} updates
...
```

If user confirms, apply the updates directly to the init files.

### Phase 5: Compress Updated Inits

After applying updates to init files, run `/compress-init {name}` for each init that was updated. This minimizes token usage while preserving all the new content.

Do this automatically after updates are applied — no need to ask the user.

## Example

```
User: /research-inits tauri inertia

Claude: Researching 2 init commands...

[Researches tauri, then inertia]

## Tauri Research Results

### Already Covered
- Window state persistence, vibrancy, context menus
- TanStack Query + Zustand state management pattern
- tauri-specta setup

### Recommended Additions
1. **Tauri 2.1 drag-and-drop API** (new in 2.1):
   ```rust
   use tauri::DragDropEvent;
   app.on_drag_drop_event(|event| { ... });
   ```
2. **Deep linking setup** for protocol handlers

### Updates Needed
- Update sentry crate version recommendation (0.34 → 0.35)

### Priority: Medium

---

## Inertia.js Research Results
...
```

## Framework-Specific Research Hints

To help agents find the right documentation:

| Init | Primary Sources |
|------|-----------------|
| tauri | v2.tauri.app, github.com/tauri-apps/tauri/releases |
| inertia | inertiajs.com, github.com/inertiajs releases |
| laravel | laravel.com/docs, Laravel News |
| drupal | https://www.drupal.org/documentation, Drupal News |
| react | react.dev, React blog |
| vue | vuejs.org, Vue blog |
| livewire | livewire.laravel.com, Livewire releases |
| tailwind | tailwindcss.com/docs |

## Notes

- Research is performed sequentially for each init command
- Uses WebSearch to find latest documentation and best practices
- Focus on actionable, specific improvements with code examples
- Don't just list features — compare to what we already have
