# LoppisFynd — Nature Distilled UI/UX Overhaul

## What This Is

LoppisFynd is a Flutter app for scanning loppisfynd in-store, saving finds offline, and fetching market comps when online. This project scopes and executes the "Nature Distilled" UI/UX overhaul across onboarding, auth, navigation shell, and the primary tabs without breaking offline-first behavior.

## Core Value

Users can reliably scan and manage finds offline, then get better identification and market insights when connectivity is available.

## Requirements

### Validated

- ✓ Offline-first local persistence is the source of truth (Drift/SQLite) — existing
- ✓ Canonical bottom tabs remain: Home, Scan, Haul, History, Profile — existing
- ✓ On-device AI inference via Gemma + optional cloud sync/auth via Supabase flags — existing

### Active

- [ ] Implement "Nature Distilled" design system + shared UI primitives exactly per the technical handoff + visual reference pack
- [ ] Rewrite startup flow (Onboarding screens 1-5) including Gemma model download prompt on onboarding #3 with a clickable info link and background download
- [ ] Replace login UX to be signup-first and match the glass/motif reference (with "Lost password / Trouble signing in"), with all UI strings localized

### Out of Scope

- Changing the app's information architecture (tabs/routes) — must not regress navigation
- Breaking offline flows or changing local DB as source of truth — core product promise
- Hardcoding user-facing strings in widgets — all copy must remain localized

## Context

- Architecture is feature-first with Riverpod (DI/state) and Drift (local DB). Core composition root is `lib/main.dart`; navigation shell is `lib/core/navigation/app_nav_shell.dart`.
- On-device model download currently exists via `ModelManager`; v2 handoff requires gating download behind onboarding consent (no silent auto-download at startup).
- Visual spec is contract-driven:
  - `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md`
  - `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf`
  - Font asset: `HomemadeApple-Regular.ttf` (accent-only)

## Constraints

- **UI Spec**: Visual Reference Pack overrides the markdown handoff if they conflict
- **Localization**: All UI strings must be `AppLocalizations` (no hardcoded strings)
- **Swedish Copy**: Preserve diacritics (å, ä, ö); no spelling mistakes
- **Offline-first**: Do not introduce online-only blocking for scanning/haul/history
- **Model Download UX**: No fake progress; reflect real download/install state and show a completion popup in the reference red color
- **Performance**: Every blur must be clipped; target smooth 60/120fps (Impeller)
- **Navigation**: Tabs must remain: Home, Scan, Haul, History, Profile

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Treat `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf` as the primary UI source of truth | Prevent UI drift | -- Pending |
| Gate Gemma model download behind explicit onboarding consent (screen #3) | Privacy expectation + v2 requirement | -- Pending |
| Keep existing architecture (Riverpod + Drift + feature-first) | Minimize churn and avoid regressions | -- Pending |

---
*Last updated: 2026-02-18 after initialization*
