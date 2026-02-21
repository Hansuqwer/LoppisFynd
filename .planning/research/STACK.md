# Stack Research

**Domain:** Flutter offline-first mobile app (Riverpod + Drift) with cloud-first AI image identification (Gemini) and optional lightweight offline object detection fallback
**Researched:** 2026-02-21
**Confidence:** MEDIUM

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Flutter + Dart | Flutter stable (project-pinned) / Dart 3.x | iOS/Android app runtime | Flutter remains the default cross-platform choice; keep the repo’s pinned stable toolchain to avoid CI drift and keep upgrades deliberate. (Confidence: HIGH) |
| `flutter_riverpod` | `^3.2.1` | App state/DI, async caching, feature boundaries | Riverpod is the de-facto non-Framework state management choice in 2026; v3+ keeps a clean provider model and supports generator/lints for safer refactors. (Confidence: HIGH) |
| Drift (SQLite) | `drift ^2.31.0` | Offline-first source of truth (hauls, scan items, queues) | Drift is the most production-proven relational persistence stack in Flutter with type-safe queries, migrations, streams, and isolate-friendly DB access. (Confidence: HIGH) |
| Supabase (Flutter) | `supabase_flutter ^2.12.0` | Auth + Storage + Edge Function invocation + optional cloud sync | Supabase provides an opinionated but flexible backend for auth, storage, and serverless endpoints; `supabase_flutter` is the canonical Flutter client. (Confidence: HIGH) |
| Supabase Edge Functions | Deno 2 (Supabase Edge Runtime) | Server-side Gemini calls, Tradera proxy, privacy ops | Edge functions keep secrets off-device (Gemini key, vendor keys), centralize prompt/versioning, and allow caching/rate limiting without adding a separate backend. (Confidence: HIGH) |
| Gemini SDK (server-side) | `@google/genai@1.42.0` | Cloud AI identification from images | Google’s unified GenAI JS SDK is the current official standard for Gemini; running it in Edge Functions avoids shipping keys to mobile clients and enables consistent results + observability. (Confidence: HIGH) |
| Lightweight offline detection runtime | `tflite_flutter ^0.12.1` | On-device fallback object detection (YOLOX-class) | TensorFlow-managed TFLite Flutter plugin gives fast, commercial-safe inference with isolate support; good fit for small quantized detectors (<10MB). (Confidence: MEDIUM) |
| Background work | `workmanager ^0.9.0+3` | Best-effort periodic sync, uploads, maintenance | WorkManager/BGTaskScheduler wrapper is still the most practical cross-platform scheduler in Flutter; treat as “eventually” not “guaranteed”. (Confidence: HIGH) |
| Observability (mobile) | `sentry_flutter ^9.14.0` | Crash + error + performance traces | Sentry is the most mature Flutter observability option; captures native crashes and supports performance instrumentation when configured. (Confidence: HIGH) |
| Observability (edge) | Sentry Deno SDK (`deno.land/x/sentry`) | Edge function errors + traces | Supabase documents Sentry monitoring for Edge Functions; add request-scoped capture and flush on errors. (Confidence: MEDIUM) |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `riverpod_annotation` + `riverpod_generator` | `riverpod_annotation ^4.0.2`, `riverpod_generator ^4.0.3` | Provider codegen (`@riverpod`) | Use for new providers and refactors: fewer footguns, easier families, better hot-reload ergonomics. (Confidence: HIGH) |
| `custom_lint` + `riverpod_lint` | `custom_lint ^0.8.1`, `riverpod_lint ^3.1.3` | Enforce Riverpod usage patterns in CI | Use to prevent subtle provider misuse during the brownfield migration (especially as AI pipeline + sync logic evolves). (Confidence: HIGH) |
| `drift_dev` + `build_runner` | `drift_dev ^2.31.0`, `build_runner ^2.11.1` | Drift codegen and tooling | Required for Drift table/query generation and drift-specific dev tooling. (Confidence: HIGH) |
| `camera` | `^0.11.4` | Capture images + stream buffers | Use for scanner flow; supports streaming and modern camera backends. (Confidence: HIGH) |
| `image` | `^4.8.0` | Pure-Dart image decode/transform | Use for deterministic cropping/resizing (e.g., create small JPEG/PNG payloads for cloud ID) when native codecs aren’t required. (Confidence: HIGH) |
| `flutter_image_compress` | `^2.4.0` | Fast native JPEG/WebP compression | Use to aggressively shrink uploads (Gemini + Storage) without janking the UI; prefer for large images where pure Dart is too slow. (Confidence: MEDIUM) |
| `connectivity_plus` | `^7.0.0` | Connectivity type signals | Use as a hint for “try sync now”, but never as a hard gate; always handle timeouts. (Confidence: HIGH) |
| `http` | `^1.6.0` | Simple HTTP client | Use for non-Supabase endpoints and lightweight requests; wrap with retries where appropriate. (Confidence: HIGH) |
| `flutter_secure_storage` | `^10.0.0` | Secure token/session storage | Use if you need stronger session persistence guarantees than shared_preferences (e.g., auth/session tokens). (Confidence: HIGH) |
| `flutter_local_notifications` | `^20.1.0` | User-visible sync/status notifications | Use for long-running uploads/sync progress or actionable errors; pair with Workmanager tasks. (Confidence: HIGH) |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Supabase CLI | Local Supabase stack + functions + migrations | Use `supabase start`, `supabase functions serve`, `supabase db reset` for parity with prod. Current release stream shows `v2.76.12` (tagged pre-release). (Confidence: MEDIUM) |
| Sentry CLI / Gradle symbol upload | Better mobile crash symbols | If you enable `--split-debug-info`, wire symbol upload in CI; otherwise stack traces will be less actionable. (Confidence: MEDIUM) |

## Installation

```bash
# Flutter (core)
flutter pub add flutter_riverpod@^3.2.1 drift@^2.31.0 supabase_flutter@^2.12.0

# Flutter (background + observability)
flutter pub add workmanager@^0.9.0+3 sentry_flutter@^9.14.0

# Flutter (AI payload + offline fallback)
flutter pub add camera@^0.11.4 image@^4.8.0 flutter_image_compress@^2.4.0 tflite_flutter@^0.12.1

# Flutter (supporting)
flutter pub add connectivity_plus@^7.0.0 http@^1.6.0 flutter_secure_storage@^10.0.0 flutter_local_notifications@^20.1.0

# Dev dependencies (codegen + lints)
flutter pub add -d build_runner@^2.11.1 drift_dev@^2.31.0 riverpod_generator@^4.0.3 riverpod_lint@^3.1.3 custom_lint@^0.8.1
flutter pub add riverpod_annotation@^4.0.2
```

Edge Functions (no install step required for Deno imports; pin versions in import specifiers):

```ts
// supabase/functions/<fn>/index.ts
import { GoogleGenAI } from "npm:@google/genai@1.42.0";
import { createClient } from "jsr:@supabase/supabase-js@2";
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Supabase Edge Function calling `@google/genai` | Firebase AI Logic (`firebase_ai ^3.8.0`) | If you want *client-to-Gemini* calls with built-in abuse protection (App Check) and don’t mind bringing Firebase into a Supabase-centric app. |
| `tflite_flutter ^0.12.1` + YOLOX-class TFLite model | Google ML Kit object detection | If you can accept limited/custom categories and prefer prepackaged models; not suitable for a custom secondhand taxonomy. |
| Drift (SQLite) | Isar / Hive | If you truly don’t need relational queries/joins/transactions; otherwise Drift’s SQL model is a better fit for scan items + sync queues. |
| `http ^1.6.0` | `dio` | If you need interceptors, advanced cancellation, or complex upload progress handling across many endpoints. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `google_generative_ai` (Dart) | Pub.dev marks it deprecated and states it will not receive new work; long-term it becomes an upgrade trap. | Server-side `@google/genai` via Supabase Edge Functions, or Firebase AI Logic (`firebase_ai`). |
| Shipping Gemini API keys in the Flutter app | Keys are extractable; abuse becomes your bill; rotating keys forces app releases. | Keep keys in Supabase secrets; call Gemini from Edge Functions. |
| Ultralytics YOLO models (AGPL) for offline detection | AGPL licensing is not compatible with typical closed-source app distribution without commercial licensing. | YOLOX (Apache 2.0) or another permissively-licensed detector; export to TFLite. |
| Mandatory multi-GB on-device model downloads on first run | Violates the core value (“launch immediately”), increases churn and support burden. | Cloud-first identification + opt-in lightweight offline fallback (<10MB). |
| Treating iOS/Android background scheduling as guaranteed | OSes throttle/kill background execution; “every N hours” is best-effort. | Make sync idempotent, incremental, and user-visible; also sync opportunistically on app resume and connectivity regain. |

## Stack Patterns by Variant

**Default (recommended):**
- Cloud-first ID: device crops/compresses → Supabase Edge Function → Gemini → stores structured result in Drift
- Offline fallback: YOLOX-class TFLite detector runs only when user opts in (or when offline)

**If strict privacy / no photo upload:**
- Disable cloud ID; run offline detection only; store “evidence” (bboxes) and a conservative label set
- Keep pricing comps optional (already proxied via Edge Function)

**If cost containment becomes critical:**
- Add Edge Function caching keyed by perceptual hash + prompt version
- Add per-user and per-device rate limits on the Edge Function; degrade to offline detection when over budget

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `camera@0.11.4` | Android SDK 24+, iOS 13+ | Sets a practical mobile floor; aligns with modern plugin ecosystem. |
| `flutter_local_notifications@20.1.0` | Flutter SDK 3.22+ | Plan Flutter upgrade before pinning this version if you’re below the minimum. |
| `sqlite3_flutter_libs` | Drift/SQLite stack | Pub.dev marks it obsolete/EOL as ecosystems move to sqlite3 v3; keep only as long as drift_flutter/drift require it, and remove once fully migrated. |

## Sources

- https://pub.dev/packages/flutter_riverpod — version `3.2.1` (Confidence: HIGH)
- https://pub.dev/packages/drift — version `2.31.0` (Confidence: HIGH)
- https://pub.dev/packages/supabase_flutter — version `2.12.0` (Confidence: HIGH)
- https://pub.dev/packages/workmanager — version `0.9.0+3` (Confidence: HIGH)
- https://pub.dev/packages/sentry_flutter — version `9.14.0` (Confidence: HIGH)
- https://pub.dev/packages/tflite_flutter — version `0.12.1` (Confidence: HIGH)
- https://github.com/googleapis/js-genai/releases — `@google/genai` release `v1.42.0` (Confidence: HIGH)
- Context7: `/googleapis/js-genai` — structured output + multimodal examples for `@google/genai` (Confidence: HIGH)
- Context7: `/supabase/supabase-js/v2.58.0` — Deno import (`jsr:@supabase/supabase-js@2`) (Confidence: HIGH)
- https://supabase.com/docs/guides/functions — Supabase Edge Functions runtime + patterns (Confidence: HIGH)
- https://supabase.com/docs/guides/functions/examples/sentry-monitoring — Sentry monitoring for Edge Functions (Confidence: MEDIUM)
- https://pub.dev/packages/google_generative_ai — marked deprecated (Confidence: HIGH)
- https://pub.dev/packages/firebase_ai — Firebase AI Logic SDK (`3.8.0`) alternative (Confidence: HIGH)
- https://raw.githubusercontent.com/Megvii-BaseDetection/YOLOX/main/LICENSE — YOLOX Apache 2.0 license (Confidence: HIGH)
- https://raw.githubusercontent.com/ultralytics/ultralytics/main/LICENSE — Ultralytics AGPL-3.0 license (Confidence: HIGH)

---
*Stack research for: Flutter offline-first AI identification app*
*Researched: 2026-02-21*
