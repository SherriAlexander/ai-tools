---
name: audit-best-practices
description: Run parallel tasks to analyze a codebase and audit for best practice usage of detected languages and frameworks.
context: fork
---

# Audit Best Practices

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

Structure findings as:

```markdown
# Best Practices Audit Report

## Stack Detected
- **Language**: [language + version if detectable]
- **Framework**: [framework(s)]
- **Notable Tools**: [build tools, linters, etc.]

## Summary
[2-3 sentence overview of findings]

## Guideline Conflicts
[If instruction files exist, note any intentional deviations from community best practices]
[e.g., "Your guidelines specify X, but best practice for TypeScript would be Y — this appears intentional"]

## Findings

### Critical (should fix)
[Issues that violate core best practices or cause problems]

### Recommended (improve quality)
[Patterns that could be more aligned with best practices]

### Minor (style preferences)
[Small improvements, optional]

## Positive Patterns Observed
[What the codebase does well in terms of best practices]
```

## Guidelines

- Be specific: cite file paths and line numbers
- Explain why: describe the best practice alternative and its benefits
- Prioritize: focus on impactful improvements over nitpicks
- Respect context: some "non-best practice" choices may be intentional
- Consider consistency: existing patterns in the codebase may take precedence over general best practices
- Defer to project rules: if instruction files contradict a best practice, note it but don't flag as a violation