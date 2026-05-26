---
phase: 02-cloud-ai-privacy-controls
verified: 2026-02-22T14:49:36Z
status: gaps_found
score: 2/5 must-haves verified
gaps:
  - truth: "Before any cloud identification upload occurs, the user sees a first-use disclosure and can change this choice later"
    status: failed
    reason: "Cloud inference runs automatically after scan capture without checking disclosure choice or the cloud-identification toggle"
    artifacts:
      - path: "lib/features/scanner/scan_capture_service.dart"
        issue: "Calls `_aiInference.run(...)` in backgroundWork with no checks for `kCloudIdentificationDisclosureChoiceKeyV1` or `kPrivacyCloudIdentificationEnabledKeyV1`"
    missing:
      - "Gate background AI inference on (1) disclosure accepted, (2) cloud toggle enabled, and (3) online + proxy configured; otherwise skip cloud call"
      - "Ensure 'Not now' choice prevents any upload until the user explicitly enables"
  - truth: "When cloud identification is disabled, the app performs no cloud identification image uploads and the UI reflects that identification is disabled"
    status: failed
    reason: "UI disables Identify, but scan capture still runs AI inference which can upload crops even when the setting is OFF"
    artifacts:
      - path: "lib/features/scanner/scan_capture_service.dart"
        issue: "No enforcement of cloud identification disabled setting"
    missing:
      - "Enforce `kPrivacyCloudIdentificationEnabledKeyV1 == 1` before any cloud upload path (including background inference)"
---

# Phase 2: Cloud AI + Privacy Controls Verification Report

**Phase Goal:** Users can identify items via cloud AI by default (when online and allowed) with clear, reversible privacy controls and no first-run model download.
**Verified:** 2026-02-22T14:49:36Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Roadmap Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | On a fresh install, the user can complete core flows (scan/capture, save items, browse/edit) without downloading any on-device AI model. | ✓ VERIFIED | `pubspec.yaml` has no `flutter_gemma`; `lib/main.dart` does not auto-install/warm up a model download; no Gemma prompts in `lib/features/dashboard/dashboard_screen.dart`. |
| 2 | Before any cloud identification upload occurs, the user sees a first-use disclosure explaining what data is uploaded, and they can change this choice later. | ✗ FAILED | `lib/features/scanner/scan_capture_service.dart` runs `_aiInference.run(...)` automatically after capture with no consent/toggle gating; can upload even when disclosure choice is "Not now". |
| 3 | When online and cloud identification is enabled, the user can run identification and receive results; the mobile app ships no cloud AI API keys. | ? UNCERTAIN | No client keys found in `lib/` and app calls proxy via `lib/services/ai/cloud_ai_proxy_client.dart`; end-to-end success depends on a deployed `supabase/functions/cloud-ai-proxy/index.ts` + configured `CLOUD_AI_PROXY_URL`. |
| 4 | When cloud identification is disabled, the app performs no cloud identification image uploads and the UI reflects that identification is disabled. | ✗ FAILED | UI disables Identify in `lib/features/analyzer/item_detail_screen.dart`, but background capture inference still runs in `lib/features/scanner/scan_capture_service.dart`. |
| 5 | The disclosure/settings make it explicit that only minimal image data is uploaded (e.g., crops) and metadata is stripped. | ✓ VERIFIED | Disclosure copy in `lib/l10n/app_en.arb`/`lib/l10n/app_sv.arb`; crop+re-encode implementation in `lib/services/ai/image_cropper.dart`. |

**Score:** 2/5 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|---------|----------|--------|---------|
| `supabase/functions/cloud-ai-proxy/index.ts` | Server-side Gemini proxy; reads secrets from env | ✓ VERIFIED | Uses `Deno.env.get('GEMINI_API_KEY')`, calls generativelanguage API via `fetch`, sets `cache-control: no-store`, does not persist payload. |
| `supabase/functions/cloud-ai-proxy/types.ts` | Request/response types | ✓ VERIFIED | Defines `CloudAiProxyRequest`/`CloudAiProxyResponse`. |
| `lib/core/config/app_config.dart` | Cloud proxy URL config | ✓ VERIFIED | Adds `CLOUD_AI_PROXY_URL` and `hasCloudAiProxy`. |
| `lib/main.dart` | Default cloud backend when configured | ✓ VERIFIED | Sets `AiBackendKind.cloudGemini` when `config.hasCloudAiProxy`. |
| `lib/services/ai/cloud_ai_proxy_client.dart` | Posts crop JPEG base64 to proxy | ✓ VERIFIED | Sends `{prompt,maxTokens,imageBase64Jpeg}` with `no-store`; handles error payload. |
| `lib/services/ai/image_cropper.dart` | Crops + re-encodes JPEG (metadata stripped) | ✓ VERIFIED | Center-square crop, resize, re-encode, size budget enforcement. |
| `lib/features/onboarding/onboarding_screen.dart` | First-use disclosure entrypoint | ✓ VERIFIED | Shows blocking disclosure on first run; stores choice. |
| `lib/features/settings/settings_screen.dart` | Privacy & Data toggles visible to all users | ✓ VERIFIED | "Privacy & Data" section; toggles persisted via `AppSettingsDao`. |
| `lib/features/analyzer/item_detail_screen.dart` | Identify button gating + reprompt | ✓ VERIFIED | Disables when toggle off; checks online; re-prompts disclosure before calling inference. |
| `lib/features/scanner/scan_capture_service.dart` | Background inference respects privacy controls | ✗ FAILED | Runs inference automatically without checking disclosure/toggle/online state; can trigger uploads unexpectedly. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `lib/main.dart` | `AiBackendKind.cloudGemini` | constructor arg | ✓ WIRED | Default backend flips to cloud when proxy configured. |
| `lib/services/ai/inference/inference_isolate_service.dart` | Proxy call | `CloudAiProxyClient.generate` | ✓ WIRED | Cloud path crops via `ImageCropper` then posts to proxy. |
| `lib/features/analyzer/item_detail_screen.dart` | Privacy settings + disclosure | `AppSettingsDao.getInt` | ✓ WIRED | Checks `kPrivacyCloudIdentificationEnabledKeyV1` + `kCloudIdentificationDisclosureChoiceKeyV1` before calling inference. |
| `lib/features/scanner/scan_capture_service.dart` | Privacy settings + disclosure | (missing) | ✗ NOT_WIRED | No checks exist; background inference can upload even when disallowed. |
| `lib/services/market/market_bridge.dart` | Comps toggle | `AppSettingsDao.getInt` | ✓ WIRED | Checks `kPrivacyFetchSoldPriceCompsEnabledKeyV1` before calling `_tradera.searchEnded`. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|------------|------------|-------------|--------|----------|
| AI-01 | 02-03-PLAN | First run usable without on-device model download | ✓ SATISFIED | No `flutter_gemma` in `pubspec.yaml`; no auto-download wiring in `lib/main.dart`. |
| AI-02 | 02-03-PLAN | Cloud identification default when online + allowed | ✗ BLOCKED | Cloud backend is default when configured, but "allowed" is not enforced in scan-capture background inference (`lib/features/scanner/scan_capture_service.dart`). |
| AI-03 | 02-01-PLAN | Proxy server-side; no client keys | ✓ SATISFIED | Edge function uses `GEMINI_API_KEY`; no client key usage found in `lib/`. |
| AI-04 | 02-02-PLAN | User can disable cloud identification; no uploads when disabled | ✗ BLOCKED | Setting disables Identify UI, but scan capture background inference can still call cloud backend. |
| PRIV-01 | 02-02-PLAN | First-use disclosure + reversible control | ✗ BLOCKED | Disclosure exists, but "Not now" does not prevent background upload on capture. |
| PRIV-02 | 02-02-PLAN | Settings toggles for crops upload + comps (default ON) | ✓ SATISFIED | Toggles exist in `lib/features/settings/settings_screen.dart`; default ON via `watchInt(...).map((v) => (v ?? 1) == 1)`. |
| PRIV-03 | 02-03-PLAN | Upload minimum data only; strip metadata | ✓ SATISFIED | `lib/services/ai/image_cropper.dart` re-encodes JPEG; disclosure copy states crops-only + metadata stripped. |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/features/scanner/scan_capture_service.dart` | (backgroundWork) | Automatic inference without consent/toggle gating | 🛑 Blocker | Can upload images even when user selected "Not now" or disabled cloud identification. |

## Human Verification Checklist (After Gaps Fixed)

### 1) Fresh install, no on-device model download

**Test:** Install fresh, complete onboarding, scan and save an item, browse/edit item.
**Expected:** No prompts to download an on-device model; app remains usable.
**Why human:** Confirms no hidden UI prompts and no runtime install flows.

### 2) "Not now" prevents uploads

**Test:** Fresh install, choose "Not now" in disclosure, then scan an item while online.
**Expected:** No cloud request is made; item saves normally; Identify action should re-prompt disclosure.
**Why human:** Verifies network behavior + background inference gating.

### 3) Cloud toggle OFF prevents uploads

**Test:** In Settings -> Privacy & Data, toggle OFF "Send crops for cloud identification"; then scan an item (online) and tap Identify.
**Expected:** No cloud request is made in background or on Identify; Identify disabled and shows hint + Open Settings.
**Why human:** Confirms UI + all upload paths are enforced.

### 4) Offline behavior

**Test:** Enable cloud identification, go offline, then tap Identify.
**Expected:** Fail-fast offline message with Retry + Open Settings; no queued upload.
**Why human:** Connectivity edge cases are difficult to prove statically.

### 5) End-to-end cloud identify works

**Test:** Configure `CLOUD_AI_PROXY_URL` and deploy `cloud-ai-proxy` with secrets; scan an item and run Identify.
**Expected:** AI keywords/desc populate; DB fields updated; no client key present in app build.
**Why human:** Requires real deployed edge function and network.

## Gaps Summary

The phase has the cloud proxy, disclosure UI, and privacy toggles implemented, and cloud identification can run through the proxy when invoked from the item detail screen.

However, the scanner capture pipeline runs AI inference automatically in the background without checking the user's disclosure choice or the cloud-identification toggle. This can cause cloud uploads even when the user selected "Not now" or explicitly turned cloud identification OFF, which breaks the core privacy goal and blocks AI-02/AI-04/PRIV-01.

---

_Verified: 2026-02-22T14:49:36Z_
_Verifier: Claude (gsd-verifier)_
