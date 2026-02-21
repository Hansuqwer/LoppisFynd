# Codebase Structure

**Analysis Date:** 2026-02-17

## Directory Layout

```
[project-root]/
├── lib/                     # Flutter application code
│   ├── main.dart            # Composition root + routing entry
│   ├── core/                # Cross-cutting platform/app primitives
│   ├── features/            # Feature-first UI screens and feature helpers
│   ├── services/            # Non-UI services (AI, market, sync, privacy, ...)
│   ├── shared/              # Reusable UI widgets/painters
│   ├── gen/                 # Generated localization output (used by app)
│   └── l10n/                # Legacy/alternate localization output (present)
├── Assets/                  # App assets (images, fonts, layout references)
├── test/                    # Unit/widget/golden tests
├── supabase/                # Supabase local project (migrations/functions)
├── android/                 # Android runner + build configs
├── ios/                     # iOS runner + build configs
├── docs/                    # Project docs
├── .planning/               # GSD planning artifacts
└── pubspec.yaml             # Flutter package manifest
```

## Directory Purposes

**lib/core/:**
- Purpose: Application-wide primitives and shared infrastructure.
- Contains: DI providers, config/flags, DB, navigation shell, storage, tokens/theme.
- Key files: `lib/core/app/providers.dart`, `lib/core/config/app_config.dart`, `lib/core/database/app_database.dart`, `lib/core/navigation/app_nav_shell.dart`, `lib/core/storage/scan_image_storage.dart`

**lib/features/:**
- Purpose: Feature-first UI, grouped by user-facing capability.
- Contains: `*_screen.dart` pages, feature-local widgets, and small feature helpers.
- Key files: `lib/features/scanner/scanner_screen.dart`, `lib/features/scanner/scan_capture_service.dart`, `lib/features/analyzer/item_detail_screen.dart`, `lib/features/settings/settings_screen.dart`

**lib/services/:**
- Purpose: Non-UI services (network/IO/background orchestration/domain operations).
- Contains: AI inference (`lib/services/ai/`), market bridge (`lib/services/market/`), sync (`lib/services/sync/`), analytics (`lib/services/analytics/`).
- Key files: `lib/services/sync/sync_scheduler.dart`, `lib/services/sync/background/background_sync.dart`, `lib/services/sync/cloud/cloud_sync_coordinator.dart`

**lib/shared/:**
- Purpose: Reusable UI components that are not feature-specific.
- Contains: `lib/shared/widgets/*` (buttons, cards, background, banners) and painters.
- Key files: `lib/shared/widgets/bento_card.dart`, `lib/shared/widgets/capsule_nav_bar.dart`, `lib/shared/widgets/atmospheric_background.dart`

**lib/gen/:**
- Purpose: Generated localization code used by the app.
- Contains: `lib/gen/app_localizations.dart` and locale-specific outputs.

**lib/l10n/:**
- Purpose: Localization outputs also present under an alternate path.
- Contains: `lib/l10n/app_localizations.dart` and locale-specific outputs.

**Assets/:**
- Purpose: Bundled assets for offline-first UX.
- Contains: Fonts (`Assets/fonts/`), imagery (`Assets/unnamed.jpg`), and references.

**supabase/:**
- Purpose: Supabase local project for cloud sync backend.
- Contains: `supabase/migrations/`, `supabase/functions/`, `supabase/config.toml`.

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap, DI wiring, and route generation.
- `lib/services/sync/background/background_sync.dart`: Workmanager background callback entry (`callbackDispatcher`).

**Configuration:**
- `lib/core/config/app_config.dart`: Compile-time environment config (`String.fromEnvironment(...)`).
- `lib/core/config/feature_flags.dart`: Compile-time feature flags.
- `analysis_options.yaml`: Analyzer configuration.
- `l10n.yaml`: Localization generation configuration.

**Core Logic:**
- `lib/core/database/app_database.dart`: Drift database definition + migrations.
- `lib/core/database/tables/scan_items.dart`: Core entity schema.
- `lib/core/database/daos/scan_items_dao.dart`: Core entity data access + cloud dirty-marking.
- `lib/services/sync/sync_scheduler.dart`: Market sync orchestration.
- `lib/services/sync/cloud/cloud_sync_coordinator.dart`: Cloud sync orchestration.
- `lib/services/ai/inference/inference_isolate_service.dart`: AI inference runner.

**Testing:**
- `test/`: Mixed unit/widget/golden tests.

## Naming Conventions

**Files:**
- `snake_case.dart` across the codebase (for example `lib/core/app/providers.dart`).
- Screens: `*_screen.dart` (for example `lib/features/scanner/scanner_screen.dart`).
- Gates/shell: `*_gate.dart` and `*_shell.dart` (for example `lib/features/auth/auth_gate.dart`, `lib/core/navigation/app_nav_shell.dart`).
- Services: `*_service.dart` or descriptive service names (for example `lib/services/sync/cloud_metadata_sync_service.dart`).
- DAOs: `*_dao.dart` with generated `*_dao.g.dart` (for example `lib/core/database/daos/scan_items_dao.dart`).
- Generated: `*.g.dart` (Drift, localization) should not be hand-edited (for example `lib/core/database/app_database.g.dart`).

**Directories:**
- `lib/features/<feature>/` for feature-owned UI + helpers.
- `lib/services/<area>/` for cross-cutting, non-UI operations.
- `lib/core/<concern>/` for app-wide primitives.

## Where to Add New Code

**New Feature:**
- Primary code: `lib/features/<feature>/` (add `*_screen.dart` and any feature-local widgets under `lib/features/<feature>/widgets/` when needed).
- Tests: `test/` (mirror feature name in path, for example `test/features_<feature>/...`).

**New Component/Module:**
- Implementation: `lib/shared/widgets/` (reusable UI) or `lib/core/` (app-wide primitives).

**New Service/Integration:**
- Implementation: `lib/services/<area>/` (create interface types alongside implementation when a noop/fake is needed, for example the `MarketDataSource` pattern in `lib/services/market/market_data_source.dart`).
- Wiring: add provider(s) in `lib/core/app/providers.dart` and override in `lib/main.dart` when runtime construction is required.

**New Local DB Table/DAO:**
- Table: `lib/core/database/tables/<name>.dart`
- DAO: `lib/core/database/daos/<name>_dao.dart`
- Registration: add to `@DriftDatabase` in `lib/core/database/app_database.dart` and bump `schemaVersion` there.

## Special Directories

**lib/gen/:**
- Purpose: Generated localization code.
- Generated: Yes.
- Committed: Yes.

**lib/core/database/*.g.dart and lib/core/database/daos/*.g.dart:**
- Purpose: Drift generated database and DAO mixins.
- Generated: Yes.
- Committed: Yes.

---

*Structure analysis: 2026-02-17*
