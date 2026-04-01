---
name: audit-best-practices
description: Run parallel tasks to analyze a codebase and audit for best practice usage of detected languages and frameworks.
context: fork
---

# Audit Best Practices

## File Scope

If a list of changed files has been provided in the conversation context (from a `/pre-pr` invocation), **restrict all analysis to those files only**. Do not read or analyze files outside this list. When running standalone, analyze the full codebase.

## Workflow

### Phase 1: Stack Detection

Examine project root to identify the technology stack:

1. **Check manifest files** (in priority order):
   - `package.json` → Node.js ecosystem (check for React, Vue, Next.js, etc.)
   - `composer.json` → PHP (check for Laravel, Symfony, etc.)
   - `Cargo.toml` → Rust
   - `go.mod` → Go
   - `pyproject.toml`, `setup.py`, `requirements.txt` → Python (check for Django, FastAPI, Flask, etc.)
   - `Gemfile` → Ruby (check for Rails, Sinatra, etc.)
   - `*.csproj`, `*.sln` → .NET/C#
   - `build.gradle`, `pom.xml` → Java/Kotlin (check for Spring, etc.)
   - `pubspec.yaml` → Dart/Flutter
   - `mix.exs` → Elixir/Phoenix
   - `Package.swift` → Swift

2. **Check config files** for framework signals:
   - `artisan`, `config/app.php` → Laravel
   - `next.config.*` → Next.js
   - `nuxt.config.*` → Nuxt
   - `vite.config.*`, `vue.config.*` → Vue
   - `tailwind.config.*` → Tailwind CSS
   - `tsconfig.json` → TypeScript

3. **Sample source files** to confirm language usage and detect patterns.

4. **Check for existing guidelines** in `*.instruction.md` files — note any that may conflict with or supplement community best practices.

**Output**: Create a stack summary listing primary language, framework(s), and notable tools.

### Phase 2: Codebase Scan

Systematically review source files. For large codebases:
- Prioritize core application code over tests/configs
- Sample representative files from each major directory
- Focus on recent/active files when git history available

### Phase 3: Best Practices Audit

Check code against best practices for the detected stack. Categories to evaluate:

**Language Idioms**
- Preferred constructs (e.g., list comprehensions in Python, pattern matching in Rust)
- Error handling patterns (e.g., Go's explicit errors, Rust's Result type)
- Naming conventions (snake_case, camelCase, etc.)
- Type usage and annotations
- Memory/resource management patterns

**Framework Conventions**
- Directory structure and file organization
- Component/class patterns (e.g., Laravel service providers, React hooks)
- Configuration approaches
- Routing conventions
- Database/ORM patterns
- Testing patterns

**Common Anti-Patterns to Flag**
- Reinventing framework functionality
- Ignoring framework conventions without reason
- Legacy patterns when modern alternatives exist
- Inconsistent style within the codebase
- Missing framework-specific optimizations

### Phase 4: Report

Use the **compact grouped output format**:

```markdown
## Best Practices Audit — N findings

### [Violation pattern] [SEVERITY]
[One sentence: what the violation is and the best practice to apply.]

- `path/to/file.ts:42` — [what's affected, ~5–10 words]
- `path/to/file.ts:88` — [what's affected]

---
N findings — X critical, Y high, Z medium, W low
```

**Output rules:**
- Omit groups with zero findings entirely
- No stack detection summary in output
- No "Positive Patterns Observed" section
- No prose summaries; surface intentional guideline deviations as LOW findings if relevant
- Fix hint per instance: ≤10 words
- Zero total findings: output `✓ 0 findings`

## Guidelines

- Be specific: cite file paths and line numbers
- Explain why: describe the best practice alternative and its benefits
- Prioritize: focus on impactful improvements over nitpicks
- Respect context: some "non-best practice" choices may be intentional
- Consider consistency: existing patterns in the codebase may take precedence over general best practices
- Defer to project rules: if instruction files contradict a best practice, note it but don't flag as a violation