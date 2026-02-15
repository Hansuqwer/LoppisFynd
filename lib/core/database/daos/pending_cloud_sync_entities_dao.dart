import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pending_cloud_sync_entities.dart';

part 'pending_cloud_sync_entities_dao.g.dart';

@DriftAccessor(tables: [PendingCloudSyncEntities])
class PendingCloudSyncEntitiesDao extends DatabaseAccessor<AppDatabase>
    with _$PendingCloudSyncEntitiesDaoMixin {
  PendingCloudSyncEntitiesDao(super.db);

  Future<void> markDirty({
    required String entityKey,
    required String entityType,
  }) {
    return into(pendingCloudSyncEntities).insertOnConflictUpdate(
      PendingCloudSyncEntitiesCompanion(
        entityKey: Value(entityKey),
        entityType: Value(entityType),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<PendingCloudSyncEntity>> listAll() {
    return (select(pendingCloudSyncEntities)..orderBy([
          (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.asc),
        ]))
        .get();
  }

  Future<List<PendingCloudSyncEntity>> listByType(String entityType) {
    return (select(pendingCloudSyncEntities)
          ..where((t) => t.entityType.equals(entityType))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<int> deleteByKeys(Iterable<String> keys) {
    final list = keys.toList(growable: false);
    if (list.isEmpty) return Future.value(0);
    return (delete(
      pendingCloudSyncEntities,
    )..where((t) => t.entityKey.isIn(list))).go();
  }
}
