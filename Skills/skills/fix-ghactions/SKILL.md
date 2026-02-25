---
name: fix-ghactions
description: Check GitHub Actions and fix any failures.
disable-model-invocation: true
---

<!-- Move the next line into the meta block if using Claude Code:
context: fork 
-->

# GitHub Actions Diagnosis and Fix

Check GitHub Actions and fix any failures.

## Instructions

Check GitHub Actions for the current branch, diagnose any failures, and fix them.

## Phase 1: Identify Failures

1. **Get the current branch**:
   ```
   git branch --show-current
   ```

2. **If on main/master, create a fix branch**:
   - Check if the current branch is `main` or `master`
   - If so, create and switch to a new branch for the fix:
     ```
     git checkout -b fix/gha-<short-description-or-timestamp>
     ```
   - You'll push this branch and create a PR later instead of pushing directly to main/master

3. **Find the latest workflow run(s) for the original branch** (use main/master if you just branched off):
   ```
   gh run list --branch <branch> --limit 5
   ```

4. **If no runs exist**, inform the user and stop.

5. **If all runs are passing**, inform the user that everything is green and stop.

6. **If there are failed runs**, identify the most recent failed run and proceed.

## Phase 2: Diagnose Failures

7. **Get details of the failed run**:
   ```
   gh run view <run_id>
   ```

8. **Fetch the failed job logs**:
   ```
   gh run view <run_id> --log-failed
   ```

9. **Analyze the failure**:
   - Identify which job(s) and step(s) failed
   - Look for error messages, stack traces, and exit codes
   - Categorize the failure type:
     - Test failure (which test, what assertion)
     - Build/compile error (syntax, type errors, missing dependencies)
     - Lint/format error (which rule, which file)
     - Timeout or resource issue
     - Flaky test (check if same test passes in other runs)
     - Infrastructure/CI configuration issue

10. **Summarize the diagnosis to the user**:
    - What failed and why
    - Which files are likely involved
    - Your proposed fix approach

## Phase 3: Fix the Issue

11. **Locate the relevant code** based on the failure:
    - For test failures: find the failing test and the code it tests
    - For build errors: find the file and line mentioned in the error
    - For lint errors: find the flagged files

12. **Implement the fix**:
    - Make the minimum changes necessary
    - Follow existing code patterns and conventions

13. **Verify locally if possible**:
    - Run the same command that failed (test, build, lint)
    - Ensure the fix works before pushing

14. **Commit and push the fix**:
    ```
    git add -A
    git commit -m "fix: <description of what was fixed>"
    git push -u origin HEAD
    ```

## Phase 4: Monitor

15. **Watch for the new run to complete**:
    ```
    gh run watch
    ```
    Or poll with:
    ```
    gh run list --branch <branch> --limit 1
    ```

16. **If the fix didn't work** (new run also fails):
    - Fetch the new failure logs
    - Diagnose again — it may be a different issue or the fix was incomplete
    - Return to Phase 3

17. **Once all checks pass**:
    - If you created a fix branch from main/master, create a PR using `gh pr create` and return the PR URL
    - Otherwise, inform the user that the issue is resolved

## Notes

- If the failure appears to be a flaky test or infrastructure issue (not caused by code in this branch), inform the user and ask how they want to proceed (retry, skip, investigate further).
- If multiple different jobs failed, address them one at a time, starting with the most fundamental (e.g., build before test, lint before build).
- If you cannot determine the cause of a failure, present what you found and ask the user for guidance.
