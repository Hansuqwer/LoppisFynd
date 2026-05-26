# Bokfynd README

**Project:** Bokfynd - Book Reseller Assistant  
**Status:** Planning & Validation Phase  
**Last Updated:** 2026-04-29

---

## What is Bokfynd?

Bokfynd is a mobile app for Swedish book resellers that helps them make instant buying decisions at flea markets and estate sales. Scan a book's ISBN barcode, see real market data from Tradera and Vinted, and know immediately if it's worth buying.

**Core Value Proposition:**
- Scan ISBN → See market data in 3-8 seconds
- Know what books sell for before you buy
- Calculate profit margins instantly
- Track your book inventory

---

## Project Status

**Current Phase:** Documentation & Validation Planning

This is a strategic pivot from LoppisFynd (generalist reseller app with AI) to Bokfynd (specialist book reseller app with ISBN lookup).

**Key Milestones:**
- ✅ Strategic analysis complete
- ✅ Vinted scraping validated (via Apify)
- ✅ Documentation reorganized
- ⏳ ISBN coverage validation (Week 1)
- ⏳ Real-world UX testing (Week 1)
- ⏳ GO/NO-GO decision (End of Week 1)
- ⏳ Code migration (8-12 weeks, if validation passes)

---

## Documentation Structure

### Strategy & Business
- [Business Analysis](strategy/business-analysis.md) - Market analysis, unit economics, competitive landscape
- [Validation Results](strategy/validation-results.md) - Vinted scraping validation, Apify integration

### Architecture & Technical
- [Architecture Overview](architecture/overview.md) - System design, data model, service layer
- [API Integration](api-integration/) - Google Books, Apify/Vinted, Tradera, Bokbörsen

### Quality Assurance
- [Scanner QA Plan](qa/scanner-qa-plan.md) - ISBN scanner testing checklist

---

## Key Features (Planned)

### Core Features
1. **ISBN Barcode Scanner** - Fast, reliable barcode scanning with torch support
2. **Book Metadata Lookup** - Google Books + Open Library integration
3. **Multi-Platform Market Data** - Tradera, Vinted (via Apify), Bokbörsen
4. **Profit Calculator** - Platform-specific fees, margin calculation
5. **Book Inventory** - Track purchased books, mark as sold

### Optional Features (Post-MVP)
- Cloud sync (Supabase)
- Export to CSV
- Price alerts
- Community pricing data

---

## Target Users

### Primary: Weekend Book Flippers
- Visits 2-3 flea markets per weekend
- Buys 20-50 books per trip
- Sells on Tradera, Vinted, Facebook groups
- **Pain:** Manually searching each book takes 5-10 minutes
- **Willingness to pay:** 50-100 kr/month

### Secondary: Used Bookstore Owners
- Buys books from estate sales, donations
- Needs to price 100+ books per week
- **Pain:** Guessing prices or spending hours researching
- **Willingness to pay:** 200-500 kr/month

---

## Technical Stack

### Mobile App
- **Framework:** Flutter 3.41.6 (stable)
- **Language:** Dart 3.10.8
- **State Management:** Riverpod 3.2.1
- **Local Database:** Drift 2.31.0 (SQLite)
- **Barcode Scanning:** google_mlkit_barcode_scanning

### Backend Services
- **Cloud Sync:** Supabase (optional)
- **ISBN Lookup:** Google Books API, Open Library
- **Market Data:** Tradera proxy, Apify (Vinted), Bokbörsen scraper
- **Analytics:** Sentry

---

## Critical Success Factors

### Validation Requirements (Week 1)
1. ✅ **ISBN Coverage ≥50%** - At least half of books have market data
2. ✅ **Barcode Scan Success ≥80%** - Works in real flea market conditions
3. ✅ **Apify Reliability ≥90%** - Vinted scraping is stable
4. ✅ **User Interest ≥70%** - Target users would use the app

**Decision Point:** If 3/4 validations pass → GO to code migration. If <2 pass → NO-GO.

---

## Development Phases

### Phase 1: Validation Sprint (Week 1) - CURRENT
- ISBN coverage validation script
- Real-world flea market testing
- Apify integration test
- User interviews

### Phase 2: Core Refactoring (2-3 weeks)
- Remove AI services and features
- Add ISBN lookup service
- Update data model (Books table)
- Migrate existing scan items

### Phase 3: Market Data Integration (2-3 weeks)
- Integrate Apify for Vinted
- Update Tradera integration
- Add Bokbörsen scraping
- Implement market data aggregation

### Phase 4: UI Updates (2-3 weeks)
- Update scanner for ISBN focus
- Build book inventory UI
- Add profit calculator
- Update settings

### Phase 5: Testing & Polish (2-3 weeks)
- Beta testing with real users
- Bug fixes and optimization
- Documentation updates
- App store preparation

**Total Timeline:** 8-12 weeks (after validation)

---

## Unit Economics

### At 1,000 Users
- **Costs:**
  - Google Books API: $107/month
  - Apify (Vinted): $49/month
  - Supabase: ~$25/month
  - **Total:** $181/month

- **Revenue (10% conversion @ 99 kr/month):**
  - 100 paid users × 99 kr = 9,900 kr/month = $990/month

- **Margin:** 82% ✅

### At 10,000 Users
- **Costs:** $1,810/month
- **Revenue:** $9,900/month
- **Margin:** 82% ✅

---

## Competitive Advantage

1. **Only Swedish-focused book scanning app**
2. **Only app with profit calculator for resellers**
3. **Only app aggregating multiple Swedish platforms**
4. **First-mover advantage in Swedish market**

---

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| ISBN coverage < 50% | Medium | High | Manual entry + community data |
| Google Books rate limit | High | High | Aggressive caching + paid tier |
| Vinted blocks scraping | Medium | Medium | Fallback to Tradera only |
| Barcode scanning fails | Medium | Medium | Torch toggle + manual entry |

---

## Next Steps

**Immediate (Week 1):**
1. Create ISBN coverage validation script
2. Schedule flea market visits for UX testing
3. Set up Apify test account
4. Recruit 5-10 book resellers for interviews
5. Execute validation sprint
6. Make GO/NO-GO decision

**If GO (Week 2+):**
1. Create detailed code migration plan
2. Begin Phase 2: Core refactoring
3. Continue with phased development

**If NO-GO:**
1. Archive Bokfynd documentation
2. Continue LoppisFynd development OR
3. Pivot to alternative approach

---

## Related Documentation

- [Migration Plan](../../migration/MIGRATION_PLAN.md) - Full migration strategy
- [LoppisFynd Legacy](../../loppisfynd-legacy/) - Original project documentation
- [Baseline Tracking](../../baseline/) - Analyzer and test baselines

---

**Project Lead:** Hans Vilund  
**Start Date:** April 2026  
**Target Launch:** Q3 2026 (if validation passes)
