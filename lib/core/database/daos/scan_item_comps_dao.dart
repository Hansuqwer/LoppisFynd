import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/scan_item_comps.dart';

part 'scan_item_comps_dao.g.dart';

@DriftAccessor(tables: [ScanItemComps])
class ScanItemCompsDao extends DatabaseAccessor<AppDatabase>
    with _$ScanItemCompsDaoMixin {
  ScanItemCompsDao(super.db);

  Future<ScanItemComp?> getByScanItemId(String scanItemId) {
    return (select(
      scanItemComps,
    )..where((t) => t.scanItemId.equals(scanItemId))).getSingleOrNull();
  }

  Stream<ScanItemComp?> watchByScanItemId(String scanItemId) {
    final q = select(scanItemComps)
      ..where((t) => t.scanItemId.equals(scanItemId));
    return q.watchSingleOrNull();
  }

  Future<void> upsert({
    required String scanItemId,
    required String rawJson,
    double? medianPrice,
    double? minPrice,
    double? maxPrice,
    int? demandScore,
    int? daysToSellEst,
    DateTime? fetchedAt,
  }) async {
    await into(scanItemComps).insertOnConflictUpdate(
      ScanItemCompsCompanion(
        scanItemId: Value(scanItemId),
        rawJson: Value(rawJson),
        medianPrice: Value(medianPrice),
        minPrice: Value(minPrice),
        maxPrice: Value(maxPrice),
        demandScore: Value(demandScore),
        daysToSellEst: Value(daysToSellEst),
        fetchedAt: fetchedAt == null ? const Value.absent() : Value(fetchedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clear(String scanItemId) async {
    await (delete(
      scanItemComps,
    )..where((t) => t.scanItemId.equals(scanItemId))).go();
  }
}
