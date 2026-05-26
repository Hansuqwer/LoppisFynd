# Tradera Proxy Readiness Checklist (FyndLoppis)

Use this checklist before implementing changes or shipping the Tradera market-price feature.

## Credentials & Accounts (Blockers)

- [ ] Rotate/revoke any Tradera credentials that were shared outside secure channels (treat as compromised).
- [ ] Ensure you have a Tradera Developer Program account and an application registered.
- [ ] Confirm with Tradera (`apiadmin@tradera.com`) what quota applies to your app id for SearchService, and request higher limits if needed.

## Secrets Hygiene (Must Not Ship to Client)

- [ ] `TRADERA_APP_KEY` is server-side only (never in Flutter, never in `--dart-define`, never in GitHub Actions logs).
- [ ] `TRADERA_APP_ID` is treated as server-side configuration (not required in client).
- [ ] If RestrictedService is ever added later, user tokens are stored server-side only (never on-device unless explicitly designed and threat-modeled).
- [ ] `.env` is gitignored; only `.env.example` is committed.

## Supabase Edge Function Deployment

- [ ] `supabase/functions/tradera-proxy/` is deployed to the correct Supabase project.
- [ ] Supabase secrets are set for the function:
  - [ ] `TRADERA_APP_ID`
  - [ ] `TRADERA_APP_KEY`
  - [ ] optional: `TRADERA_SANDBOX`
  - [ ] optional: `TRADERA_MAX_RESULT_AGE`
- [ ] Decide whether the function requires Supabase JWT verification:
  - [ ] If `verify_jwt=true`: ensure the client can send a real user JWT (requires auth) or provide an alternative strategy.
  - [ ] If `verify_jwt=false`: treat endpoint as public and enforce abuse protections (rate limiting + caching).

## Flutter App Configuration

- [ ] `TRADERA_PROXY_URL` is set per flavor via `--dart-define` and points to the deployed function:
  - e.g. `https://<PROJECT>.supabase.co/functions/v1/tradera-proxy`
- [ ] Feature flags are set appropriately (ensure `FF_DISABLE_MARKET` is not blocking intended behavior in staging/prod).
- [ ] Confirm the app passes any required headers to call the proxy:
  - [ ] If using Supabase anon key for gateway auth, ensure it is available in the client config and injected into `TraderaClient`.

## API Contract Stability

- [ ] Proxy request/response JSON matches the app models:
  - `lib/services/market/tradera_proxy_models.dart`
  - `supabase/functions/tradera-proxy/types.ts`
- [ ] Response fields are resilient to nulls (SOAP may omit fields).
- [ ] Errors are returned in a consistent JSON shape and mapped to user-facing messages in the app.

## Reliability & Offline-First Behavior

- [ ] If offline or proxy errors occur, app continues with cached market stats (no hard dependency).
- [ ] Client retry policy is safe:
  - [ ] Retries only on 429 and 5xx and network timeouts (already implemented in `lib/services/market/tradera_client.dart`).
  - [ ] Backoff is capped and does not amplify outages.
- [ ] Background market sync respects quotas:
  - [ ] Sync interval is conservative by default.
  - [ ] 429 triggers a longer cooldown (hours, not seconds).
  - [ ] Requests are deduplicated (do not refetch identical queries repeatedly).

## Caching Strategy (Critical for Quota)

- [ ] Server-side caching exists (or is explicitly planned) keyed by normalized query + page.
- [ ] Cache TTL is tuned for ended-auction comps (hours/days) rather than minutes.
- [ ] Client-side SQLite caching is used for market stats; cache invalidation policy is defined.
- [ ] If implementing HTTP caching:
  - [ ] `ETag` and `If-None-Match` are supported.
  - [ ] `Cache-Control` headers are set intentionally.

## Security Posture / Abuse Resistance

- [ ] Input validation exists on the proxy:
  - [ ] `searchWords` length constraints.
  - [ ] pagination limits.
  - [ ] allowlist/normalize `orderBy`, `itemStatus` where possible.
- [ ] Rate limiting is implemented at one layer:
  - [ ] Edge (preferred) or gateway/WAF/CDN.
- [ ] Logging does not include secrets or full upstream SOAP responses.

## Observability & Operations

- [ ] Proxy logs include request IDs and upstream status codes.
- [ ] Dashboards or metrics exist for:
  - [ ] upstream latency
  - [ ] upstream 429 rate
  - [ ] parse errors
  - [ ] cache hit rate
- [ ] Alerts are configured for sustained 429/5xx and sudden traffic spikes.

## Testing & Verification

- [ ] Deno unit tests pass:
  - `supabase/functions/tradera-proxy/tests/soap_test.ts`
  - `supabase/functions/tradera-proxy/tests/parse_test.ts`
- [ ] Manual curl smoke test succeeds against staging:
  - [ ] ended search returns items array
  - [ ] invalid input returns 400
  - [ ] upstream failure returns 502 with safe body truncation
- [ ] Flutter integration test (future work) validates parsing and offline fallback.

## Rollout Safety

- [ ] Staging/prod use different Tradera credentials (if Tradera supports it) or at least different proxy environments.
- [ ] There is a kill switch:
  - [ ] `FF_DISABLE_MARKET` can disable market fetch without a release.
- [ ] If quotas are low/uncertain, throttle background sync and ship market fetch as an on-demand action first.
