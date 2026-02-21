---
phase: 03-startup-auth-model-download
plan: 02
subsystem: auth
tags: [flutter, supabase, auth, email-password, otp]

# Dependency graph
requires:
  - phase: 02-capsule-navigation-shell
    provides: AppNavShell routing shell + startup entry
provides:
  - Signup-first (segmented) email+password auth screen with trouble-sign-in email OTP
affects: [03-03, 03-04, startup-flow]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Supabase email/password auth via signUp + signInWithPassword (no custom session persistence)
    - Trouble sign-in uses email OTP verify with shouldCreateUser=false
    - Auth UI strings sourced from AppLocalizations (no hardcoded user-facing strings)

key-files:
  created: []
  modified:
    - lib/features/auth/login_screen.dart
    - test/features_auth/login_screen_widget_test.dart
    - test/goldens/login_screen.png

key-decisions:
  - "Default auth mode to signup ('Skapa konto') to match Phase 3 contract"
  - "Surface Supabase AuthException messages in UI when available to avoid generic failures"

patterns-established:
  - "Auth UX: signup-first segmented control with trouble-sign-in OTP escape hatch"
  - "Auth errors: prefer user-visible AuthException.message over generic snackbars"

requirements-completed: [AUTH-01, AUTH-02]

# Metrics
duration: 2h 53m
completed: 2026-02-18
---

# Phase 03 Plan 02: Signup-First Auth Summary

**Signup-first segmented auth (email+password) with a complete trouble-sign-in email OTP flow, wired to Supabase and verified end-to-end (including session persistence).**

## Performance

- **Duration:** 2h 53m
- **Started:** 2026-02-18T19:36:09+01:00
- **Completed:** 2026-02-18T21:29:31Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Replaced OTP-only login with a segmented signup-first auth UI using Supabase email+password auth
- Added “Problem att logga in?” flow that sends + verifies email OTP without implicit user creation
- Updated widget test + golden snapshot to lock the Nature Distilled auth layout
- Human verification approved: OTP received via local Supabase Mailpit; login/signup and restart session persistence confirmed

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace OTP-only login with segmented signup-first email+password + trouble OTP flow** - `72e03b2` (feat)
2. **Task 2: Human verify signup-first auth flow + trouble OTP** - (checkpoint approved; no code commit)

Additional plan-related fix:
- `dd42fa1` (fix): surface Supabase auth errors in UI

Plan metadata: `docs(03-02)` commit (this plan's SUMMARY/STATE/ROADMAP update)

## Files Created/Modified

- `lib/features/auth/login_screen.dart` - Segmented signup/login + trouble-sign-in OTP flow wiring and UI
- `test/features_auth/login_screen_widget_test.dart` - Widget test coverage for auth screen behavior
- `test/goldens/login_screen.png` - Golden snapshot for auth screen visual regression safety

## Decisions Made

- Defaulted auth mode to “Skapa konto” to match the Phase 3 UX contract and reduce friction for new users.
- Surfaced Supabase `AuthException` messages in UI when available to keep failures actionable during onboarding.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Surface Supabase AuthException messages instead of generic errors**
- **Found during:** Task 1 (auth flow wiring)
- **Issue:** Generic snackbars hid actionable auth errors (e.g. invalid credentials / rate limits / OTP failures)
- **Fix:** Display `AuthException.message` for sign-in/sign-up and OTP send/verify paths when present
- **Files modified:** `lib/features/auth/login_screen.dart`
- **Verification:** `flutter analyze`, `flutter test`, human-verify checkpoint approved (Mailpit OTP receipt + end-to-end flow)
- **Committed in:** `dd42fa1`

---

**Total deviations:** 1 auto-fixed (Rule 1: 1)
**Impact on plan:** Fix was necessary for correctness of the user-facing auth experience; no scope creep.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required beyond existing Supabase project settings.

## Next Phase Readiness

- Auth entry is stable and verified; ready to proceed with Phase 03 Plan 03 (consent-gated model download/install controller).

---
*Phase: 03-startup-auth-model-download*
*Completed: 2026-02-18*

## Self-Check: PASSED

- FOUND: `.planning/phases/03-startup-auth-model-download/03-02-SUMMARY.md`
- FOUND: `72e03b2`
- FOUND: `dd42fa1`
- FOUND: `.planning/STATE.md`
- FOUND: `.planning/ROADMAP.md`
