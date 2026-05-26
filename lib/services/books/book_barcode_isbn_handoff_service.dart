import '../../features/scanner/isbn/validated_book_isbn.dart';
import 'book_isbn_draft_flow_controller.dart';

export '../../features/scanner/isbn/validated_book_isbn.dart';

abstract class BookBarcodeIsbnHandoff {
  Future<BookIsbnDraftFlowState> handoffValidatedIsbn({
    required String scanItemId,
    required ValidatedBookIsbn isbn,
    DateTime? now,
  });
}

class BookBarcodeIsbnHandoffService implements BookBarcodeIsbnHandoff {
  const BookBarcodeIsbnHandoffService({
    required BookIsbnDraftFlowController controller,
  }) : _controller = controller;

  final BookIsbnDraftFlowController _controller;

  @override
  Future<BookIsbnDraftFlowState> handoffValidatedIsbn({
    required String scanItemId,
    required ValidatedBookIsbn isbn,
    DateTime? now,
  }) {
    return _controller.createDraft(
      scanItemId: scanItemId,
      isbn: isbn.value,
      now: now,
    );
  }
}
