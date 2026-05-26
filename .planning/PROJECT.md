# FyndLoppis

## What This Is

FyndLoppis is an offline-first Flutter app (iOS/Android) for capturing secondhand finds, identifying items from photos, and fetching sold-price comparisons to help decide what to buy or resell.
This project is the 2026-2027 technical evolution of the existing app: remove the first-run Gemma model download blocker, move to cloud-first AI with an optional lightweight offline fallback, modernize dependencies, and adopt the already-landed UI System v2 tokens (including dark mode and responsive layouts).

## Core Value

The app launches immediately (no multi-GB downloads) and helps a user quickly identify and price a secondhand item from a photo, even with unreliable connectivity.

## Requirements

### Validated

- [x] Offline-first local persistence with Drift/SQLite (hauls, scan items, photos)
- [x] Camera-based scanner flow that persists captures into the local DB
- [x] AI inference pipeline using on-device Gemma via `flutter_gemma`, run off the UI thread (isolate) and persisted into scan items
- [x] Sold-price comparisons via Tradera (SOAP) through a Supabase Edge Function proxy
- [x] Optional Supabase auth + cloud metadata/photo sync (best-effort, offline-friendly)
- [x] Privacy operations (data export, cloud delete/account delete flows)
- [x] Crash/error reporting + breadcrumbs via Sentry when configured

### Active

- [ ] Remove the first-run Gemma download blocker (app usable without any model download)
- [ ] Add cloud-first AI identification (Gemini) as the default inference path
- [ ] Keep an opt-in lightweight offline fallback (commercial-safe object detection with evidence)
- [ ] Modernize dependencies to current stable and eliminate deprecated API usage
- [ ] Adopt UI System v2 tokens across shared primitives + wire dark mode
- [ ] Add responsive layout support (tablet/foldable breakpoints)
- [ ] Add token governance/export + enforcement to prevent hardcoded UI regressions

### Out of Scope

- Native Android/iOS rewrite - stay on Flutter
- Major architecture changes - keep Riverpod + Drift as the core structure
- New platforms (web/desktop) - focus on iOS/Android
- Revenue model changes (subscriptions, etc.) - not part of this roadmap

## Context

Existing codebase is a Flutter app with Riverpod DI/state, Drift (SQLite) as the offline-first source of truth, and optional Supabase for auth + cloud metadata/photo sync.
There is currently an on-device Gemma inference backend (via `flutter_gemma`) with model download/install plumbing, plus Tradera sold-price comps via a Supabase Edge Function proxy.

Primary references:
- Roadmap input: `roadmapv2/roadmap_flutter_2026_2027_v1_1.md`
- Codebase map: `.planning/codebase/` (STACK/ARCHITECTURE/INTEGRATIONS/CONCERNS)

## Constraints

- **Platforms**: iOS + Android supported throughout - do not break either
- **Offline-first**: Core flows remain functional offline; cloud features degrade gracefully
- **Performance**: First-run launch <5s; no multi-GB mandatory downloads
- **Licensing**: Offline ML must be commercially safe (avoid AGPL-licensed model stacks)
- **Privacy/Compliance**: Cloud AI requires explicit user controls and clear data handling

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Cloud-first AI (Gemini) becomes the primary identification path | Eliminates first-run model download blocker; simplifies device support matrix | -- Pending |
| Keep offline fallback, but lightweight (YOLOX-class) and opt-in | Preserve offline capability without large downloads or fragile runtimes | -- Pending |
| Use YOLOX (Apache 2.0) over Ultralytics YOLO (AGPL) | App store distribution requires commercial-safe licensing | -- Pending |
| Keep Riverpod + Drift architecture | Existing structure is sound; focus on evolution over rewrite | -- Pending |
| UI System v2 tokens/assets are baseline; remaining work is adoption + dark mode wiring | Tokens already landed; prioritize migration and enforcement | -- Pending |

---
*Last updated: 2026-02-21 after initialization*
