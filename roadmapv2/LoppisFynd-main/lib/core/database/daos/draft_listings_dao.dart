import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/draft_listings.dart';
import '../tables/scan_items.dart';

part 'draft_listings_dao.g.dart';

@DriftAccessor(tables: [DraftListings])
class DraftListingsDao extends DatabaseAccessor<AppDatabase>
    with _$DraftListingsDaoMixin {
  DraftListingsDao(super.db);

  Expression<bool> _userScope(ScanItems t, String? userId) {
    return userId == null ? t.userId.isNull() : t.userId.equals(userId);
  }

  Stream<DraftListing?> watchByScanItemId(String scanItemId) {
    final q = select(draftListings)
      ..where((t) => t.scanItemId.equals(scanItemId));
    return q.watchSingleOrNull();
  }

  Stream<List<({DraftListing draft, ScanItem item})>> watchAllForUser({
    required String? userId,
  }) {
    final joinQuery =
        select(draftListings).join([
            innerJoin(
              scanItems,
              scanItems.id.equalsExp(draftListings.scanItemId),
            ),
          ])
          ..where(_userScope(scanItems, userId))
          ..orderBy([OrderingTerm.desc(draftListings.updatedAt)]);

    return joinQuery.watch().map((rows) {
      return rows
          .map(
            (r) => (
              draft: r.readTable(draftListings),
              item: r.readTable(scanItems),
            ),
          )
          .toList(growable: false);
    });
  }

  Future<List<({DraftListing draft, ScanItem item})>> listAllForUser({
    required String? userId,
  }) {
    final joinQuery =
        select(draftListings).join([
            innerJoin(
              scanItems,
              scanItems.id.equalsExp(draftListings.scanItemId),
            ),
          ])
          ..where(_userScope(scanItems, userId))
          ..orderBy([OrderingTerm.desc(draftListings.updatedAt)]);

    return joinQuery.get().then((rows) {
      return rows
          .map(
            (r) => (
              draft: r.readTable(draftListings),
              item: r.readTable(scanItems),
            ),
          )
          .toList(growable: false);
    });
  }

  Stream<List<({DraftListing draft, ScanItem item})>> watchByHaulId({
    required String haulId,
    required String? userId,
  }) {
    final joinQuery =
        select(draftListings).join([
            innerJoin(
              scanItems,
              scanItems.id.equalsExp(draftListings.scanItemId),
            ),
          ])
          ..where(_userScope(scanItems, userId))
          ..where(scanItems.haulId.equals(haulId))
          ..orderBy([OrderingTerm.desc(draftListings.updatedAt)]);

    return joinQuery.watch().map((rows) {
      return rows
          .map(
            (r) => (
              draft: r.readTable(draftListings),
              item: r.readTable(scanItems),
            ),
          )
          .toList(growable: false);
    });
  }

  Future<DraftListing?> getByScanItemId(String scanItemId) {
    return (select(
      draftListings,
    )..where((t) => t.scanItemId.equals(scanItemId))).getSingleOrNull();
  }

  Future<void> upsert({
    required String scanItemId,
    String platform = 'tradera',
    String? title,
    String? description,
    double? askingPriceSek,
  }) async {
    await into(draftListings).insertOnConflictUpdate(
      DraftListingsCompanion(
        scanItemId: Value(scanItemId),
        platform: Value(platform),
        title: Value(title?.trim().isEmpty ?? true ? null : title!.trim()),
        description: Value(
          description?.trim().isEmpty ?? true ? null : description!.trim(),
        ),
        askingPriceSek: Value(askingPriceSek),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteByScanItemId(String scanItemId) {
    return (delete(
      draftListings,
    )..where((t) => t.scanItemId.equals(scanItemId))).go();
  }
}
