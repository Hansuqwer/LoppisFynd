# Phase 01: Dependency Modernization Baseline - Research

**Researched:** 2026-02-21
**Domain:** Flutter toolchain + dependency upgrade baseline (Riverpod/Drift/camera/workmanager) with CI + iOS/Android smoke tests
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
## Implementation Decisions

### Target support policy
- Android minSdk may be raised up to 29 for this phase.
- Primary manual smoke-test target is a modern Android 14/15 flagship.
- iOS must be smoke-tested (minimal) in Phase 1 even if day-to-day testing focus is Android.
- If dependency upgrades force an iOS deployment target bump, it is allowed up to iOS 15.

### Upgrade aggressiveness
- Upgrade style is hybrid: modernize core dependencies first, then update other packages where reasonable as long as tests remain green.
- Default when upgrades break APIs: fix forward (adapt code to new APIs), avoid pinning old behavior unless necessary.
- Package replacements are allowed only if unavoidable (unmaintained/incompatible blocker), and must preserve the same capability.
- New warnings/deprecations introduced by upgrades are zero-tolerance (must be fixed in this phase).
- Dependency constraints should prefer tight pins (exact versions) to stabilize the post-upgrade baseline.
- Android build tooling (Gradle/AGP/Kotlin) should be kept current to stable as part of Phase 1.

### Regression validation bar
- Manual smoke-test on Android must cover full core flows (capture/save/browse/edit/settings/sync toggles/background tasks best-effort).
- Golden diffs caused by dependency rendering changes are acceptable if visually reviewed and the new output is intended; update goldens.
- Test flakiness is a Phase 1 blocker; fix flakiness now (no quarantining as a default).
- Regression bar is focused on stability: no new crashes/runtime errors.

### Data safety & migrations
- No destructive Drift migrations (no dropping/losing user data). Only additive/transform migrations are allowed.
- Manual upgrade testing with a seeded/real-ish DB is not required for Phase 1 (fresh install coverage is acceptable).
- If any migration risk/uncertainty is discovered, default precaution is to add a backup/rollback step before landing the change.
- Any data corruption/validation issue is a blocker for Phase 1.

### Claude's Discretion
- None explicitly granted in discussion.

### Deferred Ideas (OUT OF SCOPE)
## Deferred Ideas

None - discussion stayed within Phase 1 scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DEP-01 | Update Riverpod to the targeted current stable range and keep the app functional | Riverpod 3.x migration requires switching legacy providers imports (`flutter_riverpod/legacy.dart`) and possibly updating any generator-based `Ref` types (if present). |
| DEP-02 | Update Drift to the targeted current stable range and keep migrations/queries working | Drift 2.31.0 is current stable on pub.dev; use official migration APIs (`Migrator`, `TableMigration`, or `make-migrations`) and keep schema upgrades additive. |
| DEP-03 | Update camera and workmanager packages without regressions | Camera 0.11.4 supports Android SDK 24+ and iOS 13+ but requires lifecycle handling in app code; Workmanager 0.9.0+3 requires iOS deployment target >= 14.0 and correct background-task setup. |
| DEP-04 | Build passes on latest Flutter stable; no deprecated APIs in use | Current repo is pinned to Flutter stable revision `67323de...` (Flutter 3.38.9, Dart 3.10.8); Phase 1 should keep `.metadata` aligned, run `dart fix` as needed, and enforce `flutter analyze` + custom_lint clean. |
| DEP-05 | Full test suite passes after dependency updates | CI runs `dart format` check, `flutter analyze`, `flutter pub run custom_lint`, `flutter test`, and Android AAB builds for staging/prod; Phase 1 must keep this exact pipeline green and fix test flakiness (incl. goldens). |
</phase_requirements>

## Summary

This phase is mostly about (1) moving Riverpod from `2.6.1` to current stable `3.2.1` and handling the Riverpod 3 migration, (2) ensuring Drift stays at the current stable (`2.31.0`) with no data-loss migrations, (3) bumping camera to `0.11.4`, and (4) keeping workmanager at `0.9.0+3` while bumping iOS deployment target to at least `14.0` (required by workmanager docs).

The repository is already pinned to Flutter stable `3.38.9` (Dart `3.10.8`) via `.metadata`, and Android build tooling is already modern (Gradle `8.14`, AGP `8.11.1`, Kotlin `2.2.20`, compileSdk `36`). The highest-risk upgrade is Riverpod because Riverpod 3 moves `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider` behind a legacy import; the app currently uses `StateProvider` and `StateNotifierProvider`.

**Primary recommendation:** Upgrade Riverpod to `3.2.1` using the Riverpod 3 migration guidance (legacy imports), bump iOS deployment target to `14.0` (or `15.0` if forced by other pods), then update/pin direct deps to exact versions with CI + device smoke tests gating every step.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter | 3.38.9 (stable) | Framework/toolchain baseline | Repo + CI are pinned via `.metadata` revision; Phase 1 must stay on latest stable. |
| Dart | 3.10.8 (stable) | Language/SDK | Comes with Flutter 3.38.9; determines analyzer + package compatibility. |
| flutter_riverpod / riverpod | 3.2.1 | State mgmt + DI | Current stable; required by DEP-01. |
| drift / drift_dev | 2.31.0 | Local persistence + codegen | Current stable; required by DEP-02. |
| camera | 0.11.4 | Camera capture/preview | Current stable; required by DEP-03. |
| workmanager | 0.9.0+3 | Background scheduling | Current stable; required by DEP-03; iOS requires deployment target >= 14.0. |

### Supporting (existing repo baseline)
| Library | Version (current) | Purpose | When to Use |
|---------|-------------------|---------|-------------|
| Gradle (wrapper) | 8.14 | Android build system | Keep aligned with AGP; CI builds AABs. |
| Android Gradle Plugin | 8.11.1 | Android build tooling | Keep current stable per Phase 1 constraints. |
| Kotlin Gradle Plugin | 2.2.20 | Kotlin toolchain for plugins | Keep aligned with AGP/Flutter templates. |
| Java toolchain (CI) | 17 | Android builds in GitHub Actions | Ensure Gradle/AGP/Kotlin remain compatible with JDK 17. |
| iOS deployment target | 13.0 (current) -> 14.0+ (required) | iOS platform baseline | Must be bumped to satisfy workmanager iOS requirements; allowed up to iOS 15. |
| sqlite3_flutter_libs | 0.5.41 (latest is `0.6.0+eol`) | Bundled sqlite on mobile | Update if Drift/sqlite3 compatibility or native build issues appear. |
| build_runner | 2.11.1 | Codegen driver | Required for drift generator; must match `drift_dev`. |
| custom_lint / custom_lint_builder | 0.8.0 | Guardrail lints | CI runs `flutter pub run custom_lint`; keep versions compatible with analyzer/Dart. |

**Versioning policy for Phase 1:** Use exact pins (e.g. `flutter_riverpod: 3.2.1`, not `^3.2.1`) for direct dependencies to stabilize the baseline; commit `pubspec.lock`.

**Installation / upgrade commands (planner should taskify):**
```bash
# inventory
flutter --version
flutter pub outdated

# upgrade (core first, then the rest)
flutter pub upgrade --major-versions

# apply mechanical API fixes when available
dart fix --apply

# verification gates
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter pub run custom_lint
flutter test
```

## Architecture Patterns

### Upgrade Sequencing Pattern (recommended)
**What:** Upgrade in small, verifiable slices instead of one massive `pub upgrade`, keeping CI green at each slice.
**When to use:** Always for Phase 1 (stability-focused, zero-tolerance warnings).
**How:**
- Slice 1: Flutter toolchain alignment (`.metadata`/Android tooling/iOS deployment target)
- Slice 2: Riverpod 3 migration (compilation fixes + tests)
- Slice 3: camera/workmanager updates + platform config
- Slice 4: Remaining dependency modernization “where reasonable”

### Riverpod 3 Migration Pattern: Legacy Import Where Needed
**What:** Keep existing `StateProvider` / `StateNotifierProvider` code working by switching imports to `legacy.dart` in Riverpod 3.
**When to use:** When upgrading to Riverpod 3 without a full Notifier rewrite.
**Example:**
```dart
// Source: https://github.com/rrousselgit/riverpod/blob/riverpod-v3.0.2/website/docs/3.0_migration.mdx
import 'package:flutter_riverpod/legacy.dart';

final startupMetricsReportedProvider = StateProvider<bool>((ref) => false);
```

### Drift Migrations Pattern: Additive Upgrades Only
**What:** Keep `schemaVersion` monotonic; use `Migrator` ops (`createTable`, `alterTable`, `addColumn`) in `onUpgrade` without dropping tables.
**When to use:** Always (data safety constraint).
**Example:**
```dart
// Source: https://drift.simonbinder.eu/migrations
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.addColumn(todos, todos.dueDate);
  }
}
```

### Workmanager Pattern: Top-Level Callback + Plugin Registrant
**What:** Ensure background isolate can use plugins by using a top-level callback and calling `DartPluginRegistrant.ensureInitialized()`.
**When to use:** Always when using `workmanager`.
**Example:**
```dart
// Source: https://docs.page/fluttercommunity/flutter_workmanager/quickstart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  });
}
```

### Camera Pattern: Handle Lifecycle Yourself
**What:** Camera plugin does not manage lifecycle; app should dispose/recreate controller on inactive/resumed.
**When to use:** Any screen that holds a `CameraController`.
**Example:**
```dart
// Source: https://pub.dev/packages/camera
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  final CameraController? cameraController = controller;
  if (cameraController == null || !cameraController.value.isInitialized) return;

  if (state == AppLifecycleState.inactive) {
    cameraController.dispose();
  } else if (state == AppLifecycleState.resumed) {
    _initializeCameraController(cameraController.description);
  }
}
```

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| State mgmt + DI | Custom global singletons / bespoke observable systems | Riverpod 3 (`flutter_riverpod`) | Riverpod handles scoping, caching, test overrides, async states, and dependency graphs. |
| Persistence + migrations | Manual sqlite schema + raw SQL migrations with ad-hoc tooling | Drift + Migrator / drift_dev migration tooling | Avoids silent data-loss and gives type-safe queries + migration test support. |
| Background scheduling | Custom Android services / iOS background hacks | workmanager | Platform-compliant scheduling with a single Dart API. |
| Camera integration | Platform channels for camera directly | camera plugin | Federated plugin with known platform edge cases covered. |

## Common Pitfalls

### Riverpod 3 “Missing StateProvider/StateNotifierProvider” Compile Failures
**What goes wrong:** After upgrading to `flutter_riverpod 3.x`, code using `StateProvider` / `StateNotifierProvider` no longer compiles.
**Why it happens:** Riverpod 3 moved these provider types behind `package:flutter_riverpod/legacy.dart`.
**How to avoid:** Update imports in files that use legacy providers (or migrate to `NotifierProvider`/`AsyncNotifierProvider` if doing a broader refactor).
**Warning signs:** Errors like “Undefined class ‘StateNotifierProvider’” or missing symbols from `flutter_riverpod.dart`.

### iOS Build Breaks: workmanager Requires iOS 14+
**What goes wrong:** iOS build fails or plugin compilation fails after dependency updates.
**Why it happens:** workmanager docs require iOS minimum deployment target `14.0`.
**How to avoid:** Bump `IPHONEOS_DEPLOYMENT_TARGET` to at least `14.0` (allowed up to `15` by Phase 1 constraints) and ensure Xcode project + Podfile match.
**Warning signs:** Pod install/build errors complaining about deployment target or unavailable APIs.

### iOS CocoaPods Scaffolding Drift (Podfile missing / mismatched)
**What goes wrong:** `flutter build ios`/`pod install` fails due to missing `ios/Podfile` or a template mismatch.
**Why it happens:** Flutter plugins on iOS are typically wired via CocoaPods; the repo currently has no `ios/Podfile` even though Flutter’s iOS build settings reference CocoaPods.
**How to avoid:** Re-introduce a Podfile matching the Flutter SDK template (see Sources) and keep deployment target consistent (>= 14.0 for workmanager).
**Warning signs:** “No such file or directory - Podfile”, “podhelper.rb not found”, or missing plugin frameworks at link time.

### Drift Migration Regressions
**What goes wrong:** Migrations work on fresh install but break upgrading users (missing columns/tables, constraint issues).
**Why it happens:** `onUpgrade` paths aren’t additive/complete for all prior versions.
**How to avoid:** Keep additive migrations only; add/expand migration tests when changing schema; avoid running queries mid-migration that assume the latest schema.
**Warning signs:** Exceptions during open, missing column errors, constraint failures.

### Golden/Widget Test Drift After Flutter/Skia Updates
**What goes wrong:** Goldens fail with small diffs after upgrades.
**Why it happens:** Text/layout rasterization changes across Flutter engine versions and/or dependency rendering changes.
**How to avoid:** Visually review diffs; update goldens intentionally (`flutter test --update-goldens`) and ensure fonts/assets are deterministic.
**Warning signs:** Many pixel diffs across unrelated widgets.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Riverpod `StateNotifierProvider` as primary API | Riverpod `Notifier/AsyncNotifier` as preferred API; legacy providers require `legacy.dart` import | Riverpod 3.0 | Riverpod upgrade requires import changes or a refactor plan. |
| Manual drift migrations only | drift_dev `make-migrations` + generated tests recommended | Drift docs (current) | Safer upgrades and easier regression testing for schema changes. |
| Camera plugin handles lifecycle | App code must manage lifecycle | camera >= 0.5.0 | Prevents camera resource leaks and “black preview” issues. |

## Open Questions

1. **iOS baseline: should Phase 1 standardize on iOS 14.0 or jump straight to iOS 15.0?**
   - What we know: workmanager requires iOS 14.0+; Phase 1 allows bump up to iOS 15.
   - What's unclear: whether any other current deps/pods force iOS 15.
   - Recommendation: plan for iOS 14.0 minimum as the baseline, with a contingency task to bump to iOS 15.0 if pods require it.

## Sources

### Primary (HIGH confidence)
- Riverpod 3 migration guide (Context7 -> GitHub): https://github.com/rrousselgit/riverpod/blob/riverpod-v3.0.2/website/docs/3.0_migration.mdx
- Drift migrations docs: https://drift.simonbinder.eu/migrations
- Camera package docs (incl. platform mins + lifecycle handling): https://pub.dev/packages/camera
- Workmanager Quick Start (iOS min deployment target + setup): https://docs.page/fluttercommunity/flutter_workmanager/quickstart
- Flutter iOS Podfile template (Flutter SDK 3.38.9): `/home/hans/.local/share/flutter/packages/flutter_tools/templates/cocoapods/Podfile-ios`

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - versions verified via `flutter pub outdated` and pub.dev pages
- Architecture: HIGH - migration requirements sourced from Riverpod/Drift/Workmanager/Camera official docs
- Pitfalls: MEDIUM - some are repo-specific (missing Podfile) but validated by repo structure + Flutter templates

**Research date:** 2026-02-21
**Valid until:** 2026-03-07 (package ecosystem moves fast; re-check pub.dev versions before landing)
