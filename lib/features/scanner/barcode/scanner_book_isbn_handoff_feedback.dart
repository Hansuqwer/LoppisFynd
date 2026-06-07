import '../../../gen/app_localizations.dart';
import '../../../services/books/book_isbn_draft_flow_controller.dart';

enum ScannerBookIsbnHandoffFeedbackKind {
  success,
  successFallback,
  notFound,
  error,
}

class ScannerBookIsbnHandoffFeedback {
  const ScannerBookIsbnHandoffFeedback({required this.kind, this.errorMessage});

  final ScannerBookIsbnHandoffFeedbackKind kind;
  final String? errorMessage;

  String message(AppLocalizations l10n) {
    return switch (kind) {
      ScannerBookIsbnHandoffFeedbackKind.success =>
        l10n.scannerBokFyndDraftReady,
      ScannerBookIsbnHandoffFeedbackKind.successFallback =>
        '${l10n.scannerBokFyndDraftReady} ${l10n.scannerBokFyndOpenLibraryFallback}',
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
    BookIsbnDraftFlowSuccess(:final appliedDraft) =>
      ScannerBookIsbnHandoffFeedback(
        kind: appliedDraft.pricingDraft.metadata.source == 'open_library'
            ? ScannerBookIsbnHandoffFeedbackKind.successFallback
            : ScannerBookIsbnHandoffFeedbackKind.success,
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
