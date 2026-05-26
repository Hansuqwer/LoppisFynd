# Phase 3: Sold-Price Comps Hardening - Research

**Researched:** 2026-02-22
**Domain:** Flutter (Drift + Workmanager) market comps pipeline + Supabase Edge Function proxy hardening
**Confidence:** MEDIUM

## User Constraints

No phase `CONTEXT.md` exists yet for Phase 3.

Constraints and prior decisions to honor while planning (from ROADMAP/REQUIREMENTS + user-provided decisions):

- Keep existing offline-first behavior: the app must stay usable offline; comps are best-effort when online.
- Preserve Phase 2 privacy posture patterns: reversible toggles are persisted in `AppSettingsDao` using versioned keys; defaults stay ON when unset.
- Use explicit gating for network features: when a feature is disabled, fail closed and do not perform network calls.
- Sync controls should remain hidden for normal users and only appear in the existing Dev Mode (current repo pattern).
- Proxy responses for cloud AI already enforce strict payload limits (413) and `cache-control: no-store`; prefer consistent safety patterns for proxies.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| MKT-01 | Sold-price comps can be fetched on demand and in background when enabled | Existing pipeline already supports queued on-demand fetch + Workmanager background runs; planning should harden gating, status/error UX, and scheduling so it is reliable and observable. |
| MKT-02 | User can disable sold-price comps; when disabled, the app performs no comps network calls | Market fetch is already gated in `lib/services/market/market_bridge.dart`; planning must extend gating to background scheduling + manual sync entrypoints so no hidden calls occur and no churny state transitions happen. |
| MKT-03 | Tradera proxy is protected against abuse (auth and/or rate limiting) and has clear error handling | Supabase Edge Function `supabase/functions/tradera-proxy/index.ts` needs explicit protection (auth posture and/or rate limiting) plus stable error contract; client needs typed error handling + user-facing messaging. |
</phase_requirements>

## Summary

Phase 3 is mostly hardening and policy alignment work across three layers:

1) The Flutter comps pipeline (queue -> fetch -> persist -> UI) already exists, but it currently treats "comps disabled" as "fetch returns null" which can still cause background/manual sync churn (status flips, stored errors) even though network calls are gated.

2) Background scheduling exists via Workmanager, but `BackgroundSync.scheduleIfConfigured` only checks `TRADERA_PROXY_URL` and an interval; it does not consider the comps enable/disable toggle. Planning should ensure a true off switch cancels scheduled work and makes sync paths no-op.

3) The Tradera proxy Edge Function works functionally but is not hardened for public abuse: it has basic input validation but no explicit auth posture, rate limiting, or structured error contract. Supabase provides a standard pattern for auth verification and a reference rate-limiting approach using Upstash Redis.

**Primary recommendation:** Plan Phase 3 around a single "market comps policy" decision point (enabled + configured + online) that gates ALL entrypoints (UI on-demand, background Workmanager, and any future auto-refresh), and harden `tradera-proxy` with a deliberate protection posture (rate limiting at minimum, optionally stronger auth) plus a stable error shape that the app can translate into actionable UI.

## Standard Stack

### Core
| Library / System | Version | Purpose | Why Standard (in this repo) |
|---|---:|---|---|
| Flutter + Dart | repo-managed | Mobile app runtime | Existing app platform |
| Drift | repo-managed | Local DB for cache + state | Existing persistence for stats + sync state |
| workmanager | repo-managed | Background periodic task | Existing `market_sync` scheduling |
| package:http | repo-managed | Calling proxy from Flutter | Used by `TraderaClient` |
| Supabase Edge Functions (Deno) | platform | Server-side proxy for Tradera SOAP | Already used (`tradera-proxy`, `cloud-ai-proxy`) |

### Supporting
| Library / System | Version | Purpose | When to Use |
|---|---:|---|---|
| Supabase Auth JWT verification patterns | docs | Protect Edge Functions / derive user claims | If proxy protection includes auth-based gating or per-user limits |
| Upstash Redis + Ratelimit | see Supabase example | Rate limiting (per-IP/per-user) at the edge | Recommended baseline for abuse protection (MKT-03) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|---|---|---|
| Upstash rate limiting | In-memory map in Edge Function | Not reliable across instances/cold starts; weak protection |
| Edge Function protection | Cloudflare Worker/WAF | Better built-in WAF/rate limits, but adds another deployment surface |

## Architecture Patterns

### Pattern 1: Centralized gating via `AppSettingsDao` (privacy-style)
**What:** Read a versioned settings key, default to ON when unset, and return early before network.
**Repo example:** `lib/services/market/market_bridge.dart` checks `kPrivacyFetchSoldPriceCompsEnabledKeyV1` and returns `null` before calling `_tradera.searchEnded(...)`.
**Planning implication:** Expand this same gate to:
- Workmanager scheduling (`BackgroundSync.scheduleIfConfigured`)
- Workmanager execution (`callbackDispatcher`)
- Manual sync entrypoints (Settings "Sync now" and Item Detail "Sync now")

### Pattern 2: Offline-first cache + best-effort refresh
**What:** Use local TTL cache for derived stats and store raw comps snapshot per item.
**Repo components:**
- TTL cache: `lib/core/database/daos/market_stats_cache_dao.dart` used by `MarketBridge`
- Per-item snapshot + timestamps: `lib/core/database/tables/scan_item_comps.dart`
**Planning implication:** UI should show `fetchedAt` as "last updated" and treat refresh failures as non-fatal.

### Pattern 3: Background refresh via Workmanager -> `SyncScheduler`
**What:** Periodic task `market_sync` opens DB, builds `MarketBridge`, runs `SyncScheduler.syncOnce()`.
**Repo entrypoint:** `lib/services/sync/background/background_sync.dart`.
**Planning implication:** Add preflight checks (configured + enabled + quotas/cooldown) before doing work to avoid noisy failures.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| JWT verification | Custom JWT parsing/validation | Supabase Edge Functions auth templates (`jose`/`getClaims`) | Key rotation + issuer rules are subtle; Supabase provides patterns |
| Distributed rate limiting | In-memory counters in Edge Function | Upstash Redis rate limiting (Supabase example) | Edge is multi-instance; needs shared state |
| Retry/backoff policy | Ad-hoc sleeps scattered across UI | Central retry/backoff in `TraderaClient` + per-item backoff in `SyncScheduler` | Keeps behavior consistent and testable |

## Common Pitfalls

### Pitfall 1: "Disabled" still causes background churn
**What goes wrong:** No network calls happen, but background/manual sync continues flipping item statuses and storing errors because fetch returns `null`.
**Where it can happen now:** `SyncScheduler` treats `null` as `_NoMarketData` error and records failure state.
**How to avoid:** When comps are disabled, make sync a no-op (return early) and cancel scheduled work.
**Confidence:** HIGH (directly visible in current code paths).

### Pitfall 2: Background task runs without proxy auth headers
**What goes wrong:** Proxy is configured to require JWT/apikey headers, but background worker constructs `TraderaClient` without `anonKey`, causing 401s and repeated retries.
**Where it can happen now:** `lib/services/sync/background/background_sync.dart`.
**How to avoid:** Ensure all TraderaClient construction consistently passes the chosen auth headers (anon key and/or user token).
**Confidence:** HIGH.

### Pitfall 3: Rate limiting without a user-facing message
**What goes wrong:** Proxy returns 429; client retries; user sees "No market data" or a generic failure.
**How to avoid:** Define a stable error contract for proxy responses, map to typed client exceptions, and surface an actionable message ("Rate limited, try again later"). Respect `Retry-After` when present.
**Confidence:** MEDIUM (requires implementation choices).

### Pitfall 4: Tradera upstream quota exhaustion
**What goes wrong:** Tradera docs mention low daily quotas; background sync can exhaust quota quickly without strong caching/cooldowns.
**How to avoid:** Combine local TTL caching (already present) with proxy-side rate limiting and a longer-lived cooldown behavior on repeated 429.
**Confidence:** MEDIUM (quota details must be confirmed with Tradera).

## Code Examples (Repo-Verified)

### Gate comps network calls in MarketBridge
Source: `lib/services/market/market_bridge.dart`

```dart
final enabled = (await _db.appSettingsDao.getInt(
  kPrivacyFetchSoldPriceCompsEnabledKeyV1,
)) ?? 1;
if (enabled != 1) return null;

final resp = await _tradera.searchEnded(searchWords: query);
```

### Workmanager scheduling (currently only checks proxy + interval)
Source: `lib/services/sync/background/background_sync.dart`

```dart
if (!config.hasTraderaProxy) {
  await Workmanager().cancelByUniqueName(_taskName);
  return;
}

final hours = (await db.appSettingsDao.getInt('market_sync_interval_hours')) ?? 6;
if (hours <= 0) {
  await Workmanager().cancelByUniqueName(_taskName);
  return;
}

await Workmanager().registerPeriodicTask(...);
```

### Retry/backoff on transient proxy errors
Source: `lib/services/market/tradera_client.dart`

```dart
if (resp.statusCode == 429 || (resp.statusCode >= 500)) {
  throw _RetryableHttpStatus(resp.statusCode);
}
```

## Proxy Hardening Notes (Supabase + Repo)

### Auth posture in Supabase Edge Functions

- Supabase supports per-function auth configuration via `supabase/config.toml` (`verify_jwt = false` to make a function public, otherwise require a valid JWT in the Authorization header).
- Supabase also documents newer, explicit in-function JWT verification patterns using `supabase.auth.getClaims(token)` or `jose` with the project JWKS endpoint.

Planning implication: decide explicitly whether `tradera-proxy` should be callable with:
- Supabase anon JWT only (lightweight barrier; still publicly extractable)
- Authenticated user JWT (stronger barrier; changes guest UX)
- Public access + strict rate limiting (works for guests; must be robust)

### Rate limiting reference approach

Supabase provides an Edge Function example using Upstash Redis + `@upstash/ratelimit`.

Planning implication: adopt this pattern for `tradera-proxy`, ideally limiting by user id when available, else by IP.

## Open Questions (Answer before finalizing the plan)

1. **What is the intended UX when comps are disabled?**
   - What we know: requirement is "no comps network calls"; cached values are currently still shown.
   - What's unclear: should the UI hide charts/stats entirely, or show cached with "disabled" state?
   - Recommendation: show existing cached stats + last-updated, but disable refresh buttons and stop background work.

2. **What proxy protection level is acceptable for guest users?**
   - What we know: app supports auth but also has guest usage patterns.
   - What's unclear: can comps require sign-in, or must it work for guests?
   - Recommendation: do not require sign-in for comps unless product explicitly accepts that tradeoff; implement rate limiting as baseline.

3. **Where should rate limiting state live?**
   - What we know: Supabase example uses Upstash (external managed Redis).
   - What's unclear: do we want an external dependency for Phase 3?
   - Recommendation: accept Upstash for MKT-03 (fastest path to robust protection), otherwise explicitly scope a weaker protection and treat as a known risk.

## Sources

### Primary (HIGH confidence)
- `.planning/ROADMAP.md` - Phase 3 goal/success criteria
- `.planning/REQUIREMENTS.md` - MKT-01..03 definitions
- `lib/services/market/market_bridge.dart` - comps gating + caching
- `lib/services/sync/background/background_sync.dart` - Workmanager scheduling/execution
- `supabase/functions/tradera-proxy/index.ts` - current proxy behavior
- Supabase Docs - Function configuration (`verify_jwt`): https://supabase.com/docs/guides/functions/function-configuration
- Supabase Docs - Securing Edge Functions / auth patterns: https://supabase.com/docs/guides/functions/auth

### Secondary (MEDIUM confidence)
- Supabase Docs - Rate limiting overview (Upstash): https://supabase.com/docs/guides/functions/examples/rate-limiting
- Supabase GitHub example (Upstash rate limit function): https://raw.githubusercontent.com/supabase/supabase/master/examples/edge-functions/supabase/functions/upstash-redis-ratelimit/index.ts
- `docs/Research/tradera-api-proxy/RESEARCH.md` - prior Tradera API + quota notes

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all components are already in-repo
- Architecture: HIGH - code paths are concrete and already wired
- Proxy protection recommendations: MEDIUM - exact auth posture and rate limit backend are decisions to make

**Research date:** 2026-02-22
**Valid until:** 2026-03-08 (2 weeks; Supabase auth guidance and quotas can shift)
