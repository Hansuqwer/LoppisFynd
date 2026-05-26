import '../../../gen/app_localizations.dart';
import '../../../services/books/book_isbn_draft_flow_controller.dart';

enum ScannerBookIsbnHandoffFeedbackKind { success, notFound, error }

class ScannerBookIsbnHandoffFeedback {
  const ScannerBookIsbnHandoffFeedback({required this.kind, this.errorMessage});

  final ScannerBookIsbnHandoffFeedbackKind kind;
  final String? errorMessage;

  String message(AppLocalizations l10n) {
    return switch (kind) {
      ScannerBookIsbnHandoffFeedbackKind.success =>
        l10n.scannerBokFyndDraftReady,
      ScannerBookIsbnHandoffFeedbackKind.notFound =>
        l10n.scannerBokFyndIsbnNotFound,
      ScannerBookIsbnHandoffFeedbackKind.error => l10n.scannerBokFyndDraftError(
        errorMessage ?? '',
      ),
    };
  }
}

ScannerBookIsbnHandoffFeedback? scannerBookIsbnHandoffFeedbackFor(
  BookIsbnDraftFlowState? state,
) {
  return switch (state) {
    BookIsbnDraftFlowSuccess() => const ScannerBookIsbnHandoffFeedback(
      kind: ScannerBookIsbnHandoffFeedbackKind.success,
    ),
    BookIsbnDraftFlowNotFound() => const ScannerBookIsbnHandoffFeedback(
      kind: ScannerBookIsbnHandoffFeedbackKind.notFound,
    ),
    BookIsbnDraftFlowError(:final message) => ScannerBookIsbnHandoffFeedback(
      kind: ScannerBookIsbnHandoffFeedbackKind.error,
      errorMessage: message,
    ),
    _ => null,
  };
}
