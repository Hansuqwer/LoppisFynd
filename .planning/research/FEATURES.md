# Feature Research

**Domain:** Secondhand/thrift companion app (photo-first item catalog + AI identification + sold-price comparisons)
**Researched:** 2026-02-21
**Confidence:** MEDIUM (competitor claims sourced; some expectations inferred from common mobile UX + reseller workflows)

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Fast photo capture + import | Core workflow starts with a photo; users expect camera + gallery import | MEDIUM | Multi-photo per item, retake, flash, focus, basic cropping; should work offline. (Already exists: scanner capture + persistence.) |
| Basic item record + editing | Users need a reliable “source of truth” beyond AI output | MEDIUM | Title, category, condition, notes, purchase price, store/location, tags; manual override of AI fields; attach photos; haul grouping. (Already exists: Drift-backed persistence.) |
| Quick search/filter/sort in catalog | Without it, the app becomes unusable after a few hauls | MEDIUM | Text search, tags, category, date, “needs review”, “queued”, “synced”; sort by captured date/value. |
| AI identification from photos (at least one mode) | Visual identification is the hook; users expect a best-effort guess | MEDIUM | Must support manual correction; should return structured fields (category/brand/model/keywords) and a confidence indicator. |
| “Try again” / alternate crops | Photo-based ID is noisy; users expect a retry loop | MEDIUM | Allow re-crop / choose best photo; store attempts; avoid repeated uploads when unchanged. |
| Sold-price comps lookup + basic stats | Pricing decision requires comps; median/range is baseline | MEDIUM | Show sample sold listings, sold date, condition notes, outlier handling (simple); cache results with “last updated”. (Already exists: Tradera sold-price comps via proxy.) |
| Offline-first core usage | Thrifting often has poor connectivity; capture must not break | HIGH | Capture + edit always available offline; network work queues for later (AI/comps/sync); clear “queued vs done” UI. (Already exists: offline-first local persistence.) |
| Simple sync (optional) | Users expect phone migration/backup and multi-device continuity | HIGH | Sign-in optional; best-effort background upload of metadata/photos; graceful offline behavior; last-sync status. (Already exists: optional Supabase auth + metadata/photo sync.) |
| Clear privacy controls | AI + photos implies trust requirements; deletion/export are expected | MEDIUM | Export data, delete local data, delete cloud data/account, clear cached images; explicit consent for cloud processing. (Already exists: export + cloud delete/account delete flows.) |
| Settings toggles for cloud vs offline behavior | Users want control over uploads, costs, and offline behavior | MEDIUM | Toggles like: cloud identification on/off, fetch comps on/off, cloud sync on/off; Wi‑Fi only / metered behavior; background sync interval; “offline model” opt-in download (not required for first run). |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| “Instant start” with no first-run blockers | Eliminates churn; app is usable immediately | MEDIUM | No mandatory multi-GB model download; default path uses cloud; offline fallback is opt-in and lightweight (aligned with active project requirements). |
| Hybrid identification pipeline (cloud-first + offline fallback) | Works across connectivity conditions while keeping good accuracy | HIGH | Cloud AI for rich metadata; offline object detection/classification for “good enough” category + cues; unify into one UX with a provenance field (“cloud/offline/manual”). |
| Evidence-based AI output | Builds trust; reduces “black box” frustration | HIGH | Return evidence: bounding boxes/crops used, top candidates, confidence; persist evidence with the scan item for later review. |
| Smart comps query generation from photos | Faster comps with fewer manual edits | HIGH | Use AI to propose search keywords/category filters; user can adjust; minimize API calls; store the query used so results are explainable and repeatable. |
| Multi-market comps + normalization | Better pricing decisions than single-market comps | HIGH | Aggregate across markets (e.g., Tradera + others), normalize currency and time window, optionally account for shipping/fees; present per-market breakdown. |
| ROI / resale profit calculator | Converts comps into a buy/no-buy decision | MEDIUM | Take purchase price + estimated fees/shipping + sell price band; show low/median/high outcomes; keep it simple (avoid full accounting suite). |
| “Thrift run” batch mode | Reduces friction during sourcing | MEDIUM | Rapid capture flow that queues AI/comps; later “review queue” screen to approve/edit results; supports hundreds of items. |
| Local-only privacy mode with redaction controls | Differentiates on trust for photo-based AI | HIGH | Global “local-only mode” disables cloud AI/comps/sync; optional on-device redaction (blur faces/background text) and “crop before upload” defaults. |
| Selective sync + audit trail | Makes sync feel safe and debuggable | HIGH | Sync metadata only vs metadata+photos; per-haul inclusion; basic audit trail (last uploaded/failed) and retry controls; avoid silent data loss. |
| Listing draft generation (copy-ready) | Helps users monetize finds faster | MEDIUM | Generate title/description/keywords per marketplace tone; do not auto-post; support copy-to-clipboard templates (SellHound positions this as a core benefit). |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Auto-posting / auto-listing to marketplaces | “One tap to sell” sounds magical | Requires marketplace auth, policy compliance, content moderation, and creates high liability for wrong listings | Generate copy-ready drafts + deep links; keep user in control of posting |
| Mandatory sign-in / account gating camera usage | “We want growth + retention” | Kills first-run conversion and breaks offline-first promise | Keep sign-in optional; offer backups/sync as the reason to sign in |
| Always uploading full-resolution photos by default | Better AI accuracy | Increases privacy risk, bandwidth cost, and user distrust | Upload smallest necessary crop/derivative; provide explicit opt-in and a per-item override |
| “Guaranteed profit” recommendations | Users want certainty | Creates trust/legal risk and drives bad decisions on noisy data | Provide ranges + confidence + comps transparency; label as estimates |
| “Everything is a marketplace integration” (scraping) | More comps sources | Scraping breaks, violates ToS, and becomes an endless maintenance burden | Use official APIs/proxies where permitted; start with 1-2 reliable markets and expand deliberately |

## Feature Dependencies

```
[Fast photo capture + import]
    └──requires──> [Basic item record + editing]
                        └──requires──> [Quick search/filter/sort in catalog]

[AI identification from photos]
    └──enhances──> [Basic item record + editing]
    └──enhances──> [Sold-price comps lookup + basic stats]  (better queries)

[Offline-first core usage]
    └──requires──> [Network queue + retry UX for AI/comps/sync]

[Simple sync (optional)]
    └──requires──> [Auth]
    └──requires──> [Conflict strategy + status reporting]

[Local-only privacy mode]
    └──conflicts──> [Cloud identification ON]
    └──conflicts──> [Cloud sync ON]
```

### Dependency Notes

- **Fast photo capture + import requires Basic item record + editing:** capture without durable local persistence creates lost work and no offline value.
- **AI identification enhances Sold-price comps lookup + basic stats:** the quality of comps depends heavily on the query; AI should output keywords/category/brand candidates, but must remain editable.
- **Offline-first core usage requires a network queue + retry UX:** “offline-first” is mostly a queueing + transparency problem; without it, users perceive the app as flaky.
- **Simple sync requires an explicit conflict/status strategy:** silent merges or invisible failures break trust; even minimal sync needs “last sync”, “failed items”, and retry.
- **Local-only privacy mode conflicts with cloud features:** implement as a single gate that disables uploads and clears pending network queues (with user confirmation).

## MVP Definition

### Launch With (v1)

- [ ] Photo capture/import + local cataloging (offline-first) — the app must be usable during a thrift trip.
- [ ] Cloud-first AI identification with manual edit loop — remove first-run blockers while keeping users in control.
- [ ] Sold-price comps (start with Tradera) + caching/last-updated — enables the buy/no-buy decision.
- [ ] Clear settings toggles (cloud ID, comps, sync; Wi‑Fi/metered behavior) — builds trust and prevents surprise uploads.
- [ ] Privacy operations (export + local/cloud delete) — required for cloud AI trust and compliance.

### Add After Validation (v1.x)

- [ ] Batch “thrift run” capture + later review queue — add once the single-item flow is solid.
- [ ] Evidence/provenance for AI results (cloud/offline/manual + confidence) — add once the cloud pipeline stabilizes.
- [ ] ROI calculator (simple) — add when users rely on comps regularly.

### Future Consideration (v2+)

- [ ] Multi-market comps aggregation + normalization — valuable but high scope and ongoing maintenance.
- [ ] Offline fallback model (lightweight, opt-in) — ship once licensing/accuracy is validated and model size stays small.
- [ ] Listing draft generation per marketplace — add if the reseller segment is a primary target.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Photo capture/import + local catalog | HIGH | MEDIUM | P1 |
| Cloud-first AI identification + edit loop | HIGH | MEDIUM | P1 |
| Sold-price comps (Tradera) + caching | HIGH | MEDIUM | P1 |
| Settings toggles for cloud/offline behavior | HIGH | MEDIUM | P1 |
| Offline queue + retry transparency for AI/comps | HIGH | HIGH | P1 |
| Optional cloud sync + status | MEDIUM | HIGH | P2 |
| Batch capture + review queue | MEDIUM | MEDIUM | P2 |
| Evidence-based AI output | MEDIUM | HIGH | P3 |
| Multi-market comps normalization | MEDIUM | HIGH | P3 |

## Competitor Feature Analysis

| Feature | Competitor A | Competitor B | Our Approach |
|---------|--------------|--------------|--------------|
| Image-based identification/search | Google Search w/ Lens supports “Search with an image” workflows (upload/drag/drop, sidebar search in Chrome) | SellHound markets photo-based identification for listing generation | Photo-first capture persists locally; cloud-first identification by default with clear opt-outs and per-item editability |
| Barcode scanning + profit calculation | Profit Bandit emphasizes instant barcode scanning, real-time Amazon data, and profit calculations/fee breakdown | InventoryLab/Scoutify positioning emphasizes “scanning to shipping” for Amazon workflows | Not Amazon-first; focus on secondhand photo capture + comps; ROI calculator can mirror the “profit breakdown” mental model without becoming an accounting tool |
| Listing drafts | SellHound markets multi-platform listing text generation (eBay/Poshmark/Mercari/Facebook Marketplace) | (N/A in sources) | Generate copy-ready drafts and templates; avoid auto-posting/integration-heavy flows until validated |

## Sources

- Google Search Help: “Search with an image on Google” (Lens) https://support.google.com/websearch/answer/1325808 (HIGH)
- SellerEngine: “Profit Bandit” product page (barcode scanning, real-time Amazon data, profit calculations, export) https://sellerengine.com/profit-bandit/ (MEDIUM; vendor marketing but specific claims)
- SellHound homepage (photo → AI analysis → listing drafts; multi-platform support; smart pricing from comps) https://sellhound.com/ (MEDIUM; vendor marketing)
- Threecolts/InventoryLab site (scanning-to-workflow positioning; Scoutify/InventoryLab bundle references) https://www.inventorylab.com/ (LOW; page content is bundle marketing and not a clean feature spec)

---
*Feature research for: secondhand/thrift companion app*
*Researched: 2026-02-21*
