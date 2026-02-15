import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/hauls.dart';

part 'hauls_dao.g.dart';

@DriftAccessor(tables: [Hauls])
class HaulsDao extends DatabaseAccessor<AppDatabase> with _$HaulsDaoMixin {
  HaulsDao(super.db);

  Stream<List<Haul>> watchAll() {
    final query = select(hauls)
      ..orderBy([
        (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<List<Haul>> listAll() {
    final query = select(hauls)
      ..orderBy([
        (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<Haul?> getById(String id) {
    return (select(hauls)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert({required String id, required String title}) async {
    await into(hauls).insertOnConflictUpdate(
      HaulsCompanion(
        id: Value(id),
        title: Value(title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> insertNew({
    required String id,
    required String title,
    double? lat,
    double? lng,
  }) async {
    await into(hauls).insert(
      HaulsCompanion.insert(
        id: id,
        title: title,
        lat: lat == null ? const Value.absent() : Value(lat),
        lng: lng == null ? const Value.absent() : Value(lng),
        updatedAt: Value(DateTime.now()),
      ),
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
  }

  Future<void> upsertFromCloud({
    required String id,
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
}
