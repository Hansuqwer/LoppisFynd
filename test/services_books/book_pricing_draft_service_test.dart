import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_market_data_service.dart';
import 'package:fynd_loppis/services/books/book_market_service.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('BookPricingDraftService', () {
    test(
      'combines ISBN metadata and market stats into a pricing draft',
      () async {
        final metadataLookup = _FakeMetadataLookup(
          result: const BookMetadata(
            isbn: '9780143127796',
            title: 'Sapiens',
            source: 'google_books',
            authors: ['Yuval Noah Harari'],
          ),
        );
        final marketLookup = _FakeMarketLookup(
          result: BookMarketStats(
            highestSoldPriceSek: 120,
            averageSoldPriceSek: 90,
            lowestSoldPriceSek: 70,
            totalSales: 3,
            salesPerMonth: 0.25,
            sourceCounts: const {'tradera': 3},
            recentSales: [
              BookSale(
                platform: 'tradera',
                priceSek: 90,
                soldAt: DateTime.utc(2026, 4, 1),
              ),
            ],
          ),
        );
        final service = BookPricingDraftService(
          metadataLookup: metadataLookup,
          marketLookup: marketLookup,
        );

        final draft = await service.createDraftForIsbn(
          isbn: '9780143127796',
          now: DateTime.utc(2026, 4, 28),
        );

        expect(draft, isNotNull);
        expect(draft!.isbn, '9780143127796');
        expect(draft.metadata.title, 'Sapiens');
        expect(draft.marketQuery, 'Sapiens Yuval Noah Harari');
        expect(draft.hasMarketStats, isTrue);
        expect(draft.suggestedListPriceSek, 90);
        expect(marketLookup.lastQuery, 'Sapiens Yuval Noah Harari');
      },
    );

    test(
      'returns metadata-only draft when market lookup is unavailable',
      () async {
        final service = BookPricingDraftService(
          metadataLookup: _FakeMetadataLookup(
            result: const BookMetadata(
              isbn: '9789174297052',
              title: 'En man som heter Ove',
              source: 'open_library',
            ),
          ),
        );

        final draft = await service.createDraftForIsbn(isbn: '9789174297052');

        expect(draft, isNotNull);
        expect(draft!.marketQuery, 'En man som heter Ove');
        expect(draft.marketStats, isNull);
        expect(draft.suggestedListPriceSek, isNull);
      },
    );

    test(
      'returns null and skips market lookup when ISBN metadata is missing',
      () async {
        final marketLookup = _FakeMarketLookup(result: null);
        final service = BookPricingDraftService(
          metadataLookup: _FakeMetadataLookup(result: null),
          marketLookup: marketLookup,
        );

        final draft = await service.createDraftForIsbn(isbn: 'missing');

        expect(draft, isNull);
        expect(marketLookup.calls, 0);
      },
    );
  });
}

class _FakeMetadataLookup implements BookMetadataLookup {
  const _FakeMetadataLookup({required this.result});

  final BookMetadata? result;

  @override
  Future<BookMetadata?> lookupIsbn(String isbn) async => result;
}

class _FakeMarketLookup implements BookMarketStatsLookup {
  _FakeMarketLookup({required this.result});

  final BookMarketStats? result;
  int calls = 0;
  String? lastQuery;

  @override
  Future<BookMarketStats?> fetchStatsForBookQuery({
    required String query,
    DateTime? now,
    int itemsPerPage = 50,
  }) async {
    calls += 1;
    lastQuery = query;
    return result;
  }
}
