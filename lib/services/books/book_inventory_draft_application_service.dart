import '../../core/database/app_database.dart';
import 'book_inventory_draft_mapper.dart';

abstract class BookInventoryDraftApplier {
  Future<void> applyToScanItem({
    required String scanItemId,
    required BookInventoryDraftPayload payload,
  });
}

class BookInventoryDraftApplicationService
    implements BookInventoryDraftApplier {
  const BookInventoryDraftApplicationService({required AppDatabase db})
    : _db = db;

  final AppDatabase _db;

  @override
  Future<void> applyToScanItem({
    required String scanItemId,
    required BookInventoryDraftPayload payload,
  }) async {
    await _db.transaction(() async {
      await _db.scanItemsDao.setAiResult(
        id: scanItemId,
        aiJson: null,
        query: payload.scanItem.query,
        desc: payload.scanItem.desc,
        confidence: null,
      );
      await _db.scanItemsDao.setCategory(
        id: scanItemId,
        category: payload.scanItem.category,
      );
      await _db.scanItemsDao.setNotes(
        id: scanItemId,
        notes: payload.scanItem.notes,
      );

      final medianPriceSek = payload.scanItem.medianPriceSek;
      final minPriceSek = payload.scanItem.minPriceSek;
      final maxPriceSek = payload.scanItem.maxPriceSek;
      if (medianPriceSek != null &&
          minPriceSek != null &&
          maxPriceSek != null) {
        await _db.scanItemsDao.setMarketStats(
          id: scanItemId,
          medianPrice: medianPriceSek,
          minPrice: minPriceSek,
          maxPrice: maxPriceSek,
        );
      }

      await _db.draftListingsDao.upsert(
        scanItemId: scanItemId,
        platform: payload.listing.platform,
        title: payload.listing.title,
        description: payload.listing.description,
        askingPriceSek: payload.listing.askingPriceSek,
      );
    });
  }
}
