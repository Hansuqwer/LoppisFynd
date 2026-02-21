import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_quotas.dart';

part 'sync_quotas_dao.g.dart';

@DriftAccessor(tables: [SyncQuotas])
class SyncQuotasDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQuotasDaoMixin {
  SyncQuotasDao(super.db);

  Future<int> getUsed(String dayKey) async {
    final row = await (select(
      syncQuotas,
    )..where((t) => t.dayKey.equals(dayKey))).getSingleOrNull();
    return row?.used ?? 0;
  }

  Future<void> incrementUsed(String dayKey, int by) async {
    final now = DateTime.now();
    await customInsert(
      'INSERT INTO sync_quotas (day_key, used, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(day_key) DO UPDATE SET '
      'used = used + excluded.used, '
      'updated_at = excluded.updated_at',
      variables: [
        Variable<String>(dayKey),
        Variable<int>(by),
        Variable<DateTime>(now),
      ],
      updates: {syncQuotas},
    );
  }
}
