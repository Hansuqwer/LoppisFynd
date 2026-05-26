# Tradera API Proxy Research (FyndLoppis)

Researched: 2026-02-18

Security note (critical): Tradera application credentials were previously shared in chat. Treat them as compromised. Do not reuse them; rotate/revoke in Tradera Developer Center and re-issue new credentials. Use placeholders in all docs/code: `TRADERA_APP_ID`, `TRADERA_APP_KEY`, `TRADERA_PUBLIC_KEY`.

## Repo Context (What Already Exists)

- Flutter app reads `TRADERA_PROXY_URL` at build time via `--dart-define` (`lib/core/config/app_config.dart`).
- The mobile client calls a JSON proxy endpoint, not Tradera SOAP directly (`lib/services/market/tradera_client.dart`).
- A Supabase Edge Function already exists for the proxy (`supabase/functions/tradera-proxy/index.ts`). It:
  - Accepts `POST` JSON.
  - Builds a SOAP `SearchAdvanced` request.
  - Calls Tradera `SearchService` (`https://api.tradera.com/v3/searchservice.asmx`).
  - Parses SOAP XML into a compact JSON response.
- Local caching of market stats exists in SQLite (`lib/core/database/daos/market_stats_cache_dao.dart` referenced by `.planning/codebase/INTEGRATIONS.md`).

Note on conventions: this repo already uses `.planning/` for planning/codebase analysis docs. No `AGENTS.md` file was found in this checkout, so this research is stored under `.planning/research/`.

## 1) Tradera API Basics (Official, Current Docs)

### Developer program + app registration

- Tradera runs a developer program and SOAP API docs under `https://api.tradera.com/v3/`.
- To use the API you need:
  - A Tradera Developer Program account (separate from a normal Tradera user account).
  - A registered application with an `AppId` and a service key (called `AppKey` in SOAP headers / query params).

Sources:
- Docs entrypoint: https://api.tradera.com/v3/
- Developer program overview: https://api.tradera.com/

### API style: SOAP services

The v3 API is SOAP-based. The documentation lists six SOAP services:
- PublicService, RestrictedService, OrderService, SearchService, ListingService, BuyerService.

Source:
- Service list: https://api.tradera.com/v3/

### Authentication mechanisms

There are two distinct auth layers:

1) Application identification (required for all calls)
- Pass `appId` + `appKey` either:
  - In the URL query string, or
  - In the SOAP `AuthenticationHeader` (`AppId`, `AppKey`).

2) User authorization (only for RestrictedService and other user-scoped methods)
- Tradera provides a token login flow:
  - User signs in at `https://api.tradera.com/tokenlogin.aspx?appId=...&pkey=...`.
  - Your app receives (or fetches) a user token via `FetchToken`.
  - Restricted calls include `userId` + `token` either in URL params or a SOAP `AuthorizationHeader`.
- Token lifetime/expiration is returned by Tradera (hard expiration date). Your system must store and refresh/reauth when expired.

For FyndLoppis price-fetch use cases, the current implementation uses SearchService (no user token required).

Sources:
- Auth overview + token login details: https://api.tradera.com/v3/DocAuthorization.aspx
- SearchService description + WSDL link: https://api.tradera.com/v3/searchservice.asmx

### Relevant endpoint for comps/price lookup

SearchService exposes `Search` and `SearchAdvanced`. The proxy uses `SearchAdvanced`.

SearchAdvanced request highlights (official allowed values):
- `ItemStatus`: `Ended` or `Active` (default `Active`).
- `OrderBy`: includes `EndDateDescending`/`EndDateAscending`, and price/bids variants.
- `ItemsPerPage`: max 500 (values above treated as 500).
- `Mode`: `And` (default), `Or`, `Exact`.
- `ItemType`: `All`, `Auction`, `BuyItNow`.
- `SellerType`: `All`, `Private`, `Company`.
- `ItemCondition`: `All`, `OnlySecondHand`, `OnlyNew`.

SearchAdvanced response highlights:
- `TotalNumberOfItems`, `TotalNumberOfPages`.
- `Items[]` contains `Id`, `ShortDescription`, `EndDate`, `BidCount`, `MaxBid`, `HasBids`, `IsEnded`, `ItemUrl`, `ThumbnailLink`, etc.

Sources:
- SearchAdvanced method docs: https://api.tradera.com/v3/searchservice.asmx?op=SearchAdvanced
- SearchAdvancedRequest class docs (allowed values): https://api.tradera.com/v3/documentation/classdocumentation.aspx?name=T%3aTradera.Api.Library.ContractData.Version4.Search.SearchAdvancedRequest
- SearchItem class docs (fields): https://api.tradera.com/v3/documentation/classdocumentation.aspx?name=T%3aTradera.Api.Library.ContractData.Version4.Search.SearchItem
- WSDL (machine-readable contract): https://api.tradera.com/v3/searchservice.asmx?WSDL

### Rate limits / quotas / anti-abuse

The official docs state:
- Call limit of 100 calls / 24 hours (the page discusses RestrictedService activation, but also states the limit applies broadly).
- When exceeding rate limit, Tradera returns HTTP 429.
- For RestrictedService access or higher call limits, contact `apiadmin@tradera.com` with your app id and use case.

This is the biggest scaling risk for FyndLoppis. If the quota is truly ~100/day per app id, a consumer mobile app will exceed it quickly without strong caching and/or quota increases.

Source:
- Quota note: https://api.tradera.com/v3/

ToS notes:
- The API is explicitly membership-based; stay within published limits and contact Tradera for approvals/activation.
- I did not find a dedicated, current, explicit “API ToS” page within the docs surfaced at `https://api.tradera.com/v3/` beyond these membership/activation notes. Treat this as a research gap to close before production scale.

## 2) Why a Proxy Is Needed (For This App)

Even though the Flutter app is not subject to browser CORS, a proxy is still the right shape:

- Secret protection: `TRADERA_APP_KEY` must never ship in the mobile app.
- SOAP → JSON translation: keep SOAP/XML parsing and envelope building server-side.
- Input validation + abuse control: constrain `searchWords`, pagination, and expensive query patterns.
- Centralized caching: reduce upstream calls (critical given quota uncertainty) and stabilize latency.
- Observability: log request volumes, cache hit rate, and upstream failures without instrumenting clients.
- Future flexibility: if Tradera changes auth/quotas, you update the proxy without forcing an app update.

## 3) Proxy Architecture Options (Recommendation)

### Recommended: Supabase Edge Function (keep current approach)

Use Supabase Edge Functions as the single proxy surface.

Why this fits FyndLoppis:
- Already implemented in-repo (`supabase/functions/tradera-proxy/`).
- Secrets management is first-class (Supabase secrets) and keeps Tradera keys off-device.
- Deploy workflow aligns with existing Supabase usage (cloud sync, auth).
- Latency is good enough for price lookup; caching can make it fast.

Key reliability/security improvements to plan (research-based requirements, not code):
- Add server-side caching (per normalized query + page) with TTL.
- Add rate limiting (per-IP and/or per-user if authenticated flows exist).
- Return cache headers + stable error shapes.
- Add request IDs and structured logs.

### Alternative: Cloudflare Worker

Best when you want aggressive edge caching + built-in rate limiting + WAF. Downsides: extra vendor and deployment surface, plus you still need to integrate with Supabase for auth/analytics if desired.

### Alternative: Node/Express (container/server)

Most flexible for heavy caching and complex logic, but highest ops burden for a small app.

Decision:
- Prefer Supabase Edge Functions now; revisit adding a CDN/WAF layer (Cloudflare) only if abuse/scale demands it.

## Setup (Implementation-Ready Steps, No Secrets)

### A) Create/confirm Tradera API access

1) Create a Tradera Developer Program account
- Docs point to registration from the v3 entrypoint.
- Source: https://api.tradera.com/v3/

2) Register an application in Tradera Developer Center
- Record (store securely):
  - `TRADERA_APP_ID` (numeric)
  - `TRADERA_APP_KEY` (service key)
  - optional future use: `TRADERA_PUBLIC_KEY` (only needed for token login / RestrictedService)

3) Confirm quota and request increases
- Email `apiadmin@tradera.com` with the app id and explain:
  - You are using SearchService for ended-auction comps.
  - Expected call volume.
  - Ask what limits apply and request higher quota/activation if needed.

### B) Configure and deploy the proxy (Supabase)

1) Set Supabase Edge Function secrets (server-side)
- Required:
  - `TRADERA_APP_ID`
  - `TRADERA_APP_KEY`
- Optional:
  - `TRADERA_SANDBOX` (0/1)
  - `TRADERA_MAX_RESULT_AGE`

2) Deploy `tradera-proxy`
- Deploy the function from `supabase/functions/tradera-proxy/` using your normal Supabase workflow.

3) Decide auth posture
- If you must keep the endpoint callable without user sign-in, do not rely on user JWT gating.
- If you require auth, ensure the client can supply user JWT (not just anon key) and document UX implications.

4) Record the proxy URL
- Hosted function URL format:
  - `https://<PROJECT>.supabase.co/functions/v1/tradera-proxy`

### C) Configure the Flutter app

1) Set `TRADERA_PROXY_URL` at build time
- Provide via `--dart-define=TRADERA_PROXY_URL=...` per flavor/environment.

2) Verify offline-first behavior
- Ensure UI can render without market data and only enhances when proxy calls succeed.

### D) Verify end-to-end

1) Smoke test with curl (staging)
- Use the example in the Testing section and confirm the JSON response parses.

2) Observe logs/metrics
- Confirm upstream status codes (200 vs 429) and latency.

## 4) Readiness Check (What This Repo Needs)

### Build-time config required in Flutter

- `TRADERA_PROXY_URL` (required for market price fetch)
  - Should point to the deployed Edge Function URL, e.g. `https://<PROJECT>.supabase.co/functions/v1/tradera-proxy`.
- If the proxy is protected by Supabase gateway JWT verification, the client must include a valid `Authorization` header.
  - Current `TraderaClient` optionally includes the Supabase anon key as a bearer token if supplied; this is not user auth, but may be sufficient if the function is deployed with JWT verification disabled or configured to allow anon.

Source (repo):
- `TRADERA_PROXY_URL` usage: `lib/core/config/app_config.dart`, `lib/services/market/tradera_client.dart`

### Server-side secrets required (Supabase)

Set as Supabase function secrets/environment variables:
- `TRADERA_APP_ID` (numeric)
- `TRADERA_APP_KEY` (string)

Optional:
- `TRADERA_SANDBOX` (0/1)
- `TRADERA_MAX_RESULT_AGE` (int; semantics need verification)

Must NOT ship to client:
- `TRADERA_APP_KEY` (never via `--dart-define`, never in app bundle)
- Any token-login secrets or user tokens if RestrictedService is ever used

Local dev workflow:
- `.env.example` exists and already separates server-side Tradera secrets from client config; keep this pattern.
- For Flutter, prefer `--dart-define-from-file=.env` or explicit `--dart-define` values (do not commit `.env`).
- For Supabase local functions, use Supabase CLI + local secrets injection (do not commit secrets files).

Background sync implications:
- Market sync runs periodically (`workmanager`). Without server caching + quota confirmation, background sync can exhaust Tradera limits.
- Treat 429 as a “cool down”: implement exponential backoff (already in `TraderaClient`) and add a longer “do not retry until” window in the market sync layer.

Offline behavior expectations:
- App should continue to function offline; price fetch should:
  - Fail fast with a typed “market unavailable” error.
  - Use cached stats in SQLite when available.
  - Degrade UI gracefully (no blocking flows).

## 5) Concrete Proxy API Contract (Tailored to FyndLoppis)

The proxy should expose a stable JSON API designed for price comps, not a raw Tradera SOAP mirror.

### Endpoint surface (recommended)

Keep the externally configured base URL (`TRADERA_PROXY_URL`) stable, and provide a small, explicit surface behind it.

Recommended routes:

- `GET {TRADERA_PROXY_URL}/health`
  - Returns `200` with `{ "ok": true }`.
  - Does not call Tradera.

- `POST {TRADERA_PROXY_URL}/v1/search-ended`
  - Purpose: ended-auction comps for price stats.
  - Maps to Tradera `SearchAdvanced` with `ItemStatus=Ended`.

- `POST {TRADERA_PROXY_URL}/v1/search-advanced`
  - Purpose: future flexibility without changing function name.
  - Allows a controlled subset of `SearchAdvancedRequest` parameters (still defaulting to safe values).

If you want to avoid route handling inside a single Edge Function, an acceptable alternative is:
- Keep a single `POST {TRADERA_PROXY_URL}` endpoint and version purely by deploying `tradera-proxy-v2` later.

### Request JSON (v1)

- Minimal (current client behavior):
  - `searchWords: string` (2..80)
  - `itemStatus: "Ended"` (proxy should default to ended comps)
  - `orderBy: "EndDateDescending"`
  - `itemsPerPage: number` (recommend 1..200; Tradera allows up to 500)
  - `pageNumber: number` (>= 1)

Additional optional fields (support if needed later):
- `categoryId`, `searchInDescription`, `onlyItemsWithThumbnail`

### Response JSON (v1)

Return a compact payload suitable for local aggregation:

```json
{
  "totalNumberOfItems": 123,
  "totalNumberOfPages": 3,
  "items": [
    {
      "id": 1001,
      "shortDescription": "Rorstrand Mon Amie tallrik",
      "endDate": "2026-02-01T12:00:00",
      "maxBid": 245,
      "totalBids": 12,
      "hasBids": true,
      "isEnded": true,
      "itemLink": "https://www.tradera.com/item/1001",
      "thumbnailLink": "https://www.tradera.com/thumb/1001.jpg"
    }
  ]
}
```

This matches the existing types in:
- `supabase/functions/tradera-proxy/types.ts`
- `lib/services/market/tradera_proxy_models.dart`

### Versioning strategy

- Use URL versioning at the proxy surface:
  - Supabase already namespaces functions under `/functions/v1/`.
  - Keep the function name stable (`tradera-proxy`) and treat the JSON schema as “v1” unless a breaking change is necessary.
- For breaking changes:
  - Deploy a new function name (`tradera-proxy-v2`) and switch `TRADERA_PROXY_URL` per app flavor.

### Caching headers / ETag guidance

To reduce quota usage and stabilize background sync:
- Compute a cache key from a normalized request (trim/lowercase `searchWords`, stable defaults, page number).
- Return:
  - `Cache-Control: public, max-age=...` (short, e.g. minutes) and `s-maxage=...` (longer, e.g. hours) when safe.
  - `ETag` from the cached payload and support `If-None-Match` (return 304).

Even without a CDN, client-side conditional requests can reduce payload sizes.

## 6) Testing, Verification, Monitoring

### Local proxy testing (curl)

Hosted Supabase:

```bash
curl -sS \
  -X POST "${TRADERA_PROXY_URL}" \
  -H 'content-type: application/json' \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "authorization: Bearer ${SUPABASE_ANON_KEY}" \
  --data '{"searchWords":"rorstrand mon amie","itemStatus":"Ended","orderBy":"EndDateDescending","itemsPerPage":50,"pageNumber":1}'
```

Note: whether `apikey/authorization` are required depends on how the function is deployed (JWT verification on/off). The mobile client currently sends them only if an anon key is provided.

### Proxy unit tests

The function includes Deno unit tests:
- `supabase/functions/tradera-proxy/tests/soap_test.ts`
- `supabase/functions/tradera-proxy/tests/parse_test.ts`

Run them in a Deno environment that matches Supabase Edge runtime.

### Flutter integration tests

Add (future work) an integration test that:
- Uses a test `TRADERA_PROXY_URL` pointing to a local served function or a staging deployment.
- Verifies:
  - 200 response parsing.
  - 429/5xx backoff behavior.
  - Offline handling falls back to cached market stats.

### Monitoring / alerting

Minimum recommended telemetry for production reliability:
- Request volume, cache hit rate, upstream latency, upstream 429s.
- Error logs with request ID and normalized query key.
- Alerts:
  - sustained upstream 429
  - sustained upstream 5xx / parse failures
  - spike in unique queries (abuse signal)

## Key Risks / Unknowns (Need Validation)

- Quota ambiguity: docs mention 100 calls/24h; confirm with Tradera whether SearchService has higher limits or requires activation. This dictates caching aggressiveness and product viability at scale.
- `MaxResultAge` semantics: present in SOAP header but not clearly documented in the v3 docs pages fetched; verify what units/behavior it controls before relying on it.
- Abuse prevention: if the endpoint is public (no auth), you must implement rate limiting + caching or expect key burn / quota exhaustion.
