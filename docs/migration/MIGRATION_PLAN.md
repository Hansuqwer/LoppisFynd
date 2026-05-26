# Bokfynd Repository Migration Plan

**Date:** 2026-04-29  
**Status:** Planning Phase  
**Goal:** Restructure LoppisFynd repository to focus on Bokfynd (book-focused reseller app)

---

## Executive Summary

This plan outlines the migration from LoppisFynd (generalist reseller app with AI inference) to Bokfynd (specialist book reseller app with ISBN lookup). The migration involves:

1. **Documentation reorganization** - Consolidate Bokfynd planning docs, archive LoppisFynd-specific materials
2. **Repository cleanup** - Remove nested project pollution, organize docs into logical structure
3. **Codebase assessment** - Identify what stays, what goes, what needs refactoring
4. **Validation requirements** - Define critical validations before full migration

**Key Decision:** This plan focuses on **documentation and repository structure** first. Code migration is deferred until after validation sprint confirms Bokfynd viability.

---

## Phase 1: Documentation Audit & Reorganization

### Current State

**Root-level documents (mixed focus):**
- `BOKFYND_VALIDATION_UPDATE.md` - Vinted validation, Apify integration strategy
- `BOKFYND_DEEP_ANALYSIS.md` - Strategic analysis, architecture comparison
- `ARCHITECTURE_REVIEW.md` - LoppisFynd technical debt analysis
- `CLAUDE.md` - Project instructions (LoppisFynd-focused)
- `README.md` - (needs review)

**Docs directory:**
- `docs/bokfynd_scanner_qa_plan.md` - QA checklist for ISBN scanner
- `docs/baseline-analyze.txt` - Analyzer baseline (5416 issues)
- `docs/MIGRATION_PLAN.md` - (if exists, needs review)

**Problems:**
- Bokfynd planning docs scattered at root level
- No clear separation between LoppisFynd legacy and Bokfynd future
- Architecture review mixes concerns (some apply to both, some LoppisFynd-specific)
- Nested project pollution (`roadmapv2/LoppisFynd-main/`)

### Target Structure

```
docs/
├── bokfynd/
│   ├── README.md                          # Bokfynd project overview
│   ├── strategy/
│   │   ├── business-analysis.md           # From BOKFYND_DEEP_ANALYSIS.md
│   │   ├── validation-results.md          # From BOKFYND_VALIDATION_UPDATE.md
│   │   ├── market-data-strategy.md        # Multi-platform integration
│   │   └── unit-economics.md              # Cost analysis, revenue model
│   ├── architecture/
│   │   ├── overview.md                    # High-level architecture
│   │   ├── data-model.md                  # Books table, market data
│   │   ├── services.md                    # ISBN lookup, market aggregation
│   │   └── migration-from-loppisfynd.md   # Code migration plan
│   ├── qa/
│   │   ├── scanner-qa-plan.md             # From bokfynd_scanner_qa_plan.md
│   │   └── validation-checklist.md        # ISBN coverage, real-world testing
│   └── api-integration/
│       ├── google-books.md                # ISBN lookup
│       ├── apify-vinted.md                # Vinted scraping
│       ├── tradera.md                     # Existing proxy
│       └── bokborsen.md                   # Future integration
│
├── loppisfynd-legacy/
│   ├── README.md                          # Legacy project context
│   ├── architecture-review.md             # From ARCHITECTURE_REVIEW.md
│   ├── technical-debt.md                  # Extracted from architecture review
│   └── lessons-learned.md                 # What worked, what didn't
│
├── migration/
│   ├── MIGRATION_PLAN.md                  # This document
│   ├── validation-sprint.md               # Week 1 validation tasks
│   ├── code-migration-phases.md           # Phased code changes
│   └── rollback-plan.md                   # If validation fails
│
├── baseline/
│   ├── baseline-analyze.txt               # Current analyzer state
│   ├── baseline-test.txt                  # Current test state
│   └── README.md                          # Baseline tracking
│
└── development/
    ├── setup.md                           # Dev environment setup
    ├── testing.md                         # Testing guidelines
    └── deployment.md                      # Build and release process
```

### Actions

**1. Create new directory structure**
```bash
mkdir -p docs/bokfynd/{strategy,architecture,qa,api-integration}
mkdir -p docs/loppisfynd-legacy
mkdir -p docs/migration
mkdir -p docs/baseline
mkdir -p docs/development
```

**2. Move and reorganize Bokfynd documents**
- Split `BOKFYND_DEEP_ANALYSIS.md` into:
  - `docs/bokfynd/strategy/business-analysis.md` (Parts 1, 4, 7, 8)
  - `docs/bokfynd/architecture/overview.md` (Parts 2, 3)
  - `docs/bokfynd/architecture/services.md` (Part 6)
- Move `BOKFYND_VALIDATION_UPDATE.md` → `docs/bokfynd/strategy/validation-results.md`
- Move `docs/bokfynd_scanner_qa_plan.md` → `docs/bokfynd/qa/scanner-qa-plan.md`
- Create `docs/bokfynd/README.md` with project overview

**3. Archive LoppisFynd documents**
- Move `ARCHITECTURE_REVIEW.md` → `docs/loppisfynd-legacy/architecture-review.md`
- Extract technical debt items → `docs/loppisfynd-legacy/technical-debt.md`
- Create `docs/loppisfynd-legacy/README.md` explaining legacy context

**4. Create migration documents**
- This document → `docs/migration/MIGRATION_PLAN.md`
- Create `docs/migration/validation-sprint.md` (Week 1 tasks)
- Create `docs/migration/code-migration-phases.md` (deferred until after validation)

**5. Organize baseline tracking**
- Move `docs/baseline-analyze.txt` → `docs/baseline/baseline-analyze.txt`
- Create `docs/baseline/README.md` explaining baseline tracking

**6. Remove unrelated documents**
- Delete or archive any documents not related to Bokfynd migration
- Remove `roadmapv2/` nested project (already excluded in analysis_options.yaml)

---

## Phase 2: Repository Cleanup

### Current Issues

1. **Nested project pollution** - `roadmapv2/LoppisFynd-main/` duplicates entire app
2. **Root-level clutter** - Too many markdown files at root
3. **Unclear project identity** - Is this LoppisFynd or Bokfynd?

### Actions

**1. Remove nested project**
```bash
# Option A: Delete entirely (if no longer needed)
rm -rf roadmapv2/

# Option B: Move outside workspace (if needed for reference)
mv roadmapv2/ ../loppisfynd-archive/
```

**2. Clean up root directory**
- Keep: `README.md`, `CLAUDE.md`, `pubspec.yaml`, `analysis_options.yaml`
- Move to docs: All other `.md` files (already done in Phase 1)
- Result: Clean root with only essential files

**3. Update README.md**
- Change project name from LoppisFynd to Bokfynd
- Update description to focus on book reselling
- Add link to `docs/bokfynd/README.md` for detailed documentation
- Add migration status badge

**4. Update CLAUDE.md**
- Update project overview to reflect Bokfynd focus
- Update architecture section (remove AI inference, add ISBN lookup)
- Update key services (remove AI, add ISBN/market data)
- Keep migration context in "Known landmines" section

---

## Phase 3: Codebase Assessment

### What Stays (Core Infrastructure)

**Keep as-is:**
- `lib/core/` - Database, storage, config, theme, navigation (all reusable)
- `lib/shared/` - Reusable widgets and painters
- `lib/gen/` - Generated localization
- `lib/l10n/` - ARB files (update strings for Bokfynd)
- `lib/services/sync/` - Cloud sync (reusable)
- `lib/services/privacy/` - Data export/deletion (reusable)
- `lib/services/analytics/` - Sentry integration (reusable)

**Refactor for Bokfynd:**
- `lib/services/market/` - Keep structure, update for multi-platform (Tradera + Vinted + Bokbörsen)
- `lib/features/settings/` - Keep, update for Bokfynd-specific settings
- `lib/features/auth/` - Keep (cloud sync still optional)

### What Goes (LoppisFynd-Specific)

**Remove entirely:**
- `lib/services/ai/` - AI inference, model management, isolates
- `lib/services/offline_detection/` - On-device object detection
- `lib/features/analyzer/` - AI-powered analysis UI
- `lib/features/summary/` - AI summary generation
- Image storage for scan photos (Bokfynd doesn't need photos)

**Archive for reference:**
- Move to `lib/_archive/` before deletion
- Keep for 1-2 sprints in case patterns are useful

### What Changes (Bokfynd-Specific)

**New services:**
- `lib/services/isbn/` - ISBN lookup (Google Books, Open Library)
- `lib/services/books/` - Book metadata management
- Update `lib/services/market/` - Multi-platform aggregation (Tradera, Vinted, Bokbörsen)

**New features:**
- `lib/features/scanner/` - Update for ISBN barcode scanning (already partially done per QA plan)
- `lib/features/books/` - Book inventory management (replaces generic scan items)
- `lib/features/profit/` - Profit calculator UI

**Database changes:**
- Remove: `scan_items`, `ai_inference_results`, `scan_images`
- Add: `books`, `book_market_data`, `book_sales`
- Keep: `hauls`, `drafts` (adapt for books)

---

## Phase 4: Validation Requirements

### Critical Validations (Must Pass Before Code Migration)

**1. ISBN Coverage Validation** (Priority 1)
- **Goal:** Confirm ≥50% of books have market data available
- **Method:** Test 100 random ISBNs (mix popular + obscure Swedish books)
- **Success Criteria:**
  - ≥50% have at least 1 sale in last 12 months
  - ≥30% have ≥5 sales (enough for meaningful stats)
- **Effort:** 1-2 days
- **Blocker:** If <30% coverage, pivot or kill project

**2. Real-World UX Testing** (Priority 2)
- **Goal:** Validate barcode scanning in flea market conditions
- **Method:** Visit 2-3 flea markets, scan 20-30 books
- **Success Criteria:**
  - Barcode scan success rate ≥80%
  - ISBN lookup success rate ≥90%
  - Time from scan to decision ≤10 seconds
- **Effort:** 1 day + travel
- **Blocker:** If scan success <60%, need better scanner or manual entry focus

**3. Apify Integration Test** (Priority 3)
- **Goal:** Confirm Vinted scraping works reliably
- **Method:** Test 20 ISBNs via Apify, measure success rate and latency
- **Success Criteria:**
  - Success rate ≥90%
  - Average latency <5 seconds
  - Cost within budget ($49/month for 100k results)
- **Effort:** 1 day
- **Blocker:** If unreliable, fall back to Tradera-only

**4. User Interviews** (Priority 4)
- **Goal:** Validate value proposition with target users
- **Method:** Interview 5-10 book resellers about workflow and pain points
- **Success Criteria:**
  - ≥70% would use the app
  - ≥50% would pay 50-100 kr/month
- **Effort:** 2-3 days
- **Blocker:** If no interest, reconsider market fit

### Validation Sprint Timeline

**Week 1: Validation Sprint**
- Day 1: ISBN coverage validation (script + analysis)
- Day 2-3: Real-world UX testing (flea market visits)
- Day 4: Apify integration test
- Day 5: User interviews + decision point

**Decision Point (End of Week 1):**
- ✅ **GO:** If 3/4 validations pass → Proceed to code migration
- ⚠️ **PIVOT:** If 2/4 pass → Adjust strategy, re-validate
- ❌ **NO-GO:** If <2 pass → Kill project or major pivot

---

## Phase 5: Code Migration (Deferred)

**Note:** This phase is deferred until after validation sprint confirms Bokfynd viability.

### Phased Approach (If Validation Passes)

**Phase 5.1: Core Refactoring (2-3 weeks)**
- Remove AI services and features
- Add ISBN lookup service
- Update data model (Books table)
- Migrate existing scan items to books (where applicable)

**Phase 5.2: Market Data Integration (2-3 weeks)**
- Integrate Apify for Vinted
- Update Tradera integration
- Add Bokbörsen scraping (if validated)
- Implement market data aggregation

**Phase 5.3: UI Updates (2-3 weeks)**
- Update scanner for ISBN focus
- Build book inventory UI
- Add profit calculator
- Update settings for Bokfynd

**Phase 5.4: Testing & Polish (2-3 weeks)**
- Beta testing with real users
- Bug fixes and performance optimization
- Documentation updates
- App store preparation

**Total Estimated Timeline:** 8-12 weeks (after validation)

---

## Phase 6: Rollback Plan

### If Validation Fails

**Scenario 1: ISBN Coverage <30%**
- **Action:** Pivot to manual entry focus, community pricing data
- **Effort:** 2-3 weeks to build alternative UX
- **Decision:** Re-validate with new approach

**Scenario 2: Real-World UX Fails**
- **Action:** Focus on manual ISBN entry, improve scanner reliability
- **Effort:** 1-2 weeks
- **Decision:** Re-test in controlled environment

**Scenario 3: No User Interest**
- **Action:** Kill Bokfynd project, keep LoppisFynd as-is
- **Effort:** 0 (no code changes made yet)
- **Decision:** Archive Bokfynd docs, continue LoppisFynd development

**Scenario 4: Multiple Validations Fail**
- **Action:** Kill project entirely
- **Effort:** 1 day to clean up docs
- **Decision:** Archive all Bokfynd work, focus on other projects

---

## Success Metrics

### Documentation Phase (This Plan)
- [ ] All Bokfynd docs organized in `docs/bokfynd/`
- [ ] All LoppisFynd legacy docs in `docs/loppisfynd-legacy/`
- [ ] Root directory cleaned (only essential files)
- [ ] README.md updated for Bokfynd
- [ ] CLAUDE.md updated for Bokfynd context

### Validation Phase (Week 1)
- [ ] ISBN coverage ≥50%
- [ ] Real-world scan success ≥80%
- [ ] Apify integration reliable (≥90% success)
- [ ] User interest validated (≥70% would use)

### Code Migration Phase (Weeks 2-13, if validation passes)
- [ ] AI services removed
- [ ] ISBN lookup implemented
- [ ] Multi-platform market data working
- [ ] Beta testing complete (10+ users)
- [ ] App store ready

---

## Next Steps

**Immediate (This Session):**
1. Execute Phase 1: Documentation reorganization
2. Execute Phase 2: Repository cleanup
3. Update README.md and CLAUDE.md
4. Commit changes: "docs: reorganize for Bokfynd migration"

**Week 1 (Validation Sprint):**
1. Create validation scripts (ISBN coverage test)
2. Schedule flea market visits
3. Set up Apify test account
4. Recruit interview participants
5. Execute validation sprint
6. Make GO/NO-GO decision

**Week 2+ (If GO):**
1. Create detailed code migration plan
2. Begin Phase 5.1: Core refactoring
3. Continue with phased approach

---

## Appendix: Document Mapping

### Bokfynd Strategy Documents
- `BOKFYND_DEEP_ANALYSIS.md` → Split into:
  - `docs/bokfynd/strategy/business-analysis.md`
  - `docs/bokfynd/architecture/overview.md`
  - `docs/bokfynd/architecture/services.md`
- `BOKFYND_VALIDATION_UPDATE.md` → `docs/bokfynd/strategy/validation-results.md`

### Bokfynd QA Documents
- `docs/bokfynd_scanner_qa_plan.md` → `docs/bokfynd/qa/scanner-qa-plan.md`

### LoppisFynd Legacy Documents
- `ARCHITECTURE_REVIEW.md` → `docs/loppisfynd-legacy/architecture-review.md`

### Migration Documents
- This document → `docs/migration/MIGRATION_PLAN.md`

### Baseline Documents
- `docs/baseline-analyze.txt` → `docs/baseline/baseline-analyze.txt`

---

**Plan Created:** 2026-04-29  
**Status:** Ready for Execution  
**Next Review:** After Phase 1-2 completion
