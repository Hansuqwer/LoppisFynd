import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../services/books/book_isbn_draft_flow_controller.dart';
import '../../../services/books/book_scanner_isbn_handoff_coordinator.dart';

class ScannerBookIsbnHandoffController {
  ScannerBookIsbnHandoffController({
    required BookScannerIsbnHandoffCoordinator coordinator,
    Duration cooldown = const Duration(seconds: 3),
  }) : _coordinator = coordinator,
       _cooldown = cooldown;

  final BookScannerIsbnHandoffCoordinator _coordinator;
  final Duration _cooldown;
  final Map<String, DateTime> _recentHandoffs = {};
  var _busy = false;

  Future<BookIsbnDraftFlowState?> maybeHandoffBarcodes({
    required String? scanItemId,
    required Iterable<Barcode> barcodes,
    DateTime? now,
  }) async {
    final targetScanItemId = scanItemId?.trim();
    if (targetScanItemId == null || targetScanItemId.isEmpty) return null;
    if (_busy) return null;

    final isbn = _coordinator.firstValidatedBarcode(barcodes);
    if (isbn == null) return null;

    final effectiveNow = now ?? DateTime.now();
    _pruneRecentHandoffs(effectiveNow);

    final recentKey = '$targetScanItemId:${isbn.value}';
    if (_recentHandoffs.containsKey(recentKey)) return null;

    _busy = true;
    try {
      final result = await _coordinator.handoffValidatedIsbn(
        scanItemId: targetScanItemId,
        isbn: isbn,
        now: effectiveNow,
      );
      _recentHandoffs[recentKey] = effectiveNow;
      return result;
    } finally {
      _busy = false;
    }
  }

  void _pruneRecentHandoffs(DateTime now) {
    _recentHandoffs.removeWhere((_, seenAt) {
      return now.difference(seenAt) >= _cooldown;
    });
  }
}
