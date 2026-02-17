# Loppisfynd — Implementation Roadmap (OpenCode / Oh My OpenCode Handoff)

_Date: 2026-02-14_

This document turns the brainstorm/manifest into an implementation-ready roadmap. It is written so you can:
1) commit it to your repo under `docs/`, and
2) point OpenCode (+ oh-my-opencode) at it to generate code in small, safe increments.

---

## 1) One‑page summary

### Product
**Loppisfynd** is a “Reseller OS” for Swedish second‑hand hunting: scan an item in-store, identify it locally, then fetch sold‑price history (Tradera) to decide if it’s worth buying.

### MVP “Definition of Done”
- User can authenticate and has an account.
- User can scan items offline and they are saved locally.
- When online, the app syncs pending scans, fetches sold prices, and updates items.
- Item detail shows a price history chart + profit calculation.
- Hauls exist (group scans into a trip) and summary shows totals + sustainability metrics.

### Technical pillars
- Flutter app (Material 3) with “Nature Distilled” design tokens.
- On‑device multimodal model (Gemma‑3 Vision) for identification/keyword extraction.
- Local-first DB (Drift/SQLite) + background sync.
- Supabase backend (Postgres + Edge Functions) for auth/sync + Tradera SOAP proxy.

---

## 2) Repo structure (feature-first)

```
lib/
  core/
    tokens/        # AppTokens: colors/spacing/radius/typography
    theme/         # ThemeData + reusable styles
    navigation/    # Router, routes, nav shell
    database/      # Drift DB + DAOs
  features/
    auth/
    dashboard/
    scanner/
    analyzer/
    summary/
    history/
    settings/
  services/
    ai/            # Gemma bootstrap + inference isolate
    market/        # MarketBridge + Supabase/Tradera clients
    sync/          # Background sync orchestration
  shared/
    models/        # DTOs (ScanItem, Haul, MarketData…)
    widgets/       # BentoCard, GlassButton, etc.
```

---

## 3) Design system (Nature Distilled)

### Tokens (starter)
- Background: **Cloud Dancer** `#F0EEE9`
- Surface: **Clay** `#E8E4DE`
- Text/Contrast: **Deep Sapphire** `#1E2B3C`
- Success/Eco: **Eucalyptus** `#8AA399`
- Primary action: **Dopamine Red** `#FF3131`
- Rare highlight: **Neon Pink** `#FF1493`

### Components
- **BentoCard**: 24px radius, subtle shadow, clay surface.
- **GlassOverlay**: 15px blur, ~10% white overlay, 24px radius.
- **Primary CTA**: Dopamine Red, large touch target, spring motion.

Typography recommendation:
- Outfit for UI text, Space Grotesk for numbers/metrics.
- Handwritten accent (optional): Homemade Apple (headers/taglines only).

---

## 4) Screen map (MVP)

1) Auth: Login (logo/brand hero)  
2) Dashboard: “Hunter Dashboard” (Market Pulse, Quick Scan, Recent Hauls)  
3) Scanner: Rapid-Fire Camera + Batch Tray  
4) Analyzer: Item Detail (Price Oscillator chart + Profit + Flip Factor)  
5) Summary: Haul Summary & Analytics  
6) History: Treasure Map + Haul list  
7) Settings: AI mode, sync intervals, quota, Tradera link

---

## 5) Data model (Drift + Supabase)

### Core entities
**Haul**
- id (uuid)
- title
- started_at, ended_at
- lat, lng (optional)
- totals cached (optional): total_invested, gross_value, net_profit, co2_saved_kg

**ScanItem**
- id (uuid)
- haul_id (fk)
- image_path, thumb_path
- ai_json (raw)
- query (string, optimized for Tradera)
- desc (short user-facing)
- confidence (double)
- purchase_price (double, nullable until user enters)
- market: median_price, min_price, max_price, demand_score, days_to_sell_est (nullable)
- status: pending_identify | pending_sync | syncing | complete | failed
- updated_at

### Sync notes
- Local DB is source of truth.
- Supabase table mirrors scans with `sync_status` + `updated_at` for last-write-wins.

---

## 6) Roadmap & milestones

### Phase 0 — Foundations (Day 1–3)
**Goal:** compile/run on iOS+Android, tokens, navigation shell, local DB scaffold.
Deliverables:
- pubspec + assets wired
- AppTokens + ThemeData
- Drift database v1 with Haul + ScanItem
- basic navigation between placeholder screens

### Phase 1 — Offline capture + persistence (Day 4–5)
**Goal:** user can create a haul, capture photos, and see them in a local list.
Deliverables:
- Camera screen: capture -> store file -> create thumbnail -> insert ScanItem
- Haul creation flow (“Start haul”)
- Local list view of scans w/ statuses

### Phase 2 — On-device AI (Day 6–8)
**Goal:** images are processed locally into structured JSON + search queries.
Deliverables:
- Gemma model installation/download on first run
- Worker isolate inference service
- Prompt templates:
  - Single item: brand/model/material/era JSON
  - Batch shelf: list of {query, desc}
- Confidence gate + error handling

### Phase 3 — Market bridge + Tradera proxy (Day 8–10)
**Goal:** given a search query, fetch sold history and compute median/trends.
Deliverables:
- Supabase Edge Function `tradera-proxy` (JSON in, SOAP out, JSON back)
- Flutter `TraderaClient` + `MarketBridge`
- Rate limiting + quota accounting
- Update ScanItem market fields

### Phase 4 — Analyzer UI (Day 10–12)
**Goal:** item detail is useful at a flea market checkout.
Deliverables:
- Price Oscillator chart (fl_chart)
- Profit calculator (fee rules)
- Flip Factor grading
- Condition adjustment (value multiplier)

### Phase 5 — Batch workflow + background sync (Day 12–14)
**Goal:** scan 10 items quickly, sync later, notify when done.
Deliverables:
- Batch tray UI with per-item processing/sync state
- “Done scanning” -> mark ready_to_sync
- Background sync (WorkManager / platform equivalents)
- Local notification when sync completes
- Haul summary totals

### Phase 6 — History + map + settings (Post-MVP)
Deliverables:
- Reverse geocoded haul naming
- Map pins by profit, filters
- Settings: AI mode (accuracy/performance), sync interval, quota UI
- One-tap Tradera draft listing (if API supports)

---

## 7) OpenCode ticket list (copy into issues)

### EPIC A — App shell & design system
- FL-001: Create AppTokens + ThemeData + reusable widgets (BentoCard, GlassButton)
- FL-002: Navigation shell (bottom tabs: Dashboard, Scanner, History, Settings)

### EPIC B — Local-first database
- FL-010: Drift schema v1 (Hauls, ScanItems) + DAOs
- FL-011: Image storage + thumbnail generation helper
- FL-012: Migration strategy scaffolding

### EPIC C — Scanner & batch tray
- FL-020: Camera capture flow
- FL-021: Batch tray widget + scan state machine
- FL-022: Queue processing + concurrency guardrails

### EPIC D — On-device AI
- FL-030: Gemma install/download + model manager
- FL-031: Inference isolate service + prompt templates
- FL-032: Parse/validate JSON output + confidence gating

### EPIC E — Market data & sync
- FL-040: Supabase Edge Function `tradera-proxy`
- FL-041: Flutter TraderaClient + MarketBridge
- FL-042: Background sync scheduler + retry/backoff + quota accounting

### EPIC F — Analyzer + summaries
- FL-050: Item detail UI (chart + profit + flip factor)
- FL-051: Haul summary UI (totals, categories, sustainability)
- FL-052: History list + map pins (post-MVP)

---

## 7.1) Epic log (v1.0 backlog; from `roadmap_refactored*.md`)

This is a more “release-ready” epic backlog (beyond the minimal OpenCode ticket list). Use it to plan post-MVP hardening and Google Play readiness without bloating individual FL tickets.

### EPIC 0 — Project, tooling & environments
**Goal:** ship safely across dev/staging/prod with repeatable builds.
**Done when:** one-command CI produces a signed (internal) AAB for staging and runs tests.

### EPIC 1 — Design system (tokens, typography, components)
**Goal:** lock visual language early to avoid UI churn.
**Done when:** screens can be built only using tokens/components (no raw hex, no ad-hoc text styles).

### EPIC 2 — App shell & navigation
**Goal:** stable structure for feature teams/modules.
**Done when:** every tab loads, supports auth gating, and global error/offline UX is in place.

### EPIC 3 — Authentication & user account
**Goal:** secure account creation and session persistence.
**Done when:** user can sign in/out and local data is tied to user id.

### EPIC 4 — Local DB foundation (Drift) + migrations
**Goal:** offline-first source of truth with safe schema evolution.
**Done when:** create/read/update hauls/items works offline; migrations covered by tests.

### EPIC 5 — Scanner (camera + batch tray + capture pipeline)
**Goal:** fast capture workflow that feels premium on low-end devices.
**Done when:** user can capture multiple items quickly and see them queued with clear states.

### EPIC 6 — On-device AI (Gemma Vision) keyword extraction
**Goal:** offline keyword extraction with controlled output.
**Done when:** scan produces stable keywords offline for most test items, with manual fallback.

### EPIC 7 — Price intelligence (Tradera proxy + sold comps)
**Goal:** reliable sold comps with rate-limit safety.
**Done when:** an item gets comps quickly on decent network and does not spam the API.

### EPIC 8 — Deal analyzer (profit, fees, Flip Factor)
**Goal:** clear “buy/don’t buy” decision support.
**Done when:** analyzer explains the decision with numbers; usable one-handed.

### EPIC 9 — Hauls, summaries & inventory workflow
**Goal:** complete “day of thrifting” workflow end-to-end.
**Done when:** user can manage a haul from scan -> saved items -> summary -> drafts.

### EPIC 10 — History map + location features (optional permission)
**Goal:** delightful retrospective + retrieval of past finds.
**Done when:** history works even without location permission (degrades gracefully).

### EPIC 11 — Sync engine (Supabase) + conflict handling
**Goal:** trustworthy sync that recovers automatically after offline.
**Done when:** airplane mode on/off never loses data; sync recovers; conflict rule documented.

### EPIC 12 — Settings, privacy controls & trust
**Goal:** meet Play/GDPR expectations and build user trust.
**Done when:** user can export and delete their data without contacting support.

### EPIC 13 — Analytics & observability (privacy-respecting)
**Goal:** measure funnel and catch issues early.
**Done when:** you can answer “why are users dropping off?” with data.

### EPIC 14 — Performance, battery, and size budgets
**Goal:** make v1.0 feel instant and not kill phones.
**Done when:** no jank in scanner; battery impact acceptable in a 30-min session.

### EPIC 15 — Testing & QA hardening
**Goal:** production stability.
**Done when:** regressions are caught pre-release; crash/ANR thresholds are safe.

### EPIC 16 — Play Store readiness & launch ops
**Goal:** pass review and execute a staged rollout.
**Done when:** rollout can be started with confidence and rolled back safely.

### EPIC 17 — Monetization (optional)
**Goal:** sustainable without wrecking UX.
**Done when:** payments are compliant, reversible, and do not block the free core loop.

---

## 8) Testing & quality gates
- Unit tests:
  - profit calculation (fee min/max)
  - market stats (median, trend)
  - JSON parsing/validation
- Integration tests:
  - DB insert/update flows
  - edge function response parsing
- Performance checks:
  - camera fps while queue is active
  - memory usage of thumbnails list

---

## 9) Security & privacy
- Store Tradera secrets only in Supabase (Vault), not in app.
- Enable Supabase RLS; user_id scoping on all tables.
- Location data stays local unless explicit consent.

---

## 10) “AGENTS.md” instructions for OpenCode (paste into repo root)
See the companion file `AGENTS.md`.


---

## 11) Recommended OpenCode + oh-my-opencode workflow

This section is optional but makes the handoff smoother.

### Why
- OpenCode is an open source AI coding agent for terminal/desktop/IDE workflows.  
- oh-my-opencode is a plugin/harness that adds multi-agent orchestration + specialized agents (e.g., Sisyphus orchestrator, Oracle, Librarian, Frontend Engineer).  

### Safe operating mode
- Use official provider API keys and comply with your model/provider ToS.
- Keep secrets out of git. Put backend secrets in Supabase Vault; local dev reads from `.env`.

### Practical runbook (per ticket)
1) Start a session in repo root.
2) Ensure `AGENTS.md` + `docs/FyndLoppis_OpenCode_Roadmap.md` are present.
3) Ask the planning agent (or Sisyphus) to:
   - restate acceptance criteria,
   - list files to change,
   - identify risks and tests.
4) Ask the implementation agent to make changes.
5) Ask a review agent (Oracle) to sanity-check architecture.
6) Ask a tester agent to add/adjust tests and run them.

### Prompt template (copy/paste)
“Implement ticket FL-0xx from docs/FyndLoppis_OpenCode_Roadmap.md.
Constraints:
- Follow AGENTS.md.
- Do not add extra features.
- Keep changes minimal and well-tested.
Output:
- A file plan first.
- Then code changes.
- Then how to run/test.”
