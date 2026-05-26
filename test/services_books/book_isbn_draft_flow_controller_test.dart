import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_orchestration_service.dart';
import 'package:fynd_loppis/services/books/book_isbn_draft_flow_controller.dart';
import 'package:fynd_loppis/services/books/book_market_data_service.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('BookIsbnDraftFlowController', () {
    test('starts idle and can reset after success', () async {
      final controller = BookIsbnDraftFlowController(
        orchestrator: _FakeOrchestrator(result: _appliedDraft()),
      );
      addTearDown(controller.dispose);

      expect(controller.state.value, isA<BookIsbnDraftFlowIdle>());

      final result = await controller.createDraft(
        scanItemId: 'scan-1',
        isbn: ' 9780143127796 ',
      );

      expect(result, isA<BookIsbnDraftFlowSuccess>());
      final success = result as BookIsbnDraftFlowSuccess;
      expect(success.scanItemId, 'scan-1');
      expect(success.isbn, '9780143127796');
      expect(success.appliedDraft.payload.listing.title, 'Sapiens');
      expect(controller.state.value, same(success));

      controller.reset();
      expect(controller.state.value, isA<BookIsbnDraftFlowIdle>());
    });

    test('emits loading before success', () async {
      final controller = BookIsbnDraftFlowController(
        orchestrator: _FakeOrchestrator(result: _appliedDraft()),
      );
      addTearDown(controller.dispose);
      final seen = <BookIsbnDraftFlowState>[];
      controller.state.addListener(() => seen.add(controller.state.value));

      await controller.createDraft(scanItemId: 'scan-1', isbn: '9780143127796');

      expect(seen.first, isA<BookIsbnDraftFlowLoading>());
      expect(seen.last, isA<BookIsbnDraftFlowSuccess>());
    });

    test('sets not-found state when orchestration returns null', () async {
      final controller = BookIsbnDraftFlowController(
        orchestrator: _FakeOrchestrator(result: null),
      );
      addTearDown(controller.dispose);

      final result = await controller.createDraft(
        scanItemId: 'scan-1',
        isbn: 'missing',
      );

      expect(result, isA<BookIsbnDraftFlowNotFound>());
      expect(controller.state.value, same(result));
    });

    test(
      'sets error state for blank ISBN without calling orchestration',
      () async {
        final orchestrator = _FakeOrchestrator(result: _appliedDraft());
        final controller = BookIsbnDraftFlowController(
          orchestrator: orchestrator,
        );
        addTearDown(controller.dispose);

        final result = await controller.createDraft(
          scanItemId: 'scan-1',
          isbn: ' ',
        );

        expect(result, isA<BookIsbnDraftFlowError>());
        expect((result as BookIsbnDraftFlowError).message, 'ISBN is required.');
        expect(orchestrator.calls, 0);
      },
    );

    test('sets error state when orchestration throws', () async {
      final controller = BookIsbnDraftFlowController(
        orchestrator: _FakeOrchestrator(error: StateError('boom')),
      );
      addTearDown(controller.dispose);

      final result = await controller.createDraft(
        scanItemId: 'scan-1',
        isbn: '9780143127796',
      );

      expect(result, isA<BookIsbnDraftFlowError>());
      expect((result as BookIsbnDraftFlowError).message, contains('boom'));
      expect(result.error, isA<StateError>());
    });
  });
}

AppliedBookInventoryDraft _appliedDraft() {
  return AppliedBookInventoryDraft(
    pricingDraft: BookPricingDraft(
      isbn: '9780143127796',
      metadata: const BookMetadata(
        isbn: '9780143127796',
        title: 'Sapiens',
        source: 'google_books',
      ),
      marketQuery: 'Sapiens',
      marketStats: BookMarketStats(
        highestSoldPriceSek: 100,
        averageSoldPriceSek: 80,
        lowestSoldPriceSek: 60,
        totalSales: 3,
        salesPerMonth: 0.25,
        sourceCounts: const {'tradera': 3},
        recentSales: [
          BookSale(
            platform: 'tradera',
            priceSek: 80,
            soldAt: DateTime.utc(2026, 4, 1),
          ),
        ],
      ),
    ),
    payload: const BookInventoryDraftPayload(
      scanItem: BookScanItemDraftPayload(
        query: 'Sapiens',
        desc: 'Sapiens',
        category: 'Books',
        medianPriceSek: 80,
        minPriceSek: 60,
        maxPriceSek: 100,
      ),
      listing: BookListingDraftPayload(
        platform: 'tradera',
        title: 'Sapiens',
        description: 'Sapiens\nISBN: 9780143127796',
        askingPriceSek: 80,
      ),
    ),
  );
}

class _FakeOrchestrator implements BookInventoryDraftOrchestrator {
  _FakeOrchestrator({this.result, this.error});

  final AppliedBookInventoryDraft? result;
  final Object? error;
  int calls = 0;

  @override
  Future<AppliedBookInventoryDraft?> createAndApplyForIsbn({
    required String scanItemId,
    required String isbn,
    DateTime? now,
  }) async {
    calls += 1;
    final thrown = error;
    if (thrown != null) throw thrown;
    return result;
  }
}
