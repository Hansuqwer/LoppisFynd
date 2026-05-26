# BokFynd Architecture Refactor Prompt
## Children's Book Scanner with Multi-Platform Price Aggregation

**Date:** 2026-05-25
**Objective:** Refactor LoppisFynd into BokFynd — a specialized book-scanning app starting with **children's books**, fetching real-time prices from **Vinted, Tradera, Bokbörsen**, and similar Swedish second-hand platforms using **Apify actors, Supabase Edge Functions, and custom scrapers**.

---

## 1. CURRENT ARCHITECTURE ANALYSIS

### 1.1 Codebase Overview

| Layer | Path | Current State | Reuse? |
|-------|------|---------------|--------|
| **Entry** | `lib/main.dart` | Bootstraps AI inference, market bridge, Supabase, Sentry | Refactor: remove AI, add multi-market |
| **Config** | `lib/core/config/app_config.dart` | Has Tradera, Google Books, Supabase, Sentry. Missing Apify. | Extend: add `apifyApiToken` |
| **Feature Flags** | `lib/core/config/feature_flags.dart` | Has `enableAi`, `enableMarket`, `enableSync`, `enableAnalytics` | Remove `enableAi`, add `enableVinted`, `enableBokborsen` |
| **Database** | `lib/core/database/app_database.dart` | 11 tables (v15), Drift/SQLite. Tables: `Hauls`, `ScanItems`, `ScanItemPhotos`, `ScanItemComps`, `ScanItemSyncStates`, `EntitySyncStatuses`, `SyncQuotas`, `AppSettings`, `DraftListings`, `MarketStatsCache`, `PendingCloudSyncEntities` | Refactor: add `Books`, `BookMarketData`, `PriceButtonConfig`; deprecate photo/AI tables |
| **Providers** | `lib/core/app/providers.dart` | Riverpod DI. Has `isbnLookupServiceProvider`, `bookMarketServiceProvider`, `bookPricingDraftServiceProvider`, full book flow chain | Extend: add Vinted/Bokbörsen providers |
| **Book Services** | `lib/services/books/` | 12 files: ISBN lookup, market data aggregation, pricing drafts, barcode handoff, flow controller, orchestration | **Core reuse** — extend with multi-platform sources |
| **Market Services** | `lib/services/market/` | `MarketBridge` (Tradera-only), `TraderaClient`, `MarketDataSource` interface, `MarketMath` | Extend: implement `MarketDataSource` for Vinted + Bokbörsen |
| **AI Services** | `lib/services/ai/` | Empty directory (already cleaned) | Remove reference from `main.dart` |
| **Sync Services** | `lib/services/sync/` | Cloud sync, background sync, scheduler | Keep as-is |
| **Scanner** | `lib/features/scanner/` | Has `barcode/` (ML Kit ISBN adapter), `isbn/` (validator), `scanner_screen.dart` | Keep barcode ISBN flow; simplify screen |
| **Features** | `lib/features/` | `analyzer/`, `auth/`, `dashboard/`, `drafts/`, `hauls/`, `history/`, `onboarding/`, `scanner/`, `settings/`, `summary/` | Remove `analyzer/`, `summary/`; transform `hauls/` → inventory; `drafts/` → book drafts |
| **Supabase Functions** | `supabase/functions/` | `tradera-proxy/` (SOAP → JSON, rate-limited), `account-delete/` | Add `vinted-scraper/`, `bokborsen-scraper/`, `book-market-aggregator/` |
| **Genspark MCP** | `genspark-mcp-server/` | MCP server for Genspark AI chat integration | Optional: repurpose for research queries |

### 1.2 Existing Book Flow (Already Built)

The codebase already has a **partial BokFynd implementation** in `lib/services/books/`:

```
Barcode Scan → MlKitBookIsbnAdapter → ValidatedBookIsbn
  → BookScannerIsbnHandoffCoordinator
    → BookBarcodeIsbnHandoffService
      → BookIsbnDraftFlowController
        → BookInventoryDraftOrchestrationService
          → BookPricingDraftService
            ├── IsbnLookupService (Google Books + Open Library)
            └── BookMarketService (Tradera only via TraderaClient)
          → BookInventoryDraftMapper
          → BookInventoryDraftApplicationService (writes to ScanItems DAO)
```

**Key insight:** The ISBN → metadata → market data → draft pipeline is already wired. The missing piece is **multi-platform market data** (currently Tradera-only).

### 1.3 Market Data Architecture (Current)

```
MarketDataSource (interface)
  └── MarketBridge (Tradera-only, with 24h cache in MarketStatsCache)
        └── TraderaClient → Supabase Edge Function (tradera-proxy) → Tradera SOAP API

BookMarketService (book-specific wrapper)
  └── TraderaBookMarketAdapter → BookMarketDataAggregator (dedup, IQR outlier filter)
```

### 1.4 What Needs to Change

| Component | Current | Target |
|-----------|---------|--------|
| Market sources | Tradera only | Tradera + Vinted + Bokbörsen + Blocket |
| Book focus | All books | Children's books first |
| AI inference | Referenced in `main.dart` | Fully removed |
| Photo storage | `ScanImageStorage` active | Remove (books use cover URLs from ISBN lookup) |
| Data model | `ScanItems` (generic) | `Books` (book-specific) with migration |
| Edge functions | `tradera-proxy` only | Add `vinted-scraper`, `bokborsen-scraper`, `book-market-aggregator` |
| Config | No Apify token | Add `APIFY_API_TOKEN` |

---

## 2. SCRAPING RESEARCH & TOOL SELECTION

### 2.1 Platform Integration Matrix

| Platform | API Type | Tool/Method | Status | Cost | Latency |
|----------|----------|-------------|--------|------|---------|
| **Tradera** | Official SOAP API | Existing `tradera-proxy` Edge Function | ✅ Working | Free (API key) | 2-5s |
| **Vinted** | No official API | **Apify Actor** (validated in docs) | ✅ Validated | $0-$49/mo | 3-8s |
| **Bokbörsen** | No API | Custom Supabase Edge Function (HTML scraping) or Apify Actor | ⏳ Unvalidated | $0-$49/mo | 2-5s |
| **Blocket** | No official API | Apify generic e-commerce scraper or custom scraper | ❌ Future | TBD | TBD |
| **Google Books** | REST API | Existing `IsbnLookupService` | ✅ Working | Free (1000/day) | 1-2s |
| **Open Library** | REST API | Existing fallback in `IsbnLookupService` | ✅ Working | Free | 1-2s |
| **Libris (KB)** | REST API | Swedish national library — excellent for Swedish children's books metadata | ❌ Future | Free | 1-2s |

### 2.2 Apify Integration Strategy

**Why Apify:**
- Already validated for Vinted (per `docs/bokfynd/strategy/validation-results.md`)
- Handles anti-scraping measures (CAPTCHA, IP rotation, browser fingerprinting)
- MCP server available for AI-agent integration
- Pay-per-result pricing ($0.49/1000 results at Starter tier)
- 5,000 free results/month (enough for MVP with 100 users)

**Apify Actor Recommendations:**
1. **Vinted:** Use a community Vinted scraper actor or build a custom actor using Apify's SDK
2. **Bokbörsen:** Build a custom Apify actor (simple HTML scraping, no anti-bot measures)
3. **Generic fallback:** Use `apify/e-commerce-scraping-tool` (11K users, 4.6 rating) for Blocket and other sites

**Apify Client Pattern (Dart):**
```dart
class ApifyClient {
  final String apiToken;
  final http.Client httpClient;

  Future<List<Map<String, dynamic>>> runActor({
    required String actorId,
    required Map<String, dynamic> input,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // 1. Start actor run
    // 2. Poll for completion
    // 3. Fetch dataset items
    // 4. Return parsed results
  }
}
```

### 2.3 Supabase Edge Functions Strategy

**New Edge Functions:**

1. **`vinted-scraper`** — Calls Apify API, parses Vinted results into `BookSale` format
2. **`bokborsen-scraper`** — Direct HTML scraping (Bokbörsen has simple HTML, no JS rendering needed)
3. **`book-market-aggregator`** — Orchestrates parallel calls to all sources, deduplicates, returns aggregated stats

**Architecture:**
```
Flutter App
  → book-market-aggregator (Edge Function)
    ├── tradera-proxy (existing Edge Function)
    ├── vinted-scraper (new Edge Function → Apify API)
    └── bokborsen-scraper (new Edge Function → HTML scrape)
```

### 2.4 Children's Book Focus Strategy

**Why children's books first:**
- High volume at flea markets (parents constantly selling)
- ISBN coverage is excellent (modern children's books always have ISBNs)
- Price range is predictable (20-150 SEK typically)
- Strong seasonal demand (back-to-school, holidays)
- Easier condition assessment (visual inspection of cover/pages)

**Implementation:**
- Add `genre`/`category` field to book metadata
- Google Books API returns `categories` — filter for children's/YA
- Add children's book-specific search terms for market data queries
- UI: "Barnböcker" (Children's Books) as default filter in inventory

---

## 3. REFACTORING PLAN

### Phase 1: Foundation (Week 1-2)

#### 1.1 Remove AI Infrastructure
**Files to modify:**
- `lib/main.dart` — Remove `AiInferenceIsolateService`, `ScanImageStorage` initialization
- `lib/core/app/providers.dart` — Remove `aiInferenceProvider`, `scanImageStorageProvider`
- `lib/core/config/feature_flags.dart` — Remove `enableAi` flag
- `pubspec.yaml` — Remove any AI-related dependencies if present

**Files to remove/archive:**
- `lib/services/ai/` (already empty)
- References to `AiInferenceIsolateService` throughout

#### 1.2 Extend Configuration
**Files to modify:**
- `lib/core/config/app_config.dart` — Add:
  ```dart
  final String apifyApiToken;
  final String vintedScraperActorId;
  final String bookMarketAggregatorUrl;
  ```
- `.env.example` — Add `APIFY_API_TOKEN`, `VINTED_SCRAPER_ACTOR_ID`, `BOOK_MARKET_AGGREGATOR_URL`

#### 1.3 Database Migration (v15 → v16)
**New tables to add:**
- `Books` — Book-specific entity with ISBN, metadata, purchase price, market stats cache
- `BookMarketData` — Individual sale records from each platform
- `PriceButtonConfig` — User-configurable quick price buttons

**Migration strategy:**
- Keep `ScanItems` table (backward compat) but add `Books` as the primary table
- `BookInventoryDraftApplicationService` should write to `Books` table
- Existing `MarketStatsCache` can be reused or replaced by `BookMarketData` aggregation

### Phase 2: Multi-Platform Market Data (Week 3-4)

#### 2.1 Implement `MarketDataSource` for Each Platform

**Vinted (via Apify):**
```dart
class VintedMarketDataSource implements MarketDataSource {
  final ApifyClient apifyClient;
  final String actorId;

  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    final results = await apifyClient.runActor(
      actorId: actorId,
      input: {
        'searchQuery': query,
        'maxItems': 50,
        'country': 'se',
        'status': 'sold',
      },
    );
    // Parse into BookSale list → aggregate stats
  }
}
```

**Bokbörsen (custom scraper):**
```dart
class BokborsenMarketDataSource implements MarketDataSource {
  // Option A: Via Supabase Edge Function
  // Option B: Direct HTTP scraping from Dart (if no anti-bot)

  @override
  Future<MarketStats?> fetchMarketStats({required String query}) async {
    // Scrape bokborsen.se search results
    // Parse HTML for sold listings
    // Extract price, date, title
  }
}
```

#### 2.2 Create `AggregatedBookMarketService`

```dart
class AggregatedBookMarketService implements BookMarketStatsLookup {
  final List<BookMarketSource> sources; // Tradera, Vinted, Bokbörsen
  final BookMarketDataAggregator aggregator;

  @override
  Future<BookMarketStats?> fetchStatsForBookQuery({
    required String query,
    DateTime? now,
  }) async {
    // Fetch from all sources in parallel (Future.wait)
    // Merge all BookSale lists
    // Delegate to aggregator for dedup + outlier filter + stats
  }
}
```

#### 2.3 Build Supabase Edge Functions

**`book-market-aggregator/index.ts`:**
```typescript
// Orchestrates parallel fetches to:
// 1. tradera-proxy (existing)
// 2. vinted-scraper (new, calls Apify)
// 3. bokborsen-scraper (new, HTML scrape)
// Returns merged, deduplicated results
```

**`vinted-scraper/index.ts`:**
```typescript
// Calls Apify API:
// POST https://api.apify.com/v2/acts/{actorId}/runs
// Poll for completion
// Fetch dataset items
// Transform to BookSale format
```

**`bokborsen-scraper/index.ts`:**
```typescript
// Direct HTML scraping of bokborsen.se
// GET https://www.bokborsen.se/search?q={isbn}
// Parse HTML with cheerio/Deno DOM
// Extract sold listings (price, date, title)
```

### Phase 3: Children's Book Optimization (Week 5)

#### 3.1 Genre Detection
- Parse Google Books `categories` field
- Map to Swedish children's book categories: `Barnböcker`, `Ungdomsböcker`, `Bilderböcker`
- Add `isChildrensBook` flag to `BookMetadata`

#### 3.2 Enhanced Search Queries
- For children's books, append `"barnbok"` to Tradera/Vinted search queries
- Filter Bokbörsen results by children's section

#### 3.3 UI Adaptations
- Default scanner mode: "Barnböcker" filter
- Quick price buttons tuned for children's book price ranges (5kr, 10kr, 15kr, 20kr, 25kr, 30kr)
- Inventory filter: "Only children's books"

### Phase 4: UI Refactoring (Week 6-7)

#### 4.1 Simplify Navigation
- Remove `analyzer/`, `summary/` features
- Tabs: Scanner | Inventory | History | Settings
- Scanner → ISBN barcode scanner (already built)
- Inventory → Book list with cover images, prices, profit margins

#### 4.2 Book Decision Screen
- Show: Cover image, Title, Author, Year
- Market stats: High / Avg / Low prices, Sales/month
- Source breakdown: "Tradera: 12 sales, Vinted: 8 sales, Bokbörsen: 3 sales"
- Quick price buttons: [5kr] [10kr] [15kr] [20kr] [25kr] [30kr]
- Profit calculator: Buy for X, sell for avg Y, profit Z after fees

#### 4.3 Inventory Screen
- List of saved books with covers
- Sort by: Date, Profit margin, Title, Platform
- Filter: All, Children's books, High profit, Low profit
- Export: CSV for accounting

### Phase 5: Testing & Polish (Week 8)

#### 5.1 Integration Tests
- ISBN lookup → market data aggregation → decision screen flow
- Each platform source independently tested
- Offline fallback (cached market data)

#### 5.2 Performance Targets
- Scan to decision: <8 seconds (barcode 1s + ISBN lookup 2s + market data 5s parallel)
- Market data cache: 24h TTL (configurable)
- App size: <50MB (no AI models)

---

## 4. DETAILED EXECUTION CHECKLIST

### Phase 1: Foundation
- [ ] Remove `AiInferenceIsolateService` from `main.dart`
- [ ] Remove `ScanImageStorage` from `main.dart` provider overrides
- [ ] Remove `aiInferenceProvider` from `providers.dart`
- [ ] Remove `scanImageStorageProvider` from `providers.dart`
- [ ] Remove `enableAi` from `FeatureFlags`
- [ ] Add `apifyApiToken`, `vintedScraperActorId`, `bookMarketAggregatorUrl` to `AppConfig`
- [ ] Update `.env.example` with new variables
- [ ] Create `Books` table in Drift (v16 migration)
- [ ] Create `BookMarketData` table in Drift
- [ ] Create `PriceButtonConfig` table in Drift
- [ ] Create corresponding DAOs
- [ ] Update `BookInventoryDraftApplicationService` to write to `Books` table

### Phase 2: Multi-Platform Market Data
- [ ] Create `ApifyClient` in `lib/services/market/apify_client.dart`
- [ ] Implement `VintedMarketDataSource` using `ApifyClient`
- [ ] Implement `BokborsenMarketDataSource` (direct or via edge function)
- [ ] Create `AggregatedBookMarketService` implementing `BookMarketStatsLookup`
- [ ] Wire into `BookPricingDraftService` via providers
- [ ] Build `vinted-scraper` Supabase Edge Function
- [ ] Build `bokborsen-scraper` Supabase Edge Function
- [ ] Build `book-market-aggregator` Supabase Edge Function
- [ ] Add integration tests for each data source
- [ ] Add integration test for aggregation (dedup, outlier filter, stats)

### Phase 3: Children's Book Focus
- [ ] Add `categories` parsing to `IsbnLookupService` → `BookMetadata`
- [ ] Add `isChildrensBook` computed property
- [ ] Enhance market query builder with children's book terms
- [ ] Add children's book filter to inventory provider

### Phase 4: UI
- [ ] Remove `analyzer/` feature screens
- [ ] Remove `summary/` feature screens
- [ ] Create `BookDecisionScreen` (new)
- [ ] Transform `HaulsScreen` → `InventoryScreen`
- [ ] Update navigation tabs (4 tabs: Scanner, Inventory, History, Settings)
- [ ] Add profit calculator bottom sheet
- [ ] Add price button configuration screen
- [ ] Update localization (en + sv ARB files)

### Phase 5: Testing & Polish
- [ ] Widget tests for `BookDecisionScreen` (en + sv)
- [ ] Widget tests for `InventoryScreen` (en + sv)
- [ ] Unit tests for `AggregatedBookMarketService`
- [ ] Unit tests for `ApifyClient`
- [ ] Integration test: full scan → decision → save flow
- [ ] `flutter analyze` zero issues
- [ ] `flutter test` all pass
- [ ] Golden tests updated for new screens

---

## 5. ARCHITECTURE DIAGRAMS

### 5.1 Target System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (iOS/Android)             │
│                                                          │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ Scanner  │→ │ ISBN Lookup  │→ │ Book Decision     │  │
│  │ (ML Kit) │  │ (Google/Open)│  │ Screen            │  │
│  └──────────┘  └──────────────┘  └───────────────────┘  │
│       │               │                    │             │
│       ▼               ▼                    ▼             │
│  ┌──────────────────────────────────────────────────┐   │
│  │        AggregatedBookMarketService               │   │
│  │  ┌─────────┐ ┌──────────┐ ┌──────────────────┐   │   │
│  │  │ Tradera │ │  Vinted  │ │   Bokbörsen      │   │   │
│  │  │ Adapter │ │ Adapter  │ │   Adapter        │   │   │
│  │  └────┬────┘ └────┬─────┘ └───────┬──────────┘   │   │
│  └───────┼───────────┼───────────────┼──────────────┘   │
│          │           │               │                   │
│  ┌───────▼───────────▼───────────────▼──────────────┐   │
│  │         Drift Database (SQLite)                   │   │
│  │  Books │ BookMarketData │ PriceButtonConfig       │   │
│  └──────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │    Supabase Edge Functions       │
          │                                  │
          │  ┌──────────────────────────┐    │
          │  │ book-market-aggregator   │    │
          │  │   ├── tradera-proxy      │    │
          │  │   ├── vinted-scraper     │    │
          │  │   └── bokborsen-scraper  │    │
          │  └──────────────────────────┘    │
          └──────────────┬──────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │    External APIs                 │
          │                                  │
          │  ├── Tradera SOAP API            │
          │  ├── Apify (Vinted Actor)        │
          │  ├── Bokbörsen (HTML scrape)     │
          │  ├── Google Books API            │
          │  └── Open Library API            │
          └─────────────────────────────────┘
```

### 5.2 Data Flow: Scan → Decision

```
1. User scans barcode
   └→ MlKitBookIsbnAdapter extracts ISBN
   └→ ValidatedBookIsbn (checksum verified)

2. ISBN Lookup (parallel)
   ├→ Google Books API → title, author, cover, categories
   └→ Open Library API (fallback)

3. Market Data Fetch (parallel, via Edge Function)
   ├→ Tradera: searchEnded("title author") → ended listings
   ├→ Vinted: Apify actor → sold listings
   └→ Bokbörsen: HTML scrape → sold listings

4. Aggregation
   └→ BookMarketDataAggregator
      ├→ Deduplicate (same price+date+url)
      ├→ IQR outlier filter (if ≥8 sales)
      └→ Calculate: high, avg, low, sales/month

5. Decision Screen
   └→ Show: cover, metadata, market stats
   └→ User taps price button [10kr]
   └→ Profit calculator: 10kr buy → 85kr avg sell → 75kr profit
   └→ Save to inventory or skip
```

---

## 6. RISK MITIGATION

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Apify Vinted actor breaks | Medium | Medium | Build custom Apify actor as backup; cache results 24h |
| Bokbörsen blocks scraping | Low | Low | Use Apify anti-blocking; fallback to Tradera+Vinted only |
| Google Books rate limit (1000/day) | Medium | High | Aggressive caching; Open Library fallback; consider paid tier |
| Children's book ISBN coverage <50% | Low | High | Validate with 100 children's book ISBNs before commit |
| Tradera API changes | Low | Medium | SOAP API is stable; proxy isolates changes |
| Apify cost at scale | Low | Low | 95% margin at 10K users; implement request deduplication |

---

## 7. SUCCESS METRICS

### Technical
- [ ] ISBN lookup <2s (p95)
- [ ] Market data aggregation <5s (p95)
- [ ] Scan-to-decision <8s (p95)
- [ ] App size <50MB
- [ ] Crash-free rate >99%
- [ ] `flutter analyze` zero issues

### Product
- [ ] ≥80% barcode scan success rate (real flea market conditions)
- [ ] ≥90% ISBN lookup success rate
- [ ] ≥60% of children's books have market data
- [ ] User can scan + decide in <10 seconds
- [ ] Average profit margin >100%

### Business
- [ ] 100 beta testers in first month
- [ ] 30%+ of scanned books saved to inventory
- [ ] 10% conversion to paid tier
- [ ] Unit economics: >80% margin at 1,000 users

---

## 8. KEY FILES REFERENCE

### Reuse (Keep & Extend)
- `lib/services/books/isbn_lookup_service.dart` — Google Books + Open Library
- `lib/services/books/book_market_data_service.dart` — Aggregator with dedup + IQR filter
- `lib/services/books/book_pricing_draft_service.dart` — Orchestrates metadata + market
- `lib/services/books/book_isbn_draft_flow_controller.dart` — State machine for scan flow
- `lib/services/books/book_scanner_isbn_handoff_coordinator.dart` — Barcode → ISBN → draft
- `lib/services/market/tradera_client.dart` — Tradera proxy client with retry
- `lib/services/market/market_data_source.dart` — Interface to implement for each platform
- `lib/services/market/market_math.dart` — Statistical calculations
- `lib/core/database/app_database.dart` — Drift database (extend schema)
- `lib/core/app/providers.dart` — Riverpod DI (add new providers)
- `supabase/functions/tradera-proxy/` — Existing Tradera edge function

### Create (New Files)
- `lib/services/market/apify_client.dart` — Apify API client
- `lib/services/market/vinted_market_data_source.dart` — Vinted via Apify
- `lib/services/market/bokborsen_market_data_source.dart` — Bokbörsen scraper
- `lib/services/books/aggregated_book_market_service.dart` — Multi-platform aggregator
- `lib/core/database/tables/books.dart` — Books table
- `lib/core/database/tables/book_market_data.dart` — Market data table
- `lib/core/database/tables/price_button_config.dart` — Price buttons table
- `lib/core/database/daos/books_dao.dart` — Books DAO
- `lib/core/database/daos/book_market_data_dao.dart` — Market data DAO
- `lib/features/books/book_decision_screen.dart` — Decision UI
- `lib/features/books/inventory_screen.dart` — Inventory UI
- `supabase/functions/vinted-scraper/index.ts` — Vinted edge function
- `supabase/functions/bokborsen-scraper/index.ts` — Bokbörsen edge function
- `supabase/functions/book-market-aggregator/index.ts` — Aggregator edge function

### Remove
- `lib/services/ai/` references in `main.dart`
- `AiInferenceIsolateService` initialization
- `ScanImageStorage` from provider overrides
- `enableAi` feature flag
- `lib/features/analyzer/` (if still present)
- `lib/features/summary/` (if still present)

---

## 9. EXECUTION INSTRUCTIONS

When executing this refactoring prompt:

1. **Start with Phase 1** — Remove AI, extend config, create database migration
2. **Run `flutter analyze`** after each phase to catch issues early
3. **Run `flutter test`** after each phase to ensure nothing breaks
4. **Build edge functions** in `supabase/functions/` with Deno tests
5. **Wire providers** last — ensure all services are tested independently first
6. **Update localization** (both `app_en.arb` and `app_sv.arb`) for all new UI strings
7. **Follow AGENTS.md conventions** — no upward imports, feature-first organization, ARB in both locales
8. **Test with real children's books** — scan 20+ books at a flea market before declaring Phase 3 complete

### Build Commands
```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart format .
fvm flutter analyze
fvm flutter test
```

### Edge Function Commands
```bash
supabase functions deploy vinted-scraper
supabase functions deploy bokborsen-scraper
supabase functions deploy book-market-aggregator
deno test supabase/functions/vinted-scraper/
deno test supabase/functions/bokborsen-scraper/
```

---

**Document Version:** 2.0
**Created:** 2026-05-25
**Author:** Architecture Analysis + Refactoring Planning
**Based on:** Deep codebase analysis of all layers, services, and existing BokFynd partial implementation
