import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:fynd_loppis/features/scanner/barcode/mlkit_book_isbn_adapter.dart';

void main() {
  const adapter = MlKitBookIsbnAdapter();

  group('MlKitBookIsbnAdapter', () {
    test(
      'converts a valid ML Kit barcode raw value into a normalized ISBN',
      () {
        final isbn = adapter.fromBarcode(
          _barcode(rawValue: '978-0-306-40615-7', displayValue: null),
        );

        expect(isbn?.value, '9780306406157');
      },
    );

    test('falls back to display value when raw value is absent', () {
      final isbn = adapter.fromBarcode(
        _barcode(rawValue: null, displayValue: ' 978 0 306 40615 7 '),
      );

      expect(isbn?.value, '9780306406157');
    });

    test('returns null for non-book, malformed, blank, or absent values', () {
      expect(adapter.fromRawValue('4006381333931'), isNull);
      expect(adapter.fromRawValue('not an isbn'), isNull);
      expect(adapter.fromRawValue('   '), isNull);
      expect(adapter.fromRawValue(null), isNull);
      expect(
        adapter.fromBarcode(_barcode(rawValue: null, displayValue: null)),
        isNull,
      );
    });

    test(
      'dedupes normalized ISBN values while preserving first-seen order',
      () {
        final isbns = adapter.fromRawValues([
          '978-0-306-40615-7',
          '9780306406157',
          '0-306-40615-2',
          '4006381333931',
          null,
        ]);

        expect(isbns.map((isbn) => isbn.value), [
          '9780306406157',
          '0306406152',
        ]);
      },
    );
  });
}

Barcode _barcode({required String? rawValue, required String? displayValue}) {
  return Barcode(
    rawValue: rawValue,
    displayValue: displayValue,
    format: BarcodeFormat.ean13,
    type: BarcodeType.product,
    corners: const [],
    size: Size.zero,
  );
}
