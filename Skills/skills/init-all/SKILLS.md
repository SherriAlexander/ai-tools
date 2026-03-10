# Initialize All Applicable Best Practices

Run all applicable /init-* commands.

## Instructions

Analyze the current repository to detect which frameworks and tools are in use, then run ALL applicable `/init-*` commands.

**This command uses parallel subagents for efficient detection.**

## How Init Commands Work

**All init commands write to `.github/instructions/{name}.instructions.md`:**

1. Each init command creates/overwrites a single file in `.github/instructions/`
2. Files use YAML frontmatter with `applyTo:` patterns for conditional loading
3. **ALWAYS run all applicable inits** — never skip because "file already exists"
4. Running an init command overwrites with the latest content
5. **This is safe to run repeatedly** — designed to be re-run to update guidelines

**Why this matters:**
- Guidelines evolve over time
- Running `/init-all` ensures all guidelines are current
- No need to check if content "matches" — just overwrite

## Phase 1: Detect Stack

Check for these indicators:

### Vue
- `package.json` with `vue` (v3+)
- `.vue` files in `src/` or `resources/js/`
- `vite.config.*` with Vue plugin
- **If found**: Queue `/init-vue`

### React
- `package.json` with `react` (v18+/v19+)
- `.tsx` or `.jsx` files in `src/`
- `vite.config.*` or `next.config.*` with React
- **If found**: Queue `/init-react`

### React Native
- `package.json` with `react-native`
- `metro.config.js` or `metro.config.ts`
- `android/` and `ios/` directories
- `app.json` with `expo` or React Native config
- **If found**: Queue `/init-reactnative`
- **Note**: Skip `/init-react` if React Native detected (different patterns)

### Tailwind CSS
- `package.json` with `tailwindcss` or `@tailwindcss/vite` or `@tailwindcss/postcss`
- `tailwind.config.js` or `tailwind.config.ts` (v3) or CSS file with `\@import "tailwindcss"` (v4)
- `postcss.config.*` with tailwindcss plugin
- **If found**: Queue `/init-tailwind`

### Dockerfile
- `Dockerfile` or `Dockerfile.*` in root or subdirectories
- `docker-compose.yml` or `docker-compose.yaml`
- `.dockerignore` file
- **If found**: Queue `/init-dockerfile`


### Parallel Detection Strategy

To speed up detection, launch **parallel subagents** using the Task tool with `subagent_type=Explore`:

**Subagent 1: Backend Detection**
```
Detect backend frameworks in this repository.

Check for:
- Docker: docker-compose.yml or docker-compose.yaml, .dockerignore, `Dockerfile` or `Dockerfile.*` in root or subdirectories

Return list of detected frameworks with evidence.
```

**Subagent 2: Frontend Detection**
```
Detect frontend frameworks in this repository.

Check for:
- Vue: package.json with vue (v3+), .vue files
- React: package.json with react (v18+/v19+), .tsx/.jsx files
- React Native: package.json with react-native, metro.config.*, android/ + ios/
- Tailwind: package.json with tailwindcss, tailwind.config.* or CSS with \@import "tailwindcss"

Return list of detected frameworks with evidence.
```

**Wait for all subagents to complete**, then merge results and proceed to Phase 3.

## Phase 2: Check Existing State

1. **Check for `.github/instructions/` directory**: Does it exist? What files are in it?
2. **Check for copilot-instructions.md, CLAUDE.md, AGENTS.md, GEMINI.md**: Do they exist?

**DO NOT check if files "already exist" or "match latest"** — just run all inits. They overwrite with current content.

### Check for Stale Rules

Look for `.github/instructions/{name}.instructions.md` files for tech that's NO LONGER in the project:

- `.github/instructions/dockerfile.instructions.md` but no `Dockerfile` in root or subdirectory
- `.github/instructions/react.instructions.md` but no React in package.json
- `.github/instructions/vue.instructions.md` but no Vue in package.json
- etc.

If stale rules found, ask the user:
```
Found rules for tech no longer in the project:
  - .github/instructions/dockerfile.instructions.md — no Dockerfile found
  - .github/instructions/vue.instructions.md — no Vue in package.json

Remove these stale files? [Y/n]
```

If confirmed, delete the stale `.github/instructions/*.instructions.md` files.

## Phase 3: Report Findings

Present to the user:

```
Detected stack:
  - React 19 (composer.json)
  - Tailwind v4 (composer.json)

Will create/update:
  - .github/instructions/react.instructions.md
  - .github/instructions/tailwind.instructions.md

Stale rules to remove:
  - .github/instructions/dockerfile.instructions.md (no longer in project)

Proceed? [Y/n]
```

## Phase 4: Execute

If user confirms:

1. **Create `.github/instructions/` directory** if it doesn't exist

2. **Remove stale rules first** (if any were identified)
   - Delete the stale `.github/instructions/*.instructions.md` files

3. **Run `/deboost`** (if Boost content detected in CLAUDE.md)

4. **Run EVERY SINGLE detected `/init-*` slash command in sequence**:

   "Run" means: execute the skill slash command (e.g., type `/init-react` and follow its instructions).

   **⚠️ CRITICAL: DO NOT STOP AFTER ONE COMMAND ⚠️**

   - Run init #1, wait for completion
   - Run init #2, wait for completion
   - Run init #3, wait for completion
   - ... continue until ALL inits are done

   **Order**: backend → backend extensions → frontend → utilities

   Example if Docker + React + Tailwind detected:
   ```
   Running /init-dockerfile... ✓ (.github/instructions/dockerfile.instructions.md)
   Running /init-react... ✓ (.github/instructions/react.instructions.md)
   Running /init-tailwind... ✓ (.github/instructions/tailwind.instructions.md)
   All 3 init commands completed.
   ```

5. **Run the built-in `/init` command**
   - This sets up the foundational copilot-instructions.md file
   - Running after framework inits means `/init` can be aware of what's in `.github/instructions/`
   - Avoids duplicate content between copilot-instructions.md and framework-specific rules

6. **Run `/agents`** to sync copilot-instructions.md to CLAUDE.md and AGENTS.md and GEMINI.md
   - This ensures other AI assistants have the same guidelines

7. **Report completion with count**: "Ran X init commands, created X rule files, removed Y stale files, synced to CLAUDE.md and AGENTS.md and GEMINI.md"

**Note on auto-loading:** Instructions in `.github/instructions/` with `applyTo:` frontmatter automatically load when you work on matching files.

## Phase 5: Suggest Next Steps

After initialization:

- Remind user to review the added content
- Suggest customizing project-specific sections in copilot-instructions.md
- Note any frameworks detected but not having an init command

## Notes

- Always ask before running commands (don't auto-execute)
- If no frameworks detected, inform user and suggest manual setup
- Order matters: deboost first, then inits, backend before frontend
- If a framework is detected but uncertain, ask the user to confirm
- If a framework is detected but no `/init-*` command exists for it, note this in the report (e.g., "Detected Next.js but no /init-nextjs available")
- **Boost content**: Look for verbose, auto-generated sections without init markers. These are from Laravel Boost and should be replaced with our cleaner init content.

## Common Mistakes to Avoid

❌ **DON'T**: Skip an init because "the file already exists"
✅ **DO**: Run it anyway — it will overwrite with latest content

❌ **DON'T**: Stop after running one init command
✅ **DO**: Run ALL detected inits in sequence until done

❌ **DON'T**: Check if content "matches" before running
✅ **DO**: Just run the init — overwriting is the point

❌ **DON'T**: Ask "should I run init-X?" for each one
✅ **DO**: Show the full list upfront, get one confirmation, run all
