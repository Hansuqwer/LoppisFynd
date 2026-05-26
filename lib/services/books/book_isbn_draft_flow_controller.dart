import 'package:flutter/foundation.dart';

import 'book_inventory_draft_orchestration_service.dart';

sealed class BookIsbnDraftFlowState {
  const BookIsbnDraftFlowState();
}

class BookIsbnDraftFlowIdle extends BookIsbnDraftFlowState {
  const BookIsbnDraftFlowIdle();
}

class BookIsbnDraftFlowLoading extends BookIsbnDraftFlowState {
  const BookIsbnDraftFlowLoading({
    required this.scanItemId,
    required this.isbn,
  });

  final String scanItemId;
  final String isbn;
}

class BookIsbnDraftFlowSuccess extends BookIsbnDraftFlowState {
  const BookIsbnDraftFlowSuccess({
    required this.scanItemId,
    required this.isbn,
    required this.appliedDraft,
  });

  final String scanItemId;
  final String isbn;
  final AppliedBookInventoryDraft appliedDraft;
}

class BookIsbnDraftFlowNotFound extends BookIsbnDraftFlowState {
  const BookIsbnDraftFlowNotFound({
    required this.scanItemId,
    required this.isbn,
  });

  final String scanItemId;
  final String isbn;
}

class BookIsbnDraftFlowError extends BookIsbnDraftFlowState {
  const BookIsbnDraftFlowError({
    required this.scanItemId,
    required this.isbn,
    required this.message,
    this.error,
  });

  final String scanItemId;
  final String isbn;
  final String message;
  final Object? error;
}

class BookIsbnDraftFlowController {
  BookIsbnDraftFlowController({
    required BookInventoryDraftOrchestrator orchestrator,
  }) : _orchestrator = orchestrator;

  final BookInventoryDraftOrchestrator _orchestrator;
  final ValueNotifier<BookIsbnDraftFlowState> state = ValueNotifier(
    const BookIsbnDraftFlowIdle(),
  );

  Future<BookIsbnDraftFlowState> createDraft({
    required String scanItemId,
    required String isbn,
    DateTime? now,
  }) async {
    final normalizedIsbn = isbn.trim();
    if (normalizedIsbn.isEmpty) {
      final next = BookIsbnDraftFlowError(
        scanItemId: scanItemId,
        isbn: normalizedIsbn,
        message: 'ISBN is required.',
      );
      state.value = next;
      return next;
    }

    state.value = BookIsbnDraftFlowLoading(
      scanItemId: scanItemId,
      isbn: normalizedIsbn,
    );

    try {
      final appliedDraft = await _orchestrator.createAndApplyForIsbn(
        scanItemId: scanItemId,
        isbn: normalizedIsbn,
        now: now,
      );
      final next = appliedDraft == null
          ? BookIsbnDraftFlowNotFound(
              scanItemId: scanItemId,
              isbn: normalizedIsbn,
            )
          : BookIsbnDraftFlowSuccess(
              scanItemId: scanItemId,
              isbn: normalizedIsbn,
              appliedDraft: appliedDraft,
            );
      state.value = next;
      return next;
    } catch (error) {
      final next = BookIsbnDraftFlowError(
        scanItemId: scanItemId,
        isbn: normalizedIsbn,
        message: error.toString(),
        error: error,
      );
      state.value = next;
      return next;
    }
  }

  void reset() {
    state.value = const BookIsbnDraftFlowIdle();
  }

  void dispose() {
    state.dispose();
  }
}
