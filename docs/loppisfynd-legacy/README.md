# LoppisFynd Legacy Documentation

This directory contains archived documentation from the original LoppisFynd project.

## What was LoppisFynd?

LoppisFynd was a **generalist reseller app** that used on-device AI to identify and value any item at flea markets. Users would take a photo, the app would run ML inference to identify the item, then fetch market data from Tradera.

**Key characteristics:**
- AI-powered item identification (TFLite models)
- Photo-based workflow (capture → inference → market lookup)
- Generalist approach (any item: clothes, electronics, furniture, books)
- Complex service layer (isolate management, model downloads, image processing)
- 10-30 second scan-to-result time

## Why the pivot to Bokfynd?

The strategic pivot from LoppisFynd to Bokfynd was driven by:

1. **Complexity reduction** - AI inference was the most complex and fragile part of the codebase
2. **Performance improvement** - ISBN barcode scanning is 60-75% faster (3-8s vs 10-30s)
3. **Clearer value proposition** - "Scan books, know exactly what to pay" vs "Scan anything and maybe get market data"
4. **Better unit economics** - Books have standardized ISBNs, reliable lookups, and active second-hand market
5. **Faster time-to-value** - Immediate decision-making at flea markets

See [docs/bokfynd/strategy/business-analysis.md](../bokfynd/strategy/business-analysis.md) for full strategic assessment.

## What's in this directory?

- **architecture-review.md** - Comprehensive analysis of LoppisFynd architecture (health score: 7.5/10)
  - Top strengths: offline-first, clean DI, feature-first organization
  - Top concerns: sync scalability, isolate overhead, edge function security
  - Critical issues: cloud sync timestamp race, Tradera proxy auth, repeated model installation

## What happens to the LoppisFynd codebase?

The LoppisFynd codebase is **not being deleted**. Instead, it's being **refactored into Bokfynd**:

- **Keep:** Core infrastructure (Drift database, Riverpod DI, navigation, sync, market data, Supabase integration)
- **Remove:** AI inference services, image storage, complex scan item state machine
- **Add:** ISBN lookup service, barcode scanning, book-specific data model, multi-platform market aggregation

See [docs/migration/MIGRATION_PLAN.md](../migration/MIGRATION_PLAN.md) for the full migration strategy.

## Timeline

- **LoppisFynd development:** 2024-2025
- **Architecture review:** April 2026
- **Bokfynd pivot decision:** April 2026
- **Validation sprint:** Week 1 (current phase)
- **Code migration:** 8-12 weeks (deferred until validation passes)

## Related Documentation

- [Bokfynd Project Overview](../bokfynd/README.md)
- [Migration Plan](../migration/MIGRATION_PLAN.md)
- [Bokfynd Architecture](../bokfynd/architecture/overview.md)
- [Business Analysis](../bokfynd/strategy/business-analysis.md)

---

**Status:** Archived  
**Last Updated:** 2026-04-29
