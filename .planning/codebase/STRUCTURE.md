# Codebase Structure

**Analysis Date:** 2026-02-21

## Directory Layout

```
[project-root]/
├── lib/                      # Flutter application code
│   ├── core/                 # App-wide infrastructure (config, DB, navigation, theme)
│   ├── features/             # Feature-first screens and feature widgets
│   ├── services/             # Side-effect and integration services
│   ├── shared/               # Reusable UI widgets/painters shared across features
│   ├── gen/                  # Generated localization output
│   └── l10n/                 # ARB source files for localization
├── supabase/                 # Supabase backend (Edge Functions + migrations)
├── test/                     # Widget/unit tests and golden tests
├── Assets/                   # Bundled images, textures, and fonts
├── packages/                 # Local Dart packages (custom lints)
├── android/                  # Android host project
├── ios/                      # iOS host project
├── docs/                     # Product/design docs and research
├── .planning/                # Generated planning artifacts (this mapping)
└── pubspec.yaml              # Flutter package manifest
```

## Directory Purposes

**`lib/core/`:**
- Purpose: Infrastructure shared across features.
- Contains: Provider definitions (`lib/core/app/providers.dart`), app config (`lib/core/config/app_config.dart`), navigation shell (`lib/core/navigation/app_nav_shell.dart`), Drift database (`lib/core/database/**`), UI tokens/theme (`lib/core/tokens/**`, `lib/core/theme/app_theme.dart`).
- Key files: `lib/core/app/providers.dart`, `lib/core/database/app_database.dart`, `lib/core/navigation/app_nav_shell.dart`.

**`lib/features/`:**
- Purpose: Feature-first UI modules.
- Contains: Screen widgets and per-feature helpers.
- Key files: `lib/features/scanner/scanner_screen.dart`, `lib/features/analyzer/item_detail_screen.dart`, `lib/features/settings/settings_screen.dart`.

**`lib/services/`:**
- Purpose: Integration/service layer and orchestration.
- Contains:
  - AI: `lib/services/ai/**`
  - Market: `lib/services/market/**`
  - Sync: `lib/services/sync/**` (background + cloud)
  - Privacy: `lib/services/privacy/**`
  - Analytics: `lib/services/analytics/analytics_service.dart`
- Key files: `lib/services/sync/sync_scheduler.dart`, `lib/services/sync/cloud/cloud_sync_coordinator.dart`.

**`lib/shared/`:**
- Purpose: Shared presentation utilities.
- Contains: Reusable widgets (`lib/shared/widgets/**`) and painters (`lib/shared/painters/**`).
- Key files: `lib/shared/widgets/bento_card.dart`, `lib/shared/widgets/capsule_nav_bar.dart`.

**`lib/gen/` and `lib/l10n/`:**
- Purpose: Localization.
- Contains: Generated localization output (`lib/gen/app_localizations*.dart`) and ARB inputs (`lib/l10n/app_sv.arb`, `lib/l10n/app_en.arb`).

**`supabase/`:**
- Purpose: Backend infra for Supabase.
- Contains: Edge Functions (`supabase/functions/**`), migrations (`supabase/migrations/**`), config (`supabase/config.toml`).
- Key files: `supabase/functions/tradera-proxy/index.ts`, `supabase/functions/account-delete/index.ts`.

**`test/`:**
- Purpose: Automated tests (unit/widget/golden).
- Contains: Golden baselines under `test/goldens/` and test suites with descriptive filenames (e.g. `test/fl_070_offline_core_screens_smoke_test.dart`).

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap, dependency injection, routing.
- `lib/services/sync/background/background_sync.dart`: Workmanager callback dispatcher for periodic market sync.
- `supabase/functions/tradera-proxy/index.ts`: Tradera SOAP proxy Edge Function.
- `supabase/functions/account-delete/index.ts`: Account deletion Edge Function.

**Configuration:**
- `pubspec.yaml`: Dependencies and bundled assets.
- `analysis_options.yaml`: Analyzer/lint configuration.
- `l10n.yaml`: Flutter localization generation config.
- `lib/core/config/app_config.dart`: Compile-time environment keys and feature gating.

**Core Logic:**
- `lib/core/database/app_database.dart`: Drift schema + migrations.
- `lib/core/database/tables/*.dart`: Drift tables.
- `lib/core/database/daos/*.dart`: Queries/mutations.
- `lib/services/sync/sync_scheduler.dart`: Market sync loop and quota/backoff.
- `lib/services/sync/cloud_metadata_sync_service.dart`: Cloud metadata bidirectional sync.
- `lib/services/sync/cloud_photo_sync_service.dart`: Cloud photo upload/download.
- `lib/services/ai/inference/inference_isolate_service.dart`: Isolate-based AI inference.

**Testing:**
- `test/`: All tests.
- `test/goldens/`: Golden image baselines.

## Naming Conventions

**Files:**
- Dart files: `snake_case.dart` (e.g. `lib/services/sync/sync_scheduler.dart`).
- Generated Dart: `*.g.dart` for Drift/build_runner output (e.g. `lib/core/database/app_database.g.dart`, `lib/core/database/daos/scan_items_dao.g.dart`).
- Supabase functions: kebab-case directories with `index.ts` entry (e.g. `supabase/functions/tradera-proxy/index.ts`).

**Directories:**
- Feature modules under `lib/features/<feature>/` (e.g. `lib/features/scanner/`).
- Service domains under `lib/services/<domain>/` (e.g. `lib/services/market/`).

## Where to Add New Code

**New Feature:**
- Primary UI: add a new module under `lib/features/<feature>/`.
- Shared widgets: add to `lib/shared/widgets/` when reused across multiple features.
- DB support (new persisted entity): add a table in `lib/core/database/tables/` and DAO in `lib/core/database/daos/`, then register in `lib/core/database/app_database.dart`.
- Wiring (DI): add a provider in `lib/core/app/providers.dart` and override it in `lib/main.dart` if it requires runtime construction.

**New Screen reachable from tabs:**
- Add a tab destination or route in `lib/core/navigation/app_nav_shell.dart`.
- Add deep-link mapping in `lib/main.dart` if it must be addressable via routes.

**New External Integration:**
- Add an integration service under `lib/services/<domain>/`.
- Keep UI thin: trigger service methods from `lib/features/**` using providers from `lib/core/app/providers.dart`.

## Special Directories

**`lib/gen/`:**
- Purpose: Generated code.
- Generated: Yes.
- Committed: Yes (present in repo).

**`supabase/migrations/`:**
- Purpose: Database schema evolution for Supabase.
- Generated: Not detected (authored SQL migrations).
- Committed: Yes.

---

*Structure analysis: 2026-02-21*
