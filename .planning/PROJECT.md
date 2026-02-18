# LoppisFynd — Nature Distilled UI/UX Overhaul

## What This Is

LoppisFynd is a Flutter app for scanning loppisfynd in-store, saving finds offline, and fetching market comps when online. This milestone implements the full “Nature Distilled” UI/UX overhaul (onboarding, auth, navigation shell, and the 5 core tabs) strictly according to the technical handoff and visual reference pack.

## Core Value

Users can reliably scan and manage finds offline, with on-device AI enabling fast identification without network.

## Requirements

### Validated

- ✓ Offline-first local persistence is the source of truth (Drift/SQLite) — existing
- ✓ Tabs and routes remain: Home, Scan, Haul, History, Profile — existing
- ✓ Optional cloud sync/auth (Supabase) and on-device AI (Gemma via `flutter_gemma`) are feature-flag gated — existing

### Active

- [ ] Implement the Nature Distilled design system and shared UI primitives exactly per handoff + Visual Reference Pack
- [ ] Rewrite startup flow (Onboarding screens 1–5) including Gemma model download prompt on onboarding screen #3 with clickable info link and background download
- [ ] Implement model download/install progress UI with real state (no fake progress) and a completion popup using the reference red color
- [ ] Replace login UX to be signup-first and match the glass/motif reference, including “Lost password / Trouble signing in”
- [ ] Ensure all UI strings are localized (no hardcoded strings) and all Swedish copy preserves diacritics (å, ä, ö)
- [ ] Add/refresh golden tests for the most important screens to prevent UI drift

### Out of Scope

- Changing information architecture, routes, or tab names — navigation must not regress
- Breaking offline flows or changing local DB as source of truth — core product promise
- Using the handwritten font for buttons/forms/long paragraphs — accent-only

## Context

- Codebase is feature-first Flutter with Riverpod + Drift. Navigation shell is `lib/core/navigation/app_nav_shell.dart`.
- Visual spec is contract-driven:
  - `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md`
  - `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md`
  - `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf`
  - Accent font: `Assets/fonts/HomemadeApple-Regular.ttf`
- Strictness: if anything conflicts, prefer the Visual Reference Pack.

## Constraints

- **UI spec**: Implement layouts/spacing/typography/copy/component shapes per handoff and Visual Reference Pack (no invention)
- **Localization**: All user-facing strings via `AppLocalizations`
- **Offline-first**: Do not introduce online-only blocking for core flows
- **Model download**: User-consented (onboarding #3); download continues in background; show real progress and real failure states
- **Performance**: Every blur is clipped; target smooth 60/120fps (Impeller)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Visual Reference Pack overrides the markdown handoff if they conflict | Prevent UI drift | — Pending |
| Canonical app name in strings is “LoppisFynd/Loppisfynd” (not “Löppisfynd” from the logo mock) | Correct Swedish spelling in UI copy | — Pending |
| Gate Gemma model download behind explicit onboarding consent (screen #3) | v2 requirement + user expectation | — Pending |
| Keep established architecture (Riverpod + Drift + feature-first) | Minimize churn and regressions | — Pending |

---
*Last updated: 2026-02-18 after initialization*
