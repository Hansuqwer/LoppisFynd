# Project Research Summary

**Project:** FyndLoppis
**Domain:** Offline-first Flutter thrift companion (photo-first catalog + cloud-first AI identification + sold-price comps) with optional lightweight offline ML fallback
**Researched:** 2026-02-21
**Confidence:** MEDIUM

## Executive Summary

FyndLoppis is an offline-first iOS/Android Flutter app for capturing secondhand finds, identifying items from photos, and pulling sold-price comparisons to support buy/no-buy and resale decisions. Experts build this category by making the local database the source of truth (capture/edit/search always works offline) and treating cloud inference/comps/sync as best-effort jobs with clear queueing + retry UX.

The research strongly points to a cloud-first identification pipeline (Gemini) routed through a server-side proxy (Supabase Edge Functions) to avoid shipping secrets, enable cost controls, and keep results consistent. The offline ML path should exist only as an opt-in, small (<10MB) fallback with evidence/confidence (assistive, not authoritative) to preserve the “instant start” value and avoid multi-GB first-run blockers.

The biggest risks are privacy/policy failures (unexpected photo upload, incorrect store declarations, leaking payloads into logs), uncontrolled inference spend, and background/sync reliability assumptions. Mitigation is architectural: a single `PrivacyGate` boundary for any image egress, strict “Edge Function only” AI calls with quotas/caching/backoff, and a unified, idempotent job runner that records last-attempted vs last-successful outcomes.

## Key Findings

### Recommended Stack

The recommended stack is an incremental evolution of the existing codebase: Flutter + Riverpod + Drift remain the core, Supabase remains the backend surface (Auth/Storage/Edge Functions), and Gemini is called server-side via `@google/genai` to keep keys and policy controls off-device. Add a lightweight on-device inference runtime only as an opt-in fallback.

**Core technologies:**
- Flutter + Dart (stable/pinned): iOS/Android app runtime — keep the repo’s pinned stable toolchain to reduce upgrade churn.
- `flutter_riverpod ^3.2.1`: state/DI and async orchestration boundaries — supports safer refactors with generator + lints.
- Drift (`drift ^2.31.0`): offline-first SQLite source of truth — type-safe queries, migrations, and stream-based UI updates.
- `supabase_flutter ^2.12.0` + Supabase Edge Functions (Deno runtime): auth/storage/server proxy — secrets stay server-side; enables caching/rate limiting and consistent AI behavior.
- Gemini server-side (`npm:@google/genai@1.42.0`): cloud identification — called from Edge Functions, not from Flutter.
- `workmanager ^0.9.0+3`: best-effort background scheduling — must be treated as non-guaranteed.
- `sentry_flutter ^9.14.0` (and Sentry for Edge Functions): observability — essential once background jobs and cloud AI are introduced.

### Expected Features

The “table stakes” are a photo-first offline catalog with fast capture, reliable editing, and search; AI identification and comps must support retries and manual correction. Differentiation comes from instant start, hybrid cloud/offline identification with provenance, and a batch capture + review queue.

**Must have (table stakes):**
- Fast photo capture + import and durable local persistence — core thrift workflow; must work offline.
- Item record + editing with manual overrides — AI output is assistive, not the source of truth.
- Quick search/filter/sort — the catalog becomes unusable without it as data grows.
- Cloud-first AI identification + “try again”/re-crop loop — structured fields + confidence + editability.
- Sold-price comps (start with Tradera) + caching/last-updated — baseline pricing decision support.
- Offline-first queue + retry transparency for AI/comps/sync — the difference between “offline-first” and “flaky”.

**Should have (competitive):**
- Instant start (no mandatory model downloads) — preserves the core value and reduces churn.
- Batch “thrift run” capture + later review queue — supports high-volume sourcing sessions.
- Provenance/evidence for AI output (cloud/offline/manual + confidence) — increases trust and debuggability.

**Defer (v2+):**
- Multi-market comps aggregation/normalization — high scope and ongoing maintenance.
- Listing draft generation — valuable for reseller segment but not required to validate core loop.

### Architecture Approach

The recommended architecture is “ports + adapters” within the existing Riverpod/Drift structure: UI calls controllers, controllers call application services, services depend on domain ports, and integrations implement ports (Supabase/Edge Functions/Gemini/Tradera/TFLite). Background entrypoints compose a minimal runtime that reuses the same jobs/services.

**Major components:**
1. `PrivacyGate` — the single boundary for any image leaving device (crop/downscale/redact + auditable metadata).
2. `AiOrchestrator` + `AiBackend` port — policy-based selection of cloud vs offline vs manual, with retries/backoff and structured results.
3. `MarketCompsRefresher` — fetch comps via Tradera proxy; cache locally; degrade gracefully offline.
4. `SyncCoordinator` + outbox tables — optional cloud replication; idempotent, incremental, and status-visible.
5. `JobRunner` — unified idempotent jobs runnable from foreground, on-resume, and background (workmanager).

### Critical Pitfalls

1. **Unexpected cloud photo upload** — add first-use disclosure + reversible toggles; enforce all egress through `PrivacyGate`.
2. **Wrong App Store/Play declarations** — maintain a data-flow inventory; treat photo-to-cloud-AI as collected user content unless proven ephemeral per store definitions.
3. **Payload leaks into logs/Sentry** — redact by default; log identifiers/sizes/timings only; never log prompts/AI JSON/image URLs.
4. **Unbounded inference spend** — Edge Function proxy must enforce quotas, payload caps, caching by content hash, and exponential backoff for 429s.
5. **Assuming background scheduling is reliable** — design jobs as best-effort; show last attempted/successful; keep jobs bounded and resumable.

## Implications for Roadmap

Based on the combined research, the roadmap should be organized around the hard dependencies: privacy/image egress boundary first, then pluggable AI via server proxy, then job orchestration/sync reliability, then optional offline ML, and finally token/dark-mode governance.

### Phase 1: Cloud AI Foundation (Privacy + Proxy + No First-Run Blockers)
**Rationale:** Everything else (AI quality, cost controls, store compliance) depends on a safe and auditable “image egress + server proxy” foundation.
**Delivers:** `PrivacyGate` + derived image artifacts, Edge Function `ai-identify` calling Gemini via `@google/genai`, `AiBackend` port + `AiOrchestrator`, and settings/consent UX; scanner usable with zero model downloads.
**Addresses:** Cloud-first AI identification, retry/re-crop loop, settings toggles, instant start.
**Avoids:** Silent photo upload, client-side secrets, inference spend spikes, payload logging leaks.

### Phase 2: Offline-First Orchestration (Queues + JobRunner + Observability)
**Rationale:** “Offline-first” is mostly orchestration transparency and idempotency; background work must reuse the same bounded jobs as foreground.
**Delivers:** Explicit job records (queued/running/succeeded/failed) with idempotency keys; unified `JobRunner` for sync/comps/maintenance; last-attempted vs last-successful surfaced; Sentry breadcrumbs tied to job/run IDs.
**Addresses:** Offline queue + retry UX for AI/comps/sync; reliability of background behavior.
**Avoids:** Background errors being swallowed, offline/online transition duplicates, “cron” assumptions.

### Phase 3: Sync + Comps Hardening (Incremental + Explainable)
**Rationale:** Once AI is cloud-first, users will notice staleness and repeated failures; incremental replication and caching prevent scale pain early.
**Delivers:** Incremental metadata sync (cursor/updated_at), batching, proper retry rules (attempted vs succeeded timestamps), comps caching/last-updated + query explainability.
**Addresses:** Optional sync, sold-price comps stability, catalog search usability.
**Avoids:** Full-table pulls, repeated paid requests, invisible failures.

### Phase 4: Opt-In Offline Fallback (Lightweight + Evidence-Based)
**Rationale:** Offline ML is high-risk (licensing + trust) and should be built only after the cloud path is stable and opt-in UX is clear.
**Delivers:** `OfflineYoloXBackend` (TFLite runtime) behind `AiBackend`, long-lived worker isolate, strict size budget + opt-in download, evidence output (boxes/confidence), and an ML bill of materials.
**Addresses:** Optional offline fallback; hybrid pipeline with provenance.
**Avoids:** Licensing traps (AGPL/non-commercial weights), “offline always returns something” trust collapse, reintroduced first-run blockers.

### Phase 5: UI System v2 Adoption (Tokens + Dark Mode + Governance)
**Rationale:** Token migration must be enforced to prevent permanent dark mode gaps and UI drift; better to harden primitives first, then screens.
**Delivers:** Token-only primitives, dark mode wiring, golden/component tests for shared UI, CI enforcement against new hardcoded colors/assets.
**Addresses:** Dark mode + responsive layouts + long-term UI maintainability.
**Avoids:** Partial token adoption and brittle goldens that get disabled.

### Phase Ordering Rationale

- Privacy/image egress and server-side AI proxy are prerequisites for compliant cloud AI.
- Job orchestration and observability are prerequisites for making offline-first and background behavior trustworthy.
- Sync/comps hardening prevents early scale failures and reduces support load.
- Offline ML is intentionally delayed until licensing/size/trust constraints can be validated.
- Token governance is treated as a foundation task to stop UI regressions during ongoing feature work.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 1:** Gemini product choice + data retention settings and their impact on App Store/Play disclosures; Edge Function auth/rate-limit patterns for paid endpoints.
- **Phase 4:** Offline model/weights/dataset licensing validation and evaluation methodology for confidence calibration.

Phases with standard patterns (skip research-phase):
- **Phase 2:** Job runner + idempotent outbox + “last attempted vs last successful” UX patterns are well-established.
- **Phase 5:** Token governance + golden test harness patterns are common in mature Flutter codebases.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM-HIGH | Most choices are mature Flutter/Supabase defaults; offline ML runtime choice is less certain and depends on model constraints. |
| Features | MEDIUM | Table stakes are clear; differentiators and competitor comparisons are partly based on marketing sources and inference. |
| Architecture | MEDIUM | Patterns are standard and fit the existing codebase, but specific seams (photo variants, job records) need validation against current DB schema. |
| Pitfalls | MEDIUM-HIGH | Privacy/cost/background pitfalls are corroborated by official store/policy docs; app-specific risk depends on exact data flows. |

**Overall confidence:** MEDIUM

### Gaps to Address

- **Gemini/Vertex retention behavior and “ephemeral processing” alignment:** document the exact provider product/settings and map to store privacy declarations.
- **Cost model for AI/comps:** define quotas, caching keys (perceptual hash strategy), and a budget policy early.
- **Offline ML feasibility:** pick model architecture/weights, verify license chain, and test accuracy/calibration on representative secondhand images.
- **Background constraints on iOS:** validate job time budgets and what can reliably run in background vs on-resume.

## Sources

### Primary (HIGH confidence)
- https://supabase.com/docs/guides/functions — Edge Functions patterns (auth, secrets, logging)
- https://pub.dev/packages/drift — offline-first persistence
- https://pub.dev/packages/flutter_riverpod — state management/DI patterns
- https://pub.dev/packages/workmanager — background scheduling constraints
- https://pub.dev/packages/sentry_flutter — Flutter observability
- https://github.com/googleapis/js-genai/releases — `@google/genai` for Gemini calls
- Apple App Store privacy details: https://developer.apple.com/support/app-privacy-on-the-app-store/
- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469

### Secondary (MEDIUM confidence)
- Supabase Sentry monitoring example: https://supabase.com/docs/guides/functions/examples/sentry-monitoring
- Vertex AI zero data retention notes: https://cloud.google.com/vertex-ai/generative-ai/docs/vertex-ai-zero-data-retention

### Tertiary (LOW-MEDIUM confidence)
- Competitor marketing pages used for feature expectations: https://sellerengine.com/profit-bandit/ and https://sellhound.com/ and https://www.inventorylab.com/

---
*Research completed: 2026-02-21*
*Ready for roadmap: yes*
