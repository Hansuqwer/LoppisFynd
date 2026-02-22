---
phase: 01-dependency-modernization-baseline
verified: 2026-02-22T09:23:34Z
status: human_needed
score: 0/4 must-haves verified
human_verification:
  - test: "Run Phase 1 CI-parity gates locally"
    expected: "All succeed: flutter pub get; dart format --output=none --set-exit-if-changed lib test; flutter analyze --fatal-warnings --fatal-infos; flutter pub run custom_lint; flutter test"
    why_human: "Requires executing Flutter toolchain; static code inspection can't prove green gates"
  - test: "Build Android release appbundles (staging + prod)"
    expected: "Both succeed: flutter build appbundle --flavor staging --release --dart-define=APP_ENV=staging and flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod"
    why_human: "Build output depends on local/CI environment and Gradle toolchain"
  - test: "Android device smoke test: scanner + create/edit + persistence"
    expected: "Camera preview works; capture/scan works; create/edit item works; close+reopen retains data; no runtime exceptions"
    why_human: "Runtime device behavior (camera, permissions, lifecycle) can't be verified via static checks"
  - test: "iOS minimal build + launch smoke test (on macOS)"
    expected: "pod install succeeds; flutter build ios --no-codesign succeeds; app launches and key screens open"
    why_human: "iOS toolchain is not available in this environment"
  - test: "Golden review (only if goldens changed)"
    expected: "Diffs in test/goldens/*.png are visually acceptable and intended"
    why_human: "Visual correctness is subjective and requires human review"
---

# Phase 1: Dependency Modernization Baseline Verification Report

**Phase Goal:** The app runs on latest Flutter stable with updated Riverpod/Drift/camera/workmanager and no regressions.
**Verified:** 2026-02-22T09:23:34Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Roadmap Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | App builds, installs, and launches on iOS and Android using latest Flutter stable. | ? UNCERTAIN | `.metadata` pins stable channel revision; CI workflow installs Flutter from `.metadata`, but build/run not executed here. |
| 2 | Core capture + catalog flows work (camera scan, item create/edit, local persistence) without runtime errors. | ? UNCERTAIN | Camera + DB + Riverpod wiring exists in code, but runtime flows not exercised here. |
| 3 | Existing local database migrations/queries continue to work with real user data. | ? UNCERTAIN | Drift migrations are present and appear additive (`lib/core/database/app_database.dart`), but real-data upgrade not exercised here. |
| 4 | Full test suite passes (including CI) after dependency updates. | ? UNCERTAIN | CI definition exists in `.github/workflows/ci.yml` and includes format/analyze/custom_lint/test + AAB builds, but CI run not inspected/executed here. |

**Score:** 0/4 truths verified

## Must-Haves Check (From Phase Plans)

### Required Artifacts

| Artifact | Expected | Status | Details |
|---------|----------|--------|---------|
| `pubspec.yaml` | Pins Riverpod/Drift/camera/workmanager baseline versions | ✓ VERIFIED | Exact pins present: `flutter_riverpod: 3.2.1`, `drift: 2.31.0`, `drift_dev: 2.31.0`, `camera: 0.11.4`, `workmanager: 0.9.0+3`. |
| `pubspec.lock` | Resolved set matches pins | ✓ VERIFIED | `flutter_riverpod` resolves to `3.2.1` in `pubspec.lock`. |
| `lib/core/app/providers.dart` | Riverpod 3 legacy providers compile via legacy import | ✓ VERIFIED | Imports `package:flutter_riverpod/legacy.dart` and uses `legacy.StateNotifierProvider`/`legacy.StateProvider`. |
| `ios/Runner.xcodeproj/project.pbxproj` | iOS deployment target >= 14.0 | ✓ VERIFIED | Contains `IPHONEOS_DEPLOYMENT_TARGET = 14.0;` entries. |
| `ios/Podfile` | Flutter podhelper wiring + iOS platform set | ✓ VERIFIED | `platform :ios, '14.0'` and `require ... podhelper` present. |
| `.github/workflows/ci.yml` | CI steps defined, including AAB build steps | ✓ VERIFIED | Runs format/analyze/custom_lint/test and `flutter build appbundle` for staging/prod. |
| `test/goldens/login_screen.png` | Golden baseline exists and is referenced by tests | ✓ VERIFIED | Referenced by `test/features_auth/login_screen_golden_test.dart`. |
| `test/goldens/dashboard_screen.png` | Golden baseline exists and is referenced by tests | ✓ VERIFIED | Referenced by `test/features_dashboard/dashboard_screen_golden_test.dart`. |
| `test/goldens/history_empty.png` | Golden baseline exists and is referenced by tests | ✓ VERIFIED | Referenced by `test/features_history/history_empty_golden_test.dart`. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `lib/core/app/providers.dart` | `package:flutter_riverpod/legacy.dart` | import | ✓ WIRED | Present as `import 'package:flutter_riverpod/legacy.dart' as legacy;`. |
| `pubspec.yaml` | `flutter_riverpod: 3.2.1` | dependency pin | ✓ WIRED | Exact pin present. |
| `ios/Podfile` | Flutter podhelper | require | ✓ WIRED | Requires `.../bin/podhelper` (Ruby loads `podhelper.rb`). |
| `.github/workflows/ci.yml` | `flutter build appbundle` | CI build steps | ✓ WIRED | Both staging/prod appbundle builds defined. |
| `test/features_*_golden_test.dart` | `test/goldens/*.png` | golden assertions | ✓ WIRED | `matchesGoldenFile('../goldens/...')` present across golden tests. |

## Requirements Coverage (Plan Frontmatter -> REQUIREMENTS.md)

| Requirement | Source Plan(s) | Description | Status | Evidence |
|------------|----------------|-------------|--------|----------|
| DEP-01 | `01-01-PLAN.md` | Update Riverpod to the targeted current stable range and keep the app functional | ? NEEDS HUMAN | Static: `flutter_riverpod: 3.2.1` pinned in `pubspec.yaml` and legacy providers updated in `lib/core/app/providers.dart`; run-time functionality requires executing gates + smoke test. |
| DEP-02 | `01-01-PLAN.md` | Update Drift to the targeted current stable range and keep migrations/queries working | ? NEEDS HUMAN | Static: `drift: 2.31.0`/`drift_dev: 2.31.0` pinned in `pubspec.yaml`; migrations present in `lib/core/database/app_database.dart`; real-data upgrade requires human validation. |
| DEP-03 | `01-01-PLAN.md` | Update camera and workmanager packages without regressions | ? NEEDS HUMAN | Static: pins in `pubspec.yaml`; camera usage in `lib/features/scanner/scanner_screen.dart`; workmanager wiring in `lib/services/sync/background/background_sync.dart`; device/runtime behavior needs smoke test. |
| DEP-04 | `01-01-PLAN.md` | Build passes on latest Flutter stable; no deprecated APIs in use | ? NEEDS HUMAN | Static: `.metadata` uses `channel: stable` and CI installs Flutter by revision; passing build/analyze requires executing verification commands. |
| DEP-05 | `01-02-PLAN.md` | Full test suite passes after dependency updates | ? NEEDS HUMAN | Static: CI workflow defines `flutter test` and build steps in `.github/workflows/ci.yml`; must be confirmed by running CI or local gate. |

## Anti-Patterns Found

- None detected in inspected Phase 1 artifacts (no obvious placeholder/TODO-only implementations in the checked files).

## Human Verification Required

See `human_verification` in frontmatter.

---

_Verified: 2026-02-22T09:23:34Z_
_Verifier: Claude (gsd-verifier)_
