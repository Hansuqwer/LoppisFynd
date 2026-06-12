# Architecture Analysis — LoppisFynd
_Generated 2026-06-12. 189 .dart files checked._

---

## DEAD CODE — files/classes/providers never referenced

### Completely Unreferenced Files (safe to delete)

| File | Defined Symbol | Evidence |
|------|---------------|---------|
| `lib/core/app/app_scope.dart` | `AppScope` (InheritedWidget) | Zero imports. Superseded by Riverpod `ProviderScope`. Never placed in widget tree. |
| `lib/features/auth/email_masking.dart` | `maskEmailForUi()` | Zero imports. Function never called anywhere. |
| `lib/features/analyzer/flip_factor.dart` | `FlipFactor` | Zero imports. `FlipFactor.grade()` never called. Concept reimplemented inline in 3 other files. |
| `lib/services/sync/cloud_photo_paths.dart` | `CloudPhotoPaths` | Zero imports. `imagePath()`/`thumbPath()` never called. |

### Unused DAOs (registered in DB, never called)

| DAO | File | Issue |
|-----|------|-------|
| `BookMarketDataDao` | `lib/core/database/daos/book_market_data_dao.dart` | Registered in `AppDatabase`, accessor `bookMarketDataDao` exists in generated code — but **no service or screen ever calls it**. `BookMarketData` table exists in the schema but is completely orphaned at runtime. |
| `PriceButtonConfigDao` | `lib/core/database/daos/price_button_config_dao.dart` | Same: registered, generated, never called. |

### Dead Providers (defined in providers.dart, never watched/read)

| Provider | Line | Issue |
|----------|------|-------|
| `appStartAtProvider` | `providers.dart:322` | Never consumed outside `providers.dart`. |
| `startupMetricsReportedProvider` | `providers.dart:331` | Never consumed. `StartupMetricsReportedNotifier` class is dead. |
| `offlineDetectorProvider` | `providers.dart:293` | Explicit stub returning `null`. Phase-4 placeholder. Never consumed. |
| `offlineIdentificationEnabledProvider` | `providers.dart:286` | Reads DB setting but nothing acts on the result. Entire offline-identification feature path is stubbed to nothing. |

### Dead Screen Classes

| Class | File | Reason |
|-------|------|--------|
| `LicenseTextScreen` | `lib/features/settings/legal_screen.dart:58` | Defined in same file as `LegalScreen`. Zero `Navigator.push` references anywhere. |

---

## BROKEN WIRING — services/features defined but not connected end-to-end

| Issue | Location | Detail |
|-------|----------|--------|
| `SyncScheduler.events` stream never consumed | `lib/services/sync/sync_scheduler.dart:38` | `_events` `StreamController` written to on all sync events (`SyncRunStarted`, `SyncRunFinished`, `ScanItemSynced`, etc.) but `.events` is never listened to by any provider, widget, or service. Dead broadcast stream. |
| `bookMarketDataDao` orphaned | `lib/core/database/daos/book_market_data_dao.dart` | Table in schema, DAO complete, never called — any data written would be unreadable by the app. |
| `priceButtonConfigDao` orphaned | `lib/core/database/daos/price_button_config_dao.dart` | Same. |
| Offline-identification feature entirely stubbed | `providers.dart:286–296` | `offlineIdentificationEnabledProvider` reads a DB setting, `offlineDetectorProvider` returns `null`. No service switches behaviour based on either. The complete offline-AI identification flow is scaffolded but unconnected. |
| Duplicate `FeatureFlags` instances | `main.dart:127` + `providers.dart:310` | `FeatureFlags.fromEnvironment()` is instantiated twice — once in `_bootstrapAndRun` (passed to `SyncScheduler`) and once in `featureFlagsProvider`. Two separate objects with the same compile-time values. Should be one singleton. |

---

## LAYER VIOLATIONS — imports going wrong direction

Architecture rule: `presentation → application → domain`. Infrastructure implements domain. `core/` must not depend on `features/`.

### Critical Upward Imports (core/services → features)

| File | Line | Import | Violation |
|------|------|--------|-----------|
| `lib/core/app/providers.dart` | L10 | `features/scanner/barcode/mlkit_book_isbn_adapter.dart` | **core → features**. `MlKitBookIsbnAdapter` should live in `services/` or `core/`, not `features/`. |
| `lib/services/books/book_scanner_isbn_handoff_coordinator.dart` | L1 | `features/scanner/barcode/mlkit_book_isbn_adapter.dart` | **services → features**. Same adapter problem. |
| `lib/services/books/book_barcode_isbn_handoff_service.dart` | L1 | `features/scanner/isbn/validated_book_isbn.dart` | **services → features**. `ValidatedBookIsbn` lives in a feature sub-folder but is used by a service. |
| `lib/core/database/daos/scan_items_dao.dart` | L6 | `services/sync/cloud/entity_keys.dart` | **core/database → services**. `entity_keys.dart` should be in `core/`. |
| `lib/core/database/daos/hauls_dao.dart` | L5 | `services/sync/cloud/entity_keys.dart` | Same. |
| `lib/core/navigation/app_nav_shell.dart` | L8–15 | imports all top-level `features/` screens | **core/navigation → features**. Shell's job, but architecturally core should not depend upward on features. |

### Moderate Violations (feature screen → service/sync direct import, bypassing provider)

| File | Line | Import | Issue |
|------|------|--------|-------|
| `lib/features/drafts/draft_editor_screen.dart` | L12 | `services/books/book_isbn_draft_flow_controller.dart` | Screen imports service directly. Should access through provider. |
| `lib/features/scanner/scanner_screen.dart` | L22 | `services/books/book_isbn_draft_flow_controller.dart` | Same. |
| `lib/features/scanner/scanner_screen.dart` | L21 | `services/sync/cloud/entity_keys.dart` | Screen importing sync utility. |
| `lib/features/history/history_screen.dart` | L18 | `services/sync/cloud/entity_keys.dart` | Same. |
| `lib/features/summary/haul_summary_screen.dart` | L15 | `services/sync/cloud/entity_keys.dart` | Same. |
| `lib/features/settings/settings_screen.dart` | L13 | `services/sync/background/background_sync.dart` | Screen calls `BackgroundSync.scheduleIfConfigured` directly. Should be via provider/service. |
| `lib/features/scanner/barcode/scanner_book_isbn_handoff_controller.dart` | L1–2 | two `services/` imports | Feature-layer class directly imports services. |
| `lib/features/scanner/barcode/scanner_book_isbn_handoff_feedback.dart` | L2 | `services/books/book_isbn_draft_flow_controller.dart` | Same. |

### DB Table Direct Imports from Features (bypasses DAO abstraction)

| File | Import |
|------|--------|
| `lib/features/hauls/haul_screen.dart:7` | `core/database/tables/scan_items.dart` — imports `ScanItemStatus` enum |
| `lib/features/scanner/widgets/batch_tray.dart:6` | Same |
| `lib/features/analyzer/widgets/market_stats_widget.dart:6` | Same |
| `lib/features/summary/haul_summary_screen.dart:6` | Same |

---

## DUPLICATE IMPLEMENTATIONS — same concept coded multiple times

| Concept | Impl 1 | Impl 2 | Impl 3 | Issue |
|---------|--------|--------|--------|-------|
| Score/verdict (0–100) | `finds_screen.dart:211` | `item_detail_screen.dart:232` | `haul_screen.dart:512` (simplified) | Same thresholds, identical logic, 3 separate inline functions. `FlipFactor` in dead `flip_factor.dart` was meant to centralise this. |
| Profit calculation | `ProfitCalculator.netProfit()` in `profit_calculator.dart` (10% fee default) | `item_detail_screen.dart:77` hardcoded `* 0.12` | — | Different fee rates (10% vs 12%). Different results for the same concept. |
| `_formatSek()` helper | `dashboard_screen.dart:215` | `haul_screen.dart:108` | — | Identical function, copy-pasted. |
| `FeatureFlags.fromEnvironment()` | `main.dart:127` | `providers.dart:310` | — | Two object instances with identical compile-time values. |
| `CloudMetadataSyncService` instantiation | `settings_providers.dart:47` (inline new) | `cloud_sync_coordinator.dart:46` (inline new) | — | Two direct `new` instead of a shared provider. |

---

## ORPHAN SCREENS — screens not navigated to from anywhere

| Screen | File | Evidence |
|--------|------|---------|
| `HaulScreen` | `lib/features/hauls/haul_screen.dart` | Zero imports or `Navigator.push` references outside its own file. Replaced by `DashboardScreen` + `HaulSummaryScreen`. |
| `FindsScreen` | `lib/features/books/finds_screen.dart` | Zero navigation references outside its own file. Replaced UI concept. |
| `LicenseTextScreen` | `lib/features/settings/legal_screen.dart:58` | Defined but never navigated to. Only `LegalScreen` is reachable. |

---

## MISSING IMPLEMENTATIONS — abstract classes with no concrete impl

**None found.** All abstract classes/interfaces have concrete implementations that are wired in providers:

| Abstract | Concrete Impls |
|----------|---------------|
| `BookMetadataLookup` | `IsbnLookupService`, `QaStableIsbnLookupService` |
| `BookMarketStatsLookup` | `BookMarketService`, `AggregatedBookMarketService` |
| `BookMarketSource` | 5 sources (Tradera, Vinted, Bokborsen, Adlibris, Blocket) |
| `MarketDataSource` | `MarketBridge`, `NoopMarketDataSource` |
| `AnalyticsService` | `SentryAnalyticsService`, `NoopAnalyticsService` |
| `EmailOtpAuthApi` | `SupabaseEmailOtpAuthApi` |

---

## NON-LOCALISED STRINGS (violates AGENTS.md)

User-facing strings hardcoded in Swedish, not in ARB files:

| File | Strings |
|------|---------|
| `lib/features/analyzer/item_detail_screen.dart` | `'Ditt loppispris'`, `'Justera för exakt vinst'`, `'Nettovinst'`, `'ROI'`, `'Säljtid'`, `'Marknadspris'`, `'Senast sålda'`, `'snittpris'`, `'Lägst ${...} kr'`, `'Högst ${...} kr'`, `'Tillagd i lager'` — 11 strings |
| `lib/features/hauls/haul_screen.dart` | `'dina fyndresor'`, `'Pågående runda'`, `'Spenderat'`, `'Snitt/bok'`, `'Marginal'`, `'kr proj.'`, `'böcker'` — 7 strings |
| `lib/features/books/finds_screen.dart` | `'värt att leta efter'`, `'Snitt ${median.round()} kr'` — 2 strings |
| `lib/dashboard/dashboard_screen.dart` | `'loppisfynd'` — 1 string |

---

## UNUSED ARB KEYS (~98 keys, ~21% of total)

Key groups defined in both `app_en.arb` and `app_sv.arb` but never referenced in any `.dart` file:

| Group | Keys | Reason Unused |
|-------|------|---------------|
| Offline AI / model settings | `settingsAiTitle`, `settingsAiModeLabel`, `settingsAiEco`, `settingsAiQuality`, `settingsAiModeSaved`, `settingsModuleAiModelTitle`, `settingsOfflineIdentification*` (6), `settingsOfflineDownload*` (6), `settingsOfflineAttribution*` (3) — 17 keys | Feature not built |
| Photo sync | `settingsSyncPhotos`, `settingsPhotoSyncCompleted`, `settingsPhotoSyncFailed` — 3 keys | Feature not implemented |
| Location/geolocation | `historyLocation*` — 7 keys | GPS haul naming not built |
| Dashboard tiles (old design) | `homeTile*`, `homeHero*` — 7 keys | Old dashboard replaced |
| Draft editor (old fields) | `draftEditorAskingPriceHint`, `draftEditorDescriptionLabel`, and 6 others — 8 keys | Replaced by current impl |
| Offline identify screen | `offlineIdentify*` except 2 used keys — 7 keys | Screen exists, keys unused |
| Tab label | `tabHaul` — 1 key | `HaulScreen` is orphaned |
| Old login flows | `loginSignIn`, `loginSignUp`, `loginTagline`, `loginTitle`, `loginAccountCreated`, `loginCodeLabel`, `loginForgotPassword`, `loginVerifyCode` — 8 keys | `LoginScreen` uses different key names |
| Misc | `authError`, `commonCopied`, `commonInstall`, `haulExpected`, `haulSubtitle`, `haulTotalValue`, `legalCopySourceUrl`, `legalViewFullLicenseText`, `scannerBokFyndReturnToDraft`, `scannerNoCamerasAvailable`, `settingsAdlibris*`, `settingsSyncStatusTitle/Subtitle` — ~20 keys | Various unused |

---

## SUMMARY

| Metric | Count |
|--------|-------|
| Total `.dart` files checked | 189 |
| Dead code files (safe to delete) | 4 |
| Dead code classes (in used files) | 2 |
| Unused DAOs | 2 |
| Dead providers | 4 |
| Orphan screens | 3 |
| Layer violations (critical) | 6 |
| Layer violations (moderate) | 8 |
| Duplicate implementations | 5 |
| Missing abstract implementations | 0 |
| Broken wiring | 5 |
| Hardcoded non-localised strings | ~21 |
| Unused ARB keys | ~98 (~21% of all keys) |

---

## PRIORITY ACTION LIST

### P0 — Correctness (causes bugs)
1. `entity_keys.dart` → move from `services/sync/cloud/` to `core/` so DAOs don't import upward into services
2. `MlKitBookIsbnAdapter` + `ValidatedBookIsbn` → move from `features/scanner/` to `services/books/` or `core/` to fix core/services → features violations
3. Unify `FeatureFlags` to a single instance via `featureFlagsProvider`; pass it to `SyncScheduler` from the provider
4. Fix profit calculation constant mismatch: `ProfitCalculator` uses 10%, `item_detail_screen` hardcodes 12%

### P1 — Architecture (causes coupling debt)
5. Extract score algorithm (0–100 flip factor) to `services/` or `domain/`, delete 3 inline duplicates and `flip_factor.dart`
6. Extract `_formatSek()` to a shared formatting utility
7. Merge `CloudMetadataSyncService` instantiations into a single provider
8. Wire `settings_screen.dart` background sync call through a provider instead of direct import

### P2 — Cleanup (dead code removal)
9. Delete `app_scope.dart`, `email_masking.dart`, `flip_factor.dart`, `cloud_photo_paths.dart`
10. Delete or wire `BookMarketDataDao` and `PriceButtonConfigDao` (either remove from DB schema or implement the calling layer)
11. Delete or wire `appStartAtProvider`, `startupMetricsReportedProvider`, `offlineDetectorProvider`, `offlineIdentificationEnabledProvider`
12. Delete `HaulScreen`, `FindsScreen`, `LicenseTextScreen` or restore navigation to them
13. Delete `SyncScheduler.events` stream machinery or wire it to a consumer

### P3 — Compliance (violates AGENTS.md)
14. Add ~21 hardcoded Swedish strings to both ARB files (`item_detail_screen`, `haul_screen`, `finds_screen`, `dashboard_screen`)
15. Purge ~98 unused ARB keys across both locale files (or implement the planned features)
