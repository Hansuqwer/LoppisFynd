# Pitfalls Research

**Domain:** Flutter offline-first mobile app (iOS/Android) with cloud AI inference (images) + optional offline ML fallback + tokenized UI (dark mode)
**Researched:** 2026-02-21
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Shipping cloud image upload without explicit, in-flow disclosure + controls

**What goes wrong:**
Users take a photo locally, but the app silently sends the image (or crop) to a third-party AI provider. App Store / Play policy review flags it as unexpected data transfer, and users feel betrayed.

**Why it happens:**
Teams treat cloud inference like any other API call and only mention it in a privacy policy or a deep settings page.

**How to avoid:**
- Add a first-run (or first-use) consent gate for "Cloud identification" that clearly states: what is sent (image/crop + metadata), to whom (service/provider), why (identify item), and how long it is retained.
- Keep the toggle user-accessible and reversible (Settings + per-scan "cloud" switch).
- Make the cloud path optional and preserve core offline flows.
- Keep disclosures consistent across: in-app copy, Privacy Policy, App Store privacy details, and Play Data Safety.

**Warning signs:**
- Review notes / store rejection mentions "user data" or "unexpected data collection".
- Support tickets: "Why is the app uploading my photos?".
- Engineers cannot answer "Do we retain the image?" without checking provider dashboards.

**Phase to address:**
Milestone 1 (Hybrid AI Enablement) + Milestone 4 (Token adoption/dark mode, for the settings UX patterns).

---

### Pitfall 2: Incorrect App Store Privacy / Play Data Safety declarations (especially for ephemerally processed photos)

**What goes wrong:**
Store listing declarations drift from actual behavior (e.g., photos are uploaded for inference, but marked as "not collected" or missing). This triggers policy enforcement or forced updates under pressure.

**Why it happens:**
Developers misunderstand "collect" vs "ephemeral processing" and forget to include third-party SDK/service behavior.

**How to avoid:**
- Inventory all off-device transmissions (app + Edge Functions + AI provider + crash/analytics SDKs).
- Treat "photo upload to cloud AI" as collected user content unless you can confidently assert ephemeral processing per store definitions.
- Add a release checklist item: update App Store privacy details + Play Data Safety as part of any cloud AI change.

**Warning signs:**
- Privacy label answers are based on "what we think" rather than a data-flow doc.
- Different team members give different answers about whether data is stored.

**Phase to address:**
Milestone 1.

---

### Pitfall 3: Prompt/image data leaking into logs, crash reports, or analytics

**What goes wrong:**
Raw prompts, AI JSON, or image URLs/paths end up in Sentry breadcrumbs, Edge Function logs, or analytics events. This expands the privacy surface area and complicates deletion/export guarantees.

**Why it happens:**
Debug logging is left enabled; errors are captured with full request bodies; "AI JSON" is treated like harmless metadata.

**How to avoid:**
- Redact request/response payloads by default; log only non-sensitive identifiers + sizes + timing.
- Split "attempt" vs "success" telemetry, and never include image content.
- Add automated checks in Edge Functions to reject oversized payloads and strip unexpected fields.

**Warning signs:**
- Sentry issues include full AI responses or user-provided text.
- Edge Function logs show base64 blobs or signed URLs.

**Phase to address:**
Milestone 1 (cloud AI rollout) + Milestone 3 (dependency modernization, logging SDK changes).

---

### Pitfall 4: Unbounded cloud inference spend (no budgets, no dedupe, no backoff)

**What goes wrong:**
Costs spike due to repeated retries, background sync loops, or UI re-tries without caching. The project responds by disabling features instead of controlling usage.

**Why it happens:**
Cloud inference is integrated directly in the app without a server-side policy layer; UI triggers multiple calls per scan.

**How to avoid:**
- Put inference behind a server-side proxy (Supabase Edge Function) that enforces: per-user limits, per-IP/device limits, payload size caps, and daily/monthly budgets.
- Cache results by content hash (e.g., perceptual hash of crop) to prevent repeated charges.
- Implement exponential backoff + jitter for 429s and provider transient failures.
- Cap image resolution/bytes before upload.

**Warning signs:**
- Many identical requests (same scanId/image) in logs.
- Frequent 429 (resource exhausted) responses.
- Billing graphs with sawtooth spikes matching app releases.

**Phase to address:**
Milestone 1 (must be part of the initial cloud AI architecture).

---

### Pitfall 5: Client-side API keys / direct-to-provider calls enabling abuse

**What goes wrong:**
Keys get extracted from the mobile binary or intercepted; attackers call the AI API at scale. Even with TLS, mobile apps cannot keep secrets.

**Why it happens:**
Teams optimize for speed by calling the model provider directly from Flutter.

**How to avoid:**
- Never ship provider secrets in the app.
- Use Edge Functions as the only caller of the AI provider.
- Require auth (Supabase JWT) for paid/limited resources and apply rate limits even for public endpoints.

**Warning signs:**
- Provider dashboards show traffic with unknown user-agents/regions.
- Edge Function isn't used for inference, only for ancillary calls.

**Phase to address:**
Milestone 1.

---

### Pitfall 6: Misunderstanding provider data retention and "zero data retention" knobs

**What goes wrong:**
The app promises "we don't store images" but the chosen provider/product logs prompts for abuse monitoring, caches inputs, or retains content for grounding features. Privacy promises become inaccurate.

**Why it happens:**
Teams read marketing summaries and don't map them to specific API features (e.g., caching, prompt logging, grounding).

**How to avoid:**
- Decide the inference product (e.g., Vertex AI managed models) and document retention behavior per feature.
- Avoid features that force retention when your product claims zero retention.
- If supported, disable caching / request exceptions for abuse monitoring and reflect the chosen setting in the privacy policy.

**Warning signs:**
- Privacy policy claims are "absolute" without referencing the provider's terms/controls.
- Engineers enable features like session resumption/grounding without updating disclosures.

**Phase to address:**
Milestone 1.

---

### Pitfall 7: Offline fallback licensing traps (AGPL model stacks, non-commercial weights, dataset restrictions)

**What goes wrong:**
The project ships an offline model/runtime that is not commercially compatible (e.g., AGPL), or uses weights trained on a dataset with restrictive terms. This creates legal risk, app store takedown exposure, and forced rework.

**Why it happens:**
Teams treat "model" as an asset, not as a licensed dependency chain (code + weights + dataset + tooling).

**How to avoid:**
- Treat the offline ML chain like a software dependency: record licenses for code + model weights + dataset.
- Prefer Apache-2.0 style stacks (e.g., YOLOX code is Apache 2.0) and avoid AGPL stacks (Ultralytics license is AGPL-3.0).
- Keep a one-page "ML bill of materials" in the repo before shipping.

**Warning signs:**
- Someone says "it's open source so it's fine".
- No one can answer "what license are the weights under?".
- Offline model came from a random Kaggle/GitHub link.

**Phase to address:**
Milestone 2 (Lightweight Offline Fallback) + Milestone 6 (Token governance can add governance patterns; mirror for ML BOM governance).

---

### Pitfall 8: Offline fallback quality that feels worse than "no result" (trust collapse)

**What goes wrong:**
Offline model returns confident-but-wrong labels, or provides results without evidence/confidence. Users stop trusting both offline and cloud identification.

**Why it happens:**
Object detection is treated as a replacement for semantic identification. Teams optimize for demo accuracy instead of calibrated confidence and evidence.

**How to avoid:**
- Make offline fallback explicitly "assistive": show bounding boxes + confidence, not just a single label.
- Add a "no confident result" path and UI copy that sets expectations.
- Evaluate on a realistic secondhand taxonomy and measure calibration (false positives are worse than misses).

**Warning signs:**
- Offline model always returns something, even in hard cases.
- Support feedback: "it keeps saying everything is a chair".

**Phase to address:**
Milestone 2.

---

### Pitfall 9: Reintroducing the first-run blocker via the "optional" offline model

**What goes wrong:**
The offline fallback model becomes a large download, auto-downloads unexpectedly, or bloats the app bundle. The original "no multi-GB first-run" goal regresses.

**Why it happens:**
Teams tie offline model install to app startup or scanner screen init for convenience.

**How to avoid:**
- Keep offline model opt-in and lazy: download only on explicit user action.
- Enforce a hard size budget (e.g., <10MB as per roadmap) and fail CI if exceeded.
- Ensure cloud-first works without any offline assets.

**Warning signs:**
- Scanner screen shows a spinner on first open even when cloud is enabled.
- Store download size grows unexpectedly.

**Phase to address:**
Milestone 1 (remove blocker) + Milestone 2 (offline fallback implementation).

---

### Pitfall 10: Treating background work as reliable scheduling (iOS especially)

**What goes wrong:**
The roadmap assumes background sync runs every N hours; in reality, the OS throttles or stops background execution when the app isn't used. Sync appears "random" and support cannot reproduce.

**Why it happens:**
Developers interpret background plugins as cron.

**How to avoid:**
- Design sync as best-effort and user-triggered first; background runs only reduce staleness.
- Make background jobs idempotent, bounded, and resumable.
- Surface "last attempted" and "last successful" sync in UI.

**Warning signs:**
- QA reports: "background sync didn't run overnight".
- Users have stale data until they open the app.

**Phase to address:**
Milestone 1 (cloud + market sync are the first to feel this) + Milestone 3 (workmanager upgrades).

---

### Pitfall 11: Background tasks that do too much (timeouts, OS punishment, silent failures)

**What goes wrong:**
Background jobs try to upload photos, run inference, generate thumbnails, and sync metadata in one go. They exceed time limits, fail mid-flight, and the app swallows errors (current codebase concern).

**Why it happens:**
Background work is implemented as "call the same sync method" without strict bounds, chunking, or time budgeting.

**How to avoid:**
- Split jobs: metadata first, photo sync separately, and avoid inference in background unless explicitly required.
- Chunk network payloads and enforce per-run time budgets.
- Record outcomes and report errors (Sentry when configured); do not return success on exceptions.

**Warning signs:**
- Background runner always reports success while data is stale.
- Temp files accumulate (already observed in photo download path).

**Phase to address:**
Milestone 1 (cloud sync coordination) + Milestone 3 (dependency upgrades) + ongoing hardening.

---

### Pitfall 12: Camera lifecycle/resource regressions after dependency upgrades

**What goes wrong:**
After upgrading Flutter/camera, the plugin no longer manages lifecycle automatically. If the app doesn't dispose/re-init on lifecycle events, the camera breaks on resume or crashes.

**Why it happens:**
Upgrades are treated as "pubspec bump" without reading breaking changes.

**How to avoid:**
- Add lifecycle handling explicitly (dispose on inactive, re-init on resumed).
- Add regression tests for scanner flow: open camera, background app, resume, capture.

**Warning signs:**
- Crash reports spike on `CameraAccessDenied` / native camera exceptions.
- QA can reproduce "black preview" after app switch.

**Phase to address:**
Milestone 3.

---

### Pitfall 13: Big-bang dependency modernization without a platform CI matrix

**What goes wrong:**
Upgrading Riverpod/Drift/camera/workmanager/Gradle/iOS pods in one sweep causes cascading regressions, and the team can't isolate root cause.

**Why it happens:**
Time pressure and a desire to "get to latest" in one milestone.

**How to avoid:**
- Upgrade in thin slices with a green baseline after each slice.
- Add CI that builds + runs tests on both iOS and Android.
- Keep a small set of golden UI tests to catch theme regressions during upgrades.

**Warning signs:**
- Multiple native build failures at once.
- A single PR touches `pubspec.yaml`, `Podfile`, Gradle, and half the codebase.

**Phase to address:**
Milestone 3.

---

### Pitfall 14: Token adoption that is partial ("mostly" tokenized) leading to dark mode gaps

**What goes wrong:**
Some widgets use tokens, others use hardcoded colors/assets. Dark mode works on a few screens but is unreadable on edge screens. New code reintroduces hardcoded styling.

**Why it happens:**
Token migration is done opportunistically without enforcement and without a strict boundary between tokens and feature UI.

**How to avoid:**
- Define a token-only primitive layer (surfaces, text styles, icons/assets) and forbid feature screens from referencing raw colors/assets.
- Add golden tests (light/dark) for shared primitives + top flows.
- Add a lint/CI check for new hardcoded colors/assets (roadmap Milestone 6).

**Warning signs:**
- "Fix dark mode" becomes a whack-a-mole task after every UI PR.
- Designers/devs cannot tell which tokens to use for surfaces vs states.

**Phase to address:**
Milestone 4 (dark mode + adoption) + Milestone 6 (governance/enforcement).

---

### Pitfall 15: Golden tests that are brittle (fonts, text rendering, platform differences)

**What goes wrong:**
Golden tests fail intermittently across platforms/CI, so teams disable them. Theme regressions slip through.

**Why it happens:**
Goldens are added without controlling fonts, text scaling, and animation.

**How to avoid:**
- Use a deterministic test harness: fixed textScaleFactor, disable animations, load fonts consistently.
- Prefer component-level goldens (primitives, cards, key screens) rather than whole-app snapshots.
- Add contrast checks as an additional non-golden assertion for dark mode.

**Warning signs:**
- PRs include "update all goldens" frequently.
- Golden failures differ between macOS/Linux runners.

**Phase to address:**
Milestone 4.

---

### Pitfall 16: Sync + inference state machines that don't handle offline transitions cleanly

**What goes wrong:**
User captures photos offline, then reconnects; the app triggers multiple sync/inference jobs concurrently. Duplicates appear, or last-sync timestamps suppress retries (already observed in coordinator).

**Why it happens:**
Offline-first is implemented at storage layer, but not at the orchestration layer (queues, idempotency keys, conflict rules).

**How to avoid:**
- Use explicit job records with states (queued/running/succeeded/failed) and idempotency keys.
- Write "last successful" timestamps only after success.
- Ensure cloud inference calls are idempotent per scan item.

**Warning signs:**
- Duplicate cloud uploads for the same scan.
- Sync stops retrying for hours after a single failure.

**Phase to address:**
Milestone 1 (cloud AI + cloud sync coordinator) + Milestone 3 (workmanager modernization).

---

### Pitfall 17: Edge Function proxy treated as a thin pass-through (no auth boundaries, no rate limits)

**What goes wrong:**
The proxy is either publicly callable (abuse/cost risk) or accidentally breaks when auth headers are missing. CORS remains wide-open and the team can't explain the threat model.

**Why it happens:**
Edge Functions are added to bypass CORS/keys quickly, then never hardened.

**How to avoid:**
- Decide: public endpoint with strict throttles, or authenticated endpoint with JWT verification.
- Add structured error responses and logging; avoid swallowing errors.
- Add tests for auth + rate limit behavior (especially for expensive endpoints).

**Warning signs:**
- App sometimes calls function via raw HTTP, sometimes via Supabase invoke.
- Function has `access-control-allow-origin: *` with no other controls.

**Phase to address:**
Milestone 1.

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Call cloud AI directly from the app | Fast to ship | Uncontrollable costs, key leakage risk, weak rate limiting | Never |
| Reuse the same "sync everything" method in foreground + background | Less code | Timeouts, silent partial sync, battery drain | Only if strictly time-bounded + chunked |
| Store raw AI JSON forever in the local DB | Debuggable history | Export/delete complexity, privacy exposure, migration burden | Only with explicit retention policy + redaction/export mode |
| Let tokens be optional (allow hardcoded colors during migration) | Faster UI tweaks | Dark mode gaps and permanent drift | Only in short-lived branches, enforced before merge |
| Big-bang dependency updates | Faster "latest" | Untriageable regressions across iOS/Android | Never |

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Cloud AI provider (Gemini/Vertex) | Forgetting data retention knobs and then writing absolute privacy claims | Document provider retention behavior; choose settings consistent with privacy policy |
| Supabase Edge Functions | Wide-open endpoint (public) + no rate limiting | JWT verification and/or explicit rate limits + budgets |
| Background job runner (workmanager) | Assuming "every N hours" is guaranteed | Best-effort design + UI visibility for last success |
| Crash reporting (Sentry) | Capturing request bodies / AI output in breadcrumbs | Redact by default; keep payloads out of telemetry |
| Camera plugin | Assuming lifecycle is handled by plugin | Dispose/re-init on lifecycle; test resume/capture flow |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Full-table cloud sync pulls | Sync time grows with user data; timeouts after reconnect | Incremental pull (`updated_at > lastSync`) + pagination | Hundreds to thousands of items |
| No caching of AI results | Same image re-identified repeatedly | Content-hash cache + idempotency | Immediately (cost + latency) |
| Repeated runtime/model init in hot path | Slow scans, battery drain | Initialize once per session; long-lived worker isolate | Immediately on mid/low-end devices |
| Unbounded background work | Battery drain; OS throttling | Chunking + time budgets + backoff | Weeks of use (reliability degrades) |

## Security Mistakes

Domain-specific security issues beyond general mobile/web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Provider secrets in the app | Key extraction; unlimited inference abuse | Server-side proxy only; rotate secrets |
| Public edge proxy to paid APIs | Billing fraud; denial-of-wallet | Auth + rate limiting + quotas |
| Overbroad CORS on proxies | Cross-site abuse from web contexts | Restrict origins where possible; require auth |
| Returning detailed provider errors to client | Leaks about quotas/models/keys | Map to safe error codes/messages |
| Logging user content on server | Privacy breach + retention obligations | Redaction + minimal logs |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| "Cloud AI" toggle buried in dev-only UI | Users can't control photo sending | Visible, plain-language setting + first-use consent |
| Offline fallback presented as equally reliable | Users trust wrong results | Label as "offline assist" + show evidence/confidence |
| Silent failure when offline | User thinks feature is broken | Clear offline state + queueing + retry indicators |
| Dark mode shipped with low contrast | Unusable screens at night | Token-driven ramps + contrast audit + goldens |

## "Looks Done But Isn't" Checklist

- [ ] **Cloud AI:** Has a first-use disclosure + user toggle + store declarations updated (App Privacy + Data Safety).
- [ ] **Cloud AI cost controls:** Server-side rate limiting + per-user quotas + caching + 429 backoff.
- [ ] **Offline fallback:** License chain documented (code + weights + dataset) and model is opt-in with a strict size budget.
- [ ] **Background sync:** Shows last attempted vs last successful; background failures are visible in diagnostics.
- [ ] **Token/dark mode:** Shared primitives have light/dark goldens; CI blocks new hardcoded colors/assets.

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Store/privacy rejection for cloud image upload | HIGH | Ship a hotfix with explicit disclosure + toggle; update store declarations; add review notes explaining behavior |
| Cost spike / abuse of inference | HIGH | Rotate keys, lock down to server-only, add rate limits + budgets, add caching; consider temporary feature flag |
| Licensing issue discovered late | HIGH | Remove/disable offline fallback, replace with permissive stack, publish attribution + update docs |
| Background sync unreliable | MEDIUM | Make sync user-triggered and visible; reduce job scope; implement retry/backoff and status recording |
| Dark mode regressions everywhere | MEDIUM | Freeze UI changes, migrate primitives first, add goldens + enforcement, then migrate screens |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Missing disclosure/controls for cloud image upload | Milestone 1 | Manual review: first-use prompt + settings toggle; store declaration checklist passes |
| Incorrect store privacy declarations | Milestone 1 | Compare data-flow inventory vs App Privacy + Data Safety answers |
| Payload leaking into logs/Sentry | Milestone 1 | Grep logs/telemetry for base64/image URLs; verify redaction rules |
| Unbounded cloud inference spend | Milestone 1 | Load test: repeated scans do not increase bill linearly; rate-limit returns 429 with backoff |
| Client-side secrets / direct provider calls | Milestone 1 | Confirm app has no provider key; all inference via Edge Function |
| Provider retention mismatch | Milestone 1 | Privacy policy matches chosen provider settings (caching/logging/grounding) |
| Offline ML licensing trap | Milestone 2 | ML BOM doc exists; licenses verified (Apache vs AGPL) |
| Offline fallback trust collapse | Milestone 2 | Evaluation set shows calibrated confidence; UI shows evidence + allows "no result" |
| Offline model reintroduces first-run blocker | Milestone 1/2 | Fresh install: scanner usable immediately; offline model downloads only on opt-in |
| Background scheduling assumed reliable | Milestone 1/3 | Verify UX shows last success; QA test with app unused for days |
| Background task overwork/timeouts | Milestone 1/3 | Background runs are bounded and chunked; failures recorded and surfaced |
| Camera lifecycle regressions | Milestone 3 | Regression test: background/resume/capture works on iOS+Android |
| Big-bang dependency upgrade | Milestone 3 | PRs upgrade in slices; CI matrix green after each |
| Partial token adoption -> dark mode gaps | Milestone 4/6 | CI check blocks hardcoded colors/assets; goldens for primitives |
| Brittle golden tests | Milestone 4 | Goldens stable across CI runners; minimal churn |
| Offline/online transition races | Milestone 1/3 | Idempotency keys in sync/inference; duplicate prevention tests |
| Thin pass-through proxy | Milestone 1 | Auth + rate limits tested; CORS + threat model documented |

## Sources

- Apple App Store App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple "App privacy details" (privacy labels, definitions of collection): https://developer.apple.com/support/app-privacy-on-the-app-store/
- Google Play Data safety form overview (incl. ephemeral processing definition): https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play User Data policy (prominent disclosure + consent requirements): https://support.google.com/googleplay/android-developer/answer/10144311
- Vertex AI "zero data retention" and data caching/logging notes: https://cloud.google.com/vertex-ai/generative-ai/docs/vertex-ai-zero-data-retention
- Vertex AI throughput quota / 429 guidance: https://cloud.google.com/vertex-ai/generative-ai/docs/resources/throughput-quota
- Supabase Edge Functions overview (auth/policies at gateway): https://supabase.com/docs/guides/functions
- Supabase Edge Functions rate limiting example: https://supabase.com/docs/guides/functions/examples/rate-limiting
- Flutter workmanager plugin (background scheduling wrapper): https://pub.dev/packages/workmanager
- Flutter background_fetch plugin (iOS cadence limits + termination behavior): https://pub.dev/packages/background_fetch
- Flutter camera plugin (lifecycle not handled by plugin): https://pub.dev/packages/camera
- YOLOX Apache 2.0 license (code licensing baseline): https://raw.githubusercontent.com/Megvii-BaseDetection/YOLOX/main/LICENSE
- Ultralytics AGPL-3.0 license (example of licensing trap): https://raw.githubusercontent.com/ultralytics/ultralytics/main/LICENSE
- Google Generative AI prohibited use policy (policy constraints relevant to app features): https://policies.google.com/terms/generative-ai/use-policy

---
*Pitfalls research for: offline-first Flutter app with cloud AI + optional offline ML + tokenized UI*
*Researched: 2026-02-21*
