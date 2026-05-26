import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_market_data_service.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('BookInventoryDraftMapper', () {
    test('maps pricing draft into scan item and listing payloads', () {
      final mapper = const BookInventoryDraftMapper();
      final payload = mapper.map(
        BookPricingDraft(
          isbn: '9780143127796',
          metadata: const BookMetadata(
            isbn: '9780143127796',
            title: 'Sapiens',
            source: 'google_books',
            authors: ['Yuval Noah Harari'],
            publisher: 'Harper',
            publishYear: 2015,
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
        ),
      );

      expect(payload.scanItem.query, 'Sapiens Yuval Noah Harari');
      expect(payload.scanItem.desc, 'Sapiens Yuval Noah Harari');
      expect(payload.scanItem.category, 'Books');
      expect(payload.scanItem.medianPriceSek, 95);
      expect(payload.scanItem.minPriceSek, 70);
      expect(payload.scanItem.maxPriceSek, 140);
      expect(payload.scanItem.notes, contains('BokFynd market stats'));

      expect(payload.listing.platform, 'tradera');
      expect(payload.listing.title, 'Sapiens - Yuval Noah Harari');
      expect(payload.listing.askingPriceSek, 95);
      expect(
        payload.listing.description,
        contains('Author: Yuval Noah Harari'),
      );
      expect(payload.listing.description, contains('Publisher: Harper'));
      expect(payload.listing.description, contains('Year: 2015'));
      expect(payload.listing.description, contains('ISBN: 9780143127796'));
      expect(payload.listing.description, contains('Market evidence: 9 sales'));
    });

    test('creates metadata-only payload when market stats are absent', () {
      final mapper = const BookInventoryDraftMapper();
      final payload = mapper.map(
        const BookPricingDraft(
          isbn: '9789174297052',
          metadata: BookMetadata(
            isbn: '9789174297052',
            title: 'En man som heter Ove',
            source: 'open_library',
          ),
          marketQuery: 'En man som heter Ove',
        ),
      );

      expect(payload.scanItem.query, 'En man som heter Ove');
      expect(payload.scanItem.desc, 'En man som heter Ove');
      expect(payload.scanItem.category, 'Books');
      expect(payload.scanItem.notes, isNull);
      expect(payload.scanItem.medianPriceSek, isNull);
      expect(payload.scanItem.minPriceSek, isNull);
      expect(payload.scanItem.maxPriceSek, isNull);

      expect(payload.listing.title, 'En man som heter Ove');
      expect(payload.listing.askingPriceSek, isNull);
      expect(payload.listing.description, contains('ISBN: 9789174297052'));
      expect(payload.listing.description, isNot(contains('Market evidence')));
    });

    test('trims author fields and skips empty optional lines', () {
      final mapper = const BookInventoryDraftMapper();
      final payload = mapper.map(
        const BookPricingDraft(
          isbn: '9780000000002',
          metadata: BookMetadata(
            isbn: '9780000000002',
            title: '  Clean Code  ',
            source: 'google_books',
            authors: [' ', ' Robert C. Martin '],
            publisher: ' ',
          ),
          marketQuery: 'Clean Code Robert C. Martin',
        ),
      );

      expect(payload.listing.title, 'Clean Code - Robert C. Martin');
      expect(payload.scanItem.desc, 'Clean Code Robert C. Martin');
      expect(payload.listing.description, isNot(contains('Publisher:')));
      expect(payload.listing.description, isNot(contains('Author:  ')));
    });
  });
}
