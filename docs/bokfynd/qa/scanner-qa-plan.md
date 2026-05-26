# BokFynd scanner QA plan

Status: pre-live-camera checklist  
Scope: opt-in BokFynd ISBN scanner route only

Use this checklist before attempting a live camera/device test. The goal is to verify the reviewed service and route behavior with predictable data first, then decide whether a real camera test is worth the time.

## Scope

In scope:

- Manual ISBN entry in the BokFynd panel.
- The BokFynd scan action from `DraftEditorScreen`.
- `ScannerScreen(bookDraftScanItemId: scanItemId)` route context.
- ML Kit barcode values converted into validated ISBNs.
- Draft-flow result feedback for success, not-found, and error.
- Duplicate scan suppression.
- Returning from the scanner route to the draft editor.

Out of scope:

- Normal scanner tab behavior changes.
- Live camera reliability claims.
- Device-specific ML Kit performance.
- App-store readiness.
- Backend load testing.

## Prerequisites

- Test build uses a seeded draft scan item.
- The draft editor opens for that exact `scanItemId`.
- Google Books/Open Library responses are controlled through fake service data or a stable test network setup.
- Preferred dev-only stable data mode:

  ```sh
  flutter run -d emulator-5554 --debug --no-pub --flavor dev \
    --dart-define=APP_ENV=dev \
    --dart-define=BOKFYND_QA_STABLE_ISBN_DATA=true
  ```

- Stable ISBNs in that mode:
  - success: `9780306406157`
  - not found: `9780143127796`
  - forced error: `0306406152`
- Tradera proxy can be disabled unless explicitly testing market-stat enrichment.
- Camera permission behavior is tested separately in the existing scanner QA matrix.

## Manual checklist

### 1. Normal scanner tab remains unchanged

Steps:

1. Open the app normally.
2. Tap the Scanner tab.
3. Confirm the scanner screen opens without a BokFynd draft context.
4. Tap a visible barcode chip if one appears.

Expected:

- Scanner tab does not create or update a BokFynd draft.
- Barcode chip tap still copies the barcode value.
- Existing snackbar says the barcode was copied.
- Existing auto-capture behavior is not blocked by BokFynd logic.

Evidence:

- Screen recording or short note: `normal scanner tab: no BokFynd context`.

### 2. Draft editor opens opt-in scanner route

Steps:

1. Open a draft item.
2. Find the BokFynd ISBN panel.
3. Tap the ISBN scan action.

Expected:

- A scanner route opens from the draft editor.
- The scanner route is tied to the current draft `scanItemId`.
- Manual ISBN entry remains available when returning to the draft.

Evidence:

- Screen recording or note with draft `scanItemId`.

### 3. Success path

Setup:

- Use a valid ISBN that resolves to metadata.
- Prefer `9780306406157` when the dev-only stable lookup stack is active.

Steps:

1. Open the BokFynd scanner route from a draft item.
2. Present the valid ISBN barcode.
3. Wait for the draft flow to complete.

Expected:

- The first valid ISBN is accepted.
- Draft metadata is applied to the same `scanItemId`.
- A snackbar confirms the BokFynd draft was updated.
- Snackbar includes `Back to draft`.
- Tapping `Back to draft` returns to the draft editor.
- The draft editor shows the updated draft fields.

Evidence:

- Before/after draft state.
- Snackbar text.
- Confirmation that route returned to the same draft item.

### 4. Not-found path

Setup:

- Use `9780143127796` when the dev-only stable lookup stack is active.

Steps:

1. Open the BokFynd scanner route from a draft item.
2. Present the not-found ISBN barcode.
3. Wait for the draft flow to complete.

Expected:

- The barcode is accepted as an ISBN.
- No draft fields are overwritten with empty data.
- A snackbar says no book metadata matched.
- `Back to draft` returns to the draft editor.

Evidence:

- Snackbar text.
- Draft remains unchanged.

### 5. Error path

Setup:

- Use `0306406152` when the dev-only stable lookup stack is active, or force the lookup/orchestration layer to return an error with another controlled failing test service.

Steps:

1. Open the BokFynd scanner route from a draft item.
2. Present a valid ISBN barcode.
3. Wait for the error result.

Expected:

- Scanner does not crash.
- Existing barcode overlay remains usable.
- A snackbar shows the draft error message.
- `Back to draft` returns to the draft editor.
- Draft data is not partially overwritten.

Evidence:

- Snackbar text.
- Error note with fake/test setup used.

### 6. Duplicate scan suppression

Setup:

- Use one valid ISBN.

Steps:

1. Open the BokFynd scanner route from a draft item.
2. Present the same valid ISBN repeatedly inside three seconds.
3. Keep the same barcode visible past the cooldown.

Expected:

- First scan starts one draft handoff.
- Duplicate detections inside the cooldown do not start additional handoffs.
- After cooldown, the same ISBN can trigger again if still visible.
- User does not see stacked snackbar spam during the cooldown.

Evidence:

- Count of handoff events or visible snackbar count.

### 7. Multiple barcodes visible

Setup:

- Present at least one non-book barcode and one valid ISBN barcode.

Steps:

1. Open the BokFynd scanner route from a draft item.
2. Present both barcodes.

Expected:

- Non-book barcode is ignored for BokFynd.
- First valid ISBN is selected.
- Normal barcode overlay can still show detected barcode values.

Evidence:

- Note which ISBN was selected.

## Optional integration-test plan

Do this only after the manual checklist above passes.

Recommended order:

1. Widget-level route test: draft editor scan action opens `ScannerScreen(bookDraftScanItemId: scanItemId)`.
2. Controller-level scanner test: fake ML Kit `Barcode` values produce success, not-found, error, and duplicate-suppression outcomes.
3. Integration-level fake scanner test: inject deterministic barcode values into the handoff controller without using a camera.
4. Device-level smoke: run on one Android device first with real camera input.
5. iOS smoke only after Android is stable.

Do not start with a live camera test. It mixes camera permission, ML Kit recognition, device focus, lighting, routing, service orchestration, and draft persistence in one failure surface.

## Current automated coverage

Existing tests already cover:

- ISBN validation.
- ML Kit barcode value adaptation.
- scanner-side handoff controller decision logic.
- service-level handoff coordinator.
- draft-editor route into scanner context.
- normal scanner tab has no BokFynd context.
- feedback mapping for success and error.

Known gap:

- No live camera/device test yet.
- No end-to-end test that physically scans a printed ISBN.

## Stop conditions

Stop before live-device testing if any of these fail:

- Normal scanner tab creates or updates a BokFynd draft.
- Duplicate scans create repeated draft updates inside the cooldown.
- `Back to draft` returns to the wrong route.
- Not-found or error paths overwrite existing draft data.
- Barcode copy/tap behavior regresses.
