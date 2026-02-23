# Phase 3: User Setup Required

**Generated:** 2026-02-23
**Phase:** 03-sold-price-comps-hardening
**Status:** Incomplete

Complete these items for the `tradera-proxy` durable rate limiting to function.

## Environment Variables

| Status | Variable | Source | Add to |
|--------|----------|--------|--------|
| [ ] | `UPSTASH_REDIS_REST_URL` | Upstash Console -> Database -> REST URL | Supabase secrets (Edge Functions env) |
| [ ] | `UPSTASH_REDIS_REST_TOKEN` | Upstash Console -> Database -> REST Token | Supabase secrets (Edge Functions env) |

## Account Setup

- [ ] **Create Upstash Redis database** (if needed)
  - URL: https://console.upstash.com/
  - Notes: Enable REST access (Upstash provides REST URL + token)

## Dashboard Configuration

- [ ] **Add secrets to Supabase project**
  - Location: Supabase Dashboard -> Project Settings -> Secrets
  - Add: `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`

## Verification

After completing setup, verify:

- Deploy the updated Edge Function `tradera-proxy`.
- Call the function repeatedly and confirm it returns HTTP 429 with JSON:
  - `{ "error": { "code": "rate_limited", "message": "...", "retryAfterSeconds": ... } }`
  - `retry-after` header present when retry delay is known

---

**Once all items complete:** Mark status as "Complete" at top of file.
