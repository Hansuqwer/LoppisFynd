---
phase: 03-sold-price-comps-hardening
verified: 2026-02-23T21:29:26Z
status: human_needed
score: 4/4 must-haves verified
re_verification:
  previous_status: gaps_found
  previous_score: 3/4
  gaps_closed:
    - "When background comps are enabled, comps refresh attempts happen automatically (best-effort) and update items when successful"
  gaps_remaining: []
  regressions: []
human_verification:
  - test: "Background scheduling reacts immediately to Settings toggle"
    expected: "Toggling 'Fetch sold-price comps' OFF cancels periodic work; toggling ON (no restart) schedules periodic work; background runs best-effort when enabled + proxy configured."
    why_human: "Workmanager scheduling/execution must be verified on device/emulator; this repo change wires rescheduling, but runtime behavior is environment/device-dependent."
  - test: "Proxy rate limiting + error UX with deployed tradera-proxy"
    expected: "With Upstash secrets configured and Edge Function deployed, repeated requests trigger HTTP 429 with stable {error:{code,message,retryAfterSeconds}} + retry-after; app surfaces actionable error and remains usable."
    why_human: "Requires deployed Supabase Edge Function + Upstash configuration and real network; UX clarity is subjective."
---

# Phase 3: Sold-Price Comps Hardening Verification Report

**Phase Goal:** Sold-price comps work reliably on demand and in background when enabled, with a true off switch and robust proxy protection.
**Verified:** 2026-02-23T21:29:26Z
**Status:** human_needed
**Re-verification:** Yes — after gap closure

## Goal Achievement

### Observable Truths (Success Criteria)

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | The user can fetch sold-price comps on demand for an item and see that results are associated with a last-updated time. | ✓ VERIFIED | `lib/features/analyzer/item_detail_screen.dart` renders "Last updated" from comps `fetchedAt`; `lib/services/sync/sync_scheduler.dart` upserts comps with `fetchedAt: now` and updates item market stats. |
| 2 | When background comps are enabled, comps refresh attempts happen automatically (best-effort) and update items when successful. | ✓ VERIFIED (code-path) | `lib/main.dart` initializes Workmanager and calls `BackgroundSync.scheduleIfConfigured(db: db)` at startup; `lib/features/settings/settings_screen.dart` now calls `BackgroundSync.scheduleIfConfigured(db: db)` after toggling `kPrivacyFetchSoldPriceCompsEnabledKeyV1`, so enable/disable immediately reschedules/cancels. Background task execution is gated in `lib/services/sync/background/background_sync.dart` and runs `SyncScheduler.syncOnce()` best-effort. |
| 3 | When the user disables sold-price comps, the app performs no comps network calls and the UI clearly indicates comps are disabled. | ✓ VERIFIED | `lib/services/sync/sync_scheduler.dart` returns before quota/pending items/market calls when `kPrivacyFetchSoldPriceCompsEnabledKeyV1 != 1`; `lib/services/sync/background/background_sync.dart` cancels work when disabled and exits early in `callbackDispatcher`; `lib/features/analyzer/item_detail_screen.dart` disables comps actions and shows an "Open settings" hint; regression test in `test/services_sync/fl_042_sync_scheduler_test.dart`. |
| 4 | When the proxy rate-limits/blocks/errors, the user sees a clear, actionable error state and core app flows still work. | ✓ VERIFIED (code-path) | `supabase/functions/tradera-proxy/index.ts` enforces durable Upstash rate limiting and returns stable `{error:{code,message,retryAfterSeconds?}}` with `retry-after` on 429; `lib/services/market/tradera_client.dart` maps this to concise actionable exceptions; `lib/services/sync/sync_scheduler.dart` persists `lastError/nextAttemptAt` and `lib/features/analyzer/item_detail_screen.dart` surfaces them. Proxy + client behaviors covered by `supabase/functions/tradera-proxy/tests/index_test.ts` and `test/services_market/fl_041_tradera_client_test.dart`. |

**Score:** 4/4 truths verified

### Required Artifacts (Exists + Substantive + Wired)

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `lib/services/sync/sync_scheduler.dart` | True no-op gating when comps disabled + persists last updated | ✓ VERIFIED | Reads `kPrivacyFetchSoldPriceCompsEnabledKeyV1` and returns before any quota/state/market work; upserts comps with `fetchedAt` and persists errors/backoff for UI. |
| `lib/services/sync/background/background_sync.dart` | Background scheduling/execution respects comps enabled + proxy configured | ✓ VERIFIED | `scheduleIfConfigured` cancels/schedules Workmanager based on comps enabled, proxy configured, and interval; `callbackDispatcher` exits early when disabled/proxy missing, else runs `SyncScheduler.syncOnce()` best-effort. |
| `lib/features/analyzer/item_detail_screen.dart` | Last-updated + disabled/offline/proxy-missing states + error surface | ✓ VERIFIED | Renders last-updated from comps; disables actions and shows disabled/offline/proxy-not-configured hints; shows last sync error and next attempt time. |
| `lib/features/settings/settings_screen.dart` | Settings toggle immediately reschedules/cancels background work | ✓ VERIFIED | Comps toggle persists `kPrivacyFetchSoldPriceCompsEnabledKeyV1` and calls `BackgroundSync.scheduleIfConfigured(db: db)` immediately. |
| `test/services_sync/fl_042_sync_scheduler_test.dart` | No-network contract when disabled | ✓ VERIFIED | Asserts quota unchanged, no sync state written, status unchanged when comps disabled, even with throwing market source. |
| `supabase/functions/tradera-proxy/index.ts` | Rate-limited proxy + stable JSON error contract | ✓ VERIFIED | Exports `handleRequest`, uses Upstash sliding-window limiter, stable error envelope + retry-after + no-store, and fail-closed when secrets missing. |
| `supabase/functions/tradera-proxy/tests/index_test.ts` | Proxy contract + rate-limit behavior tests | ✓ VERIFIED | Covers 405/400/429 + success response shape + cache-control. |
| `lib/services/market/tradera_client.dart` | Typed/actionable proxy error mapping | ✓ VERIFIED | Parses error envelope and `retry-after`; treats 429 as actionable (no tight retries); bounded retries for 5xx; concise errors. |
| `test/services_market/fl_041_tradera_client_test.dart` | Client mapping + retry behavior tests | ✓ VERIFIED | Covers 429 mapping (retryAfterSeconds) and 5xx retry recovery. |

### Key Link Verification (Wiring)

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `lib/features/settings/settings_screen.dart` | `lib/services/sync/background/background_sync.dart` | Call `BackgroundSync.scheduleIfConfigured` after persisting comps toggle | ✓ WIRED | `onChanged` for comps switch awaits `BackgroundSync.scheduleIfConfigured(db: db)`. |
| `lib/main.dart` | `lib/services/sync/background/background_sync.dart` | Startup scheduling | ✓ WIRED | Calls `BackgroundSync.initialize()` and `BackgroundSync.scheduleIfConfigured(db: db)` during bootstrap. |
| `lib/services/sync/sync_scheduler.dart` | `lib/core/settings/app_settings_keys.dart` | DB read of comps enabled key | ✓ WIRED | Uses `kPrivacyFetchSoldPriceCompsEnabledKeyV1` with null => enabled. |
| `lib/services/sync/background/background_sync.dart` | `workmanager` | schedule + cancel + executeTask | ✓ WIRED | Uses `registerPeriodicTask`, `cancelByUniqueName`, and `executeTask`. |
| `supabase/functions/tradera-proxy/index.ts` | Upstash env | Durable rate limiting | ✓ WIRED | Reads `UPSTASH_REDIS_REST_URL`/`UPSTASH_REDIS_REST_TOKEN` and fails closed when missing. |
| `lib/services/market/tradera_client.dart` | Proxy error contract | `code/message/retryAfterSeconds` + `retry-after` | ✓ WIRED | Parses proxy error envelope and header and surfaces actionable messages. |

### Requirements Coverage

| Requirement | Source Plan | Description (.planning/REQUIREMENTS.md) | Status | Evidence |
| --- | --- | --- | --- | --- |
| MKT-01 | `03-01-PLAN.md`, `03-03-PLAN.md` | Sold-price comps can be fetched on demand and in background when enabled | ? NEEDS HUMAN | On-demand path + last-updated verified in `lib/features/analyzer/item_detail_screen.dart` + `lib/services/sync/sync_scheduler.dart`; background scheduling is wired in `lib/main.dart` and Settings rescheduling is wired in `lib/features/settings/settings_screen.dart`, but Workmanager runtime execution must be validated on device/emulator. |
| MKT-02 | `03-01-PLAN.md` | User can disable sold-price comps; when disabled, the app performs no comps network calls | ✓ SATISFIED | Scheduler and background executor short-circuit; UI disables actions; enforced by `test/services_sync/fl_042_sync_scheduler_test.dart`. |
| MKT-03 | `03-02-PLAN.md` | Tradera proxy is protected against abuse (auth and/or rate limiting) and has clear error handling | ? NEEDS HUMAN | Durable rate limiting + stable error contract implemented and tested in `supabase/functions/tradera-proxy/index.ts` + tests; client maps errors in `lib/services/market/tradera_client.dart`; requires deployed Edge Function and configured Upstash secrets to validate end-to-end. |

**Requirements cross-check:** PLAN frontmatter declares `MKT-01`, `MKT-02`, `MKT-03`; all three are defined in `.planning/REQUIREMENTS.md` and mapped to Phase 3 in the traceability table. No additional Phase 3 requirements appear orphaned.

### Anti-Patterns Found

No TODO/FIXME/placeholder stubs found in the phase’s key implementation files. (The only `return null` matches are normal parse/guard code paths.)

### Human Verification Required

### 1. Background Scheduling Reacts Immediately to Toggle (Deferred)

**Test:** In Settings, toggle "Fetch sold-price comps" OFF then ON (without restarting). Wait long enough for a periodic tick (or use logs) and confirm periodic background work is canceled/scheduled immediately and actually runs when enabled + proxy configured.
**Expected:** OFF cancels periodic work; ON schedules periodic work; background runs best-effort and updates items when successful.
**Why human:** Device/emulator Workmanager scheduling/execution cannot be proven purely by static code checks. (The rescheduling wiring is implemented in `lib/features/settings/settings_screen.dart`, but runtime verification is deferred as requested.)

### 2. Proxy Rate Limit UX With Deployed Edge Function

**Test:** Deploy `supabase/functions/tradera-proxy` with Upstash secrets configured, then trigger rate limiting (repeat requests) and observe app error UI after a sync attempt.
**Expected:** HTTP 429 returns stable error envelope + `retry-after`; client surfaces an actionable message (incl retry delay) and app remains usable.
**Why human:** Requires deployed infrastructure + real network; UX clarity is subjective.

---

_Verified: 2026-02-23T21:29:26Z_
_Verifier: Claude (gsd-verifier)_
