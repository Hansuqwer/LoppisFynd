import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/books/book_barcode_isbn_handoff_service.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_orchestration_service.dart';
import 'package:fynd_loppis/services/books/book_isbn_draft_flow_controller.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('ValidatedBookIsbn', () {
    test('normalizes validated scanner barcode values', () {
      final isbn = ValidatedBookIsbn.fromScannerValue('978-0-306-40615-7');

      expect(isbn.value, '9780306406157');
    });

    test('rejects non-book or malformed barcode values', () {
      expect(
        () => ValidatedBookIsbn.fromScannerValue('4006381333931'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ValidatedBookIsbn.fromScannerValue('not an isbn'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('BookBarcodeIsbnHandoffService', () {
    test(
      'forwards validated ISBN into the existing draft controller flow',
      () async {
        final orchestrator = _FakeOrchestrator(result: _appliedDraft());
        final controller = BookIsbnDraftFlowController(
          orchestrator: orchestrator,
        );
        addTearDown(controller.dispose);
        final service = BookBarcodeIsbnHandoffService(controller: controller);

        final result = await service.handoffValidatedIsbn(
          scanItemId: 'scan-1',
          isbn: ValidatedBookIsbn.fromScannerValue('978-0-306-40615-7'),
          now: DateTime.utc(2026, 4, 28),
        );

        expect(result, isA<BookIsbnDraftFlowSuccess>());
        expect(orchestrator.calls, 1);
        expect(orchestrator.lastScanItemId, 'scan-1');
        expect(orchestrator.lastIsbn, '9780306406157');
      },
    );

    test(
      'returns controller not-found state without adding scanner behavior',
      () async {
        final orchestrator = _FakeOrchestrator(result: null);
        final controller = BookIsbnDraftFlowController(
          orchestrator: orchestrator,
        );
        addTearDown(controller.dispose);
        final service = BookBarcodeIsbnHandoffService(controller: controller);

        final result = await service.handoffValidatedIsbn(
          scanItemId: 'scan-1',
          isbn: ValidatedBookIsbn.fromScannerValue('978-0-306-40615-7'),
        );

        expect(result, isA<BookIsbnDraftFlowNotFound>());
        expect(orchestrator.calls, 1);
      },
    );
  });
}

AppliedBookInventoryDraft _appliedDraft() {
  return const AppliedBookInventoryDraft(
    pricingDraft: BookPricingDraft(
      isbn: '9780306406157',
      metadata: BookMetadata(
        isbn: '9780306406157',
        title: 'Example Book',
        source: 'google_books',
      ),
      marketQuery: 'Example Book',
    ),
    payload: BookInventoryDraftPayload(
      scanItem: BookScanItemDraftPayload(
        query: 'Example Book',
        desc: 'Example Book',
        category: 'Books',
      ),
      listing: BookListingDraftPayload(
        platform: 'tradera',
        title: 'Example Book',
        description: 'Example Book\nISBN: 9780306406157',
      ),
    ),
  );
}

class _FakeOrchestrator implements BookInventoryDraftOrchestrator {
  _FakeOrchestrator({required this.result});

  final AppliedBookInventoryDraft? result;
  int calls = 0;
  String? lastScanItemId;
  String? lastIsbn;

  @override
  Future<AppliedBookInventoryDraft?> createAndApplyForIsbn({
    required String scanItemId,
    required String isbn,
    DateTime? now,
  }) async {
    calls += 1;
    lastScanItemId = scanItemId;
    lastIsbn = isbn;
    return result;
  }
}
