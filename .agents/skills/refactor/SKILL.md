---
name: refactor
description: Improve internal structure without changing behavior. Use when the user says /refactor or asks to clean up architecture, split files, simplify code, or remove duplication.
---

Refactor under behavior preservation.

Workflow:

1. Identify the smallest coherent refactor boundary.
2. Preserve public behavior, routes, localization keys, provider contracts, and repository interfaces unless explicitly approved.
3. Prefer moving code over rewriting it.
4. Run focused tests or analysis for the touched area.
5. Report behavior-preservation assumptions and any test gaps.

Dependency changes are allowed only when needed for the refactor and when a clear revert path is preserved. Do not change native signing/app identity config or broaden scope without asking.
