# Phase 1: Dependency Modernization Baseline - Context

**Gathered:** 2026-02-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Modernize the Flutter toolchain and core dependencies so the app builds, installs, and launches (Android and iOS) with tests passing and no data-loss regressions. This phase is about upgrades + fixing breakages/regressions caused by upgrades, not adding new features.

</domain>

<decisions>
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

</decisions>

<specifics>
## Specific Ideas

- Primary Android validation target: Android 14/15 flagship device.

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within Phase 1 scope.

</deferred>

---

*Phase: 01-dependency-modernization-baseline*
*Context gathered: 2026-02-21*
