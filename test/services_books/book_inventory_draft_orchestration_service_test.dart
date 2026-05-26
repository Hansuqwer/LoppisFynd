import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_application_service.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_orchestration_service.dart';
import 'package:fynd_loppis/services/books/book_market_data_service.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('BookInventoryDraftOrchestrationService', () {
    test('creates, maps, applies, and returns the applied draft', () async {
      final pricingDraft = _pricingDraft();
      final applier = _FakeDraftApplier();
      final service = BookInventoryDraftOrchestrationService(
        pricingDraftCreator: _FakePricingDraftCreator(result: pricingDraft),
        mapper: const BookInventoryDraftMapper(),
        draftApplier: applier,
      );

      final result = await service.createAndApplyForIsbn(
        scanItemId: 'scan-1',
        isbn: '9780143127796',
        now: DateTime.utc(2026, 4, 28),
      );

      expect(result, isNotNull);
      expect(result!.pricingDraft, same(pricingDraft));
      expect(result.payload.listing.title, 'Sapiens - Yuval Noah Harari');
      expect(applier.calls, 1);
      expect(applier.lastScanItemId, 'scan-1');
      expect(applier.lastPayload!.scanItem.query, 'Sapiens Yuval Noah Harari');
    });

    test(
      'returns null and skips apply when pricing draft is missing',
      () async {
        final applier = _FakeDraftApplier();
        final service = BookInventoryDraftOrchestrationService(
          pricingDraftCreator: const _FakePricingDraftCreator(result: null),
          mapper: const BookInventoryDraftMapper(),
          draftApplier: applier,
        );

        final result = await service.createAndApplyForIsbn(
          scanItemId: 'scan-1',
          isbn: 'missing',
        );

        expect(result, isNull);
        expect(applier.calls, 0);
      },
    );

    test('applies through real app database facade', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await _seedScanItem(db);
      final service = BookInventoryDraftOrchestrationService(
        pricingDraftCreator: _FakePricingDraftCreator(result: _pricingDraft()),
        mapper: const BookInventoryDraftMapper(),
        draftApplier: BookInventoryDraftApplicationService(db: db),
      );

      final result = await service.createAndApplyForIsbn(
        scanItemId: 'scan-1',
        isbn: '9780143127796',
      );

      expect(result, isNotNull);
      final item = await db.scanItemsDao.getById('scan-1');
      expect(item!.query, 'Sapiens Yuval Noah Harari');
      expect(item.category, 'Books');
      expect(item.medianPrice, 95);

      final draft = await db.draftListingsDao.getByScanItemId('scan-1');
      expect(draft!.title, 'Sapiens - Yuval Noah Harari');
      expect(draft.askingPriceSek, 95);
    });
  });
}

BookPricingDraft _pricingDraft() {
  return BookPricingDraft(
    isbn: '9780143127796',
    metadata: const BookMetadata(
      isbn: '9780143127796',
      title: 'Sapiens',
      source: 'google_books',
      authors: ['Yuval Noah Harari'],
    ),
    marketQuery: 'Sapiens Yuval Noah Harari',
    marketStats: BookMarketStats(
      highestSoldPriceSek: 140,
      averageSoldPriceSek: 95,
      lowestSoldPriceSek: 70,
      totalSales: 9,
      salesPerMonth: 0.75,
      sourceCounts: const {'tradera': 9},
      recentSales: [
        BookSale(
          platform: 'tradera',
          priceSek: 95,
          soldAt: DateTime.utc(2026, 4, 1),
        ),
      ],
    ),
  );
}

class _FakePricingDraftCreator implements BookPricingDraftCreator {
  const _FakePricingDraftCreator({required this.result});

  final BookPricingDraft? result;

  @override
  Future<BookPricingDraft?> createDraftForIsbn({
    required String isbn,
    DateTime? now,
  }) async {
    return result;
  }
}

class _FakeDraftApplier implements BookInventoryDraftApplier {
  int calls = 0;
  String? lastScanItemId;
  BookInventoryDraftPayload? lastPayload;

  @override
  Future<void> applyToScanItem({
    required String scanItemId,
    required BookInventoryDraftPayload payload,
  }) async {
    calls += 1;
    lastScanItemId = scanItemId;
    lastPayload = payload;
  }
}

Future<void> _seedScanItem(AppDatabase db) async {
  await db.haulsDao.upsert(id: 'haul-1', title: 'Book haul');
  await db.scanItemsDao.insertNew(
    id: 'scan-1',
    haulId: 'haul-1',
    userId: null,
    imagePath: '/tmp/book.jpg',
    thumbPath: '/tmp/book-thumb.jpg',
  );
}
