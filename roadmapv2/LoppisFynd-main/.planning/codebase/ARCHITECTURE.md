# Architecture

**Analysis Date:** 2026-02-17

## Pattern Overview

**Overall:** Feature-first Flutter app with a shared `core/` platform layer, Drift-backed offline persistence, and a service layer for AI/market/cloud sync.

**Key Characteristics:**
- Offline-first persistence via Drift (`lib/core/database/app_database.dart`) with UI reading/writing via DAOs (for example `lib/core/database/daos/scan_items_dao.dart`).
- Dependency injection + reactive state via Riverpod providers (`lib/core/app/providers.dart`) overridden at bootstrap (`lib/main.dart`).
- Optional external integrations gated by compile-time config (`lib/core/config/app_config.dart`) and feature flags (`lib/core/config/feature_flags.dart`).

## Layers

**App Bootstrap / Composition Root:**
- Purpose: Initialize platform services and wire concrete implementations into DI.
- Location: `lib/main.dart`
- Contains: `AppDatabase.open()`, `Supabase.initialize(...)` (conditional), `BackgroundSync.initialize()` + scheduling, `MarketBridge` vs `NoopMarketDataSource`, `SyncScheduler`, `ModelManager`, `AiInferenceIsolateService`, and Riverpod `ProviderScope` overrides.
- Depends on: `lib/core/config/app_config.dart`, `lib/core/database/app_database.dart`, `lib/services/*`
- Used by: Entire app runtime.

**DI / State / App Signals (Riverpod):**
- Purpose: Provide app-wide dependencies and reactive signals (auth session, connectivity, settings).
- Location: `lib/core/app/providers.dart`
- Contains: Providers for DB/config/storage/AI/sync; `StreamProvider` for `onboardingCompleteProvider`, `highContrastEnabledProvider`, `authSessionProvider`, `isOnlineProvider`.
- Depends on: Drift DAOs, `connectivity_plus`, optional Supabase client.
- Used by: Screens (`lib/features/**`) and navigation shell (`lib/core/navigation/app_nav_shell.dart`).

**Navigation / Shell:**
- Purpose: Route entry, tab shell, and deep-link bridging.
- Location: `lib/main.dart`, `lib/core/navigation/app_nav_shell.dart`, `lib/core/navigation/spring_route.dart`
- Contains: `MaterialApp.onGenerateRoute` deep-link skeleton (`/home`, `/scan`, `/haul`, `/history`, `/profile`, `/item/<id>`), tab scaffold (`AppNavShell`), and animated route transitions (`SpringRoute`).
- Depends on: Feature screens (`lib/features/**`), providers (`lib/core/app/providers.dart`).
- Used by: `lib/features/auth/auth_gate.dart` (post-auth) and deep links (`lib/features/onboarding/deep_link_gate.dart`).

**Presentation (Feature Screens):**
- Purpose: UI + interaction logic per feature.
- Location: `lib/features/`
- Contains: Screens like `lib/features/scanner/scanner_screen.dart`, `lib/features/dashboard/dashboard_screen.dart`, `lib/features/history/history_screen.dart`, `lib/features/settings/settings_screen.dart`, `lib/features/analyzer/item_detail_screen.dart`.
- Depends on: Riverpod providers, Drift DAOs, and services (AI/sync).
- Used by: `lib/core/navigation/app_nav_shell.dart`.

**Persistence (Local DB):**
- Purpose: Local source of truth for hauls, scan items, settings, sync queues/status.
- Location: `lib/core/database/`
- Contains: Drift database (`lib/core/database/app_database.dart`), tables (`lib/core/database/tables/*.dart`), DAOs (`lib/core/database/daos/*.dart`), generated code (`lib/core/database/*.g.dart`).
- Depends on: Drift runtime.
- Used by: Features and services.

**Services (AI / Market / Sync / Privacy / etc.):**
- Purpose: Non-UI domain operations and external interactions.
- Location: `lib/services/`
- Contains:
  - AI: `lib/services/ai/model_manager.dart`, `lib/services/ai/inference/inference_isolate_service.dart`, `lib/services/ai/inference/ai_pipeline.dart`
  - Market: `lib/services/market/market_bridge.dart` implementing `lib/services/market/market_data_source.dart`
  - Market sync: `lib/services/sync/sync_scheduler.dart` and background runner `lib/services/sync/background/background_sync.dart`
  - Cloud sync: coordinator `lib/services/sync/cloud/cloud_sync_coordinator.dart` + metadata/photos services.
- Depends on: DB, config, optional Supabase.
- Used by: UI and background tasks.

**Local File Storage:**
- Purpose: Persist scan photos and thumbnails in app documents directory.
- Location: `lib/core/storage/scan_image_storage.dart`
- Contains: Image import + deferred thumbnail generation, orphan cleanup.
- Depends on: filesystem + `compute()` isolate for thumbnail work.
- Used by: `lib/features/scanner/scan_capture_service.dart`, cloud photo sync (`lib/services/sync/cloud_photo_sync_service.dart`).

## Data Flow

**Startup / Gating / Shell:**

1. `lib/main.dart` loads `AppConfig.fromEnvironment()` and starts Sentry if configured.
2. `lib/main.dart` opens `AppDatabase`, initializes optional Supabase, schedules background sync, builds concrete services, and runs `ProviderScope` overrides.
3. `MaterialApp` initial route builds `lib/features/onboarding/onboarding_gate.dart`.
4. `OnboardingGate` reads `onboardingCompleteProvider` and either shows `lib/features/onboarding/onboarding_screen.dart` or `lib/features/auth/auth_gate.dart`.
5. `AuthGate` chooses between `lib/core/navigation/app_nav_shell.dart` and `lib/features/auth/login_screen.dart` (when Supabase auth is enabled).

**Scan Capture -> Thumbnail -> AI -> Market Queue:**

1. User captures from `lib/features/scanner/scanner_screen.dart`.
2. `ScanCaptureService.persistCapturedImage(...)` (`lib/features/scanner/scan_capture_service.dart`) imports the image via `ScanImageStorage.importImageDeferred(...)` (`lib/core/storage/scan_image_storage.dart`).
3. The scan item + scan photo rows are inserted via Drift DAOs (`lib/core/database/daos/scan_items_dao.dart`, `lib/core/database/daos/scan_item_photos_dao.dart`).
4. Background queue generates thumbnail then writes thumb paths back to DB.
5. Best-effort AI runs via `AiInferenceIsolateService.run(...)` (`lib/services/ai/inference/inference_isolate_service.dart`) and parses via `AiPipeline` (`lib/services/ai/inference/ai_pipeline.dart`).
6. On successful inference, item fields are updated and status transitions to `ScanItemStatus.pendingSync` (`lib/core/database/tables/scan_items.dart`) to enter market sync.

**Market Sync (Online Price Comps):**

1. UI can trigger `SyncScheduler.syncOnce()` (`lib/services/sync/sync_scheduler.dart`) or background work runs it (`lib/services/sync/background/background_sync.dart`).
2. Scheduler selects pending items via `ScanItemsDao.listPendingMarketSync(...)` (`lib/core/database/daos/scan_items_dao.dart`).
3. Fetch uses `MarketDataSource.fetchComps(...)` (`lib/services/market/market_data_source.dart`) implemented by `MarketBridge` (`lib/services/market/market_bridge.dart`) or `NoopMarketDataSource` (`lib/services/market/market_data_source.dart`).
4. Results are cached (`lib/core/database/daos/market_stats_cache_dao.dart`) and stored per item (`lib/core/database/daos/scan_item_comps_dao.dart`, `lib/core/database/daos/scan_items_dao.dart`).
5. Status transitions are validated by `ScanItemStateMachine` (`lib/core/database/scan_item_state_machine.dart`) and backoff is tracked in `lib/core/database/daos/scan_item_sync_states_dao.dart`.

**Cloud Sync (Optional Supabase):**

1. `AppNavShell` listens for online/auth transitions (`lib/core/navigation/app_nav_shell.dart`) and calls `CloudSyncCoordinator.syncIfNeeded(...)` (`lib/services/sync/cloud/cloud_sync_coordinator.dart`).
2. Coordinator seeds dirty entities once per user via `CloudSyncSeedService.ensureSeeded(...)` (`lib/services/sync/cloud/cloud_sync_seed_service.dart`) into `PendingCloudSyncEntities` (`lib/core/database/tables/pending_cloud_sync_entities.dart`).
3. Metadata sync runs bidirectionally:
   - Push: `CloudMetadataSyncService.pushLocalToCloud()` (`lib/services/sync/cloud_metadata_sync_service.dart`) upserts rows into Supabase tables and clears dirty keys.
   - Pull: `CloudMetadataSyncService.pullCloudToLocal(...)` upserts into Drift via `*_Dao.upsertFromCloud(...)` and flags LWW conflicts via `isLwwConflict(...)` (`lib/services/sync/cloud/conflict_detector.dart`).
4. Photo sync runs bidirectionally via `CloudPhotoSyncService` (`lib/services/sync/cloud_photo_sync_service.dart`): upload dirty scan photos and download missing images into local storage.
5. Sync health is recorded in `EntitySyncStatuses` (`lib/core/database/tables/entity_sync_statuses.dart`) via `lib/core/database/daos/entity_sync_statuses_dao.dart`.

**State Management:**
- Riverpod is the primary DI/state mechanism (`lib/core/app/providers.dart`).
- Screens commonly combine `ref.watch(...)` for dependencies with Drift `StreamBuilder` from DAO watchers (for example `ScanItemsDao.watchByHaulId(...)` used in `lib/features/scanner/scanner_screen.dart`).

## Key Abstractions

**Database + DAOs (Drift):**
- Purpose: Local persistence + query/watch APIs.
- Examples: `lib/core/database/app_database.dart`, `lib/core/database/daos/scan_items_dao.dart`, `lib/core/database/tables/scan_items.dart`
- Pattern: Drift tables + DAOs, with generated mixins in `*.g.dart`.

**MarketDataSource:**
- Purpose: Fetch market price comps/stats with optional caching.
- Examples: `lib/services/market/market_data_source.dart`, `lib/services/market/market_bridge.dart`
- Pattern: Interface + concrete implementation + noop fallback.

**SyncScheduler:**
- Purpose: Serialize market sync runs, enforce quota/backoff, emit sync events.
- Examples: `lib/services/sync/sync_scheduler.dart`, `lib/services/sync/sync_events.dart`
- Pattern: Queue-based scheduler using `SerialTaskQueue` (`lib/core/utils/serial_task_queue.dart`).

**Cloud Sync Coordinator + Services:**
- Purpose: Orchestrate cloud sync and isolate concerns (metadata vs photos).
- Examples: `lib/services/sync/cloud/cloud_sync_coordinator.dart`, `lib/services/sync/cloud_metadata_sync_service.dart`, `lib/services/sync/cloud_photo_sync_service.dart`
- Pattern: Coordinator + bidirectional sync services + dirty-entity queue.

**AI Inference Pipeline:**
- Purpose: Run model inference off the UI thread and parse structured results.
- Examples: `lib/services/ai/inference/inference_isolate_service.dart`, `lib/services/ai/inference/ai_pipeline.dart`, `lib/services/ai/model_manager.dart`
- Pattern: Isolate execution + prompt selection + JSON extraction/parsing + confidence gating.

## Entry Points

**Main App Entry:**
- Location: `lib/main.dart`
- Triggers: App launch.
- Responsibilities: Bootstraps config, DB, optional Supabase, background sync scheduling, service wiring, and root widget creation.

**Background Task Entry:**
- Location: `lib/services/sync/background/background_sync.dart`
- Triggers: Workmanager periodic task `market_sync`.
- Responsibilities: Ensure Flutter bindings/plugins, open DB, construct market bridge + scheduler, run `SyncScheduler.syncOnce()`.

## Error Handling

**Strategy:** UI-safe fallbacks + best-effort background work + status/telemetry capture.

**Patterns:**
- Global widget error UI via `ErrorWidget.builder` (`lib/main.dart`).
- Optional Sentry initialization and guarded runner (`lib/main.dart`).
- Sync failures recorded into DB state: scan item status transitions (`lib/core/database/daos/scan_items_dao.dart`) and cloud sync entity statuses (`lib/core/database/daos/entity_sync_statuses_dao.dart`).

## Cross-Cutting Concerns

**Logging:** Sentry (when configured) and targeted try/catch around background/IO paths (`lib/main.dart`, `lib/services/sync/background/background_sync.dart`).
**Validation:** Scan item status transitions enforced by `ScanItemStateMachine` (`lib/core/database/scan_item_state_machine.dart`); query sanitization via `lib/core/text/keyword_query_sanitizer.dart`.
**Authentication:** Supabase auth session gated in `lib/features/auth/auth_gate.dart` and exposed to app via `authSessionProvider` (`lib/core/app/providers.dart`).

---

*Architecture analysis: 2026-02-17*
