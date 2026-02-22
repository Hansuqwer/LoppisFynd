# Phase 02: Cloud AI + Privacy Controls - Research

**Researched:** 2026-02-22
**Domain:** Flutter client + Supabase Edge Function proxy + privacy gating
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### First-use disclosure flow
- Disclosure appears on first app launch.
- Presentation is a blocking full-screen/modal that requires an explicit choice.
- Choices are exactly: "Enable cloud identification" and "Not now".
- Detail level on the disclosure is short (2-4 bullets) with a "Learn more" link.
- If the user chose "Not now", the next attempt to use Identify re-prompts just-in-time with the same disclosure and requires "Enable" to proceed.

### Privacy controls in Settings
- Settings includes a new top-level section named "Privacy & Data".
- Controls are visible to all users by default.
- Cloud control is a single toggle labeled "Send crops for cloud identification" (default ON).
- The cloud toggle subtext explicitly mentions the upload is minimal (crops only).
- "Fetch sold-price comps" is a toggle in the same "Privacy & Data" section.

### What gets uploaded (user-facing transparency)
- Provider naming in UI is generic: "cloud AI" (do not name the provider).
- The "Learn more" path includes an optional preview of the image data that would be uploaded (the crop(s)).
- Minimal image data rule is strict: crops only; never upload the full photo.
- Retention statement: uploaded image data is not stored on our server (processed transiently).

### Disabled/offline behavior
- If "Send crops for cloud identification" is OFF in Settings, Identify appears disabled with a short hint to enable it in Settings.
- If the user is offline while cloud identification is ON, tapping Identify fails fast with an "You're offline" message and a Retry action (no queuing).
- Blocked states include an "Open Settings" shortcut (both disabled and offline cases).

### Removing Gemma from first-run
- No onboarding or dashboard flow should prompt a Gemma download.
- Any on-device identification remains opt-in only (not prompted by default).

### Claude's Discretion
None specified.

### Deferred Ideas (OUT OF SCOPE)
None - discussion stayed within Phase 2 scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| AI-01 | App usable on first run without downloading any on-device AI model | Remove Gemma-first-run prompts; ensure cloud path is default and does not depend on local model files; ensure Settings/Onboarding no longer block on model install. |
| AI-02 | Cloud AI identification (Gemini) default when online and allowed | Add a `cloudGemini` backend to the AI abstraction; set as default in `lib/main.dart`; gate execution on connectivity + privacy toggle + consent. |
| AI-03 | Cloud AI requests proxied server-side (no API keys in app) | Implement Supabase Edge Function `cloud-ai-proxy` that holds `GEMINI_API_KEY` in Supabase secrets; mobile app calls proxy URL only. |
| AI-04 | User can disable cloud identification; when disabled, app does not upload images | Persist setting in `AppSettings` via `AppSettingsDao`; ensure Identify UI disables and AI service refuses to call proxy when OFF. |
| PRIV-01 | First-use disclosure explains cloud identification + what data uploaded; reversible | Implement first-use disclosure modal + Learn more; store choice; allow later change via Settings toggle. |
| PRIV-02 | Settings toggles exist and default ON | Add Settings section "Privacy & Data" visible to all; add two toggles with defaults; wire both to behavior. |
| PRIV-03 | Only minimum image data sent (crops) and metadata stripped | Client creates crop(s) from the photo and re-encodes (EXIF stripped) before upload; proxy does not log/store bytes; document transient processing. |
</phase_requirements>

## Summary

Phase 2 is mostly wiring and guardrails: (1) implement a server-side Gemini proxy so the Flutter app never ships a cloud API key, (2) define a strict "crops-only" upload contract and enforce it client-side, and (3) add a first-use disclosure plus always-visible privacy toggles that can fully disable identification uploads.

The codebase already has a stable pattern for server proxies (Supabase Edge Functions in `supabase/functions/**` and mobile clients that call a configured URL from `AppConfig`). It also already persists small settings values in Drift via `AppSettingsDao` and exposes streams for reactive UI. Reuse these patterns for cloud identification gating and for the sold-price comps toggle.

**Primary recommendation:** Implement a Supabase Edge Function `cloud-ai-proxy` that accepts base64-encoded crop JPEG(s) + prompt, calls Gemini server-side using an API key stored as a Supabase secret, and returns only model text/JSON. In Flutter, add a cropper that re-encodes the crop(s) (stripping metadata) and hard-blocks any attempt to upload the full photo.

## Standard Stack

### Core
| Library / System | Version | Purpose | Why Standard |
|------------------|---------|---------|-------------|
| Supabase Edge Functions (Deno) | repo existing | Server-side proxy holding secrets | Already used for Tradera; fits AI-03 (no keys in app). |
| `package:http` (Flutter) | `^1.6.0` (pubspec) | Call proxy endpoint | Already in app; simple, predictable. |
| `package:image` (Flutter) | `^4.7.2` (pubspec) | Decode/crop/re-encode images | Lets us enforce crops-only + EXIF stripping by re-encoding. |
| Drift `AppSettings` | repo existing | Persist privacy toggles + consent | Already used for consent/dev-mode/sync interval. |

### Supporting
| Library / System | Purpose | When to Use |
|------------------|---------|-------------|
| `connectivity_plus` | Online/offline gating | Fail-fast offline behavior and UI messaging. |
| Sentry breadcrumbs | Privacy-safe debugging | Log only high-level events (no image bytes). |

## Architecture Patterns

### Recommended Project Structure (existing)
- Client features: `lib/features/**` (screens, dialogs)
- Services: `lib/services/**` (AI, market, sync)
- Config: `lib/core/config/app_config.dart` (compile-time defines)
- Persisted settings: `lib/core/database/daos/app_settings_dao.dart`
- Server proxies: `supabase/functions/**/index.ts`

### Pattern 1: Proxy-backed integration
**What:** App calls a configured URL; server function holds secrets and talks to upstream.
**Where it exists:** `supabase/functions/tradera-proxy/index.ts`, `lib/services/market/tradera_client.dart`, `lib/core/config/app_config.dart`.
**How to apply:** Add `cloud-ai-proxy` with `GEMINI_API_KEY` secret and add a Flutter client that posts `{ prompt, maxTokens, crops[] }`.

### Pattern 2: Settings as Drift key-value
**What:** Persist small settings as keyed ints/strings with watch streams.
**Where it exists:** `lib/core/database/daos/app_settings_dao.dart` and many call sites.
**How to apply:** Store `cloud_ai_consent_v1` and toggles like `privacy_cloud_send_crops_v1`, `privacy_fetch_sold_price_comps_v1`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Metadata stripping | Ad-hoc EXIF removal | Decode + re-encode crop via `package:image` | Re-encoding guarantees EXIF is dropped and output is bounded. |
| Proxy security | Embedding API keys in Flutter | Supabase secrets + server proxy | Meets AI-03 and reduces abuse blast radius. |

## Common Pitfalls

### Pitfall 1: Uploading the full photo accidentally
**What goes wrong:** A refactor passes the original file/bytes to the proxy.
**How to avoid:** Make the cropper API accept only `File original` and return `Uint8List` crop bytes; never expose a code path that sends original bytes; add asserts and unit tests around crop size and dimensions.

### Pitfall 2: "Default ON" vs "consent required" confusion
**What goes wrong:** Toggle appears ON but consent was "Not now", leading to unexpected behavior.
**How to avoid:** Keep a separate consent state (`unknown/accepted/declined`) and treat "Not now" as "needs re-confirmation"; Identify flow should re-prompt just-in-time until accepted.

### Pitfall 3: Logging sensitive payloads
**What goes wrong:** Proxy logs request bodies (base64 crops) or Flutter logs crop bytes.
**How to avoid:** Ensure proxy never logs request bodies; log only sizes/dimensions and request IDs; add `cache-control: no-store` responses.

### Pitfall 4: Edge function timeouts / large payloads
**What goes wrong:** Large base64 images lead to slow calls or timeouts.
**How to avoid:** Downscale and JPEG compress crops client-side; cap max pixels and bytes; fail with actionable error if crop exceeds budget.

## Code Examples

### Supabase function CORS + JSON pattern (existing)
See: `supabase/functions/tradera-proxy/index.ts`.

### Flutter settings persistence
See: `lib/core/database/daos/app_settings_dao.dart` and usage patterns in `lib/features/settings/settings_screen.dart`.

## Sources

### Primary (HIGH confidence)
- Repo architecture + patterns: `/.planning/codebase/ARCHITECTURE.md`
- Existing proxy style: `supabase/functions/tradera-proxy/index.ts`
- Existing settings persistence: `lib/core/database/daos/app_settings_dao.dart`

### Secondary (MEDIUM confidence)
- Google Gen AI SDK README (for conceptual API + key security warnings): https://raw.githubusercontent.com/googleapis/js-genai/main/README.md

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH (all choices already in repo)
- Architecture: HIGH (reusing established proxy + settings patterns)
- Gemini upstream REST schema: MEDIUM (SDK references are available; executor should validate endpoint/response shape while implementing the edge function)

**Valid until:** 2026-03-22 (re-check Gemini API shapes if implementing after this)
