import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:fynd_loppis/features/scanner/barcode/mlkit_book_isbn_adapter.dart';
import 'package:fynd_loppis/services/books/book_barcode_isbn_handoff_service.dart';
import 'package:fynd_loppis/services/books/book_isbn_draft_flow_controller.dart';
import 'package:fynd_loppis/services/books/book_scanner_isbn_handoff_coordinator.dart';

void main() {
  group('BookScannerIsbnHandoffCoordinator', () {
    test(
      'selects the first validated raw ISBN and delegates handoff',
      () async {
        final handoff = _FakeHandoff();
        final coordinator = BookScannerIsbnHandoffCoordinator(
          isbnAdapter: const MlKitBookIsbnAdapter(),
          handoff: handoff,
        );

        final result = await coordinator.handoffFirstRawValue(
          scanItemId: 'scan-1',
          rawValues: ['4006381333931', '978-0-306-40615-7', '0-306-40615-2'],
          now: DateTime.utc(2026, 4, 28),
        );

        expect(result, isA<BookIsbnDraftFlowNotFound>());
        expect(handoff.calls, 1);
        expect(handoff.lastScanItemId, 'scan-1');
        expect(handoff.lastIsbn?.value, '9780306406157');
        expect(handoff.lastNow, DateTime.utc(2026, 4, 28));
      },
    );

    test(
      'returns null and does not delegate when no ISBN is detected',
      () async {
        final handoff = _FakeHandoff();
        final coordinator = BookScannerIsbnHandoffCoordinator(
          isbnAdapter: const MlKitBookIsbnAdapter(),
          handoff: handoff,
        );

        final result = await coordinator.handoffFirstRawValue(
          scanItemId: 'scan-1',
          rawValues: ['4006381333931', 'not an isbn', null, '   '],
        );

        expect(result, isNull);
        expect(handoff.calls, 0);
      },
    );

    test(
      'accepts ML Kit barcode detections without scanner UI wiring',
      () async {
        final handoff = _FakeHandoff();
        final coordinator = BookScannerIsbnHandoffCoordinator(
          isbnAdapter: const MlKitBookIsbnAdapter(),
          handoff: handoff,
        );

        final result = await coordinator.handoffFirstBarcode(
          scanItemId: 'scan-1',
          barcodes: [
            _barcode(rawValue: '4006381333931', displayValue: null),
            _barcode(rawValue: null, displayValue: ' 978 0 306 40615 7 '),
          ],
        );

        expect(result, isA<BookIsbnDraftFlowNotFound>());
        expect(handoff.calls, 1);
        expect(handoff.lastIsbn?.value, '9780306406157');
      },
    );
  });
}

class _FakeHandoff implements BookBarcodeIsbnHandoff {
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

    return BookIsbnDraftFlowNotFound(scanItemId: scanItemId, isbn: isbn.value);
  }
}

Barcode _barcode({required String? rawValue, required String? displayValue}) {
  return Barcode(
    type: BarcodeType.product,
    format: BarcodeFormat.ean13,
    displayValue: displayValue,
    rawValue: rawValue,
    rawBytes: rawValue == null ? null : Uint8List.fromList(rawValue.codeUnits),
    boundingBox: const Rect.fromLTWH(0, 0, 10, 10),
    cornerPoints: const [],
    value: null,
  );
}
