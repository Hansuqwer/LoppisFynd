import 'book_inventory_draft_application_service.dart';
import 'book_inventory_draft_mapper.dart';
import 'book_pricing_draft_service.dart';

class AppliedBookInventoryDraft {
  const AppliedBookInventoryDraft({
    required this.pricingDraft,
    required this.payload,
  });

  final BookPricingDraft pricingDraft;
  final BookInventoryDraftPayload payload;
}

abstract class BookInventoryDraftOrchestrator {
  Future<AppliedBookInventoryDraft?> createAndApplyForIsbn({
    required String scanItemId,
    required String isbn,
    DateTime? now,
  });
}

class BookInventoryDraftOrchestrationService
    implements BookInventoryDraftOrchestrator {
  const BookInventoryDraftOrchestrationService({
    required BookPricingDraftCreator pricingDraftCreator,
    required BookInventoryDraftMapper mapper,
    required BookInventoryDraftApplier draftApplier,
  }) : _pricingDraftCreator = pricingDraftCreator,
       _mapper = mapper,
       _draftApplier = draftApplier;

  final BookPricingDraftCreator _pricingDraftCreator;
  final BookInventoryDraftMapper _mapper;
  final BookInventoryDraftApplier _draftApplier;

  @override
  Future<AppliedBookInventoryDraft?> createAndApplyForIsbn({
    required String scanItemId,
    required String isbn,
    DateTime? now,
  }) async {
    final pricingDraft = await _pricingDraftCreator.createDraftForIsbn(
      isbn: isbn,
      now: now,
    );
    if (pricingDraft == null) return null;

    final payload = _mapper.map(pricingDraft);
    await _draftApplier.applyToScanItem(
      scanItemId: scanItemId,
      payload: payload,
    );

    return AppliedBookInventoryDraft(
      pricingDraft: pricingDraft,
      payload: payload,
    );
  }
}
