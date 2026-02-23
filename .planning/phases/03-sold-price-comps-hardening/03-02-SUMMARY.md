---
phase: 03-sold-price-comps-hardening
plan: 02
subsystem: api
tags: [supabase, edge-functions, deno, upstash, ratelimit, tradera, retry-after]

# Dependency graph
requires: []
provides:
  - Durable Upstash-backed rate limiting for `tradera-proxy`
  - Stable JSON error contract for all `tradera-proxy` non-2xx responses
  - Flutter client mapping of proxy errors into actionable exceptions
affects: [market-sync, sold-price-comps, error-ux]

# Tech tracking
tech-stack:
  added: ["npm:@upstash/ratelimit", "npm:@upstash/redis", "Deno (dev tooling)"]
  patterns:
    - "Edge function handler exported as handleRequest(req, deps) for testability"
    - "Stable error envelope: {error:{code,message,retryAfterSeconds?}}"
    - "Rate-limit responses include retry-after header when known"

key-files:
  created:
    - supabase/functions/tradera-proxy/tests/index_test.ts
    - deno.json
    - deno.lock
    - .planning/phases/03-sold-price-comps-hardening/03-USER-SETUP.md
  modified:
    - supabase/functions/tradera-proxy/index.ts
    - supabase/functions/tradera-proxy/types.ts
    - lib/services/market/tradera_client.dart
    - test/services_market/fl_041_tradera_client_test.dart
    - .gitignore

key-decisions:
  - "Treat HTTP 429 as actionable (no tight client retry loop); surface retry-after to UX"
  - "Rate limit key prefers JWT sub when present, else hashed bearer token, else IP"
  - "Fail closed with server_not_configured when Upstash env vars are missing"

patterns-established:
  - "Proxy errors are contract-based and mappable (code/message/retryAfterSeconds)"

requirements-completed:
  - MKT-03

# Metrics
duration: 26 min
completed: 2026-02-23
---

# Phase 3 Plan 02: Sold-Price Comps Hardening Summary

**Upstash-backed rate limiting + stable `tradera-proxy` error contract, with Flutter client mapping for actionable 429/5xx states.**

## Performance

- **Duration:** 26 min
- **Started:** 2026-02-23T06:21:41Z
- **Completed:** 2026-02-23T06:48:18Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Hardened `supabase/functions/tradera-proxy/index.ts` with exported `handleRequest()` handler, body-size guard, cache-control: no-store, and durable Upstash rate limiting.
- Standardized all proxy errors to `{error:{code,message,retryAfterSeconds?}}` with `retry-after` header for 429.
- Updated `lib/services/market/tradera_client.dart` to parse the error contract, surface concise actionable errors, and avoid tight retry behavior on rate limiting.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add durable rate limiting + stable JSON error contract to tradera-proxy** - `5ef2af6` (feat)
2. **Task 2: Map proxy errors into actionable TraderaClient exceptions** - `4716d39` (feat)

**Plan metadata:** (docs commit after SUMMARY + STATE updates)

## Files Created/Modified

- `supabase/functions/tradera-proxy/index.ts` - Upstash rate limiting + stable error contract + testable handler export
- `supabase/functions/tradera-proxy/types.ts` - Shared error contract types
- `supabase/functions/tradera-proxy/tests/index_test.ts` - Regression tests for 405/400/429 and success path
- `lib/services/market/tradera_client.dart` - Parse proxy error envelope + respect retry-after for 429
- `test/services_market/fl_041_tradera_client_test.dart` - Tests for 429 mapping and 5xx retry recovery
- `deno.json` - Enables Deno npm auto-install for Edge Function tests
- `deno.lock` - Locks Deno/npm dependencies used by Edge Function tests
- `.planning/phases/03-sold-price-comps-hardening/03-USER-SETUP.md` - Upstash + Supabase secrets setup checklist

## Decisions Made

- Treated 429 as a user-actionable outcome (surface retry-after), while keeping bounded retries for transient 5xx.
- Required Upstash secrets for durable rate limiting; missing secrets return `server_not_configured`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added Deno test runner support for npm imports**
- **Found during:** Task 1 (proxy tests)
- **Issue:** `deno` was missing locally, and Deno npm imports required a repo `deno.json` config for auto-install.
- **Fix:** Installed Deno to user home, added `deno.json` (`nodeModulesDir: auto`), and ignored `node_modules`.
- **Files modified:** `deno.json`, `deno.lock`, `.gitignore`
- **Verification:** `/home/hans/.deno/bin/deno test -A supabase/functions/tradera-proxy/tests/*.ts`
- **Committed in:** `5ef2af6` (Task 1)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Necessary to run/lock Edge Function tests; no scope creep.

## Issues Encountered

- Deno was not installed in the environment; resolved via a user-level install and a minimal `deno.json` config to support npm imports.

## User Setup Required

**External services require manual configuration.** See `.planning/phases/03-sold-price-comps-hardening/03-USER-SETUP.md`.

## Next Phase Readiness

- Code + unit tests are in place; next step is deploying `tradera-proxy` with Upstash secrets configured.
- Manual verification (recommended): trigger rate limiting against the deployed function and confirm the app surfaces an actionable message while remaining usable.

## Self-Check: PASSED

- Confirmed required files exist (SUMMARY, USER-SETUP, new tests, deno config/lock).
- Confirmed task commits exist: `5ef2af6`, `4716d39`.
