# Codex Workflows

Use these names as interactive slash workflows or as the matching script when running non-interactively.

## `/plan`

Built into Codex CLI. Use it for read-only planning before multi-file or architectural work.

Script equivalent:

```sh
scripts/codex-plan.sh "Plan Phase 1 of <feature>"
```

## `/brainstorm`

Repo skill: `.agents/skills/brainstorm`. Use it for options and tradeoffs only. It is read-only by default.

Script equivalent:

```sh
scripts/codex-brainstorm.sh "Brainstorm approaches for <problem>"
```

## `/review`

Built into Codex CLI. Use it for review of local changes. The project script keeps the review read-only:

```sh
scripts/codex-review.sh
```

## `/execute fullAuto`

Use for hands-off implementation inside the repo only. It runs the `fullAuto` profile, which is workspace-write with no extra writable roots.

```sh
scripts/codex-execute.sh "Implement Phase 1 of <feature>. Continue without asking unless a secret, protected native config, workflow, destructive command, main push, merge, or outside-repo source write is required. Commits, PR creation, installs, and dependency changes are allowed if revertible."
```

## `/FullAutoApproval`

Use for a single approved task or phase. It runs the `FullAutoApproval` profile, which is also repo-write-only.

```sh
scripts/codex-full-auto-approval.sh "Implement the approved phase. Do not stop unless a protected boundary is reached."
```

## `/refactor`

Repo skill: `.agents/skills/refactor`. Use it for behavior-preserving structure changes.

```sh
scripts/codex-refactor.sh "Refactor <area> without behavior changes."
```

Full-auto boundaries:

- No writes outside the current repository.
- Commits, PR creation, package installs, and dependency changes are allowed when Codex preserves a clear revert path.
- No secrets, native signing/app identity config, `.github/workflows/`, destructive commands, pushes to `main`, merges, or outside-repo source writes without asking.
- Hooks still block `flutter clean`, `pod deintegrate`, `rm -rf`, `git push`, and `git reset --hard`.
