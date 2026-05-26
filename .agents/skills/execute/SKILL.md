---
name: execute
description: Implement an approved task end to end. Use when the user says /execute, asks for fullAuto execution, or wants a planned phase implemented with minimal interruption.
---

This workflow may edit files only inside the current repository. Do not write outside the repo, including home directories, package caches, global config, temp directories, iOS/Android signing material, or secrets.

Workflow:

1. Confirm the implementation target from the latest plan or prompt.
2. Make focused repo-local edits.
3. Run the smallest relevant verification after each meaningful change.
4. Commits, PR creation, package installs, and dependency changes are allowed only when there is a clear revert path.
5. Stop and ask before touching secrets, native signing/app identity config, `.github/workflows/`, destructive commands, pushes to `main`, merges, or outside-repo source writes.
6. Finish with what changed, verification results, residual risks, and revert instructions for any commit, PR, install, or dependency change.

Do not run `flutter clean`, `pod deintegrate`, `rm -rf`, `git push`, or `git reset --hard`.
