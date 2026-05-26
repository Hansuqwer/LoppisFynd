import '../../features/scanner/barcode/mlkit_book_isbn_adapter.dart';
import 'book_barcode_isbn_handoff_service.dart';
import 'book_isbn_draft_flow_controller.dart';

class BookScannerIsbnHandoffCoordinator {
  const BookScannerIsbnHandoffCoordinator({
    required MlKitBookIsbnAdapter isbnAdapter,
    required BookBarcodeIsbnHandoff handoff,
  }) : _isbnAdapter = isbnAdapter,
        _handoff = handoff;

  final MlKitBookIsbnAdapter _isbnAdapter;
  final BookBarcodeIsbnHandoff _handoff;

  ValidatedBookIsbn? firstValidatedBarcode(Iterable<dynamic> barcodes) {
    final isbns = _isbnAdapter.fromBarcodes(barcodes);
    return isbns.isEmpty ? null : isbns.first;
  }

  Future<BookIsbnDraftFlowState> handoffValidatedIsbn({
    required String scanItemId,
    required ValidatedBookIsbn isbn,
    DateTime? now,
  }) {
    return _handoff.handoffValidatedIsbn(
      scanItemId: scanItemId,
      isbn: isbn,
      now: now,
    );
  }

  Future<BookIsbnDraftFlowState?> handoffFirstBarcode({
    required String scanItemId,
    required Iterable<dynamic> barcodes,
    DateTime? now,
  }) {
    final isbn = firstValidatedBarcode(barcodes);
    if (isbn == null) return Future.value();

    return handoffValidatedIsbn(scanItemId: scanItemId, isbn: isbn, now: now);
  }

  Future<BookIsbnDraftFlowState?> handoffFirstRawValue({
    required String scanItemId,
    required Iterable<String?> rawValues,
    DateTime? now,
  }) {
    return _handoffFirstValidatedIsbn(
      scanItemId: scanItemId,
      isbns: _isbnAdapter.fromRawValues(rawValues),
      now: now,
    );
  }

  Future<BookIsbnDraftFlowState?> _handoffFirstValidatedIsbn({
    required String scanItemId,
    required List<ValidatedBookIsbn> isbns,
    DateTime? now,
  }) {
    if (isbns.isEmpty) return Future.value();

    return handoffValidatedIsbn(
      scanItemId: scanItemId,
      isbn: isbns.first,
      now: now,
    );
  }
}
