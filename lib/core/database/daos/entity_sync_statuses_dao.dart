import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/entity_sync_statuses.dart';

part 'entity_sync_statuses_dao.g.dart';

@DriftAccessor(tables: [EntitySyncStatuses])
class EntitySyncStatusesDao extends DatabaseAccessor<AppDatabase>
    with _$EntitySyncStatusesDaoMixin {
  EntitySyncStatusesDao(super.db);

  Future<void> set({
    required String entityKey,
    required String status,
    String? lastError,
  }) async {
    await into(entitySyncStatuses).insertOnConflictUpdate(
      EntitySyncStatusesCompanion(
        entityKey: Value(entityKey),
        status: Value(status),
        lastError: Value(lastError),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<EntitySyncStatuse?> watchOne(String entityKey) {
    final q = select(entitySyncStatuses)
      ..where((t) => t.entityKey.equals(entityKey));
    return q.watchSingleOrNull();
  }

  Stream<Map<String, EntitySyncStatuse>> watchMany(Iterable<String> keys) {
    final list = keys.toList(growable: false);
    if (list.isEmpty) return Stream.value(const {});

    final q = select(entitySyncStatuses)..where((t) => t.entityKey.isIn(list));
    return q.watch().map((rows) {
      final out = <String, EntitySyncStatuse>{};
      for (final r in rows) {
        out[r.entityKey] = r;
      }
      return out;
    });
  }

  Stream<List<EntitySyncStatuse>> watchProblems() {
    final q = select(entitySyncStatuses)
      ..where((t) => t.status.isNotIn(['synced']))
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return q.watch();
  }

  Future<int> deleteByKeys(Iterable<String> keys) {
    final list = keys.toList(growable: false);
    if (list.isEmpty) return Future.value(0);
    return (delete(
      entitySyncStatuses,
    )..where((t) => t.entityKey.isIn(list))).go();
  }
}
