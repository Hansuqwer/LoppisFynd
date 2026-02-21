# Phase 4: Core Screens + Goldens - Research

**Researched:** 2026-02-19
**Domain:** Flutter UI reskin (Nature Distilled) + golden tests + offline-first regression
**Confidence:** MEDIUM

## User Constraints

No Phase 4 `CONTEXT.md` exists yet. Constraints are inherited from prior phases (`.planning/STATE.md`) and the Phase 4 brief.

- Avoid ThemeData-wide input/button overrides that drift existing goldens; keep theme changes additive via tokens.
- Keep `GlassOverlay` API stable; prefer `GlassSurface`/`GlassBoard` primitives for new screens.
- No hardcoded user-facing strings; use `AppLocalizations`.
- Handwritten font accent-only.
- OFF-01: Offline flows must remain functional; UI must not introduce online-only blockers.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SCR-01 | Home parity (hero CTA + bento tiles + capsule nav) | Home tab is `DashboardScreen` (`lib/features/dashboard/dashboard_screen.dart`) hosted by `AppNavShell` (`lib/core/navigation/app_nav_shell.dart`). Existing tokens/primitives exist for board/glass/bento/capsule. |
| SCR-02 | Current Haul parity ("Totalt värde:" + list rows; camera action styled) | Haul tab is `HaulScreen` (`lib/features/hauls/haul_screen.dart`) reading offline data from Drift via `appDatabaseProvider`. Can deep-link to Scanner tab via `deepLinkTabIndexProvider`. |
| SCR-03 | History empty parity (search bar + pebble filters + coffee-cup empty state) | History tab is `HistoryScreen` (`lib/features/history/history_screen.dart`). Has `CoffeeCupEmptyState` (`lib/features/history/widgets/coffee_cup_empty_state.dart`) and search/filter state already (currently `TextField` + `ChoiceChip`). |
| SCR-04 | Draft editor parity (stacked glass, preview, AI tags, fields incl. "Pris (SEK)") | Draft editor is `DraftEditorScreen` (`lib/features/drafts/draft_editor_screen.dart`) backed by Drift (`ScanItems`, `DraftListings`). `StackedBackplates` exists (`lib/shared/widgets/glass_board.dart`). |
| SCR-05 | Profile/Settings parity (bento modules: "Molnsynk & Data", "AI & Modell", "Integritet"), clean by default | Profile tab is `SettingsScreen` (`lib/features/settings/settings_screen.dart`). Dev-only sync controls already gated behind 7-tap Dev Mode (`dev_mode_enabled_v1`). |
| QA-01 | Goldens: at minimum Login, Home, History empty, Draft editor | Existing goldens: Login + BentoCard (`test/features_auth/login_screen_golden_test.dart`, `test/fl_066_bento_card_golden_test.dart`, PNGs in `test/goldens/`). Extend with additional tests + PNGs for Home/History-empty/Draft editor. |
| OFF-01 | Offline flows remain functional; UI must not introduce online-only blockers | All Phase 4 target screens are already offline-backed via Drift streams (`appDatabaseProvider`), and online-only features are gated by `AppConfig.hasSupabase` / `AppConfig.hasTraderaProxy` / `isOnlineProvider`. |

</phase_requirements>

## Summary

Phase 4 is primarily a **visual retrofit** over already-working offline screens: the 5-tab shell is already wired (`AppNavShell` + `CapsuleNavBar` + `NatureBackground`), and the data sources for Haul/History/Draft are already the local Drift DB (offline-first). Planning should therefore treat this phase as **layout + styling work** with strict constraints: use existing tokens/primitives, keep localization rules, and avoid theme-wide overrides.

The main planning risk is scope creep: `HistoryScreen` currently implements map/list/sort/category filtering; `SettingsScreen` contains many sections and dev-only controls; `DashboardScreen` already has animations and cards but not reference-parity. To plan well, isolate parity to **the referenced states** (Home, Current Haul, History-empty, Draft editor, Profile modules), and use goldens to lock in the layouts that match the reference pack.

**Primary recommendation:** Reskin existing screens in-place (no new navigation/IA), add small new UI primitives only where needed (e.g., “pebble” filter chip), and introduce 3 new goldens (Home, History-empty, Draft editor) using the existing in-memory DB + ProviderScope override pattern.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | (repo uses Dart `^3.10.8`) | UI framework | Existing app; required for widgets/goldens |
| flutter_riverpod | `^2.6.1` | State/DI | All app-wide dependencies come from providers (`lib/core/app/providers.dart`) |
| drift / drift_flutter | `^2.31.0` / `^0.2.8` | Offline DB | Offline-first persistence; screens use stream queries |
| flutter_test | SDK | Widget + golden tests | Existing goldens use `matchesGoldenFile` |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_animate | `^4.5.2` | Entry animations | Use sparingly; ensure goldens settle (no infinite anims) |
| google_fonts | `^6.3.3` | Fonts config | Must keep `GoogleFonts.config.allowRuntimeFetching = false` in tests |
| supabase_flutter | `^2.12.0` | Optional auth/sync | Screens must remain functional when `AppConfig.hasSupabase == false` |
| workmanager | `^0.9.0+3` | Background tasks | Tests that touch scheduling may need fakes (see `test/features_settings/fl_068_settings_dev_mode_reveal_test.dart`) |

## Where The Five Tabs Live Today

Tab contract is defined in `lib/core/navigation/app_nav_shell.dart`:

- Home tab: `DashboardScreen` (`lib/features/dashboard/dashboard_screen.dart`)
- Scan tab: `ScannerScreen` (`lib/features/scanner/scanner_screen.dart`)
- Haul tab: `HaulScreen` (`lib/features/hauls/haul_screen.dart`)
- History tab: `HistoryScreen` (`lib/features/history/history_screen.dart`)
- Profile tab: `SettingsScreen` (`lib/features/settings/settings_screen.dart`)

Phase 4 scope is **reskin/restructure these widgets**, not a new navigation system (NAV-01 already verified in Phase 2).

## Architecture Patterns

### Pattern: Tab Screens Are Offline-Backed Stream UIs
**What:** Screens read Drift via `ref.watch(appDatabaseProvider)` and render with `StreamBuilder`.
**When to use:** Any UI that reflects local DB state (Haul, History, Draft editor).
**Example:**
```dart
// Source: lib/features/hauls/haul_screen.dart
final db = ref.watch(appDatabaseProvider);
final userId = ref.watch(activeUserIdProvider);

return StreamBuilder<List<ScanItem>>(
  stream: db.scanItemsDao.watchByHaulId(haulId, userId: userId),
  builder: (context, snapshot) {
    final items = snapshot.data ?? const [];
    ...
  },
);
```

### Pattern: Capsule Nav Safe Insets
**What:** `AppNavShell` pads tab content by `CapsuleNavBar.obstructionHeight(context)` so tab screens don’t need to hand-roll bottom spacing.
**When to use:** Any tab screen that scrolls to bottom.
**Example:**
```dart
// Source: lib/core/navigation/app_nav_shell.dart
Expanded(
  child: Padding(
    padding: EdgeInsets.only(
      bottom: CapsuleNavBar.obstructionHeight(context),
    ),
    child: IndexedStack(...),
  ),
)
```

### Pattern: Glass Primitives (Clipped Blur)
**What:** Use `GlassSurface` / `GlassBoard` / `StackedBackplates` instead of ad-hoc `BackdropFilter`.
**When to use:** Any new glass container for parity layouts.
**Example:**
```dart
// Source: lib/shared/widgets/glass_surface.dart
return ClipRRect(
  borderRadius: borderRadius,
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
    child: DecoratedBox(...),
  ),
);
```

### Anti-Patterns to Avoid
- **Theme-wide widget overrides:** Don’t add/modify broad `InputDecorationTheme`, `ButtonTheme`, etc. Use tokens + local styles (locked constraint; also reduces golden drift).
- **Hardcoded strings:** Must be `AppLocalizations` (L10N-01).
- **Unclipped blur:** Never add a `BackdropFilter` without clip.

## Don’t Hand-Roll

| Problem | Don’t Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| UI glass/blur surfaces | Custom `BackdropFilter` trees per screen | `GlassSurface` / `GlassBoard` / `GlassOverlay` | Guarantees clipped blur + consistent token usage |
| Localization | Inline strings | `AppLocalizations` (`lib/gen/app_localizations.dart`) | Enforced by requirements + prevents copy regressions |
| Golden harness | Custom screenshot/diff logic | `flutter_test` `matchesGoldenFile` pattern already in repo | Keeps CI expectations stable |
| Offline persistence | Per-screen state caches | Drift DB + existing DAOs | OFF-01 depends on DB being source-of-truth |

## Golden Test Harness (What Exists + How To Extend)

### Existing Goldens
- `test/features_auth/login_screen_golden_test.dart` → `test/goldens/login_screen.png`
- `test/fl_066_bento_card_golden_test.dart` → `test/goldens/bento_card.png`

### Existing Golden Pattern (Replicate)
Key conventions already used:

- Disable runtime font fetching: `GoogleFonts.config.allowRuntimeFetching = false;`
- Fixed device surface size: `tester.binding.setSurfaceSize(const Size(390, 844));`
- Wrap target in `RepaintBoundary` with a `GlobalKey`
- Use `MaterialApp(theme: AppTheme.light(), locale: const Locale('sv'), ...)`
- For app-backed screens, use `ProviderScope(overrides: [...])` with `AppDatabase.inMemory()`

### Golden-Safe UI Rules (Practical)
- Ensure the golden state is deterministic: no randoms, no time-of-day strings, no network images.
- Avoid infinite animations; if using `flutter_animate`, ensure `pumpAndSettle` reaches idle.
- Prefer local assets (`Assets/...`) and local DB state (Drift in-memory).

## Offline-First Data Flow (Reskin-Safe Boundaries)

### What must remain true
- UI should still read/write the same DAOs (`ScanItemsDao`, `DraftListingsDao`, `HaulsDao`, `AppSettingsDao`).
- “Save draft”, “Create haul”, “Edit fields” actions must remain available offline (no `AppConfig.hasSupabase` gating for core local actions).

### Screen-specific notes
- `HaulScreen` uses `defaultHaulIdProvider` (`lib/core/app/providers.dart`) and watches scan items by haul ID; reskinning should not change the query or ID semantics.
- `HistoryScreen` reads all hauls + scan items; parity work for the **empty state** should avoid rewriting map/list logic unless necessary.
- `DraftEditorScreen` updates DB via `draftListingsDao.upsert` and should stay safe even when item photos are missing (already handles missing `thumbPath`).

## Common Pitfalls

### Pitfall: Goldens fail due to fonts
**What goes wrong:** Text metrics differ or fallback fonts are used.
**Why it happens:** Runtime font fetching or missing font assets.
**How to avoid:** Keep `GoogleFonts.config.allowRuntimeFetching = false` in goldens and keep font families as asset families (`pubspec.yaml` fonts section).
**Warning signs:** Off-by-a-few-pixels text wrapping; CI-only failures.

### Pitfall: Goldens fail due to unfinished async/animations
**What goes wrong:** Snapshots captured mid-transition.
**Why it happens:** `flutter_animate` entry anims, `Animated*` widgets, `StreamBuilder` initial emissions.
**How to avoid:** `pumpAndSettle` with enough duration; avoid repeating animations; keep loading states explicit.
**Warning signs:** Flaky tests; different results across runs.

### Pitfall: Adding online-only UI blockers
**What goes wrong:** Reskin adds required network calls (e.g., remote images) or disables offline actions.
**Why it happens:** Pulling in network images/icons; gating buttons on `isOnline`.
**How to avoid:** Use local assets/placeholders; keep offline actions enabled; ensure online-only features stay optional.
**Warning signs:** App unusable in airplane mode.

### Pitfall: History “empty” doesn’t trigger for new users
**What goes wrong:** DB always has the current haul (`haul_current_*`), so `hauls.isEmpty` never becomes true and reference empty UI is never shown.
**Why it happens:** Current implementation treats all hauls as history.
**How to avoid:** (Recommended) treat the default/current haul as “Current Haul” and exclude it from the “History” list/empty-state checks.
**Warning signs:** Coffee-cup empty state never visible.

## Code Examples

### Provider Override Pattern for App Screens in Tests
```dart
// Source: test/fl_065_nav_smoke_test.dart (pattern)
final db = AppDatabase.inMemory();
addTearDown(db.close);

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      // add appConfigProvider / storage / modelManager overrides as needed
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const AppNavShell()),
  ),
);
```

### Deep-Linking to Scanner Tab From Other Screens
```dart
// Source: lib/features/dashboard/dashboard_screen.dart
ref.read(deepLinkTabIndexProvider.notifier).state = 1; // scanner tab index
```

## Recommended Plan Split (3 Plans) + Key Files

### Plan 04-01: Core screens parity (Home + Current Haul + History empty + Draft editor)
Primary files:
- `lib/features/dashboard/dashboard_screen.dart`
- `lib/features/hauls/haul_screen.dart`
- `lib/features/history/history_screen.dart`
- `lib/features/drafts/draft_editor_screen.dart`
- Likely small new widgets under `lib/shared/widgets/` (e.g., pebble filter chip, haul row, pill button) to keep layouts consistent

Verification:
- `flutter test`
- Manual: run app offline and verify scan/haul/draft flows still work (OFF-01)

### Plan 04-02: Profile/Settings parity (bento modules; clean by default)
Primary files:
- `lib/features/settings/settings_screen.dart`
- `lib/features/settings/privacy_screen.dart` (if module routes change)
- `lib/features/settings/sync_status_screen.dart` (if module routes change)

Verification:
- `flutter test test/features_settings/fl_068_settings_dev_mode_reveal_test.dart`
- Manual: verify Dev Mode still required to show sync controls (7-tap)

### Plan 04-03: Goldens + offline regression sanity
Primary files:
- New golden tests:
  - `test/features_dashboard/dashboard_screen_golden_test.dart` (new)
  - `test/features_history/history_empty_golden_test.dart` (new)
  - `test/features_drafts/draft_editor_golden_test.dart` (new)
- New PNGs in `test/goldens/`

Verification:
- `flutter test`
- `flutter test --update-goldens` (only when intentionally updating baseline images)
- Targeted: `flutter test test/features_auth/login_screen_golden_test.dart`

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Theme-wide overrides for inputs/buttons | Token-driven + local styles | Phase 1 decision (`.planning/STATE.md`) | Reduces drift risk; keeps goldens stable |
| Per-screen un-clipped blur | `GlassSurface`/`GlassBoard` enforce clip | Phase 1 (DS-02) | Prevents perf issues + visual artifacts |
| No capsule-safe insets | `AppNavShell` pads content by capsule obstruction | Phase 2 | Prevents content under capsule nav |

## Open Questions

1. **What exactly counts as “History” vs “Current Haul”?**
   - What we know: `defaultHaulIdProvider` defines a special “current haul” ID; History tab currently lists all hauls.
   - What’s unclear: Should History exclude the current haul so new users see the designed empty state?
   - Recommendation: Exclude the default/current haul from History list/empty checks (aligns with SCR-03 reference and keeps Haul tab responsible for current haul).

2. **Should goldens include the capsule nav + Nature background, or just the inner board?**
   - What we know: Existing login golden captures a full-screen scene; bento card golden captures an isolated widget.
   - Recommendation: For Phase 4 goldens, capture the full tab scene including background where it affects blur; at minimum ensure a deterministic background exists behind glass widgets.

## Sources

### Primary (HIGH confidence)
- `.planning/ROADMAP.md` - Phase 4 goals + plan split
- `.planning/REQUIREMENTS.md` - SCR-01..SCR-05, QA-01, OFF-01
- `.planning/STATE.md` - locked constraints carried into Phase 4
- `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md` - reference pack mapping + implementation notes
- `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md` - copy fixes + parity notes
- `lib/core/navigation/app_nav_shell.dart` - tab wiring + capsule safe inset
- `lib/shared/widgets/glass_surface.dart`, `lib/shared/widgets/glass_board.dart`, `lib/shared/widgets/capsule_nav_bar.dart` - primitives/tokens usage
- `test/features_auth/login_screen_golden_test.dart`, `test/fl_066_bento_card_golden_test.dart` - existing golden harness patterns

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - versions are in `pubspec.yaml` and code usage is explicit.
- Architecture: HIGH - tab wiring + providers + primitives are in-repo.
- Pitfalls: MEDIUM - golden flake causes are common, but final risk depends on how closely Phase 4 mirrors the PDF visuals.

**Research date:** 2026-02-19
**Valid until:** 2026-03-21 (30 days)
