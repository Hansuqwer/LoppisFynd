---
phase: 03-sold-price-comps-hardening
verified: 2026-02-23T07:03:41.750Z
status: gaps_found
score: 3/4 must-haves verified
gaps:
  - truth: "When background comps are enabled, comps refresh attempts happen automatically (best-effort) and update items when successful"
    status: partial
    reason: "Toggling 'Fetch sold-price comps' in Settings updates the flag but does not (re)schedule/cancel Workmanager periodic work immediately; background refresh may not start after enabling until next app start or another call to BackgroundSync.scheduleIfConfigured."
    artifacts:
      - path: "lib/features/settings/settings_screen.dart"
        issue: "Comps toggle onChanged writes kPrivacyFetchSoldPriceCompsEnabledKeyV1 but never calls BackgroundSync.scheduleIfConfigured."
      - path: "lib/services/sync/background/background_sync.dart"
        issue: "Has correct gating + cancel logic, but relies on scheduleIfConfigured being invoked after setting changes."
    missing:
      - "Call BackgroundSync.scheduleIfConfigured(db: db) after changing kPrivacyFetchSoldPriceCompsEnabledKeyV1 (both enable and disable)."
      - "(Optional) Surface a brief snackbar/toast if background scheduling is unavailable due to missing proxy config."
---

# Phase 3: Sold-Price Comps Hardening Verification Report

**Phase Goal:** Sold-price comps work reliably on demand and in background when enabled, with a true off switch and robust proxy protection.
**Verified:** 2026-02-23T07:03:41.750Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Success Criteria)

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | The user can fetch sold-price comps on demand for an item and see that results are associated with a last-updated time. | ✓ VERIFIED | `lib/features/analyzer/item_detail_screen.dart` renders "Last updated" from `ScanItemComps.fetchedAt`; `lib/services/sync/sync_scheduler.dart` upserts comps with `fetchedAt: now`. |
| 2 | When background comps are enabled, comps refresh attempts happen automatically (best-effort) and update items when successful. | ✗ FAILED | Workmanager scheduling exists (`lib/main.dart` calls `BackgroundSync.scheduleIfConfigured`), but Settings comps toggle does not trigger (re)scheduling; enabling can leave periodic work canceled until restart. |
| 3 | When the user disables sold-price comps, the app performs no comps network calls and the UI clearly indicates comps are disabled. | ✓ VERIFIED | `lib/services/sync/sync_scheduler.dart` early-returns before quotas/status/market calls; `lib/services/sync/background/background_sync.dart` returns before constructing `TraderaClient`; `lib/features/analyzer/item_detail_screen.dart` disables comps actions + shows disabled hint; regression test in `test/services_sync/fl_042_sync_scheduler_test.dart`. |
| 4 | When the proxy rate-limits/blocks/errors, the user sees a clear, actionable error state and core app flows still work. | ✓ VERIFIED (code-path) | `supabase/functions/tradera-proxy/index.ts` returns stable `{error:{code,message,retryAfterSeconds?}}` (incl 429 retry-after); `lib/services/market/tradera_client.dart` maps to concise `TraderaClientException`; `lib/services/sync/sync_scheduler.dart` persists `lastError/nextAttemptAt`; UI shows error panel in `lib/features/analyzer/item_detail_screen.dart`. |

**Score:** 3/4 truths verified

### Required Artifacts (Exists + Substantive + Wired)

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `lib/services/sync/sync_scheduler.dart` | True no-op gating when comps disabled | ✓ VERIFIED | Reads `kPrivacyFetchSoldPriceCompsEnabledKeyV1` and returns before quota/status/market calls; emits start/finish events. |
| `lib/services/sync/background/background_sync.dart` | Background scheduling/execution respects comps enabled + proxy configured | ✓ VERIFIED | Cancels periodic work when disabled/proxy-missing; callback exits early before network client. |
| `lib/features/analyzer/item_detail_screen.dart` | Last-updated + disabled/offline/proxy-missing states | ✓ VERIFIED | Renders last updated, disables actions when unavailable, shows disabled/offline/proxy-not-configured hints, shows last sync error. |
| `test/services_sync/fl_042_sync_scheduler_test.dart` | No-network contract when disabled | ✓ VERIFIED | Test sets setting to 0 and asserts no quota/state churn and no market calls (throwing market). |
| `supabase/functions/tradera-proxy/index.ts` | Rate-limited proxy + stable JSON error contract | ✓ VERIFIED | Upstash-backed sliding window + stable error envelope + retry-after + no-store. |
| `supabase/functions/tradera-proxy/tests/index_test.ts` | Proxy contract + rate-limit behavior tests | ✓ VERIFIED | Covers 405/400/429 + success response shape. |
| `lib/services/market/tradera_client.dart` | Typed/actionable proxy error mapping | ✓ VERIFIED | Parses error envelope; treats 429 as actionable; bounded retries for 5xx; concise messages. |
| `test/services_market/fl_041_tradera_client_test.dart` | Client mapping + retry behavior tests | ✓ VERIFIED | Covers 429 mapping and 5xx retry recovery. |

### Key Link Verification (Wiring)

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `lib/services/sync/sync_scheduler.dart` | `lib/core/settings/app_settings_keys.dart` | DB read of comps enabled key | ✓ WIRED | Uses `kPrivacyFetchSoldPriceCompsEnabledKeyV1` with null -> enabled. |
| `lib/services/sync/background/background_sync.dart` | workmanager | schedule + cancel + executeTask | ✓ WIRED | `registerPeriodicTask`, `cancelByUniqueName`, `executeTask` present. |
| `lib/features/analyzer/item_detail_screen.dart` | `lib/core/app/providers.dart` | Provider gating for UI | ✓ WIRED | Watches `fetchSoldPriceCompsEnabledProvider`, `isOnlineProvider`, `appConfigProvider`. |
| `supabase/functions/tradera-proxy/index.ts` | Upstash env | Durable rate limiting | ✓ WIRED | Reads `UPSTASH_REDIS_REST_URL`/`UPSTASH_REDIS_REST_TOKEN`; fail-closed `server_not_configured`. |
| `lib/services/market/tradera_client.dart` | Proxy error contract | code/message/retryAfterSeconds | ✓ WIRED | Parses `error.code`, `error.message`, `error.retryAfterSeconds`, plus `retry-after` header. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| MKT-01 | `03-01-PLAN.md` | Sold-price comps can be fetched on demand and in background when enabled | ⚠️ PARTIAL | On-demand + last-updated verified; background scheduling exists but not triggered when enabling via Settings toggle.
| MKT-02 | `03-01-PLAN.md` | User can disable sold-price comps; when disabled, the app performs no comps network calls | ✓ SATISFIED | Scheduler + background executor short-circuit; UI disables actions; test enforces no-op.
| MKT-03 | `03-02-PLAN.md` | Tradera proxy is protected against abuse and has clear error handling | ? NEEDS HUMAN | Code + unit tests cover rate limiting + stable error contract; real protection requires configuring Upstash secrets and deploying the Edge Function.

**Requirements cross-check:** Plan frontmatter declares `MKT-01`, `MKT-02`, `MKT-03`; all three exist in `.planning/REQUIREMENTS.md` and are mapped to Phase 3 in the traceability table. No additional Phase 3 requirements appear to be orphaned.

### SUMMARY.md Self-Checks

| File | Tool Verification |
| --- | --- |
| `.planning/phases/03-sold-price-comps-hardening/03-01-SUMMARY.md` | `gsd-tools verify-summary` => passed; commit hashes exist (`1a07bbc`, `74133ec`). |
| `.planning/phases/03-sold-price-comps-hardening/03-02-SUMMARY.md` | `gsd-tools verify-summary` => passed; commit hashes exist (`5ef2af6`, `4716d39`). |

## Human Verification Required

### 1. Background Enable/Disable Scheduling

**Test:** In Settings, toggle "Fetch sold-price comps" OFF then ON (without restarting). Wait >1 interval tick (or use logs) and confirm periodic background sync gets (re)scheduled and actually runs when enabled.
**Expected:** OFF cancels periodic work; ON schedules periodic work; background runs update items when successful.
**Why human:** Workmanager behavior and scheduling persistence require device/emulator runtime.

### 2. Proxy Rate Limit UX (Deployed)

**Test:** Deploy `tradera-proxy` with Upstash secrets, then trigger rate limiting (repeated requests). Observe app error UI on Item Detail after a sync attempt.
**Expected:** HTTP 429 returns stable error envelope + retry-after; client surfaces actionable message (incl retry delay) and app remains usable.
**Why human:** Requires deployed Edge Function + real network; UX clarity is subjective.

## Gaps Summary

Background syncing is correctly gated at execution time, but enabling/disabling sold-price comps in Settings does not immediately update Workmanager scheduling. This can leave background refresh inactive after enabling (if it was previously canceled at startup) until the next app start or another scheduling trigger.

---

_Verified: 2026-02-23T07:03:41.750Z_
_Verifier: Claude (gsd-verifier)_
