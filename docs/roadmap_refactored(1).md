# FYNDLOPPIS — Google Play v1.0 Roadmap (Local‑first Reseller OS)

> Refactored from your original brainstorm into a **release-ready** roadmap (not just MVP).  
> Focus: **scan → price intel → decision support → haul tracking → draft listing** with a premium 2026 UI.

---

## Table of contents
1. Product definition
2. Design system (typography, color, layout, motion)
3. UX flows & screen specs
4. Technical architecture & modules
5. Data model & sync strategy
6. AI pipeline (on-device VLM) + Tradera price intelligence
7. Security, privacy, compliance (GDPR + Play)
8. Quality: testing, performance, observability
9. Monetization & growth
10. Release plan: Alpha → Beta → Production
11. Post‑launch roadmap (v1.1+)

---

## 1) Product definition

### Vision
A **local-first, AI-powered thrift companion** that turns a camera scan into:
- **Accurate search keywords** (offline)  
- **Sold-price reality** (online)  
- **Clear “flip decision” signals** (profit, demand, risk)

### Target users
- Casual “loppis hunters” that want a fast price sanity-check.
- Semi‑pro resellers that need workflow speed + inventory + analytics.

### Core loop (v1.0)
1) Scan item → 2) Extract keywords locally → 3) Fetch sold comps → 4) Show net profit + sellability → 5) Save to haul → 6) Draft listing

### Success metrics (define before release)
- Scan → “useful result” rate
- Average time-to-result (offline keyword + online comps)
- Hauls created per week / user
- Crash-free sessions & ANR rate
- Pro conversion (if monetized)

---

## 2) Design system (complete)

## 2.1 Brand + tone
**“Nature Distilled”**: restorative clarity + earthy trust + dopamine accents for “find” moments.

### 2.2 Color palette (tokens + usage)
**Canvas**
- `bg/primary` Cloud Dancer — `#F0EEE9`
- `surface/card` Clay White — `#E8E4DE`

**Neo-neutrals**
- `success/secondary` Eucalyptus — `#8AA399`
- `accent/earth` Terracotta Clay — `#CB8573`
- `text/primary` Copper Oak — `#935233`

**Digital twilight**
- `ink/deep` Deep Sapphire — `#1E2B3C`
- `gradient/fog` Atmospheric Fog — `#5B6C8F`

**Saturation revival (dopamine accents)**
- `cta/primary` High‑Energy Red — `#FF3131`
- `alert/profit` Neon Pink — `#FF1493`
- `active/voice-gps` Electric Blue — `#00E5FF`

**Effects**
- Glassmorphism card: `#FFFFFF33` (20% white) + blur 15px
- Atmospheric gradients: Cloud Dancer → Eucalyptus / Fog

> Deliverable: `tokens.dart` exporting colors + semantic aliases (do not hardcode hex across widgets).

### 2.3 Typography (type ramp + roles)
**Primary UI font:** Outfit  
**Display/data font:** Space Grotesk  
**Handwritten accent (optional):** “perfectly imperfect” script (headers/taglines only)

#### Type scale (suggested)
- Display XL: 48–56 (Hero profit metric)
- Display L: 36–40 (Screen titles)
- Title: 22–28 (Card headlines)
- Body: 14–16 (Descriptions, hints)
- Label: 12–13 (Chips, metadata)

#### Rules
- Use **Space Grotesk** for numbers, profit, scores, badges.
- Use **Outfit** for readable UI text.
- Reserve handwritten font for 1–2 moments (welcome, “Fynd!”) to avoid gimmick fatigue.

### 2.4 Layout system
**Bento Grid** as the primary home and analytics layout.
- 8pt spacing grid
- Card radius: 24
- Shadows: subtle, warm (avoid pure black)
- Chips for state (Pending, Synced, High margin, Slow flip)

### 2.5 Motion & interaction
**Material 3 Expressive (M3E) spring motion**
- Bento tiles “snap” in on load (staggered entrance)
- Card expansion transitions preserve continuity
- Profit number uses “oscillator” micro-motion when value increases
- Haptics on: scan success, high margin, errors (gentle wobble)

Deliverables:
- Motion tokens (durations, spring configs)
- A single “SpringRoute” page transition used across the app

### 2.6 Accessibility & localization (required for v1.0)
- High contrast mode (toggle)
- Dynamic type scaling
- VoiceOver/TalkBack labels for all controls
- Swedish as default locale (en optional)
- Avoid text-in-images for critical info

---

## 3) UX flows & screen specs (v1.0)

### Global navigation
Bottom nav (5):
1) Home (Dashboard)
2) Scan
3) Haul (current + summaries)
4) History (map + list)
5) Profile/Settings

### Screens (spec-level)

#### 0. Login / Onboarding
- Logo tile + hero image
- Email/social auth
- Permissions education: camera + optional location
- First-run: model download / storage notice (if needed)

#### 1. Home — “Hunter Dashboard” (Bento)
Bento modules:
- Market Pulse (trending categories)
- Quick Scan CTA (High‑Energy Red)
- Recent hauls carousel
- Drafts/pending sync
- Monthly goal + progress
- “Continue researching” (pending comps)

#### 2. Scan — Rapid-Fire Scanner
- Camera viewfinder
- Batch Tray (thumbnails)
- Real-time local tagging (AR overlay)
- Status per item: `keyworded → pending comps → comps fetched → scored`
- Power saver mode (optional): reduces VLM frequency

#### 3. Item Detail — Deal Analyzer
- Price Oscillator (sold comps over time)
- Profit calculator (net profit after fees)
- Flip Factor (A–F)
- Condition toggle (like new/good/defect) impacts estimate
- Save to haul + notes + photos

#### 4. Haul Summary & Analytics
- Hero: total potential net profit (kinetic)
- Item groups: Fast flips vs Long-term
- One-tap “Draft on Tradera”
- Export/share (CSV later)

#### 5. History — Treasure Map
- Map pins color-coded by profit
- Reverse-geocoded haul names (e.g., “Loppis i …”)
- Filters: best margin, most recent, category

#### 6. Profile & Settings
- Lifetime stats, carbon saved (optional gamification)
- Tradera linkage + API quota
- Model settings (battery vs accuracy)
- Privacy & data controls (export/delete)
- Support / feedback

---

## 4) Technical architecture & modules

### 4.1 Stack (v1.0)
- **Flutter** UI + Material 3
- **Drift/SQLite** local DB (offline-first ground truth)
- **Background tasks**: connectivity-triggered sync
- **On-device VLM**: Gemma‑Vision (quantized) via mobile runtime
- **Backend**: Supabase (auth, sync, functions, RLS)
- **Marketplace bridge**: Tradera API via secure proxy (Edge Function)

### 4.2 App modules (suggested)
- `core/` theme, tokens, utils, error handling, routing
- `features/auth/`
- `features/scan/` camera, overlay, batch tray, VLM runner
- `features/items/` item detail, scoring, comps
- `features/hauls/` sessions, summaries, exports
- `features/history/` map + filters
- `features/settings/` privacy, model mgmt, account deletion
- `data/` drift db, repositories, sync engine
- `services/` tradera proxy client, analytics, notifications

### 4.3 CI/CD & environments
- Flavors: `dev`, `staging`, `prod`
- Automated builds (AAB), versioning, release notes generation
- Secrets handling (never ship Tradera keys in the client)

---

## 5) Data model & sync strategy

### 5.1 Entities (minimum viable, v1.0)
- `user` (supabase auth id)
- `haul` (id, createdAt, location, title, totals)
- `item` (id, haulId, photos, keywords, condition, purchasePrice)
- `comps` (itemId, soldListings snapshot, stats: avg, median, range)
- `sync_status` (per item + per haul)

### 5.2 Offline-first rules
- Local DB is the source of truth.
- Every network action is idempotent.
- Sync is **event-driven**: connectivity regained → batch sync.

### 5.3 Conflict strategy
- Last-write-wins for simple fields
- Avoid multi-device edits in v1.0 (document limitation)

---

## 6) AI pipeline + price intelligence

### 6.1 On-device VLM (keyword extraction)
- Input: photo(s)
- Output: 3–5 search keywords + optional maker/pattern
- Enforce structured output (JSON) to reduce hallucinations
- Provide “manual refine” UI (chips editable)

### 6.2 Tradera comps fetching
- Use sold/ended listing queries
- Filter outliers (e.g., 1 SEK broken auctions) before statistics
- Cache results per keyword set (avoid rate limit blows)

### 6.3 Scoring (Deal Score / Flip Factor)
Inputs:
- purchase price
- median sold price
- volume/sellability proxy (sales frequency)
- condition multiplier
Outputs:
- net profit estimate
- flip factor A–F
- confidence indicator

---

## 7) Security, privacy & compliance

### 7.1 Security
- Supabase RLS for all user-owned rows
- Minimal data collection
- Protect any marketplace credentials
- Encrypt sensitive local fields if needed (tokens)

### 7.2 Privacy (GDPR + Play)
Required deliverables:
- Privacy policy (in-app + store listing)
- Data Safety form completion
- Account deletion + data deletion (in-app flow + web link if required)
- Data export (optional but strong trust signal)

### 7.3 Permissions philosophy
- Camera: required
- Location: optional (“enhances haul naming + history map”)
- Photos/storage: explain why if used

---

## 8) Quality: testing, performance, observability

### 8.1 Testing pyramid
- Unit tests: scoring, parsing, outlier filtering
- Integration: DB migrations, sync, auth flows
- Golden tests: critical UI (dashboard cards, analyzer)
- Device matrix: low-end Android, mid-range, flagship

### 8.2 Performance / battery
- VLM warm-up (camera screen entry)
- Throttle inference for continuous scanning
- App size management for model assets (PAD if needed)
- Cold start targets, memory budgets

### 8.3 Observability
- Crash reporting
- Performance traces (scan pipeline, network sync)
- Analytics (privacy-respecting): funnel events + feature usage

---

## 9) Monetization & growth (optional for v1.0, recommended)
- Freemium: limited scans/day
- Pro subscription: unlimited scans + advanced analytics + export
- Affiliate: “Draft on Tradera” convenience flow

---

## 10) Release plan: Alpha → Beta → Production (Google Play)

### Phase A — Foundations (Weeks 1–2)
- App shell, routing, theming, tokens
- Drift schema + migrations
- Supabase project + RLS baseline
- Tradera proxy skeleton (Edge Function)

Exit criteria:
- Can create hauls/items locally, no crashes
- Theme + typography locked

Repo gaps (to reach Phase A exit criteria in this codebase):
- Bottom nav is still 4 tabs (spec requires 5: Home/Scan/Haul/History/Profile).
- No SpringRoute / app-wide spring page transition.
- No high-contrast theme toggle.

### Phase B — Core Loop MVP (Weeks 3–6)
- Scanner screen + batch tray
- Local VLM keyword output + manual edit
- Online comps fetch + outlier filtering
- Item detail + profit calc

Exit criteria:
- End-to-end scan → comps → save to haul

Repo gaps:
- Manual keyword refine UI (editable chips) is missing.
- Comps outlier filtering (IQR/median-based) + TTL caching by keyword set is missing.
- Profit calc is missing explicit fees + shipping assumptions (net profit).

### Phase C — Hauls + History (Weeks 7–9)
- Haul summary screen
- Reverse geocoding (optional)
- History map + filters

Exit criteria:
- “Day of thrifting” workflow complete

Repo gaps:
- Dedicated Haul tab ("current + summaries") is missing.
- History filters are minimal (profit/loss only; missing category/margin/recent).

### Phase D — Polish + Trust (Weeks 10–12)
- Onboarding + permissions education
- Accessibility pass + localization
- Error states + empty states + offline handling
- Analytics + crash reporting

Exit criteria:
- “v1.0 quality bar” met

Repo gaps:
- Onboarding/perms education screen is missing.
- Localization is not wired via ARB/AppLocalizations (strings are hard-coded).
- Accessibility audit items missing (high contrast mode; broader Semantics coverage).
- Offline banner + richer empty/error states are incomplete.
- No crash reporting / analytics instrumentation.

### Phase E — Play Store readiness (Weeks 13–14)
- AAB build + signing
- Target API compliance
- Data Safety + privacy policy
- Account deletion & support links
- Store listing assets + ASO keywords
- Closed testing → open testing → production

Exit criteria:
- Ready for production rollout

Repo gaps:
- Privacy policy URL + in-app privacy screen is missing.
- Account deletion + data deletion flows are missing.
- Data export flow is missing.
- Release pipeline (AAB signing/CI/flavors) is missing.

---

## 11) Google Play launch checklist (hard requirements)

- [ ] Target API level policy compliance (update `targetSdkVersion` as required)
- [ ] Publish with Android App Bundle (AAB)
- [ ] Play App Signing enabled
- [ ] Data Safety form completed + matches real behavior
- [ ] Privacy policy URL in listing + in-app
- [ ] Account deletion flow documented + accessible
- [ ] Content rating questionnaire
- [ ] Store listing: screenshots, feature graphic, short/long description
- [ ] Closed testing with enough testers + feedback loop
- [ ] Android Vitals: crash/ANR thresholds acceptable

---

## 12) Post-launch roadmap (v1.1+)
- Improved demand model (category-specific)
- Watchlist alerts (price drops / trending)
- Listing automation improvements
- Multi-device sync & collaboration
- Optional “community comps” (crowd signals) if privacy-safe

---

## 13) Epic backlog (v1.0 implementation)

> Use this as your implementation backlog for Linear/GitHub Projects: **Epics → Stories → Tasks**.  
> Each epic includes “Done when” to keep scope crisp for Google Play production.

### EPIC 0 — Project, tooling & environments
**Goal:** ship safely across dev/staging/prod with repeatable builds.
- [ ] Create flavors: `dev`, `staging`, `prod`
- [ ] Configure env/secrets (no secrets in client; use runtime config)
- [ ] CI: lint + format + unit tests + build AAB
- [ ] Release versioning strategy (SemVer + build numbers)
- [ ] Logging + crash reporting SDK integrated (staging + prod)
**Done when:** one-command CI produces signed (internal) AAB for staging + runs tests.

### EPIC 1 — Design system (tokens, typography, components)
**Goal:** lock visual language early to avoid UI churn.
- [ ] Implement `tokens.dart` (semantic colors + spacing + radii + elevation)
- [ ] Typography ramp: Outfit + Space Grotesk, with text styles + number styles
- [ ] Core components: BentoCard, Chips, PrimaryCTA, MetricTile, EmptyState, ErrorBanner
- [ ] Motion tokens + default page transition (spring route)
- [ ] Light/dark/high-contrast modes (at least light + high-contrast for v1.0)
**Done when:** screens can be built only using tokens/components (no raw hex, no ad-hoc text styles).

### EPIC 2 — App shell & navigation
**Goal:** stable structure for feature teams/modules.
- [ ] Router + deep links skeleton
- [ ] Bottom nav (Home, Scan, Haul, History, Profile)
- [ ] Global state scaffolding (auth state, sync state, feature flags)
- [ ] App-wide error boundary + offline banner
**Done when:** every tab loads with placeholder content, no crashes, supports auth gating.

### EPIC 3 — Authentication & user account
**Goal:** secure account creation and session persistence.
- [ ] Supabase auth: email (and optional providers later)
- [ ] Session persistence + logout
- [ ] Basic profile model (display name, locale, preferences)
- [ ] Account deletion entry point (stub UI now, full in EPIC 10)
**Done when:** user can sign in/out, and local data is tied to user id.

### EPIC 4 — Local DB foundation (Drift) + migrations
**Goal:** local-first “source of truth” with safe schema evolution.
- [ ] Drift schema for `haul`, `item`, `photos`, `comps`, `sync_status`
- [ ] Migration strategy (versioned, tested)
- [ ] Repository layer + DTOs
- [ ] Seed + dev fixtures
**Done when:** you can create/read/update hauls/items offline; migrations covered by tests.

### EPIC 5 — Scanner (camera + batch tray + capture pipeline)
**Goal:** fast capture workflow that feels premium on low-end devices.
- [ ] Camera integration + permissions UX
- [ ] Batch tray (multi-capture session)
- [ ] Photo storage strategy (compressed + cache directory + cleanup)
- [ ] Capture states: captured → keywording → comps pending → scored
- [ ] Haptics + feedback (success/error)
**Done when:** user can capture multiple items quickly and see them queued.

### EPIC 6 — On-device AI (Gemma Vision) keyword extraction
**Goal:** offline keyword extraction with controlled output.
- [ ] Model packaging strategy (download-on-demand vs bundled; size budget)
- [ ] Inference runner (throttled, cancellable, background-safe)
- [ ] Structured JSON output contract + validator
- [ ] Manual refine UI (editable keyword chips + brand/model override)
- [ ] Accuracy modes (battery vs quality)
**Done when:** scan produces stable keywords offline for 80%+ of test items, with manual fallback.

### EPIC 7 — Price intelligence (Tradera proxy + sold comps)
**Goal:** reliable sold comps with rate-limit safety.
- [ ] Supabase Edge Function proxy (SOAP → JSON)
- [ ] Client service + retries/backoff + timeouts
- [ ] Query builder from keywords + category hints
- [ ] Outlier filtering + stats (median, IQR, range)
- [ ] Local caching keyed by keyword set (TTL)
**Done when:** an item gets comps in <10s on decent network and doesn’t spam the API.

### EPIC 8 — Deal Analyzer (profit, fees, Flip Factor)
**Goal:** clear “buy/don’t buy” decision support.
- [ ] Profit calculator (fees + shipping assumptions + purchase price)
- [ ] Price Oscillator chart (sold comps over time)
- [ ] Condition multiplier UI + notes
- [ ] Flip Factor scoring (A–F) + confidence indicator
- [ ] Save to haul + quick edit
**Done when:** analyzer explains the decision with numbers, not vibes; usable with one hand.

### EPIC 9 — Hauls, summaries & inventory workflow
**Goal:** complete “day of thrifting” workflow end-to-end.
- [ ] Create/edit haul (title, date, optional location)
- [ ] Haul Summary hero metrics + grouping (fast vs long-term)
- [ ] Inventory list views + filters (margin, category, status)
- [ ] Draft listing workflow (store draft fields + photos; Tradera posting later if allowed)
**Done when:** user can manage a haul from scan → saved items → summary → drafts.

### EPIC 10 — History map + location features (optional permission)
**Goal:** delightful retrospective + retrieval of past finds.
- [ ] Optional location permission + clear value explanation
- [ ] Reverse geocoding for haul naming (cached)
- [ ] Map pins + list toggle
- [ ] Filters and search
**Done when:** history works even without location permission (degrades gracefully).

### EPIC 11 — Sync engine (Supabase) + conflict handling
**Goal:** trustworthy multi-session sync (even if single-device in v1.0).
- [ ] Sync queue + idempotent upserts
- [ ] Sync status per entity + UI indicators
- [ ] Background sync trigger on connectivity regain
- [ ] LWW conflict rule documented + surfaced to user when detected
- [ ] Offline-first guarantees (no data loss on crashes)
**Done when:** turning airplane mode on/off never loses data; sync recovers automatically.

### EPIC 12 — Settings, privacy controls & trust
**Goal:** meet Play/GDPR expectations and build user trust.
- [ ] Privacy screen: what’s stored locally vs cloud
- [ ] Export data (JSON/CSV) for hauls/items
- [ ] Delete data (local + server) + account deletion flow
- [ ] Model management: storage size, clear cache, re-download
- [ ] Support + feedback entry points
**Done when:** user can export and delete their data without contacting you.

### EPIC 13 — Analytics & observability (privacy‑respecting)
**Goal:** measure the funnel and catch issues early.
- [ ] Core funnel events (scan started, keyword ready, comps ready, saved, draft created)
- [ ] Performance traces (inference time, comps fetch time, sync duration)
- [ ] Crash-free sessions reporting
- [ ] Feature flags (kill switches for risky features)
**Done when:** you can answer “why are users dropping off?” with data.

### EPIC 14 — Performance, battery, and size budgets
**Goal:** make v1.0 feel instant and not kill phones.
- [ ] Cold start and navigation performance targets
- [ ] Inference throttling + warm-up strategy
- [ ] Image compression + memory limits
- [ ] App size control (Play Asset Delivery if model is large)
- [ ] Low-end device QA pass (Android Go class)
**Done when:** no jank in scanner, and battery impact is acceptable in a 30-min session.

### EPIC 15 — Testing & QA hardening
**Goal:** production stability.
- [ ] Unit tests (scoring, parsing, outlier filters, fee calc)
- [ ] Integration tests (DB migrations, auth, sync)
- [ ] Golden tests for key UI states
- [ ] Manual test matrix (devices + locales + offline)
- [ ] Pre-launch report readiness + vitals targets
**Done when:** regressions are caught before release; crash/ANR thresholds are safe.

### EPIC 16 — Play Store readiness & launch ops
**Goal:** pass review and execute a staged rollout.
- [ ] AAB + Play App Signing configured
- [ ] Target API compliance + policy checks
- [ ] Data Safety form + privacy policy URL in listing + in-app
- [ ] Store listing assets: screenshots, feature graphic, short/long description
- [ ] Closed testing → open testing → production staged rollout
- [ ] Post-release monitoring plan (vitals + support triage)
**Done when:** production rollout can be started with confidence and rolled back safely.

### EPIC 17 — Monetization (if shipping with v1.0)
**Goal:** sustainable without wrecking UX.
- [ ] Paywall rules (limits, trial, restore purchases)
- [ ] Subscription implementation (Play Billing)
- [ ] Pro features gating (analytics, exports, unlimited scans)
- [ ] Pricing experiments (feature flags)
**Done when:** payments are compliant, reversible, and don’t block core loop for free users.

---

## Definition of Done (global)
A story is “done” only when:
- Works offline (if applicable), with error states handled
- Accessibility labels + keyboard focus (where relevant)
- Telemetry hooks added (if user-facing)
- Tests updated/added for critical logic
- No hardcoded tokens (colors/type/spacing)
