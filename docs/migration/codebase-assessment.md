# Bokfynd Migration — Codebase Assessment

**Date:** 2026-04-29  
**Status:** Phase 3 — Read-only analysis  
**Scope:** LoppisFynd → Bokfynd migration planning  
**Baseline:** 5,416 analyzer issues (docs/baseline/baseline-analyze.txt)

> **Important:** No code changes should be made until the Week 1 validation sprint passes (see docs/migration/MIGRATION_PLAN.md Phase 4).

---

## 1. Current Architecture Map

### Codebase Size

| Layer | Files | Approx. Lines |
|-------|-------|----------------|
| `lib/features/` | 40 | ~35,000 |
| `lib/services/` | 46 | ~18,000 |
| `lib/core/` | 51 | ~8,000 |
| `lib/shared/` | ~8 | ~2,000 |
| `lib/gen/` | 3 | ~5,000 generated |
| **Total** | **~155** | **~68,000** |

### Feature Modules (`lib/features/`)

| Feature | Files | Key Screens | Notes |
|---------|-------|-------------|-------|
| `scanner/` | 10 | `scanner_screen.dart` (27k lines) | Already has barcode + ISBN subdirs |
| `analyzer/` | 3 | `item_detail_screen.dart` (50k lines!) | Heaviest screen — AI result viewer |
| `settings/` | 6 | `settings_screen.dart` (33k lines) | Sync status, privacy, account deletion |
| `drafts/` | 2 | `draft_editor_screen.dart` (31k lines) | Listing draft editor |
| `history/` | 3 | `history_screen.dart` (33k lines) | Scan history browser |
| `summary/` | 1 | `haul_summary_screen.dart` (39k lines) | Haul summary with charts |
| `auth/` | 5 | `login_screen.dart` (26k lines) | Email OTP auth |
| `dashboard/` | 1 | `dashboard_screen.dart` (14k lines) | Home screen |
| `hauls/` | 1 | `haul_screen.dart` (12k lines) | Haul management |
| `onboarding/` | 3 | `onboarding_screen.dart` (11k lines) | First-run flow |
| `offline_detection/` | 2 | `offline_detection_screen.dart` (17k lines) | Model download UI |

### Service Layer (`lib/services/`)

| Service | Files | Lines | Purpose |
|---------|-------|-------|---------|
| `ai/` | 10 | ~1,550 | TFLite inference, model manager, cloud AI proxy |
| `ai/inference/` | 7 | — | Isolate service, JSON parsing, pipeline |
| `books/` | 12 | ~3,000 | **Already partially migrated** — ISBN lookup, market data, draft flow |
| `market/` | 6 | ~1,800 | Tradera client + proxy models, market math |
| `offline_detection/` | 6 | ~1,140 | On-device object detection, model catalog |
| `sync/` | 7+ | ~2,300 | Cloud sync coordinator, background sync, photo sync |
| `privacy/` | 3 | ~600 | Data export, local/cloud deletion |
| `analytics/` | 1 | ~150 | Sentry wrapper |
| `notifications/` | 1 | ~200 | Local notification helpers |
| `location/` | 2 | ~200 | Geocoding cache |

### Core Infrastructure (`lib/core/`)

| Module | Purpose |
|--------|---------|
| `database/` | Drift schema (11 tables, schema v15), 11 DAOs |
| `app/providers.dart` | 253-line Riverpod DI root — composition root |
| `app/app_scope.dart` | App bootstrap and initialization |
| `config/app_config.dart` | Compile-time env config |
| `config/feature_flags.dart` | Feature flag constants |
| `navigation/` | Custom router, spring route transitions |
| `storage/scan_image_storage.dart` | Local image file management |
| `theme/`, `tokens/` | Design system (colors, spacing, typography, motion) |
| `settings/` | Persistent settings key constants |

### Database Schema (v15 — 11 tables)

| Table | Purpose | Bokfynd fate |
|-------|---------|--------------|
| `scan_items` | Core scan record (AI fields, image paths, status) | ❌ Replace with `books` |
| `scan_item_photos` | Photo paths per scan item | ❌ Remove (no photos in Bokfynd) |
| `scan_item_comps` | Market comparables per scan item | 🔄 Repurpose as `book_market_data` |
| `scan_item_sync_states` | Per-item cloud sync state | 🔄 Rename to `book_sync_states` |
| `hauls` | Grouping container for scan sessions | 🔄 Keep — maps well to "scanning trip" |
| `market_stats_cache` | Cached market stats per item | 🔄 Keep — rename columns for books |
| `entity_sync_statuses` | Aggregate sync health per entity type | ✅ Keep as-is |
| `sync_quotas` | Sync rate limiting | ✅ Keep as-is |
| `pending_cloud_sync_entities` | Queue for cloud sync | ✅ Keep as-is |
| `app_settings` | Key-value settings store | ✅ Keep as-is |
| `draft_listings` | Listing draft state | 🔄 Repurpose for book listing drafts |

### Edge Functions (`supabase/functions/`)

| Function | Purpose | Bokfynd fate |
|----------|---------|--------------|
| `tradera-proxy/` | Proxy Tradera API calls with auth | ✅ Keep — central to market data |
| `cloud-ai-proxy/` | Proxy cloud AI inference | ❌ Remove — no AI in Bokfynd |
| `account-delete/` | GDPR account deletion | ✅ Keep — legal requirement |

---

## 2. Component Classification

### ✅ Keep As-Is

| Component | Path | Rationale |
|-----------|------|-----------|
| Drift + SQLite setup | `lib/core/database/app_database.dart` | Core persistence layer, just add new tables |
| Riverpod DI root | `lib/core/app/providers.dart` | Add/remove providers, keep structure |
| App config | `lib/core/config/app_config.dart` | Add `googleBooksApiKey`, `apifyApiToken` |
| Feature flags | `lib/core/config/feature_flags.dart` | Add ISBN/book flags |
| Navigation | `lib/core/navigation/` | No changes needed |
| Design tokens | `lib/core/tokens/`, `lib/core/theme/` | Reuse entirely |
| Analytics | `lib/services/analytics/` | Sentry — no changes |
| Auth feature | `lib/features/auth/` | Login/logout unchanged |
| Onboarding | `lib/features/onboarding/` | Update copy only |
| Settings | `lib/features/settings/` | Minor updates (remove AI section) |
| Sync services | `lib/services/sync/` | Keep for cloud sync of book inventory |
| Privacy services | `lib/services/privacy/` | GDPR compliance — keep as-is |
| Notifications | `lib/services/notifications/` | Keep as-is |
| Tradera proxy (edge fn) | `supabase/functions/tradera-proxy/` | Core market data source |
| Account-delete (edge fn) | `supabase/functions/account-delete/` | Legal requirement |
| Market math | `lib/services/market/market_math.dart` | Price calculations reusable |
| Tradera client | `lib/services/market/tradera_client.dart` | Keep — adapt for ISBN search |

### 🔄 Refactor

| Component | Path | Required Changes |
|-----------|------|-----------------|
| Scanner feature | `lib/features/scanner/` | Remove photo capture flow; scanner_screen.dart already integrates barcode scanning — strip AI trigger, wire to ISBN flow |
| Analyzer/Detail screen | `lib/features/analyzer/item_detail_screen.dart` | Rebuild as `BookDetailScreen` — show book metadata + market data instead of AI results |
| Dashboard | `lib/features/dashboard/dashboard_screen.dart` | Replace scan item list with book inventory list |
| Haul screen | `lib/features/hauls/haul_screen.dart` | Rename "haul" to "scanning trip" conceptually; keep grouping logic |
| History screen | `lib/features/history/history_screen.dart` | Filter by book properties (ISBN, author) instead of AI category |
| Summary screen | `lib/features/summary/haul_summary_screen.dart` | Update charts for book profit metrics |
| Draft editor | `lib/features/drafts/draft_editor_screen.dart` | Simplify for book listing (title, ISBN, price) |
| Market service | `lib/services/market/market_bridge.dart` | Extend for multi-platform aggregation (Apify, Bokbörsen) |
| Market models | `lib/services/market/market_models.dart` | Add `BookSale`, `BookMarketStats` models |
| Profit calculator | `lib/features/analyzer/profit_calculator.dart` | Already platform-agnostic — wire to book pricing |
| App config | `lib/core/config/app_config.dart` | Add `googleBooksApiKey`, `apifyApiToken` fields |
| Database schema | `lib/core/database/` | Migration v15→v16: add `books`, `book_market_data` tables |

### ❌ Remove

| Component | Path | Lines | Reason |
|-----------|------|-------|--------|
| AI inference service | `lib/services/ai/inference/` | ~700 | No AI in Bokfynd |
| AI model manager | `lib/services/ai/model_manager.dart` | ~230 | No model downloads |
| Image cropper | `lib/services/ai/image_cropper.dart` | ~80 | No image processing |
| Cloud AI proxy client | `lib/services/ai/cloud_ai_proxy_client.dart` | ~80 | No cloud AI |
| Offline detection service | `lib/services/offline_detection/` | ~1,140 | TFLite object detection |
| Offline detection feature | `lib/features/offline_detection/` | ~600 | Model download UI |
| Scan capture service | `lib/features/scanner/scan_capture_service.dart` | ~200 | Camera photo capture |
| Scan image storage | `lib/core/storage/scan_image_storage.dart` | ~150 | No image storage |
| Cloud AI proxy (edge fn) | `supabase/functions/cloud-ai-proxy/` | — | No AI backend |
| `tflite_flutter` dep | `pubspec.yaml` | — | ~15MB binary asset reduction |
| `camera` dep | `pubspec.yaml` | — | Large native plugin |
| Location service | `lib/services/location/` | ~200 | Not needed for books |
| `geocoding` + `geolocator` deps | `pubspec.yaml` | — | Location not needed |
| `image` dep | `pubspec.yaml` | — | Only used for image processing |
| Scan item state machine | `lib/core/database/scan_item_state_machine.dart` | — | Replaced by simpler book states |

**Total removable code: ~3,400 lines across ~25 files**  
**Dependencies removed: tflite_flutter, camera, geocoding, geolocator, image** (significant APK/IPA size reduction)

### ➕ Add (New for Bokfynd)

| Component | Path | Notes |
|-----------|------|-------|
| ISBN lookup service | `lib/services/books/isbn_lookup_service.dart` | **Already exists!** Google Books + Open Library |
| Book market service | `lib/services/books/book_market_service.dart` | **Already exists!** Tradera adapter |
| Book market data service | `lib/services/books/book_market_data_service.dart` | **Already exists!** Aggregation layer |
| ISBN validator | `lib/features/scanner/isbn/isbn_validator.dart` | **Already exists!** ISBN-10/13 validation |
| MLKit ISBN adapter | `lib/features/scanner/barcode/mlkit_book_isbn_adapter.dart` | **Already exists!** |
| Apify/Vinted service | `lib/services/market/vinted_apify_service.dart` | New — requires Apify API token |
| Books database table | `lib/core/database/tables/books.dart` | New — ISBN, metadata, purchase price |
| Book market data table | `lib/core/database/tables/book_market_data.dart` | New — per-sale records |
| Book detail screen | `lib/features/analyzer/book_detail_screen.dart` | Replaces item_detail_screen |
| Book inventory screen | `lib/features/dashboard/book_inventory_screen.dart` | Browse owned books |

> **Key finding:** The `lib/services/books/` directory (12 files, ~3,000 lines) was already scaffolded on 2026-04-28 — ISBN lookup, barcode handoff, draft flow, and market data services are already in place. This significantly reduces the migration effort.

---

## 3. Dependency Graph

### Service-to-Service Dependencies

```
providers.dart (DI root)
├── isbnLookupServiceProvider
│   └── IsbnLookupService → [Google Books API, Open Library API]
│       OR QaStableIsbnLookupService (dev/QA mode)
│
├── bookMarketServiceProvider
│   └── BookMarketService → TraderaClient → [Tradera Proxy Edge Fn]
│
├── bookPricingDraftServiceProvider
│   ├── isbnLookupServiceProvider
│   └── bookMarketServiceProvider
│
├── bookInventoryDraftOrchestrationServiceProvider
│   ├── bookPricingDraftServiceProvider
│   ├── bookInventoryDraftMapperProvider
│   └── bookInventoryDraftApplicationServiceProvider
│       └── appDatabaseProvider
│
├── bookIsbnDraftFlowControllerProvider
│   └── bookInventoryDraftOrchestrationServiceProvider
│
├── bookBarcodeIsbnHandoffServiceProvider
│   └── bookIsbnDraftFlowControllerProvider
│
├── bookScannerIsbnHandoffCoordinatorProvider
│   ├── mlKitBookIsbnAdapterProvider
│   └── bookBarcodeIsbnHandoffServiceProvider
│
├── cloudSyncCoordinatorProvider
│   ├── appDatabaseProvider
│   ├── appConfigProvider
│   └── → [Supabase Storage, Supabase DB]
│
├── aiInferenceProvider ← ❌ REMOVE
│   └── AiInferenceIsolateService (TFLite isolate)
│
└── syncSchedulerProvider
    └── SyncScheduler → cloudSyncCoordinatorProvider
```

### Feature-to-Service Dependencies

```
scanner_screen.dart
├── bookScannerIsbnHandoffCoordinatorProvider ✅
├── aiInferenceProvider ← ❌ REMOVE dependency
└── scanImageStorageProvider ← ❌ REMOVE dependency

item_detail_screen.dart (50k lines — heaviest file)
├── appDatabaseProvider (scan items)  ← 🔄 swap to books
├── bookMarketServiceProvider ✅
└── AI result display logic ← ❌ REMOVE

dashboard_screen.dart
├── appDatabaseProvider (scan items stream) ← 🔄 swap to books
└── haulIdProvider

drafts/
└── bookInventoryDraftOrchestrationServiceProvider ✅ (already wired)
```

### Circular Dependencies
None detected — the architecture correctly flows downward: features → services → core.

### Critical Path Components (must migrate first)
1. **Database schema** — everything depends on this
2. **`providers.dart`** — DI root, must stay consistent during migration
3. **`scanner_screen.dart`** — first user touchpoint
4. **`item_detail_screen.dart`** — most complex screen, needs full rewrite as `book_detail_screen.dart`

---

## 4. Refactoring Checklist

### Step 1 — Remove AI services (estimated 2-3 days)

- [ ] Delete `lib/services/ai/inference/` (7 files)
- [ ] Delete `lib/services/ai/model_manager.dart`
- [ ] Delete `lib/services/ai/image_cropper.dart`
- [ ] Delete `lib/services/ai/cloud_ai_proxy_client.dart`
- [ ] Delete `lib/services/offline_detection/` (6 files)
- [ ] Delete `lib/features/offline_detection/` (2 files)
- [ ] Delete `lib/features/scanner/scan_capture_service.dart`
- [ ] Delete `lib/core/storage/scan_image_storage.dart`
- [ ] Delete `supabase/functions/cloud-ai-proxy/`
- [ ] Remove `aiInferenceProvider` from `providers.dart`
- [ ] Remove `scanImageStorageProvider` from `providers.dart`
- [ ] Remove `tflite_flutter`, `camera`, `image` from `pubspec.yaml`
- [ ] Remove `geocoding`, `geolocator` from `pubspec.yaml` (location service)
- [ ] Delete `lib/services/location/` (2 files)
- [ ] Run `fvm dart run build_runner build --delete-conflicting-outputs`

### Step 2 — Database migration v15→v16 (estimated 1-2 days)

- [ ] Create `lib/core/database/tables/books.dart` (id, userId, isbn, title, author, publisher, publishYear, coverUrl, purchasePriceSek, saved, scannedAt, updatedAt)
- [ ] Create `lib/core/database/tables/book_market_data.dart` (id, isbn, platform, priceSek, soldAt, listingUrl, fetchedAt)
- [ ] Create `lib/core/database/tables/book_market_stats.dart` (isbn PK, highestSoldPriceSek, averageSoldPriceSek, lowestSoldPriceSek, salesPerMonth, lastUpdatedAt)
- [ ] Add migration block `if (from < 16)` in `app_database.dart`
- [ ] Create DAOs: `BooksDao`, `BookMarketDataDao`, `BookMarketStatsDao`
- [ ] Register new tables + DAOs in `@DriftDatabase` annotation
- [ ] Run build_runner

### Step 3 — Wire Apify/Vinted service (estimated 1-2 days)

- [ ] Create `lib/services/market/vinted_apify_service.dart`
- [ ] Implement `MarketDataSource` interface
- [ ] Add `apifyApiToken` to `AppConfig`
- [ ] Add `hasApify` getter to `AppConfig`
- [ ] Create `apifyApiTokenProvider` and `vintedMarketDataSourceProvider` in `providers.dart`
- [ ] Extend `AggregatedMarketDataService` to include Vinted source

### Step 4 — Refactor scanner screen (estimated 2-3 days)

- [ ] Remove photo capture trigger from `scanner_screen.dart`
- [ ] Remove AI inference call path
- [ ] Keep and expand barcode scanning flow (already present in `scanner/barcode/`)
- [ ] Wire scan success → `bookScannerIsbnHandoffCoordinatorProvider` (already scaffolded)
- [ ] Add loading state for ISBN lookup + market data fetch
- [ ] Add "not found" state for unknown ISBNs
- [ ] Add manual ISBN entry fallback

### Step 5 — Replace item_detail_screen with book_detail_screen (estimated 3-5 days)

- [ ] Create `lib/features/analyzer/book_detail_screen.dart`
- [ ] Show book cover (from coverUrl), title, author, publisher
- [ ] Show market data: highest/average/lowest sold price, sales velocity
- [ ] Wire `profit_calculator.dart` (already exists and is platform-agnostic)
- [ ] Add platform breakdown (Tradera vs Vinted prices)
- [ ] Add "Save to inventory" action
- [ ] Delete `item_detail_screen.dart` after replacement

### Step 6 — Update dashboard to book inventory (estimated 2-3 days)

- [ ] Replace scan item stream with books stream from `BooksDao`
- [ ] Add ISBN search/filter
- [ ] Show book cover thumbnails
- [ ] Add "mark as sold" action
- [ ] Rename "haul" → "scanning trip" in UI strings

### Step 7 — Update ARB strings (ongoing)

- [ ] Rename all "scan item" → "book" strings in `app_en.arb`
- [ ] Rename all "scan item" → "bok" strings in `app_sv.arb`
- [ ] Add new strings: ISBN lookup states, market data states, book inventory labels
- [ ] Remove AI-related strings (confidence, identification, AI pending, etc.)

### Step 8 — Settings screen cleanup (estimated 1 day)

- [ ] Remove AI model section from settings
- [ ] Remove offline detection / model download section
- [ ] Add "Data Sources" section (Tradera, Vinted toggles)
- [ ] Keep sync settings, privacy settings, account deletion

### Step 9 — Update tests (ongoing)

- [ ] Remove tests for AI inference, model manager, image cropper
- [ ] Add tests for `IsbnLookupService` (already exists in `lib/services/books/`)
- [ ] Add tests for `BookMarketDataService`
- [ ] Add widget tests for `BookDetailScreen`
- [ ] Add widget tests for updated `DashboardScreen`
- [ ] Maintain minimum 1 English + 1 Swedish locale test per new screen

---

## 5. Risk Assessment

### 🔴 High Risk

| Risk | Affected Components | Mitigation |
|------|-------------------|------------|
| `item_detail_screen.dart` is 50k lines — rewrite risk | Analyzer feature | Build new `book_detail_screen.dart` alongside old; swap in navigation only when ready |
| Database migration (v15→v16) on existing user data | `app_database.dart` | Write migration carefully; test on in-memory DB first; keep old tables until cutover confirmed |
| `providers.dart` is the DI root — any mistake breaks the app | Everything | Change one provider at a time; run `flutter analyze` after each |
| `scanner_screen.dart` already has AI paths deeply entangled | Scanner feature | Use feature flags (`FF_DISABLE_AI`) to gate removal rather than deleting immediately |

### 🟡 Medium Risk

| Risk | Affected Components | Mitigation |
|------|-------------------|------------|
| Cloud sync expects `scan_items` shape — sync will break after schema change | Sync services | Update `CloudMetadataSyncService` to use books table before deploying |
| Tradera search by ISBN vs. by item name — API may not support ISBN query | `TraderaClient` | Test ISBN search against Tradera proxy before Step 2; have title+author fallback |
| Apify rate limits or actor downtime | Vinted market data | Degrade gracefully — show "Vinted data unavailable" rather than error |
| Draft listings format mismatch after model change | `draft_editor_screen.dart` | Clear existing drafts on migration or version the draft format |

### 🟢 Low Risk

| Risk | Affected Components | Mitigation |
|------|-------------------|------------|
| Removing `camera` dependency breaks camera permissions on iOS | iOS build | Verify Info.plist camera usage strings are removed after dep removal |
| `fl_chart` used in summary screen — keep or remove? | `haul_summary_screen.dart` | Keep — book profit trend charts are valuable |
| ARB string renames break existing Swedish translations | Localization | Use `[[TRANSLATE]]` placeholder for Swedish and translate in batch |

---

## 6. Effort Estimation

### Phase Breakdown

| Phase | Description | Effort | Complexity | Depends On |
|-------|-------------|--------|------------|------------|
| **A** | Remove AI services + dead code | 2-3 days | Low | Nothing |
| **B** | Database migration v15→v16 | 1-2 days | Medium | Nothing |
| **C** | Apify/Vinted service | 1-2 days | Medium | B |
| **D** | Scanner screen refactor | 2-3 days | Medium | A |
| **E** | Book detail screen (new) | 3-5 days | High | B, C |
| **F** | Dashboard → book inventory | 2-3 days | Medium | B |
| **G** | Settings cleanup | 1 day | Low | A |
| **H** | ARB strings update | 1-2 days | Low | Ongoing |
| **I** | Tests + QA | 3-5 days | Medium | All above |
| **J** | Beta testing + polish | 5-10 days | Medium | All above |

**Total estimated effort: 21-36 working days = 4-7 weeks** (with one developer, part-time)  
**Timeline target: 8-12 weeks** gives comfortable buffer for iteration and beta feedback.

### Critical Path

```
A (Remove AI) ──┐
                ├── D (Scanner) ──┐
B (DB schema) ──┤                 ├── I (Tests) ── J (Beta)
                ├── E (Detail) ───┤
C (Apify) ──────┘                 │
                  F (Dashboard) ──┘
                  G (Settings) ───┘
```

Phases A and B can run in parallel. Phase E (book detail screen) is the longest single task and sits on the critical path.

---

## 7. Key Findings

**The migration is significantly less work than anticipated.** Much of the Bokfynd service layer was already scaffolded on 2026-04-28:

- `lib/services/books/` (12 files) — ISBN lookup, barcode handoff, draft flow, market data all exist
- `lib/features/scanner/barcode/` — MLKit ISBN adapter already built
- `lib/features/scanner/isbn/` — ISBN validator and type already built
- `profit_calculator.dart` — already platform-agnostic

**The biggest effort is UI replacement**, not service work:
- `item_detail_screen.dart` (50k lines) → needs full rewrite as `book_detail_screen.dart`
- `dashboard_screen.dart` → needs inventory view
- `scanner_screen.dart` → needs AI path removed, ISBN path expanded

**The biggest risk is the database migration.** Schema v15→v16 must be carefully written with proper `onUpgrade` handling to avoid data loss on existing installs.

---

## 8. Recommended Sequence

Given the findings above, the recommended execution order once validation passes:

1. **Start with removals** (Phase A) — no risk, immediate complexity reduction
2. **Database migration** (Phase B) — enables everything else
3. **Scanner refactor** (Phase D) — highest user-facing value, already 80% wired
4. **Book detail screen** (Phase E) — most effort, start early
5. **Dashboard + Settings** (Phases F, G) — parallelize with Phase E
6. **Apify integration** (Phase C) — add after core flow is stable
7. **Tests + polish** (Phases I, J) — continuous, not a final step

---

**Assessment Date:** 2026-04-29  
**Prepared for:** Bokfynd validation decision  
**Next action:** Complete Week 1 validation sprint (docs/migration/MIGRATION_PLAN.md Phase 4)
