# OpenCode Rules for this repo (Loppisfynd)

You are an AI coding agent working inside this repository.

## North Star
Implement the Loppisfynd app exactly as described in `docs/roadmap_refactored(1).md`.

## Hard constraints
- Do NOT add features that are not in the roadmap.
- Keep changes small: one ticket (FL-xxx) per PR/commit series.
- Prefer feature-first architecture: do not create “mega” folders.
- Never commit secrets. Supabase/Tradera keys must be read from env or Supabase Vault.
- Keep the app offline-first: everything must function without internet except price fetch.

## Output rules
For each ticket:
1) Propose a file plan (what files change/create).
2) Implement.
3) Add/adjust tests where relevant.
4) Ensure `flutter test` passes.
5) Update docs if you changed architecture.

## UX rules (Nature Distilled)
- Use AppTokens for all colors/radius/spacing.
- Prefer Bento cards, soft shadows, 24px radii.
- Keep motion springy and tactile; avoid harsh/linear transitions.

## AI rules
- LLM output must be structured JSON (strict parsing).
- Never trust LLM price output; prices come only from Tradera via the proxy.
- Run inference off the UI thread (isolate) to avoid jank.

## Done criteria
A ticket is done only when acceptance criteria are met and the feature is demonstrable in-app.
