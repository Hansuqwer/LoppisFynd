import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:fynd_loppis/features/scanner/barcode/mlkit_book_isbn_adapter.dart';
import 'package:fynd_loppis/features/scanner/barcode/scanner_book_isbn_handoff_controller.dart';
import 'package:fynd_loppis/features/scanner/barcode/scanner_book_isbn_handoff_feedback.dart';
import 'package:fynd_loppis/services/books/book_barcode_isbn_handoff_service.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_orchestration_service.dart';
import 'package:fynd_loppis/services/books/book_isbn_draft_flow_controller.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/book_scanner_isbn_handoff_coordinator.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  group('ScannerBookIsbnHandoffController', () {
    test('does not delegate without a draft scan item context', () async {
      final handoff = _FakeHandoff();
      final controller = _controller(handoff);

      final result = await controller.maybeHandoffBarcodes(
        scanItemId: null,
        barcodes: [_barcode(rawValue: '9780306406157')],
      );

      expect(result, isNull);
      expect(handoff.calls, 0);
    });

    test('does not delegate when no barcode is a valid ISBN', () async {
      final handoff = _FakeHandoff();
      final controller = _controller(handoff);

      final result = await controller.maybeHandoffBarcodes(
        scanItemId: 'scan-1',
        barcodes: [
          _barcode(rawValue: '4006381333931'),
          _barcode(rawValue: 'not an isbn'),
        ],
      );

      expect(result, isNull);
      expect(handoff.calls, 0);
    });

    test('delegates the first valid ISBN for the draft scan item', () async {
      final handoff = _FakeHandoff(state: _notFoundState);
      final controller = _controller(handoff);

      final result = await controller.maybeHandoffBarcodes(
        scanItemId: ' scan-1 ',
        barcodes: [
          _barcode(rawValue: '4006381333931'),
          _barcode(rawValue: '978-0-306-40615-7'),
          _barcode(rawValue: '0-306-40615-2'),
        ],
        now: DateTime.utc(2026, 4, 28),
      );

      expect(result, isA<BookIsbnDraftFlowNotFound>());
      expect(handoff.calls, 1);
      expect(handoff.lastScanItemId, 'scan-1');
      expect(handoff.lastIsbn?.value, '9780306406157');
      expect(handoff.lastNow, DateTime.utc(2026, 4, 28));
    });

    test('returns success state for snackbar feedback mapping', () async {
      final handoff = _FakeHandoff(state: _successState);
      final controller = _controller(handoff);

      final result = await controller.maybeHandoffBarcodes(
        scanItemId: 'scan-1',
        barcodes: [_barcode(rawValue: '9780306406157')],
      );
      final feedback = scannerBookIsbnHandoffFeedbackFor(result);

      expect(result, isA<BookIsbnDraftFlowSuccess>());
      expect(feedback?.kind, ScannerBookIsbnHandoffFeedbackKind.success);
    });

    test('returns error state for snackbar feedback mapping', () async {
      final handoff = _FakeHandoff(state: _errorState);
      final controller = _controller(handoff);

      final result = await controller.maybeHandoffBarcodes(
        scanItemId: 'scan-1',
        barcodes: [_barcode(rawValue: '9780306406157')],
      );
      final feedback = scannerBookIsbnHandoffFeedbackFor(result);

      expect(result, isA<BookIsbnDraftFlowError>());
      expect(feedback?.kind, ScannerBookIsbnHandoffFeedbackKind.error);
      expect(feedback?.errorMessage, contains('lookup failed'));
    });

    test('skips duplicate ISBN handoffs inside the cooldown window', () async {
      final handoff = _FakeHandoff();
      final controller = _controller(
        handoff,
        cooldown: const Duration(seconds: 3),
      );

      await controller.maybeHandoffBarcodes(
        scanItemId: 'scan-1',
        barcodes: [_barcode(rawValue: '9780306406157')],
        now: DateTime.utc(2026, 4, 28, 10),
      );
      await controller.maybeHandoffBarcodes(
        scanItemId: 'scan-1',
        barcodes: [_barcode(rawValue: '978-0-306-40615-7')],
        now: DateTime.utc(2026, 4, 28, 10, 0, 2),
      );
      await controller.maybeHandoffBarcodes(
        scanItemId: 'scan-1',
        barcodes: [_barcode(rawValue: '9780306406157')],
        now: DateTime.utc(2026, 4, 28, 10, 0, 3),
      );

      expect(handoff.calls, 2);
    });
  });
}

ScannerBookIsbnHandoffController _controller(
  _FakeHandoff handoff, {
  Duration cooldown = const Duration(seconds: 3),
}) {
  return ScannerBookIsbnHandoffController(
    coordinator: BookScannerIsbnHandoffCoordinator(
      isbnAdapter: const MlKitBookIsbnAdapter(),
      handoff: handoff,
    ),
    cooldown: cooldown,
  );
}

class _FakeHandoff implements BookBarcodeIsbnHandoff {
  _FakeHandoff({this.state = _notFoundState});

  final BookIsbnDraftFlowState Function(String scanItemId, String isbn) state;
  int calls = 0;
  String? lastScanItemId;
  ValidatedBookIsbn? lastIsbn;
  DateTime? lastNow;

  @override
  Future<BookIsbnDraftFlowState> handoffValidatedIsbn({
    required String scanItemId,
    required ValidatedBookIsbn isbn,
    DateTime? now,
  }) async {
    calls += 1;
    lastScanItemId = scanItemId;
    lastIsbn = isbn;
    lastNow = now;

    return state(scanItemId, isbn.value);
  }
}

BookIsbnDraftFlowState _notFoundState(String scanItemId, String isbn) {
  return BookIsbnDraftFlowNotFound(scanItemId: scanItemId, isbn: isbn);
}

BookIsbnDraftFlowState _errorState(String scanItemId, String isbn) {
  return BookIsbnDraftFlowError(
    scanItemId: scanItemId,
    isbn: isbn,
    message: 'lookup failed',
  );
}

BookIsbnDraftFlowState _successState(String scanItemId, String isbn) {
  return BookIsbnDraftFlowSuccess(
    scanItemId: scanItemId,
    isbn: isbn,
    appliedDraft: AppliedBookInventoryDraft(
      pricingDraft: BookPricingDraft(
        isbn: isbn,
        metadata: BookMetadata(
          isbn: isbn,
          title: 'Example Book',
          source: 'test',
        ),
        marketQuery: 'Example Book',
      ),
      payload: const BookInventoryDraftPayload(
        scanItem: BookScanItemDraftPayload(
          query: 'Example Book',
          desc: 'Example Book',
          category: 'Books',
        ),
        listing: BookListingDraftPayload(
          platform: 'tradera',
          title: 'Example Book',
          description: 'Example Book',
        ),
      ),
    ),
  );
}

Barcode _barcode({required String rawValue}) {
  return Barcode(
    type: BarcodeType.product,
    format: BarcodeFormat.ean13,
    displayValue: rawValue,
    rawValue: rawValue,
    rawBytes: Uint8List.fromList(rawValue.codeUnits),
    boundingBox: const Rect.fromLTWH(0, 0, 10, 10),
    cornerPoints: const [],
    value: null,
  );
}
