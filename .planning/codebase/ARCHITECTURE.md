# Architecture

**Analysis Date:** 2026-02-21

## Pattern Overview

**Overall:** Flutter app with feature-first UI modules, Riverpod-based dependency injection, and an offline-first local database (Drift) augmented by optional Supabase cloud services.

**Key Characteristics:**
- Offline-first persistence and UI rendering via Drift streams (`lib/core/database/app_database.dart`, `lib/core/database/daos/*.dart`).
- Explicit dependency injection at startup via Riverpod provider overrides (`lib/main.dart`, `lib/core/app/providers.dart`).
- Side-effects and integrations isolated into service modules (`lib/services/**`).

## Layers

**Presentation (screens + UI composition):**
- Purpose: Build the app UI and trigger user-driven actions.
- Location: `lib/features/**`, `lib/shared/widgets/**`.
- Contains: Screen widgets, dialogs, feature widgets.
- Depends on: Riverpod providers (`lib/core/app/providers.dart`), Drift DAOs (`lib/core/database/daos/*.dart`), services (`lib/services/**`).
- Used by: Navigation shell and route generator (`lib/core/navigation/app_nav_shell.dart`, `lib/main.dart`).

**State / Dependency Injection (composition root):**
- Purpose: Provide configured singletons and app-wide state streams.
- Location: `lib/core/app/providers.dart`.
- Contains: Providers for config, database, auth session, connectivity, feature flags, analytics, sync coordinator.
- Depends on: `supabase_flutter` auth/session (`lib/core/app/providers.dart`), `connectivity_plus` (`lib/core/app/providers.dart`).
- Used by: All feature widgets via `ref.watch(...)` / `ref.read(...)`.

**Persistence (local DB):**
- Purpose: Local source of truth for offline-first workflows.
- Location: `lib/core/database/**`.
- Contains: Drift `Table` definitions (`lib/core/database/tables/*.dart`), DAOs (`lib/core/database/daos/*.dart`), migrations (`lib/core/database/app_database.dart`).
- Depends on: Drift runtime (`drift`, `drift_flutter`) and filesystem (`path_provider`) (`lib/core/database/app_database.dart`).
- Used by: Features and services for reads/writes; also cloud sync dirty-marking (`lib/core/database/daos/scan_items_dao.dart`, `lib/core/database/daos/hauls_dao.dart`).

**Application Services (side effects + orchestration):**
- Purpose: Encapsulate integration logic (AI inference, market data, sync, privacy operations).
- Location: `lib/services/**`.
- Contains:
  - AI model management + inference isolate runtime (`lib/services/ai/**`).
  - Market data caching + fetch via Tradera proxy (`lib/services/market/**`).
  - Market background sync scheduler + cloud sync coordinator (`lib/services/sync/**`).
  - Privacy/export/delete operations (`lib/services/privacy/**`).
- Depends on: Drift, filesystem, HTTP, Supabase SDK.
- Used by: Features (e.g. scanner uses `ScanCaptureService`) and background entrypoints.

**Backend / Cloud (optional):**
- Purpose: Auth, metadata sync, photo storage, and Tradera SOAP proxy.
- Location: Supabase Edge Functions and migrations (`supabase/functions/**`, `supabase/migrations/**`).
- Contains: Edge function handlers (`supabase/functions/tradera-proxy/index.ts`, `supabase/functions/account-delete/index.ts`).
- Used by: App via `supabase_flutter` and HTTP (`lib/services/sync/cloud_metadata_sync_service.dart`, `lib/services/market/tradera_client.dart`).

## Data Flow

**App bootstrap + composition:**

1. App starts in `lib/main.dart` (`main()` -> `_bootstrapAndRun`).
2. Configuration is read from compile-time defines via `AppConfig.fromEnvironment()` (`lib/core/config/app_config.dart`).
3. Local DB is opened via `AppDatabase.open()` (`lib/core/database/app_database.dart`).
4. Optional Supabase SDK init runs when configured (`Supabase.initialize` in `lib/main.dart`).
5. Background market sync is registered via Workmanager (`lib/services/sync/background/background_sync.dart`).
6. Core dependencies are injected using Riverpod provider overrides in `ProviderScope` (`lib/main.dart`).
7. `MaterialApp` routes to onboarding/auth gates (`lib/main.dart`, `lib/features/onboarding/onboarding_gate.dart`, `lib/features/auth/auth_gate.dart`).

**Scan -> persist -> identify -> market sync (offline-first):**

1. User captures an image in `ScannerScreen` (`lib/features/scanner/scanner_screen.dart`).
2. `ScanCaptureService.persistCapturedImage(...)` saves the image and inserts a new `ScanItem` + `ScanItemPhoto` row (`lib/features/scanner/scan_capture_service.dart`).
3. Follow-up work is serialized via `SerialTaskQueue` (`lib/core/utils/serial_task_queue.dart`) to avoid CPU spikes.
4. Thumbnail generation completion updates DB paths and transitions the scan item status via `ScanItemsDao` (`lib/core/database/daos/scan_items_dao.dart`).
5. AI inference runs in a spawned isolate via `AiInferenceIsolateService` (`lib/services/ai/inference/inference_isolate_service.dart`) and is parsed/validated through `AiPipeline` (`lib/services/ai/inference/ai_pipeline.dart`).
6. On success, keywords and confidence are stored (`ScanItemsDao.setAiResult`) and status transitions to `pendingSync` (`lib/core/database/tables/scan_items.dart`, `lib/core/database/daos/scan_items_dao.dart`).
7. Market sync is executed on-demand or in background via `SyncScheduler.syncOnce()` (`lib/services/sync/sync_scheduler.dart`).
8. Market fetch uses `MarketBridge` cache -> `TraderaClient` -> Supabase Edge Function proxy (`lib/services/market/market_bridge.dart`, `lib/services/market/tradera_client.dart`, `supabase/functions/tradera-proxy/index.ts`).
9. Results are stored in comps/stats tables and the scan item status transitions to `complete` (`lib/services/sync/sync_scheduler.dart`, `lib/core/database/daos/scan_item_comps_dao.dart`).

**Cloud sync (optional Supabase):**

1. Cloud sync is coordinated by `CloudSyncCoordinator.syncIfNeeded(...)` (`lib/services/sync/cloud/cloud_sync_coordinator.dart`).
2. It triggers metadata upsert/pull (`lib/services/sync/cloud_metadata_sync_service.dart`) and photo storage upload/download (`lib/services/sync/cloud_photo_sync_service.dart`).
3. Local changes mark entities dirty in `PendingCloudSyncEntities` via DAO writes (`lib/core/database/daos/scan_items_dao.dart`, `lib/core/database/daos/hauls_dao.dart`).
4. Entity sync status is tracked in `EntitySyncStatuses` (`lib/core/database/tables/entity_sync_statuses.dart`, `lib/core/database/daos/entity_sync_statuses_dao.dart`).

**Background sync (market):**

1. Workmanager entrypoint `callbackDispatcher()` runs periodic task `market_sync` (`lib/services/sync/background/background_sync.dart`).
2. It opens a DB, builds `MarketBridge` + `SyncScheduler`, runs `syncOnce`, then closes DB.

## Key Abstractions

**Providers (DI + app state):**
- Purpose: Define app-wide dependencies and state streams.
- Examples: `lib/core/app/providers.dart`, overrides in `lib/main.dart`.
- Pattern: Provider override composition root; features read dependencies from `WidgetRef`.

**Local database access (DAOs):**
- Purpose: Centralize queries and mutations and mark cloud-dirty entities.
- Examples: `lib/core/database/daos/scan_items_dao.dart`, `lib/core/database/daos/hauls_dao.dart`.
- Pattern: Drift DAOs + `insertOnConflictUpdate`, `watch*()` streams for UI reactivity.

**Status state machine:**
- Purpose: Enforce valid scan item status transitions.
- Examples: `lib/core/database/scan_item_state_machine.dart`, `lib/core/database/tables/scan_items.dart`.
- Pattern: Transition guard called from DAO (`ScanItemsDao.transitionStatus`).

**Serial task queue:**
- Purpose: Serialize expensive operations and avoid resource spikes.
- Examples: `lib/core/utils/serial_task_queue.dart`, used by `lib/features/scanner/scan_capture_service.dart` and `lib/services/sync/cloud/cloud_sync_coordinator.dart`.

**Integration bridges:**
- Purpose: Isolate external API calls behind a domain interface.
- Examples: `lib/services/market/market_data_source.dart` + `lib/services/market/market_bridge.dart` + `lib/services/market/tradera_client.dart`.

**AI inference isolate boundary:**
- Purpose: Run model inference off the UI thread and parse validated JSON results.
- Examples: `lib/services/ai/inference/inference_isolate_service.dart`, `lib/services/ai/inference/ai_pipeline.dart`.

## Entry Points

**Flutter app runtime:**
- Location: `lib/main.dart`.
- Triggers: App start.
- Responsibilities: Initialize config/services, open DB, initialize optional Supabase and Sentry, inject dependencies, set up routing.

**Background sync dispatcher:**
- Location: `lib/services/sync/background/background_sync.dart`.
- Triggers: OS-scheduled periodic Workmanager execution.
- Responsibilities: Create minimal runtime (config + DB) and run `SyncScheduler.syncOnce()`.

**Supabase Edge Functions:**
- Tradera proxy: `supabase/functions/tradera-proxy/index.ts`.
- Account deletion: `supabase/functions/account-delete/index.ts`.
- Triggers: HTTPS invocation from the app (via Supabase client).

## Error Handling

**Strategy:** Best-effort operations that never block startup; errors are surfaced via UI banners/snackbars and persisted in sync-status tables where relevant.

**Patterns:**
- App-level fallback UI for widget build errors via `ErrorWidget.builder` (`lib/main.dart`).
- Try/catch around external I/O with safe fallbacks (e.g., `CloudSyncCoordinator` sets status to `failed` but continues) (`lib/services/sync/cloud/cloud_sync_coordinator.dart`).
- State machine enforcement throwing `StateError` on invalid transitions (`lib/core/database/daos/scan_items_dao.dart`).

## Cross-Cutting Concerns

**Logging/Analytics:**
- Approach: Breadcrumb-style analytics with optional Sentry implementation (`lib/services/analytics/analytics_service.dart`).

**Validation:**
- Approach: Input validation at boundaries (e.g., query sanitization in `ScanItemsDao.setAiResult` using `sanitizeKeywordQuery`) (`lib/core/text/keyword_query_sanitizer.dart`, `lib/core/database/daos/scan_items_dao.dart`).

**Authentication:**
- Approach: Optional Supabase auth; app supports guest scope when Supabase is not configured (`lib/features/auth/auth_gate.dart`, `lib/core/app/providers.dart`).

---

*Architecture analysis: 2026-02-21*
