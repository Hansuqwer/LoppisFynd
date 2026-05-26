# Bokfynd

**Book Reseller Assistant for the Swedish Market**

Bokfynd is an offline-first Flutter mobile app (iOS + Android) that helps Swedish book resellers make instant buying decisions at flea markets and estate sales. Scan a book's ISBN barcode, see real market data from Tradera and Vinted, and know immediately if it's worth buying.

---

## 🚀 Project Status

**Current Phase:** Planning & Validation (Week 1)

This is a strategic pivot from LoppisFynd (generalist reseller app with AI) to Bokfynd (specialist book reseller app with ISBN lookup).

**Key Milestones:**
- ✅ Strategic analysis complete
- ✅ Vinted scraping validated (via Apify)
- ✅ Documentation reorganized
- ⏳ ISBN coverage validation (Week 1)
- ⏳ Real-world UX testing (Week 1)
- ⏳ GO/NO-GO decision (End of Week 1)
- ⏳ Code migration (8-12 weeks, if validation passes)

See [docs/bokfynd/README.md](docs/bokfynd/README.md) for full project overview.

---

## 📖 Documentation

### For Developers
- **[CLAUDE.md](CLAUDE.md)** - Development guidelines and architecture overview
- **[Migration Plan](docs/migration/MIGRATION_PLAN.md)** - Full migration strategy from LoppisFynd to Bokfynd
- **[Architecture Overview](docs/bokfynd/architecture/overview.md)** - Technical architecture and data model

### For Stakeholders
- **[Business Analysis](docs/bokfynd/strategy/business-analysis.md)** - Market analysis, unit economics, competitive landscape
- **[Validation Results](docs/bokfynd/strategy/validation-results.md)** - Vinted scraping validation, Apify integration

### Legacy Documentation
- **[LoppisFynd Archive](docs/loppisfynd-legacy/)** - Original project documentation and architecture review

---

## 🎯 What is Bokfynd?

**Core Value Proposition:**
- Scan ISBN → See market data in 3-8 seconds
- Know what books sell for before you buy
- Calculate profit margins instantly
- Track your book inventory

**Target Users:**
- Weekend book flippers (20-50 books per trip)
- Used bookstore owners (100+ books per week)

**Performance vs LoppisFynd:**
- 60-75% faster (3-8s vs 10-30s per scan)
- 73% code complexity reduction
- 82% profit margin at scale

---

## 🛠️ Technical Stack

- **Framework:** Flutter 3.41.6 (stable)
- **Language:** Dart 3.10.8
- **State Management:** Riverpod 3.2.1
- **Local Database:** Drift 2.31.0 (SQLite)
- **Barcode Scanning:** google_mlkit_barcode_scanning
- **Cloud Backend:** Supabase
- **ISBN Lookup:** Google Books API, Open Library
- **Market Data:** Tradera proxy, Apify (Vinted), Bokbörsen scraper

---

## 🚦 Development Commands

### Setup
```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

### Code Quality
```bash
fvm dart format .
fvm flutter analyze
fvm flutter test
```

### Run App
```bash
fvm flutter run
```

See [CLAUDE.md](CLAUDE.md) for full development guidelines.

---

## 📊 Critical Success Factors

**Validation Requirements (Week 1):**
1. ✅ **ISBN Coverage ≥50%** - At least half of books have market data
2. ✅ **Barcode Scan Success ≥80%** - Works in real flea market conditions
3. ✅ **Apify Reliability ≥90%** - Vinted scraping is stable
4. ✅ **User Interest ≥70%** - Target users would use the app

**Decision Point:** If 3/4 validations pass → GO to code migration. If <2 pass → NO-GO.

---

## 🗺️ Roadmap

### Phase 1-2: Documentation Reorganization (Current)
- ✅ Reorganize docs into logical structure
- ✅ Split analysis into focused documents
- ⏳ Update root-level files
- ⏳ Commit changes

### Phase 3: Codebase Assessment (Planning)
- Analyze current LoppisFynd codebase
- Identify reusable components
- Map dependencies
- Create detailed refactoring plan

### Phase 4: Validation Sprint (Week 1)
- ISBN coverage validation script
- Real-world flea market testing
- Apify integration test
- User interviews
- GO/NO-GO decision

### Phase 5: Code Migration (8-12 weeks, deferred)
- Core refactoring (remove AI, add ISBN lookup)
- Market data integration (Apify, Tradera, Bokbörsen)
- UI updates (book inventory, profit calculator)
- Testing & polish

See [docs/migration/MIGRATION_PLAN.md](docs/migration/MIGRATION_PLAN.md) for full timeline.

---

## 🏗️ Architecture Highlights

**Simplification from LoppisFynd:**
- -20% services (5 → 4)
- -27% database tables (11 → 8)
- -50% background jobs (2 → 1)
- -73% service layer complexity (300 lines → 80 lines)

**Key architectural principles:**
- **Local-first:** Drift (SQLite) is source of truth; cloud sync is optional
- **Reactive:** Drift streams + Riverpod StreamProviders drive UI updates
- **No upward imports:** Dependencies flow downward (presentation → services → core)

See [docs/bokfynd/architecture/overview.md](docs/bokfynd/architecture/overview.md) for details.

---

## 📈 Unit Economics

**At 1,000 users:**
- Costs: $181/month (Google Books, Apify, Supabase)
- Revenue: $990/month (10% conversion @ 99 kr/month)
- **Margin: 82%** ✅

**At 10,000 users:**
- Costs: $1,810/month
- Revenue: $9,900/month
- **Margin: 82%** ✅

See [docs/bokfynd/strategy/business-analysis.md](docs/bokfynd/strategy/business-analysis.md) for full analysis.

---

## 🤝 Contributing

This is currently a solo project in planning phase. Contributions will be welcome after the validation sprint passes and code migration begins.

---

## 📄 License

[Add license information]

---

## 📞 Contact

**Project Lead:** Hans Vilund  
**Start Date:** April 2026  
**Target Launch:** Q3 2026 (if validation passes)

---

**Previous Project:** This codebase was originally LoppisFynd, a generalist reseller app with AI-powered item identification. See [docs/loppisfynd-legacy/](docs/loppisfynd-legacy/) for archived documentation.
