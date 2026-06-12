# ISBN Scanner → Draft: Broken Wiring Fix

## Problem
Scanning a book barcode shows the barcode in the AR overlay (visual detection works) but nothing happens: no draft is created, no fields are populated, no feedback is shown.

## Root Cause Analysis

### BW-1 (CRITICAL): Future discarded — no user feedback in scanner
`scanner_screen.dart:_handleBarcodes` calls `handoff.maybeHandoffBarcodes(...)` but discards the returned `Future<BookIsbnDraftFlowState?>`. The draft IS written to the DB (the ValueNotifier in `BookIsbnDraftFlowController` fires correctly), but:
- The scanner screen shows zero feedback (no snackbar, no toast)
- The user sees the scanner, the AR box flashes, and nothing else
- The feedback utility `scannerBookIsbnHandoffFeedbackFor` exists and is correct but is dead code — never called from `ScannerScreen`

Fix: make `_handleBarcodes` async, await the handoff, use `scannerBookIsbnHandoffFeedbackFor` to show a `ScaffoldMessenger` snackbar, then pop the scanner on success.

### BW-2 (HIGH): scanner auto-closes after success — but currently never does
When a barcode is scanned from `DraftEditorScreen` (via `bookDraftScanItemId`), the expected UX is:
1. Scanner opens
2. User points at barcode
3. Draft is created / found / errored
4. Scanner auto-dismisses and user is back at the draft editor with fields populated

Currently step 3–4 never happen. Fix: `Navigator.of(context).pop()` after a success state.

### BW-3 (MEDIUM): Manual apply button — unawaited future
`draft_editor_screen.dart:585` — `flowController.createDraft(...)` future not awaited. Functional (ValueNotifier drives UI), but suppresses lint and prevents post-completion actions (e.g., clearing the ISBN input on success).

### BW-4 (MEDIUM): `IsbnLookupService` — `SocketException` not caught
`isbn_lookup_service.dart:_getJsonObject` catches `FormatException`, `TimeoutException`, `http.ClientException` but not `dart:io.SocketException`. On some Android devices/networks, DNS failures throw `SocketException` directly (not wrapped in `ClientException`). This leaks up to `BookIsbnDraftFlowController.createDraft`'s catch block and becomes a raw error message shown to the user.

Fix: catch `Exception` broadly or add explicit `SocketException` import.

## Files Changed

| File | Change |
|---|---|
| `lib/features/scanner/scanner_screen.dart` | Make `_handleBarcodes` async; await handoff; show snackbar; pop on success |
| `lib/features/drafts/draft_editor_screen.dart` | Add `unawaited()` annotation on manual apply |
| `lib/services/books/isbn_lookup_service.dart` | Catch `Exception` in `_getJsonObject` to cover `SocketException` |

## Test Plan
1. Open any draft editor item
2. Tap the barcode scan icon
3. Point camera at book ISBN barcode
4. Expected: AR overlay highlights barcode → snackbar appears ("Draft ready" or "Not found") → scanner dismisses → draft editor fields populated
5. Test "not found": scan a non-book barcode → snackbar shows not-found message, scanner stays open
6. Test offline: disable wifi → scan → snackbar shows error (not crash)
