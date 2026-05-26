import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../isbn/validated_book_isbn.dart';

class MlKitBookIsbnAdapter {
  const MlKitBookIsbnAdapter();

  ValidatedBookIsbn? fromBarcode(Barcode barcode) {
    return fromRawValue(_barcodeRawValue(barcode));
  }

  ValidatedBookIsbn? fromRawValue(String? rawValue) {
    final trimmed = rawValue?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    try {
      return ValidatedBookIsbn.fromScannerValue(trimmed);
    } on FormatException {
      return null;
    }
  }

  List<ValidatedBookIsbn> fromBarcodes(Iterable<Barcode> barcodes) {
    return _dedupe(barcodes.map(fromBarcode));
  }

  List<ValidatedBookIsbn> fromRawValues(Iterable<String?> rawValues) {
    return _dedupe(rawValues.map(fromRawValue));
  }

  String? _barcodeRawValue(Barcode barcode) {
    final raw = barcode.rawValue?.trim();
    if (raw != null && raw.isNotEmpty) return raw;

    final display = barcode.displayValue?.trim();
    if (display != null && display.isNotEmpty) return display;

    return null;
  }

  List<ValidatedBookIsbn> _dedupe(Iterable<ValidatedBookIsbn?> isbns) {
    final seen = <String>{};
    final result = <ValidatedBookIsbn>[];

    for (final isbn in isbns) {
      if (isbn == null || !seen.add(isbn.value)) continue;
      result.add(isbn);
    }

    return result;
  }
}
