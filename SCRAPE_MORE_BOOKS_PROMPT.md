# Prompt: Scrape More Books — Expand Market Data Coverage

## Context

LoppisFynd is a Flutter app (iOS + Android, Swedish market) for flea-market
book resellers. Users scan a barcode → the app fetches sold-price comps from
three sources and derives min / median / max / demand stats stored in
`ScanItemComps` and `ScanItems`.

### Current scraping stack

| Layer | What it does |
|---|---|
| `TraderaClient` | POSTs to a Supabase Edge Function (`tradera-proxy`) that calls the Tradera SOAP API for ended auctions. Returns `TraderaProxyResponse` with `maxBid`, `endDate`, `hasBids`, `isEnded`. |
| `BokborsenMarketDataSource` | POSTs to `bokborsen-scraper` Edge Function which HTML-scrapes `bokborsen.se/search?q=…&sort=sold_date`. Returns `{ items: [{price, soldAt, url, title}] }`. |
| `VintedMarketDataSource` | Calls Apify actor (configured via `VINTED_SCRAPER_ACTOR_ID`) via `ApifyClient`. Returns sold listings from Vinted Sweden. |
| `AggregatedBookMarketService` | Fan-out over all three sources, passes all sales through `BookMarketDataAggregator` (IQR outlier filter → median / min / max). |
| `SyncScheduler` | Processes `ScanItems` with `status = pendingSync`, fetches comps via `MarketBridge` (Tradera-only) or `AggregatedBookMarketService`, writes to `ScanItemComps` + `ScanItems`, increments daily quota (`maxCallsPerDay = 200`). |
| `book-market-aggregator` Edge Function | Server-side fan-out (Tradera + Vinted + Bokbörsen), deduplication, basic stats. |

### Current query construction
The `ScanItem.query` field holds a free-text Tradera-style search string
(e.g. `"Pippi Långstrump Astrid Lindgren"`). It is set manually or auto-
generated from ISBN lookup metadata.

### Schema (Drift/SQLite)
```dart
// ScanItems (relevant columns)
String id, String? query, String? isbn,
double? minPrice, double? medianPrice, double? maxPrice,
ScanItemStatus status  // pendingIdentify → pendingSync → syncing → complete

// ScanItemComps
String scanItemId, String rawJson,
double? medianPrice, double? minPrice, double? maxPrice,
int? demandScore, int? daysToSellEst, DateTime fetchedAt

// Books (separate ISBN-resolved table)
String isbn, String title, String? author,
int? highestSoldPriceSek, int? averageSoldPriceSek, int? lowestSoldPriceSek,
double? salesPerMonth, int? totalSales
```

---

## Goal

Add **two new book-market scraping sources** and a **bulk ISBN enrichment
pipeline** so that:

1. **Adlibris second-hand** prices are scraped (largest Swedish new/used book
   marketplace — already has a public search page).
2. **Pricerunner book comps** are fetched (aggregates new + used prices, useful
   as a ceiling/demand proxy).
3. A **bulk pre-scrape job** can enrich the `Books` table from a list of ISBNs
   without the user having to physically scan each one (useful for seeding the
   FindsScreen with real market data).

---

## Deliverables

### 1. `adlibris-scraper` Supabase Edge Function

**File:** `supabase/functions/adlibris-scraper/index.ts`

- Accepts `POST { query: string, maxResults?: number }` (same shape as
  `bokborsen-scraper`).
- Fetches `https://www.adlibris.com/se/sok?query=<encoded>&filter=USED`
  (or the correct used-books URL — verify via curl before coding).
- Parses HTML for used-book listings: extract `price` (SEK integer),
  `title` (string), `url` (absolute), `condition` (string | null),
  `soldAt` (null — Adlibris shows current listings, not sold dates; use
  `fetchedAt` as proxy and document this).
- Returns `{ items: [{platform:"adlibris", price, title, url, condition,
  soldAt: null}], source:"adlibris", query }`.
- Respects `maxResults` (cap 100).
- Same CORS + error envelope as existing scrapers.

**File:** `supabase/functions/adlibris-scraper/tests/adlibris_scraper_test.ts`

- Unit tests with fixture HTML (copy a real response snippet).
- Test: empty results for query with no matches.
- Test: extracts price, title, URL correctly from sample block.

---

### 2. `AdlibrisMarketDataSource` Flutter client

**File:** `lib/services/market/adlibris_market_data_source.dart`

- Mirrors `BokborsenMarketDataSource` exactly.
- Constructor: `functionUrl`, `httpClient?`, `anonKey?`, `timeout?`.
- `search({required String query, DateTime? now})` → `Future<List<BookSale>>`.
- Maps Adlibris items to `BookSale(platform:'adlibris', priceSek:...,
  soldAt: now, listingUrl:...)`.
- Since Adlibris shows *current asking prices* (not sold), set
  `soldAt = now` and document this as a "demand proxy" not a true sold comp.

**File:** `lib/services/books/adlibris_book_market_source.dart`

- Implements `BookMarketSource` wrapping `AdlibrisMarketDataSource`.
- Identical pattern to `VintedBookMarketSource`.

---

### 3. Wire Adlibris into the aggregator

**Files to update:**

- `lib/core/config/app_config.dart` — add `adlibrisScraperUrl` string field
  + `hasAdlibrisScraper` getter.
- `lib/core/app/providers.dart` — add `adlibrisMarketDataSourceProvider` and
  wire it into `aggregatedBookMarketServiceProvider` sources list.
- `supabase/functions/book-market-aggregator/index.ts` — add Adlibris as a
  4th fan-out call; update `SourceResult` union; update deduplication key to
  also handle null `soldAt`.

**ARB strings** (`lib/l10n/app_sv.arb` + `lib/l10n/app_en.arb`):
- `"settingsAdlibrisScraperConfigured"` / not-configured variants.

---

### 4. Bulk ISBN enrichment pipeline

**Problem:** The `Books` table has ISBNs from past scans but many rows have
`null` for `averageSoldPriceSek` because the user never queued them for sync.
We want a background job that, given a list of ISBNs, auto-constructs the
query, fetches comps from all sources, and writes stats back.

#### 4a. `BulkIsbnEnrichmentService`

**File:** `lib/services/books/bulk_isbn_enrichment_service.dart`

```dart
class BulkIsbnEnrichmentService {
  // Dependencies:
  //   BookMetadataLookup isbnLookup   — to resolve ISBN → title+author
  //   BookMarketStatsLookup market    — AggregatedBookMarketService
  //   BooksDao booksDao
  //   SyncQuotasDao quotasDao
  //   int maxCallsPerDay              — default 50 (separate quota from scan sync)

  /// Enrich up to [batchSize] books that have no market stats yet.
  /// Returns the number of books updated.
  Future<int> enrichStale({
    int batchSize = 20,
    Duration staleBefore = const Duration(days: 7),
  });

  /// Enrich a specific list of ISBNs regardless of staleness.
  Future<int> enrichIsbnList(List<String> isbns);
}
```

- For each ISBN:
  1. Look up metadata via `IsbnLookupService` (title + author).
  2. Construct query: `"${title} ${author}"` (trim + collapse whitespace).
  3. Call `AggregatedBookMarketService.fetchStatsForBookQuery`.
  4. Write result to `BooksDao.setMarketStats`.
  5. Respect per-day quota (key: `bulk_enrich_YYYY-MM-DD`).
  6. Log event via `AnalyticsService`.

- `enrichStale` queries `BooksDao` for rows where
  `averageSoldPriceSek IS NULL AND saved = true`, ordered by `scannedAt DESC`,
  limited to `batchSize`.

#### 4b. Provider

Add `bulkIsbnEnrichmentServiceProvider` to `lib/core/app/providers.dart`.

#### 4c. Settings UI hook

In `lib/features/settings/settings_screen.dart`, add a "Hämta marknadsdata
för alla böcker" / "Fetch market data for all books" action button under
the **Market sync** section. Taps call
`bulkIsbnEnrichmentServiceProvider.enrichStale()` and shows a snackbar with
count of enriched books.

**ARB strings:**
- `"settingsBulkEnrichCta"`: `"Hämta marknadsdata för alla böcker"` / `"Fetch market data for all books"`
- `"settingsBulkEnriching"`: `"Hämtar…"` / `"Fetching…"`
- `"settingsBulkEnrichDone"`: `"Uppdaterade {count} böcker."` / `"Updated {count} books."`
- `"settingsBulkEnrichFailed"`: `"Misslyckades: {error}"` / `"Failed: {error}"`

---

### 5. `BooksDao` additions

**File:** `lib/core/database/daos/books_dao.dart` — add:

```dart
/// Books saved by user with no market stats yet, ordered by most recent.
Future<List<Book>> listStaleMarketStats({
  int limit = 20,
  required DateTime olderThan,
});
```

Implementation: `WHERE saved = true AND averageSoldPriceSek IS NULL
AND updatedAt < olderThan ORDER BY scannedAt DESC LIMIT ?`.

---

### 6. `book-market-aggregator` — add Adlibris fan-out

Update `supabase/functions/book-market-aggregator/index.ts`:

- Read `ADLIBRIS_URL` from env (falls back to
  `${supabaseUrl}/functions/v1/adlibris-scraper`).
- Add 4th `Promise.allSettled` entry calling `adlibris-scraper`.
- Map response items: since `soldAt` may be null, use current ISO timestamp
  as fallback in deduplication key.
- Add `adlibris` to `sourceCounts` in the stats response.

---

## Architecture constraints

- Follow existing layer conventions:
  `presentation → application → domain`. No upward imports.
- All new Flutter code: `fvm flutter analyze` must pass zero new issues.
- All user-visible strings in both `app_sv.arb` and `app_en.arb`.
- `BulkIsbnEnrichmentService` must be pure Dart (`lib/services/…`) with
  no Flutter imports.
- Supabase Edge Functions: Deno/TypeScript, same CORS envelope as existing
  functions. Add unit tests with fixture HTML.
- No `.env` file reads or secrets hard-coded.
- `ADLIBRIS_SCRAPER_URL` added to `.env.example` with an empty default.

---

## Verification steps (run before marking done)

```bash
# Flutter side
fvm flutter analyze            # zero new issues
fvm flutter test               # all tests pass

# Edge function tests (Deno)
deno test supabase/functions/adlibris-scraper/tests/
deno test supabase/functions/book-market-aggregator/tests/

# Manual smoke test
curl -X POST http://localhost:54321/functions/v1/adlibris-scraper \
  -H "Content-Type: application/json" \
  -d '{"query":"Pippi Långstrump","maxResults":5}' | jq .
```

---

## File checklist

| Status | File |
|---|---|
| NEW | `supabase/functions/adlibris-scraper/index.ts` |
| NEW | `supabase/functions/adlibris-scraper/tests/adlibris_scraper_test.ts` |
| NEW | `lib/services/market/adlibris_market_data_source.dart` |
| NEW | `lib/services/books/adlibris_book_market_source.dart` |
| NEW | `lib/services/books/bulk_isbn_enrichment_service.dart` |
| EDIT | `lib/core/config/app_config.dart` — add `adlibrisScraperUrl` |
| EDIT | `lib/core/app/providers.dart` — add adlibris + bulk providers |
| EDIT | `lib/core/database/daos/books_dao.dart` — add `listStaleMarketStats` |
| EDIT | `lib/features/settings/settings_screen.dart` — add bulk enrich button |
| EDIT | `supabase/functions/book-market-aggregator/index.ts` — 4th source |
| EDIT | `lib/l10n/app_sv.arb` + `app_en.arb` — new strings |
| EDIT | `.env.example` — add `ADLIBRIS_SCRAPER_URL=` |
