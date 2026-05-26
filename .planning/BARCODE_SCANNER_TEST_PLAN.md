# Barcode Scanner & Market Data Integration Test Plan

**App**: LoppisFynd — book reseller app for Swedish market  
**Created**: 2026-05-26  
**Status**: Draft  
**Estimated total execution time**: ~2.5 hours (automated: ~15 min, manual: ~2 hours)

---

## Table of Contents

1. [Existing Test Coverage](#1-existing-test-coverage)
2. [Barcode Scanner Tests](#2-barcode-scanner-tests)
3. [Market Data Integration Tests](#3-market-data-integration-tests)
4. [Supabase Edge Function Tests](#4-supabase-edge-function-tests)
5. [Manual Verification Checklist](#5-manual-verification-checklist)
6. [Test Data: Sample ISBN Barcodes](#6-test-data-sample-isbn-barcodes)
7. [Screenshot & Recording Requirements](#7-screenshot--recording-requirements)
8. [Known Blockers](#8-known-blockers)

---

## 1. Existing Test Coverage

### Unit Tests (PASS — already exist)

| Test File | Coverage | Status |
|-----------|----------|--------|
| `test/features_scanner/mlkit_book_isbn_adapter_test.dart` | ISBN normalization, fallback to displayValue, non-book rejection, dedup | EXISTS |
| `test/features_scanner/isbn_validator_test.dart` | Normalize, checksum, EAN-13 prefix rejection, malformed input | EXISTS |
| `test/features_scanner/scanner_book_isbn_handoff_controller_test.dart` | Handoff delegation, cooldown, feedback mapping, error states | EXISTS |
| `test/services_books/vinted_book_market_source_test.dart` | Apify fake/throwing client, blank query, zero-price filter | EXISTS |
| `test/services_books/bokborsen_book_market_source_test.dart` | HTTP mock, error handling, blank query, zero-price filter | EXISTS |
| `test/services_books/aggregated_book_market_service_test.dart` | Multi-source aggregation, source failure resilience, empty/blank | EXISTS |
| `test/services_books/isbn_lookup_service_test.dart` | Google Books + OpenLibrary lookup, cache, timeout | EXISTS |
| `test/services_books/tradera_book_market_adapter_test.dart` | Tradera SOAP response parsing | EXISTS |
| `test/services_books/book_barcode_isbn_handoff_service_test.dart` | Handoff service flow | EXISTS |
| `test/services_books/book_scanner_isbn_handoff_coordinator_test.dart` | Coordinator logic | EXISTS |
| `test/services_books/book_isbn_draft_flow_controller_test.dart` | Draft flow states | EXISTS |
| `supabase/functions/tradera-proxy/tests/index_test.ts` | 405, 400, 429, 200 success path (Deno) | EXISTS |
| `supabase/functions/tradera-proxy/tests/parse_test.ts` | SOAP XML parsing | EXISTS |
| `supabase/functions/tradera-proxy/tests/soap_test.ts` | SOAP envelope/request building | EXISTS |
| `supabase/functions/account-delete/tests/account_delete_test.ts` | Full coverage: CORS, auth, CRUD, storage cleanup (Deno) | EXISTS |

### Gaps Identified

| Gap | Priority | Type |
|-----|----------|------|
| ScannerScreen widget tests (EN + SV) | HIGH | Widget test |
| End-to-end barcode → ISBN → lookup → draft integration test | HIGH | Integration test |
| `book-market-aggregator` Deno unit tests | HIGH | Unit test |
| `vinted-scraper` Deno unit tests | MEDIUM | Unit test |
| `bokborsen-scraper` Deno unit tests | MEDIUM | Unit test |
| Camera permission flow widget test | MEDIUM | Widget test |
| Market data display widget test (decision screen) | MEDIUM | Widget test |

---

## 2. Barcode Scanner Tests

### 2.1 Widget Tests for ScannerScreen (TO CREATE)

**File**: `test/features_scanner/scanner_screen_widget_test.dart`

| Test Case | Description | Pass Criteria |
|-----------|-------------|---------------|
| `renders scanner title in English` | Pump ScannerScreen with EN locale | `scannerTitle` ARB key text visible |
| `renders scanner title in Swedish` | Pump ScannerScreen with SV locale | Swedish `scannerTitle` text visible |
| `shows camera placeholder when no camera available` | Pump on test device without camera | Camera icon or placeholder rendered |
| `shows error banner when camera permission denied` | Mock permission as denied | ErrorBanner with `errorCameraTitle` visible |
| `capture button is disabled while capturing` | Tap capture, verify disabled state | GlassButton `onPressed` is null during save |
| `done scanning button queues items` | Mock DB, tap done | SnackBar with `scannerQueuedItems(n)` shown |
| `barcode tap copies to clipboard` | Simulate barcode tap callback | SnackBar with `snackbarCopiedBarcode` shown |
| `batch tray renders scan items` | Seed DB with 2 scan items | BatchTray shows 2 items |
| `delete scan item removes from tray` | Swipe-to-delete on batch item | Item removed, snackbar with `scannerDeletedScan` |

### 2.2 Integration Tests: Barcode → ISBN → Book Lookup Flow (TO CREATE)

**File**: `test/features_scanner/barcode_to_draft_integration_test.dart`

| Test Case | Flow Steps | Pass Criteria |
|-----------|------------|---------------|
| `valid ISBN-13 barcode creates book draft` | Scan `9789100128883` → validate → lookup (mock Google Books) → create draft | Draft with title, ISBN, and market query populated |
| `invalid barcode shows no handoff` | Scan `4006381333931` (non-book EAN) | No handoff triggered, no draft created |
| `ISBN lookup failure shows error feedback` | Scan valid ISBN → mock HTTP failure | `BookIsbnDraftFlowError` with snackbar feedback |
| `ISBN not found shows not-found feedback` | Scan valid ISBN → mock 0 results | `BookIsbnDraftFlowNotFound` with snackbar |
| `cooldown prevents duplicate handoffs` | Scan same ISBN twice within 3s | Only 1 handoff call recorded |
| `multiple barcodes: first valid ISBN wins` | Scan [non-book, valid ISBN-13, valid ISBN-10] | First valid ISBN (`978...`) used for handoff |
| `network timeout during ISBN lookup` | Mock timeout on Google Books + OpenLibrary | Graceful fallback, error state returned |

### 2.3 Edge Cases

| Edge Case | Test Approach | Expected Behavior |
|-----------|---------------|-------------------|
| Camera permission permanently denied | Mock `PermissionStatus.permanentlyDenied` | ErrorBanner with "Open Settings" retry action |
| Camera permission temporarily denied | Mock `PermissionStatus.denied` | ErrorBanner with "Continue" retry action |
| Barcode with null rawValue + valid displayValue | Unit test in adapter | Falls back to displayValue |
| Hyphenated ISBN `978-0-306-40615-7` | Unit test | Normalized to `9780306406157` |
| ISBN-10 with check digit X: `080442957X` | Unit test | Accepted, normalized to `080442957X` |
| Blank/whitespace barcode | Unit test | Returns null |
| Non-book EAN-13 prefix (e.g., `4006381333931`) | Unit test | Rejected by validator |
| Camera lifecycle: pause/resume | Widget test with `AppLifecycleState` | Camera re-initializes on resume |
| Rapid successive scans | Integration test with cooldown | Cooldown window respected |

---

## 3. Market Data Integration Tests

### 3.1 End-to-End Market Data Flow (TO CREATE)

**File**: `test/services_books/market_data_e2e_test.dart`

| Test Case | Flow | Pass Criteria |
|-----------|------|---------------|
| `full aggregation: Tradera + Vinted + Bokbörsen` | Mock all 3 sources → aggregate → compute stats | Stats: totalSales, lowest/highest/avg price, sourceCounts |
| `partial failure: Vinted down, others OK` | Mock Vinted throw, Tradera + Bokbörsen return data | Stats computed from 2 sources, Vinted absent from sourceCounts |
| `all sources empty` | All sources return `[]` | `fetchStatsForBookQuery` returns `null` |
| `deduplication across sources` | Same price+date from Tradera and Vinted | Both counted (different platforms) |
| `outlier filtering` | Inject extreme price (10x median) | Outlier excluded from stats |
| `blank query short-circuits` | Query = `"   "` | Returns null without calling sources |
| `Swedish book title with special chars` | Query = `"Barnen i Bullerbyn"` | Sources called with correct encoding |

### 3.2 Existing Unit Tests (VERIFY)

Run all existing market source tests:

```bash
fvm flutter test test/services_books/vinted_book_market_source_test.dart
fvm flutter test test/services_books/bokborsen_book_market_source_test.dart
fvm flutter test test/services_books/aggregated_book_market_service_test.dart
fvm flutter test test/services_books/tradera_book_market_adapter_test.dart
fvm flutter test test/services_books/book_market_data_service_test.dart
fvm flutter test test/services_books/book_market_service_test.dart
fvm flutter test test/services_market/
```

---

## 4. Supabase Edge Function Tests

### 4.1 Edge Functions Inventory

| Function | Path | Secrets Required | Deno Tests |
|----------|------|------------------|------------|
| `tradera-proxy` | `supabase/functions/tradera-proxy/` | `TRADERA_APP_ID`, `TRADERA_APP_KEY`, `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN` | YES (3 test files) |
| `vinted-scraper` | `supabase/functions/vinted-scraper/` | `APIFY_API_TOKEN`, `VINTED_SCRAPER_ACTOR_ID` | NO |
| `bokborsen-scraper` | `supabase/functions/bokborsen-scraper/` | None (scrapes public HTML) | NO |
| `book-market-aggregator` | `supabase/functions/book-market-aggregator/` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | NO |
| `account-delete` | `supabase/functions/account-delete/` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | YES (1 test file) |

### 4.2 Deno Unit Tests to Create

#### `vinted-scraper` tests (TO CREATE)

**File**: `supabase/functions/vinted-scraper/tests/index_test.ts`

| Test Case | Pass Criteria |
|-----------|---------------|
| OPTIONS returns 204 + CORS | Status 204, CORS headers present |
| GET returns 405 | Status 405, error.code = `method_not_allowed` |
| Invalid JSON returns 400 | Status 400, error.code = `invalid_json` |
| Query too short (< 2 chars) returns 400 | Status 400, error.code = `invalid_request` |
| Missing APIFY_API_TOKEN returns 500 | Status 500, error.code = `server_not_configured` |
| Apify run failure returns 502 | Status 502, error.code = `apify_start_failed` |
| Success path with mocked Apify | Status 200, items array with platform = "vinted" |
| Zero-price items filtered out | Items with price = 0 excluded |

#### `bokborsen-scraper` tests (TO CREATE)

**File**: `supabase/functions/bokborsen-scraper/tests/index_test.ts`

| Test Case | Pass Criteria |
|-----------|---------------|
| OPTIONS returns 204 + CORS | Status 204 |
| GET returns 405 | Status 405 |
| Invalid JSON returns 400 | Status 400 |
| Query too short returns 400 | Status 400 |
| HTML fetch failure returns 502 | Status 502, error.code = `fetch_failed` |
| Success path with fixture HTML | Status 200, items parsed correctly |
| HTML with no listings returns empty items | Status 200, items = [] |

#### `book-market-aggregator` tests (TO CREATE)

**File**: `supabase/functions/book-market-aggregator/tests/index_test.ts`

| Test Case | Pass Criteria |
|-----------|---------------|
| OPTIONS returns 204 + CORS | Status 204 |
| GET returns 405 | Status 405 |
| Invalid JSON returns 400 | Status 400 |
| Query too short returns 400 | Status 400 |
| Missing SUPABASE_URL returns 500 | Status 500, error.code = `server_not_configured` |
| All 3 sources succeed → aggregated stats | Status 200, stats with totalSales, sourceCounts |
| One source fails → partial results | Status 200, other sources present, failed source has error |
| All sources fail → null stats | Status 200, stats = null |
| Deduplication across sources | Duplicate price+date+url removed |

### 4.3 Manual curl Tests

Replace `<SUPABASE_URL>` and `<SUPABASE_ANON_KEY>` with actual values before running.

#### tradera-proxy

```bash
# Success path
curl -X POST "${SUPABASE_URL}/functions/v1/tradera-proxy" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"searchWords": "Astrid Lindgren", "itemStatus": "Ended", "orderBy": "EndDateDescending", "itemsPerPage": 5, "pageNumber": 1}'

# Expected: 200 with { totalNumberOfItems, items: [...] }

# Method not allowed
curl -X GET "${SUPABASE_URL}/functions/v1/tradera-proxy" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}"
# Expected: 405 { error: { code: "method_not_allowed" } }

# Invalid JSON
curl -X POST "${SUPABASE_URL}/functions/v1/tradera-proxy" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{broken'
# Expected: 400 { error: { code: "invalid_json" } }

# Query too short
curl -X POST "${SUPABASE_URL}/functions/v1/tradera-proxy" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"searchWords": "a"}'
# Expected: 400 { error: { code: "invalid_request" } }
```

#### vinted-scraper

```bash
# Success path
curl -X POST "${SUPABASE_URL}/functions/v1/vinted-scraper" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query": "Astrid Lindgren bok", "maxResults": 5}'

# Expected: 200 { items: [...], source: "vinted", query: "..." }

# Missing secrets (test in local dev without APIFY_API_TOKEN)
curl -X POST "http://localhost:54321/functions/v1/vinted-scraper" \
  -H "Content-Type: application/json" \
  -d '{"query": "test book"}'
# Expected: 500 { error: { code: "server_not_configured" } }
```

#### bokborsen-scraper

```bash
# Success path
curl -X POST "${SUPABASE_URL}/functions/v1/bokborsen-scraper" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query": "Astrid Lindgren", "maxResults": 5}'

# Expected: 200 { items: [...], source: "bokborsen", query: "..." }

# Empty results
curl -X POST "${SUPABASE_URL}/functions/v1/bokborsen-scraper" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query": "xyznonexistentbook12345"}'

# Expected: 200 { items: [], source: "bokborsen" }
```

#### book-market-aggregator

```bash
# Full aggregation
curl -X POST "${SUPABASE_URL}/functions/v1/book-market-aggregator" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query": "Astrid Lindgren Bröderna Lejonhjärta", "isbn": "9789100128883", "maxResults": 10}'

# Expected: 200 { query, isbn, items, stats: { highestPrice, averagePrice, lowestPrice, totalSales, sourceCounts }, sources }

# Invalid query
curl -X POST "${SUPABASE_URL}/functions/v1/book-market-aggregator" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query": "x"}'
# Expected: 400 { error: { code: "invalid_request" } }
```

#### account-delete

```bash
# Missing auth
curl -X POST "${SUPABASE_URL}/functions/v1/account-delete" \
  -H "Content-Type: application/json"
# Expected: 401 { error: "Missing bearer token" }

# Valid auth (DANGER: only run with test account)
# curl -X POST "${SUPABASE_URL}/functions/v1/account-delete" \
#   -H "Authorization: Bearer ${TEST_USER_JWT}"
# Expected: 200 { ok: true, storageError: null }
```

### 4.4 Secret Configuration Verification

| Secret | Used By | Verify Command |
|--------|---------|----------------|
| `SUPABASE_URL` | aggregator, account-delete | `supabase secrets list` |
| `SUPABASE_SERVICE_ROLE_KEY` | aggregator, account-delete | `supabase secrets list` |
| `TRADERA_APP_ID` | tradera-proxy | `supabase secrets list` |
| `TRADERA_APP_KEY` | tradera-proxy | `supabase secrets list` |
| `TRADERA_SANDBOX` | tradera-proxy (optional) | `supabase secrets list` |
| `UPSTASH_REDIS_REST_URL` | tradera-proxy | `supabase secrets list` |
| `UPSTASH_REDIS_REST_TOKEN` | tradera-proxy | `supabase secrets list` |
| `APIFY_API_TOKEN` | vinted-scraper | `supabase secrets list` |
| `VINTED_SCRAPER_ACTOR_ID` | vinted-scraper | `supabase secrets list` |

---

## 5. Manual Verification Checklist

### 5.1 iOS Simulator Testing

> **Blocker**: iOS 26 arm64 simulator issue. Use iOS 18.x simulator or physical device.

| Step | Action | Expected | Pass/Fail |
|------|--------|----------|-----------|
| 1 | Launch app on iOS 18.x simulator | App starts without crash | [ ] |
| 2 | Navigate to Scanner screen | Camera view or placeholder rendered | [ ] |
| 3 | Camera permission dialog appears | Dialog with title from `scannerCameraPermissionTitle` | [ ] |
| 4 | Grant camera permission | Camera feed visible (simulator shows black/test pattern) | [ ] |
| 5 | Verify scanner title text (EN) | Matches `app_en.arb` `scannerTitle` | [ ] |
| 6 | Switch language to Swedish | All scanner text switches to Swedish | [ ] |
| 7 | Tap Capture button | Haptic feedback, snackbar with scan ID | [ ] |
| 8 | Tap "Done Scanning" | Items queued, snackbar with count | [ ] |
| 9 | Verify batch tray shows items | Scan items listed below camera | [ ] |
| 10 | Delete a scan item | Item removed, snackbar confirmation | [ ] |

### 5.2 Physical Device Testing

| Step | Action | Expected | Pass/Fail |
|------|--------|----------|-----------|
| 1 | Launch app on physical iPhone | App starts | [ ] |
| 2 | Navigate to Scanner | Camera permission prompt | [ ] |
| 3 | Grant camera permission | Live camera feed visible | [ ] |
| 4 | Point at ISBN barcode (see test data below) | Barcode AR overlay highlights detected barcode | [ ] |
| 5 | Tap detected barcode | Value copied to clipboard, haptic feedback | [ ] |
| 6 | Scan ISBN `9789100128883` (Swedish book) | ISBN validated, handoff triggers book lookup | [ ] |
| 7 | Verify book metadata populated | Title, author from Google Books / OpenLibrary | [ ] |
| 8 | Verify market data fetched | Tradera + Vinted + Bokbörsen prices shown | [ ] |
| 9 | Verify pricing suggestion | Suggested price based on market stats | [ ] |
| 10 | Scan non-book barcode (e.g., grocery item) | No ISBN handoff, no book draft created | [ ] |
| 11 | Scan in low light | Barcode still detected (ML Kit handles low light) | [ ] |
| 12 | Scan at angle | Barcode detected from 30-45 degree angle | [ ] |
| 13 | Rapid scan 5 books in sequence | All processed, cooldown prevents duplicates | [ ] |

### 5.3 Barcode Scanning Accuracy Test

Use the sample ISBNs in Section 6. For each:

| Step | Action | Expected | Pass/Fail |
|------|--------|----------|-----------|
| 1 | Display barcode on screen (phone/laptop) | Scanner detects within 2 seconds | [ ] |
| 2 | Print barcode on paper | Scanner detects within 2 seconds | [ ] |
| 3 | Scan from physical book | Scanner detects within 2 seconds | [ ] |
| 4 | Verify ISBN-13 normalization | Hyphens stripped, correct 13-digit value | [ ] |
| 5 | Verify ISBN-10 acceptance | 10-digit with X check digit accepted | [ ] |

### 5.4 Market Data Display Verification

| Step | Action | Expected | Pass/Fail |
|------|--------|----------|-----------|
| 1 | Scan a known popular Swedish book | Market data from all 3 sources | [ ] |
| 2 | Verify Tradera prices shown | Ended auction prices, SEK | [ ] |
| 3 | Verify Vinted prices shown | Sold listing prices, SEK | [ ] |
| 4 | Verify Bokbörsen prices shown | Sold listing prices, SEK | [ ] |
| 5 | Verify aggregated stats | Lowest, highest, average, total count | [ ] |
| 6 | Verify source counts per platform | e.g., "Tradera: 5, Vinted: 3, Bokbörsen: 2" | [ ] |
| 7 | Scan obscure book with no market data | Graceful empty state, no crash | [ ] |
| 8 | Verify pricing suggestion algorithm | Suggested price within market range | [ ] |

### 5.5 Localization Verification (EN + SV)

| Key | English (app_en.arb) | Swedish (app_sv.arb) | EN Pass | SV Pass |
|-----|----------------------|----------------------|---------|---------|
| `scannerTitle` | Verify rendered | Verify rendered | [ ] | [ ] |
| `scannerSubtitle` | Verify rendered | Verify rendered | [ ] | [ ] |
| `scannerCapture` | Verify on button | Verify on button | [ ] | [ ] |
| `scannerDoneScanning` | Verify on button | Verify on button | [ ] | [ ] |
| `scannerBarcodeAimHint` | Verify in overlay | Verify in overlay | [ ] | [ ] |
| `scannerCameraPermissionTitle` | Verify in dialog | Verify in dialog | [ ] | [ ] |
| `scannerCameraPermissionBody` | Verify in dialog | Verify in dialog | [ ] | [ ] |
| `scannerCameraPermissionDenied` | Verify in error | Verify in error | [ ] | [ ] |
| `snackbarCopiedBarcode` | Verify in snackbar | Verify in snackbar | [ ] | [ ] |
| `snackbarSavedScan` | Verify in snackbar | Verify in snackbar | [ ] | [ ] |
| `errorCameraTitle` | Verify in error banner | Verify in error banner | [ ] | [ ] |

---

## 6. Test Data: Sample ISBN Barcodes

### Valid ISBN-13 (Swedish books — use for real scanning tests)

| ISBN-13 | Book | Notes |
|---------|------|-------|
| `9789100128883` | Astrid Lindgren — Bröderna Lejonhjärta | Swedish classic, likely has Tradera data |
| `9789100575173` | Astrid Lindgren — Pippi Långstrump | High market data availability |
| `9789170375576` | Stieg Larsson — Män som hatar kvinnor | Popular, good Tradera coverage |
| `9789100115203` | Astrid Lindgren — Mio min Mio | Swedish classic |
| `9789113121949` | Selma Lagerlöf — Nils Holgerssons underbara resa | Classic |

### Valid ISBN-13 (International — good for Google Books lookup)

| ISBN-13 | Book | Notes |
|---------|------|-------|
| `9780306406157` | Test ISBN (widely used in examples) | Google Books + OpenLibrary |
| `9780140449136` | Don Quixote (Penguin Classics) | High availability |
| `9780061120084` | To Kill a Mockingbird | High availability |

### Valid ISBN-10

| ISBN-10 | Book | Notes |
|---------|------|-------|
| `0306406152` | Test ISBN-10 | Equivalent to 9780306406157 |
| `080442957X` | Test ISBN-10 with X check digit | Tests X normalization |

### Invalid / Non-Book Barcodes (for rejection tests)

| Value | Type | Expected Behavior |
|-------|------|-------------------|
| `4006381333931` | EAN-13 (non-book prefix 400) | Rejected by validator |
| `0123456789012` | EAN-13 (invalid checksum) | Rejected by validator |
| `not an isbn` | Text | Rejected by adapter |
| `   ` | Whitespace | Rejected by adapter |
| `97891` | Truncated | Rejected by validator |
| `978ABCDEFGHIJ` | Malformed | Rejected by validator |
| `9789100128884` | ISBN-13 with wrong checksum | Rejected by validator |

---

## 7. Screenshot & Recording Requirements

Per AGENTS.md Definition of Done: **PR body must have screenshots or recording for UI changes.**

| Change Type | Required Evidence |
|-------------|-------------------|
| ScannerScreen layout changes | Screenshot in EN + SV |
| Barcode AR overlay changes | Screen recording showing detection |
| Error banner changes | Screenshot of error state |
| Market data display changes | Screenshot with real market data |
| Permission flow changes | Screen recording of permission dialog flow |
| Batch tray changes | Screenshot with multiple items |

### Recording Checklist

- [ ] Scanner screen in English (full scroll)
- [ ] Scanner screen in Swedish (full scroll)
- [ ] Barcode detection AR overlay in action
- [ ] Camera permission dialog (first time)
- [ ] Camera permission denied error state
- [ ] Book draft created from ISBN scan
- [ ] Market data display for a known book
- [ ] Empty state for unknown book

---

## 8. Known Blockers

| Blocker | Impact | Workaround |
|---------|--------|------------|
| iOS 26 arm64 simulator issue | Cannot test on latest iOS simulator | Use iOS 18.x simulator or physical device |
| Supabase invoice blocker | Cannot deploy/test edge functions in production | Use `supabase functions serve` locally for development testing |

### Local Edge Function Testing

```bash
# Start Supabase locally
supabase start

# Deploy functions locally
supabase functions serve

# Set secrets locally
supabase secrets set \
  TRADERA_APP_ID=<test_id> \
  TRADERA_APP_KEY=<test_key> \
  APIFY_API_TOKEN=<test_token> \
  VINTED_SCRAPER_ACTOR_ID=<test_actor>

# Run Deno tests
deno test supabase/functions/tradera-proxy/tests/
deno test supabase/functions/account-delete/tests/
```

---

## Test Execution Order

1. **Run all existing Flutter tests** (~5 min)
   ```bash
   fvm flutter test
   ```

2. **Run existing Deno tests** (~1 min)
   ```bash
   deno test supabase/functions/tradera-proxy/tests/
   deno test supabase/functions/account-delete/tests/
   ```

3. **Run `flutter analyze`** (~2 min)
   ```bash
   fvm flutter analyze
   ```

4. **Manual curl tests against local Supabase** (~15 min)

5. **Create missing widget tests** (~30 min dev time)

6. **Create missing Deno unit tests** (~30 min dev time)

7. **Manual physical device testing** (~45 min)

8. **Localization verification** (~15 min)
