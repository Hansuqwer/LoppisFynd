import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/hauls.dart';
import '../../../services/sync/cloud/entity_keys.dart';

part 'hauls_dao.g.dart';

@DriftAccessor(tables: [Hauls])
class HaulsDao extends DatabaseAccessor<AppDatabase> with _$HaulsDaoMixin {
  HaulsDao(super.db);

  Future<void> _markDirty(String id) {
    return attachedDatabase.pendingCloudSyncEntitiesDao.markDirty(
      entityKey: haulEntityKey(id),
      entityType: 'haul',
    );
  }

  Stream<List<Haul>> watchAll({String? userId}) {
    final query = select(hauls)
      ..where(
        (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<List<Haul>> listAll({String? userId}) {
    final query = select(hauls)
      ..where(
        (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<List<Haul>> listByIds(Iterable<String> ids, {String? userId}) {
    final list = ids.toList(growable: false);
    if (list.isEmpty) return Future.value(const []);
    final query = select(hauls)
      ..where(
        (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
      )
      ..where((t) => t.id.isIn(list));
    return query.get();
  }

  Future<Haul?> getById(String id, {String? userId}) {
    final query = select(hauls)..where((t) => t.id.equals(id));
    query.where(
      (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
    );
    return query.getSingleOrNull();
  }

  Stream<Haul?> watchById(String id, {String? userId}) {
    final query = select(hauls)..where((t) => t.id.equals(id));
    query.where(
      (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
    );
    return query.watchSingleOrNull();
  }

  Future<void> upsert({
    required String id,
    required String title,
    String? userId,
  }) async {
    await into(hauls).insertOnConflictUpdate(
      HaulsCompanion(
        id: Value(id),
        userId: Value(userId),
        title: Value(title),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> insertNew({
    required String id,
    required String title,
    String? userId,
    double? lat,
    double? lng,
  }) async {
    await into(hauls).insert(
      HaulsCompanion.insert(
        id: id,
        userId: userId == null ? const Value.absent() : Value(userId),
        title: title,
        lat: lat == null ? const Value.absent() : Value(lat),
        lng: lng == null ? const Value.absent() : Value(lng),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> ensureCurrentHaul({
    required String id,
    required String title,
    required String? userId,
  }) async {
    final existing = await (select(
      hauls,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing != null) return;
    await insertNew(id: id, title: title, userId: userId);
  }

  Future<int> claimGuestDataForUser(String userId) {
    return (update(hauls)..where((t) => t.userId.isNull())).write(
      HaulsCompanion(userId: Value(userId), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setLocation({
    required String id,
    required double? lat,
    required double? lng,
  }) async {
    await (update(hauls)..where((t) => t.id.equals(id))).write(
      HaulsCompanion(
        lat: Value(lat),
        lng: Value(lng),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> updateDetails({
    required String id,
    required String? userId,
    required String title,
    required DateTime startedAt,
    required DateTime? endedAt,
    required double? lat,
    required double? lng,
  }) async {
    final nextTitle = title.trim();
    if (nextTitle.isEmpty) return;

    final q = update(hauls)
      ..where((t) => t.id.equals(id))
      ..where(
        (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
      );
    await q.write(
      HaulsCompanion(
        title: Value(nextTitle),
        startedAt: Value(startedAt),
        endedAt: Value(endedAt),
        lat: Value(lat),
        lng: Value(lng),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> upsertFromCloud({
    required String id,
    required String userId,
    required String title,
    required DateTime startedAt,
    required DateTime? endedAt,
    required double? lat,
    required double? lng,
    required double? totalInvested,
    required double? grossValue,
    required double? netProfit,
    required double? co2SavedKg,
    required DateTime updatedAt,
  }) async {
    await into(hauls).insertOnConflictUpdate(
      HaulsCompanion(
        id: Value(id),
        userId: Value(userId),
        title: Value(title),
        startedAt: Value(startedAt),
        endedAt: Value(endedAt),
        lat: Value(lat),
        lng: Value(lng),
        totalInvested: Value(totalInvested),
        grossValue: Value(grossValue),
        netProfit: Value(netProfit),
        co2SavedKg: Value(co2SavedKg),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<int> deleteById(String id) {
    return (delete(hauls)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllForUser({required String? userId}) {
    return (delete(hauls)..where(
          (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
        ))
        .go();
  }
}
