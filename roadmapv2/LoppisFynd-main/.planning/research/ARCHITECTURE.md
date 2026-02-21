# Architecture Research

**Domain:** UI/UX overhaul (Nature Distilled) in an existing offline-first Flutter app
**Researched:** 2026-02-18
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌───────────────────────────────────────────────────────────────────────────┐
│ Presentation (feature-first)                                              │
│                                                                           │
│  ┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐   │
│  │ Onboarding/Auth    │   │ 5-Tab Shell       │   │ Feature Screens   │   │
│  │ (startup gates)    │   │ (background + nav)│   │ (scan/haul/etc)   │   │
│  └─────────┬─────────┘   └─────────┬─────────┘   └─────────┬─────────┘   │
│            │                       │                       │             │
├────────────┴───────────────────────┴───────────────────────┴─────────────┤
│ Design System Layer (churn shield)                                        │
│                                                                           │
│  Tokens + Theme            Shared UI primitives                           │
│  (colors/type/spacing)     (glass surfaces, boards, nav, backgrounds)     │
│                                                                           │
├───────────────────────────────────────────────────────────────────────────┤
│ State + Orchestration (Riverpod)                                          │
│                                                                           │
│  Providers (DI) + Feature Controllers (UI state machines)                 │
│  - model download/install state                                           │
│  - dev-mode gating for advanced controls                                  │
│                                                                           │
├───────────────────────────────────────────────────────────────────────────┤
│ Domain Services + Persistence (offline-first)                             │
│                                                                           │
│  Services/              Drift DB (source of truth)        Local files      │
│  - AI inference         - app_settings (flags/consent)    - photos/models  │
│  - market sync          - scan_items/hauls/etc            - resumable dl   │
│  - cloud sync (opt)                                                     │
└───────────────────────────────────────────────────────────────────────────┘
```

This overhaul is safest when treated as a *design-system retrofit* that sits between feature screens and the existing domain/services layers. The goal is to swap visuals without rewriting data flows.

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `lib/core/tokens/**` | Single source of truth for visual constants | `AppColors`, `AppRadius`, `AppSpacing`, `AppShadows`, `AppMotion`, plus new blur/opacity tokens |
| `lib/core/theme/app_theme.dart` | ThemeData defaults + global typography mapping | `ThemeData(useMaterial3: true, textTheme: AppTypography.textTheme, ...)` |
| `lib/shared/widgets/**` | Reusable primitives that enforce visual parity + perf rules | `GlassSurface`, `GlassBoard`, `CapsuleNavBar`, `AtmosphericBackground/NatureBackground`, `EmptyState` |
| `lib/core/navigation/app_nav_shell.dart` | 5-tab shell with persistent background + capsule nav | `Stack(background + OfflineBanner + tab content + CapsuleNavBar)` |
| `lib/features/**` | Feature-first screens and small local widgets | Keep existing screen entrypoints; refactor UI incrementally |
| `lib/features/*/controllers/**` | UI orchestration state machines (download, view state) | Riverpod `Notifier/StateNotifier` |
| `lib/services/ai/model_manager.dart` | Low-level model file operations (resume, atomic moves) | Download/install/delete on local FS |
| `lib/core/database/**` | Offline-first persistence and app settings | Drift DAOs + tables; `app_settings` as a small KV store |

## Recommended Project Structure

Use the existing feature-first layout, and make the design system the primary "churn boundary".

```
lib/
├── core/
│   ├── app/                     # Riverpod providers (DI + app signals)
│   ├── config/                  # AppConfig + feature flags
│   ├── database/                # Drift DB + DAOs (offline-first source of truth)
│   ├── navigation/              # AppNavShell, route transitions
│   ├── theme/                   # ThemeData composition
│   └── tokens/                  # Design tokens (colors/type/radius/spacing/motion)
├── services/                    # Domain services (AI, sync, market, cloud)
├── shared/
│   ├── painters/                # Background/texture painters
│   └── widgets/                 # Design-system primitives (NO business logic)
└── features/
    ├── onboarding/              # Startup flow + model prompt callout
    ├── auth/                    # Login/signup (visual parity with reference)
    ├── dashboard/               # Home (board + hero + tiles)
    ├── scanner/                 # Capture flows (offline preserved)
    ├── hauls/                   # Current haul board + list
    ├── history/                 # History empty + filters
    ├── drafts/                  # Draft editor board
    ├── settings/                # Profile/settings modules
    └── model_manager/           # Model UX (controller + widgets)
        ├── controllers/
        └── widgets/
```

### Structure Rationale

- **`lib/core/tokens/**` + `lib/shared/widgets/**`:** The fastest path to strict visual parity is centralizing all "Nature Distilled" look-and-feel in tokens + primitives, and then composing screens from those parts.
- **`lib/features/**` stays stable:** Preserve feature routes and data flows (DAOs/services/providers). UI changes should be mostly within screens and their local widgets.
- **Controllers live with features:** Download/install state is feature UI state, but depends on stable services (`ModelManager`) and a persisted consent flag (Drift settings).

## Architectural Patterns

### Pattern 1: Design System as the Primary Churn Boundary

**What:** Express the overhaul as tokens + primitives, and keep feature screens as composition only.

**When to use:** Any time pixel parity matters and you want minimal regressions across a large feature surface.

**Trade-offs:** Up-front work to build primitives; pays off by reducing per-screen bespoke styling and eliminating "UI drift".

**Example:** enforce the blur rule via a single primitive (no raw `BackdropFilter` in feature code).

```dart
// shared/widgets/glass_surface.dart
// - ALWAYS ClipRRect/ClipRect around BackdropFilter
// - all blur sigmas come from AppBlur tokens
// - all radii/spacings come from tokens
```

### Pattern 2: Backwards-Compatible Primitive Upgrades

**What:** Prefer upgrading existing shared widgets (same public API) over introducing new ones.

**When to use:** When a primitive is already widely referenced (e.g. `CapsuleNavBar`, `AtmosphericBackground`, `BentoCard`, `GlassOverlay`).

**Trade-offs:** Slightly more care to avoid behavior changes; dramatically less churn in feature screens.

**Example:** evolve `CapsuleNavBar` to match the selected-bubble behavior from the reference pack without forcing a shell rewrite.

### Pattern 3: Controller-Owned Long-Running UI Work

**What:** Model download/install is a state machine owned by a Riverpod controller that survives navigation changes (keepAlive).

**When to use:** Any work that must continue while the user navigates (onboarding -> app shell) and needs consistent UI across multiple surfaces.

**Trade-offs:** Slight complexity in state modeling; avoids duplicated logic in Dashboard/Onboarding/Settings.

**Example:** a `ModelInstallController` that exposes states like `needsConsent`, `downloading(progress)`, `ready`, `failed`.

## Data Flow

### Request Flow (Model Download / Install)

```
User taps "Download" (Onboarding page 3)
    ↓
Onboarding calls ModelInstallController.ensureInstalled()
    ↓
Controller:
  - persists consent flag in Drift app_settings
  - streams progress from ModelManager.downloadFromUrl(onProgress)
  - performs atomic move to final model path (ModelManager already does)
    ↓
Controller emits state → UI surfaces update:
  - Onboarding callout (progress + learn more)
  - Dashboard preflight card (same controller, no duplicate state)
  - Settings AI module (status + retry)
    ↓
AI inference uses modelPath; future runs succeed once the file exists
```

### State Management

```
Persistent state:
  - installed? (filesystem: ModelManager.state())
  - consent? (Drift: app_settings['gemma_download_consent'])

Ephemeral state (in-memory, Riverpod):
  - download progress (received/total)
  - last error
  - installing flag
```

### Key Data Flows

1. **UI visual parity:** Feature screens compose `shared/widgets` primitives; tokens are the only place where numbers/colors are tuned.
2. **Localization correctness:** Only feature screens (and feature-level widgets) call `AppLocalizations`; shared primitives accept already-localized strings or use semantic-neutral UI.
3. **Offline-first invariants:** All existing DAOs/services remain the source of truth; UI changes must not create new online-only dependencies.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-1k users | Current approach is sufficient; focus on golden tests + perf (blur clipping) |
| 1k-100k users | Reduce repaint cost (RepaintBoundary on boards/nav), avoid overdraw in background, tighten image cache sizing |
| 100k+ users | Consider caching expensive background paints to images; formalize design system versioning and migration notes |

### Scaling Priorities

1. **First bottleneck:** GPU cost from blur/overdraw; solve by clipped BackdropFilters, limiting blur regions, and using cached paints.
2. **Second bottleneck:** UI drift/regressions; solve by goldens for primitives + key screens and by preventing hard-coded strings.

## Anti-Patterns

### Anti-Pattern 1: Styling Per Screen (Token Bypass)

**What people do:** Add new colors/radii/spacings inline while implementing screens to hit visuals quickly.

**Why it's wrong:** The app becomes impossible to tune for parity (every tweak requires chasing constants), and screens drift from each other.

**Do this instead:** Put every visual number in `lib/core/tokens/**` and every glass/nav/background in `lib/shared/widgets/**`.

### Anti-Pattern 2: Duplicated Model Download Logic in Multiple Screens

**What people do:** Each screen re-implements progress/error state with `setState` around `ModelManager.downloadFromUrl`.

**Why it's wrong:** Inconsistent behavior, broken "download continues while navigating", and localization bugs (hard-coded status strings).

**Do this instead:** One controller (Riverpod) is the integration point; all UI surfaces render the same state.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| `flutter_gemma` | AI backend reads a local model file path | Keep inference path stable; treat model install as file provisioning |
| Workmanager | Background periodic work | Consider a lightweight "model download retry" task only after consent (optional) |
| Supabase (optional) | Auth + cloud sync | Must remain optional; UI should not assume network/auth |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `features/*` ↔ `shared/widgets/*` | direct widget composition | Shared widgets must stay logic-free; accept params instead |
| `features/model_manager/*` ↔ `services/ai/model_manager.dart` | controller calls service | Service owns filesystem; controller owns UI state + consent |
| `features/model_manager/*` ↔ `core/database/app_settings_dao.dart` | DAO access via providers | Persist consent + keep dev mode controls hidden by default |
| `core/navigation/app_nav_shell.dart` ↔ feature screens | tab selection + IndexedStack/Stack | Keep 5 tabs; preserve deep-link providers |

## Sources

- `docs/LoppisFynd_Nature_Distilled_Technical_Handoff_v2.md` (implementation order + model prompt + primitives)
- `docs/UiUxOverHaul/Technical_Handoff_Patch_v2.md` (copy fixes + new primitives + golden guidance)
- `docs/LoppisFynd_Nature_Distilled_Visual_Reference_Pack.pdf` (visual parity targets)
- `.planning/codebase/ARCHITECTURE.md` (current app layering + offline-first constraints)
- `lib/core/navigation/app_nav_shell.dart` (5-tab shell + background + capsule nav)
- `lib/services/ai/model_manager.dart` (resumable download + atomic moves)

---
*Architecture research for: Nature Distilled UI/UX retrofit*
*Researched: 2026-02-18*
