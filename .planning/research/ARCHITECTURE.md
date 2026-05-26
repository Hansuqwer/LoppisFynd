# Architecture Research

**Domain:** Offline-first Flutter (iOS/Android) app with cloud-first AI and optional offline ML fallback
**Researched:** 2026-02-21
**Confidence:** MEDIUM

## Standard Architecture

### System Overview

This domain wants a strict direction of dependencies:

- UI/features depend on application services (use-cases/orchestrators)
- application services depend on domain ports (interfaces)
- infrastructure implements ports (Drift DAOs, filesystem stores, HTTP/Supabase clients, AI backends)
- background entrypoints reuse the same application services, but spin up their own minimal dependency graph

```
┌───────────────────────────────────────────────────────────────────────────────┐
│ Presentation (features)                                                      │
├───────────────────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌────────────────┐  ┌──────────────────┐                │
│  │ Scanner UI     │  │ Item details   │  │ Settings/Privacy  │                │
│  └──────┬─────────┘  └──────┬─────────┘  └──────┬───────────┘                │
│         │                    │                    │                            │
│         ▼                    ▼                    ▼                            │
│  Feature controllers/state (Riverpod Notifiers/Controllers)                    │
└─────────┬───────────────────────────────┬────────────────────────────────────┘
          │                               │
          ▼                               ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│ Application layer (use-cases/orchestrators)                                   │
├───────────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────┐   ┌──────────────────┐   ┌────────────────────────┐  │
│  │ ScanCaptureService   │→  │ AiOrchestrator    │→  │ MarketCompsRefresher    │  │
│  └────────────────────┘   └──────────────────┘   └────────────────────────┘  │
│            │                         │                      │                 │
│            ▼                         ▼                      ▼                 │
│  ┌────────────────────┐   ┌──────────────────┐   ┌────────────────────────┐  │
│  │ SyncCoordinator      │   │ PrivacyGate      │   │ JobRunner (foreground/  │  │
│  │ (cloud optional)     │   │ (image policy)   │   │ background)             │  │
│  └────────────────────┘   └──────────────────┘   └────────────────────────┘  │
└─────────┬───────────────────────────────┬────────────────────────────────────┘
          │                               │
          ▼                               ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│ Domain ports (interfaces) + domain models                                     │
├───────────────────────────────────────────────────────────────────────────────┤
│  Ports: AiBackend, ImageStore, ScanRepository, CompsRepository, SyncOutbox,   │
│         Connectivity, Clock, Logger, Metrics                                  │
│  Models: ScanItem, PhotoAssetRef, AiEvidence, SyncState, JobRun               │
└─────────┬───────────────────────────────┬────────────────────────────────────┘
          │                               │
          ▼                               ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│ Infrastructure (adapters)                                                     │
├───────────────────────────────────────────────────────────────────────────────┤
│  Local: Drift DB/DAOs, file storage (original+thumb+redacted variants),       │
│         long-lived isolates for CPU work (thumb gen, offline inference)       │
│  Network: Supabase client, Edge Function clients, HTTP clients                │
│  AI: CloudGeminiBackend (via Edge Function), OfflineYoloXBackend (opt-in)     │
│  Observability: Sentry + local diagnostics store (DB-backed)                  │
└─────────┬───────────────────────────────┬────────────────────────────────────┘
          │                               │
          ▼                               ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│ External services                                                             │
├───────────────────────────────────────────────────────────────────────────────┤
│ Supabase (Auth/Storage/Edge Functions)   Gemini (cloud vision)   Tradera SOAP │
└───────────────────────────────────────────────────────────────────────────────┘

Background entrypoints:
  OS scheduler → workmanager callbackDispatcher → BackgroundRuntime → JobRunner
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| Feature UI (Scanner/Item/Settings) | Render state and trigger intentful actions only | Widgets + Riverpod controllers |
| Feature controller | Translate user actions into use-case calls; map results to UI state | `AsyncNotifier`/`Notifier` + typed states |
| `ScanCaptureService` | Persist captures (image + DB rows), create thumbnails, enqueue follow-up work | Uses `ImageStore` + Drift DAOs + task queue |
| `PrivacyGate` | Enforce consent + policy before any image leaves device; apply cropping/redaction/downscaling | Pure Dart + isolate helpers; configurable policy |
| `AiOrchestrator` | Choose AI backend per policy (cloud default, offline optional); handle retries/backoff; persist results | Depends on `AiBackend` registry, DB, settings, connectivity |
| `AiBackend` (port) | A pluggable identification contract | `CloudGeminiBackend`, `OfflineYoloXBackend` |
| `CloudGeminiBackend` | Call cloud AI without shipping secrets; normalize response into `AiResult` | Supabase Edge Function client (preferred) |
| `OfflineYoloXBackend` | Run opt-in lightweight offline detection; provide evidence (boxes/classes) | TFLite/ONNX plugin + long-lived isolate |
| `SyncCoordinator` | Optional cloud sync: outbox drain + incremental pull + conflict resolution | Drift outbox tables + Supabase APIs |
| `MarketCompsRefresher` | Fetch sold comps via Tradera proxy; cache results locally; degrade offline | HTTP/Supabase Edge Function proxy + Drift caches |
| `JobRunner` | Run idempotent “jobs” in foreground or background (sync/comps/cleanup) | Shared job registry + `workmanager` entrypoint |
| Observability (`Logger`, `Metrics`, `Diagnostics`) | Breadcrumbs, error reports, job/run traces, user-shareable debug bundle | Sentry + DB log ring buffer + diagnostics screen |

## Recommended Project Structure

Keep the existing Riverpod + Drift + `lib/features`, `lib/core`, `lib/services` shape, but make boundaries explicit by introducing “ports/adapters” seams.

```
lib/
├── core/                     # Cross-cutting: config, result/error types, logging, utils
│   ├── config/
│   ├── database/             # Drift DB + DAOs (local source of truth)
│   ├── logging/
│   ├── observability/
│   └── utils/                # serial task queue, isolate helpers
├── domain/                   # Pure domain models + ports (interfaces)
│   ├── ai/                   # AiBackend port + AiResult/Evidence models
│   ├── privacy/              # Image policy models (consent, redaction rules)
│   ├── sync/                 # Outbox/sync state machine models
│   └── market/               # comps models + repository ports
├── services/                 # Application use-cases/orchestrators
│   ├── ai/                   # AiOrchestrator + backends registry
│   ├── privacy/              # PrivacyGate implementation
│   ├── sync/                 # SyncCoordinator + job definitions
│   ├── market/               # MarketCompsRefresher
│   └── diagnostics/          # debug bundle creation
├── integrations/             # Adapters to external services (no UI)
│   ├── supabase/             # storage/auth/functions clients
│   ├── gemini/               # edge-function request/response DTOs
│   ├── tradera/              # proxy client
│   └── yolo/                 # offline model runtime bindings
├── background/               # workmanager entrypoint + background runtime composition
│   ├── callback_dispatcher.dart
│   └── background_runtime.dart
├── features/                 # UI screens and feature-local controllers
│   ├── scanner/
│   ├── items/
│   ├── settings/
│   └── diagnostics/
└── main.dart                 # Composition root: provider overrides + boot + routing
```

### Structure Rationale

- **`domain/`:** defines stable seams (`AiBackend`, `ImageStore`, `SyncOutbox`) so you can swap cloud/offline AI without UI churn.
- **`services/`:** holds the “policy brains” (consent, backend selection, retries) so integrations stay dumb and testable.
- **`integrations/`:** concentrates all external API quirks (Supabase functions, Gemini/Tradera DTOs, offline model bindings) away from the rest of the code.
- **`background/`:** prevents background-only init from leaking into `main.dart` and enforces “minimal runtime” rules.

## Architectural Patterns

### Pattern 1: Pluggable AI via Ports + Policy-Based Selection

**What:** Define an `AiBackend` interface (port) and select an implementation at runtime using a single `AiOrchestrator` policy engine.

**When to use:** Always. Cloud vs offline is a product decision and changes over time; the app should not hardcode it into screens.

**Trade-offs:** Slight upfront abstraction work; large long-term win: easier experimentation, safer rollouts, simpler deprecations.

**Example:**
```dart
enum AiBackendId { cloudGemini, offlineYolo }

abstract interface class AiBackend {
  AiBackendId get id;
  Future<AiResult> identify(AiInput input);
}

final class AiOrchestrator {
  AiOrchestrator({
    required Map<AiBackendId, AiBackend> backends,
    required PrivacyGate privacyGate,
    required AiPolicy policy,
    required Connectivity connectivity,
  })  : _backends = backends,
        _privacyGate = privacyGate,
        _policy = policy,
        _connectivity = connectivity;

  final Map<AiBackendId, AiBackend> _backends;
  final PrivacyGate _privacyGate;
  final AiPolicy _policy;
  final Connectivity _connectivity;

  Future<AiResult> identifyFromPhoto(PhotoAssetRef photo) async {
    final sanitized = await _privacyGate.prepareForAi(photo);

    final preferCloud = _policy.cloudAiEnabled && await _connectivity.isOnline();
    final backendId = preferCloud ? AiBackendId.cloudGemini : AiBackendId.offlineYolo;

    final backend = _backends[backendId]!;
    return backend.identify(AiInput(photo: sanitized));
  }
}
```

### Pattern 2: Privacy Gate for Images (Consent + Redaction as a First-Class Boundary)

**What:** All “image leaves device” operations must flow through a single `PrivacyGate` that enforces consent + transformation policy.

**When to use:** Any cloud AI call, any cloud photo sync/upload, and any diagnostics export.

**Trade-offs:** Adds pipeline steps (crop/downscale/redact), but reduces compliance risk and user trust damage.

**Key rules (opinionated):**

- Never upload “original” by default; upload only a derived artifact (`crop` or `redacted`) scoped to the AI task.
- Consent is explicit and revocable; policy is configurable per feature (“cloud identify” and “cloud photo sync” are separate toggles).
- Redaction is deterministic and auditable: store *what was sent* (hash + dimensions + policy version), not the pixels.

**Suggested image pipeline inside `PrivacyGate` (directional, no backdoors):**

```
Original (local-only) → normalize/rotate → strip metadata → downscale → crop → redact → upload
```

Practical privacy defaults for 2026-2027:

- Strip EXIF/location metadata from any derived artifact.
- Prefer sending a low-resolution crop (e.g., max dimension cap) rather than the full frame.
- Maintain a clear separation between:
  - **AI artifact** (ephemeral or short-lived, purpose-limited)
  - **Cloud backup artifact** (explicit opt-in, long-lived)
- Persist an “egress audit record” per request: `backendId`, `policyVersion`, `imageHash`, `byteSize`, `dimensions`, `timestamp`, `scanItemId`.

### Pattern 3: Offline-First Source of Truth + Sync Outbox

**What:** Drift DB remains the single source of truth. Cloud sync is a best-effort replication layer built on:

- an outbox table (pending operations)
- per-entity sync status
- incremental pull (by `updated_at` or server cursor)

**When to use:** Always. It keeps the app usable offline and prevents “dual write” bugs.

**Trade-offs:** Requires careful conflict rules; pays back by removing an entire class of “stuck in sync” failures.

Implementation guidance aligned to current codebase:

- Keep current “dirty marking” but evolve metadata sync to be incremental (avoid full-table pulls).
- Track “attempted” vs “succeeded” timestamps separately (prevents failed attempts from suppressing retries).

### Pattern 4: Unified Job Runner (Foreground + Background)

**What:** Define jobs once, run them from:

- user actions (foreground “sync now”)
- app lifecycle hooks (on resume)
- OS scheduler (workmanager)

Each job is idempotent and records a `JobRun` row for debugging.

**When to use:** Sync, comps refresh, cleanup, cache pruning.

**Trade-offs:** Requires discipline (idempotency, timeouts, partial progress), but fixes “background is a different app” drift.

## Data Flow

### Request Flow (Scan → Persist → Identify → Comps)

```
[User takes photo]
    ↓
Scanner UI → ScanCaptureService → (ImageStore + Drift)
    ↓
AiOrchestrator → PrivacyGate → AiBackend (CloudGemini | OfflineYoloX)
    ↓
Persist AiResult to Drift → mark item eligible for comps/sync
    ↓
MarketCompsRefresher (foreground or JobRunner) → Tradera proxy → Drift caches
```

### State Management (Riverpod)

```
Drift watch streams + Providers
    ↓ (subscribe)
Screens/widgets ←→ Feature controllers (intent) → services/use-cases → DAOs
```

### Key Data Flows

1. **Cloud AI identify (privacy-aware):** local photo → derived crop/redacted → Edge Function → `AiResult` → DB.
2. **Offline AI fallback:** local photo → derived (downscaled) → offline runtime isolate → evidence boxes → DB.
3. **Optional cloud photo sync:** local photo variants → policy gate (original vs redacted) → Supabase Storage → sync status.
4. **Background comps refresh:** job scheduled → minimal runtime → fetch comps → persist → update “last refreshed”.
5. **Diagnostics bundle:** DB job runs + sync statuses + recent logs + config (redacted) → export/share.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-1k users | Current monolith app + Edge Functions is sufficient; focus on privacy gate + correctness. |
| 1k-100k users | Add per-user quotas/rate limits in Edge Functions; incremental metadata sync + batching; cache comps aggressively. |
| 100k+ users | Move AI proxy from Edge Functions to a dedicated backend (Cloud Run) if needed; add queueing; stronger abuse detection. |

### Scaling Priorities

1. **First bottleneck:** Cloud sync and comps fetch volume → incremental pulls, pagination, batch writes, backoff.
2. **Second bottleneck:** AI cost and latency → backend policy (quotas, caching), minimize pixels sent (crop + downscale).

## Anti-Patterns

### Anti-Pattern 1: UI Calls External Clients Directly

**What people do:** `ScannerScreen` hits Gemini/Tradera directly.

**Why it's wrong:** Breaks testability, privacy guarantees, and makes backend swaps expensive.

**Do this instead:** UI → controller → `AiOrchestrator`/`MarketCompsRefresher` with ports.

### Anti-Pattern 2: Uploading Original Images by Default

**What people do:** Reuse the same photo path for local storage, cloud sync, and cloud AI.

**Why it's wrong:** Turns a product toggle into a compliance incident; makes “consent” meaningless.

**Do this instead:** Store variants; gate any upload through `PrivacyGate`; upload only derived artifacts unless user explicitly enables cloud photo backup.

### Anti-Pattern 3: Background Tasks Swallow Errors

**What people do:** Always return success from background callbacks; only log `print()`.

**Why it's wrong:** Production debugging becomes impossible; jobs silently stop working.

**Do this instead:** Record `JobRun` rows, return retry/failure appropriately, and report errors via Sentry when configured.

### Anti-Pattern 4: One-Isolate-Per-Inference

**What people do:** Spawn/kill an isolate per offline inference call.

**Why it's wrong:** Latency and battery regress; cancellation races are hard.

**Do this instead:** Long-lived worker isolate (or small pool) for offline CPU work; request/response over a typed channel.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Supabase Edge Functions | App calls `functions.invoke()` (preferred) or signed HTTPS with explicit auth headers | Central place for auth, rate limits, and keeping AI API keys off-device. |
| Supabase Storage | Optional photo backup; use policies + per-user paths | Must be governed by the same `PrivacyGate` policy as AI uploads. |
| Gemini (cloud vision) | Called from server-side proxy (Edge Function or Cloud Run) | Avoid embedding API keys; enforce quotas; log request metadata only. |
| Tradera | Use existing SOAP proxy Edge Function | Decide public vs authenticated and enforce; add rate limiting if public. |
| Sentry | App + Edge Functions monitoring when configured | Use breadcrumbs + job run IDs; support user-generated diagnostics bundle. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `features/*` ↔ `services/*` | direct method calls via Riverpod-injected service | UI never touches integrations/clients directly. |
| `services/*` ↔ `domain/*` | domain ports + domain models | Enables swapping backends and testing with fakes. |
| `services/*` ↔ `integrations/*` | adapter implementations only | Integrations do not reach into UI or Riverpod. |
| `background/*` ↔ `services/*` | job runner API | Background runtime initializes minimal dependencies and reuses jobs. |

## Suggested Build Order (2026-2027 evolution)

This ordering minimizes rewrites and supports incremental rollout.

1. **PrivacyGate + image asset variants (foundation)**
   - Define `PhotoAssetRef` + variants (`original`, `thumb`, `ai_crop`, `redacted`) and a single gate for “leaves device”.
   - Add persistent audit metadata (hash, dimensions, policy version) to DB.

2. **AI ports + AiOrchestrator (pluggable selection)**
   - Introduce `AiBackend` port, unify result schema, and make selection purely policy-driven.

3. **Cloud Gemini backend via server-side proxy (default path)**
   - Add an Edge Function `ai-identify` (or equivalent) to call Gemini without shipping secrets.
   - Enforce auth, quotas, and log correlation IDs.

4. **Settings + consent UX + safe defaults**
   - Ship toggles: “cloud identify” (default ON) and “cloud photo backup” (default OFF).
   - Make revocation immediate (stop sending pixels; optionally delete cloud artifacts).

5. **Remove first-run model download**
   - Ensure the cloud path works without any offline model install.
   - Keep offline detection disabled unless explicitly enabled.

6. **Offline fallback backend (YOLOX-class) + long-lived worker isolate**
   - Add offline runtime and evidence output; keep model small and opt-in.

7. **Unify background work into JobRunner + observability**
   - Refactor existing background sync to record `JobRun` rows + surface failures.
   - Ensure jobs run on resume as well (iOS scheduling is best-effort).

8. **Sync scalability improvements**
   - Incremental pull (by `updated_at`/cursor), batching, and correct “attempted vs succeeded” timestamps.

## Sources

- workmanager (Flutter) package overview (wraps Android WorkManager + iOS Background Tasks): https://pub.dev/packages/workmanager
- Flutter Workmanager Quickstart (iOS BGTaskScheduler / Background Fetch notes): https://docs.page/fluttercommunity/flutter_workmanager/quickstart
- Supabase Edge Functions overview (gateway/JWT validation, secrets, logs): https://supabase.com/docs/guides/functions
- Supabase Storage overview (bucket types, access control concepts): https://supabase.com/docs/guides/storage
- Existing codebase architecture map (Riverpod + Drift + services + background): `.planning/codebase/ARCHITECTURE.md`
- Known codebase concerns (background error swallowing, sync scaling, isolate-per-inference): `.planning/codebase/CONCERNS.md`

---
*Architecture research for: offline-first Flutter app with cloud-first AI*
*Researched: 2026-02-21*
