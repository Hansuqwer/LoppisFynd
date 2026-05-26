---
name: full-auto-approval
description: Run one approved task or phase hands-off. Use when the user says /FullAutoApproval, "full auto during this task", or asks Codex to continue without confirmation for a bounded phase.
---

This is a bounded phase mode, not a permanent permission change.

Rules:

1. Operate only inside the current repository.
2. Continue without confirmation for normal repo-local edits, formatting, analysis, and tests.
3. Commits, PR creation, package installs, and dependency changes are allowed when they are captured in a revertible state.
4. Before those operations, capture `git status`, the current branch, and relevant diffs.
5. Stop and ask before secrets, native signing/app identity config, `.github/workflows/`, destructive commands, pushes to `main`, merges, or outside-repo source writes.
6. Keep verification proportional and report any skipped checks.
7. Finish with revert instructions for every commit, PR, install, or dependency change.

Use the `FullAutoApproval` or `fullAuto` Codex profile when launching this workflow non-interactively.
