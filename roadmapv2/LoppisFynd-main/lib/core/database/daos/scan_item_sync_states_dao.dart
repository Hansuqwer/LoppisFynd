import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/scan_item_sync_states.dart';

part 'scan_item_sync_states_dao.g.dart';

@DriftAccessor(tables: [ScanItemSyncStates])
class ScanItemSyncStatesDao extends DatabaseAccessor<AppDatabase>
    with _$ScanItemSyncStatesDaoMixin {
  ScanItemSyncStatesDao(super.db);

  Future<ScanItemSyncState?> getByScanItemId(String scanItemId) {
    return (select(
      scanItemSyncStates,
    )..where((t) => t.scanItemId.equals(scanItemId))).getSingleOrNull();
  }

  Future<void> upsert({
    required String scanItemId,
    required int attempts,
    required DateTime? nextAttemptAt,
    required String? lastError,
  }) async {
    await into(scanItemSyncStates).insertOnConflictUpdate(
      ScanItemSyncStatesCompanion(
        scanItemId: Value(scanItemId),
        attempts: Value(attempts),
        nextAttemptAt: Value(nextAttemptAt),
        lastError: Value(lastError),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clear(String scanItemId) async {
    await (delete(
      scanItemSyncStates,
    )..where((t) => t.scanItemId.equals(scanItemId))).go();
  }
}
