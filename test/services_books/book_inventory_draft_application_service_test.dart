import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_application_service.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';

void main() {
  group('BookInventoryDraftApplicationService', () {
    test('applies scan item enrichment and draft listing payload', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await _seedScanItem(db);

      final service = BookInventoryDraftApplicationService(db: db);
      await service.applyToScanItem(
        scanItemId: 'scan-1',
        payload: const BookInventoryDraftPayload(
          scanItem: BookScanItemDraftPayload(
            query: 'Sapiens Yuval Noah Harari',
            desc: 'Sapiens Yuval Noah Harari',
            category: 'Books',
            notes:
                'BokFynd market stats; average=95 SEK; low=70 SEK; high=140 SEK; sales=9',
            medianPriceSek: 95,
            minPriceSek: 70,
            maxPriceSek: 140,
          ),
          listing: BookListingDraftPayload(
            platform: 'tradera',
            title: 'Sapiens - Yuval Noah Harari',
            description: 'Sapiens\nISBN: 9780143127796',
            askingPriceSek: 95,
          ),
        ),
      );

      final item = await db.scanItemsDao.getById('scan-1');
      expect(item, isNotNull);
      expect(item!.query, 'Sapiens Yuval Noah Harari');
      expect(item.desc, 'Sapiens Yuval Noah Harari');
      expect(item.category, 'Books');
      expect(item.notes, contains('BokFynd market stats'));
      expect(item.medianPrice, 95);
      expect(item.minPrice, 70);
      expect(item.maxPrice, 140);

      final draft = await db.draftListingsDao.getByScanItemId('scan-1');
      expect(draft, isNotNull);
      expect(draft!.platform, 'tradera');
      expect(draft.title, 'Sapiens - Yuval Noah Harari');
      expect(draft.description, 'Sapiens\nISBN: 9780143127796');
      expect(draft.askingPriceSek, 95);
    });

    test('applies metadata-only draft without setting market stats', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await _seedScanItem(db);

      final service = BookInventoryDraftApplicationService(db: db);
      await service.applyToScanItem(
        scanItemId: 'scan-1',
        payload: const BookInventoryDraftPayload(
          scanItem: BookScanItemDraftPayload(
            query: 'En man som heter Ove',
            desc: 'En man som heter Ove',
            category: 'Books',
          ),
          listing: BookListingDraftPayload(
            platform: 'tradera',
            title: 'En man som heter Ove',
            description: 'En man som heter Ove\nISBN: 9789174297052',
          ),
        ),
      );

      final item = await db.scanItemsDao.getById('scan-1');
      expect(item, isNotNull);
      expect(item!.query, 'En man som heter Ove');
      expect(item.desc, 'En man som heter Ove');
      expect(item.category, 'Books');
      expect(item.notes, isNull);
      expect(item.medianPrice, isNull);
      expect(item.minPrice, isNull);
      expect(item.maxPrice, isNull);

      final draft = await db.draftListingsDao.getByScanItemId('scan-1');
      expect(draft, isNotNull);
      expect(draft!.title, 'En man som heter Ove');
      expect(draft.askingPriceSek, isNull);
    });
  });
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
