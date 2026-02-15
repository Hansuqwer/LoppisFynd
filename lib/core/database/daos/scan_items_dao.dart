import 'package:drift/drift.dart';

import '../app_database.dart';
import '../scan_item_state_machine.dart';
import '../tables/scan_items.dart';

part 'scan_items_dao.g.dart';

@DriftAccessor(tables: [ScanItems])
class ScanItemsDao extends DatabaseAccessor<AppDatabase>
    with _$ScanItemsDaoMixin {
  ScanItemsDao(super.db);

  Stream<List<ScanItem>> watchAll() {
    final query = select(scanItems)
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<List<ScanItem>> watchByHaulId(String haulId) {
    final query = select(scanItems)
      ..where((t) => t.haulId.equals(haulId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<List<ScanItem>> listAll() {
    final query = select(scanItems)
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<ScanItem?> getById(String id) {
    return (select(scanItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<ScanItem?> watchById(String id) {
    return (select(
      scanItems,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertNew({
    required String id,
    required String haulId,
    required String imagePath,
    required String thumbPath,
    ScanItemStatus? status,
  }) async {
    await into(scanItems).insert(
      ScanItemsCompanion.insert(
        id: id,
        haulId: haulId,
        imagePath: Value(imagePath),
        thumbPath: Value(thumbPath),
        status: status == null ? const Value.absent() : Value(status),
      ),
    );
  }

  Future<void> setStatus({
    required String id,
    required ScanItemStatus status,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> transitionStatus({
    required String id,
    required ScanItemStatus to,
  }) async {
    final current = await getById(id);
    if (current == null) return;

    if (!ScanItemStateMachine.canTransition(from: current.status, to: to)) {
      throw StateError(
        'Invalid ScanItemStatus transition: ${current.status.name} -> ${to.name}',
      );
    }

    await setStatus(id: id, status: to);
  }

  Future<void> setThumbPath({
    required String id,
    required String thumbPath,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        thumbPath: Value(thumbPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setAiResult({
    required String id,
    required String? aiJson,
    required String? query,
    required String? desc,
    required double? confidence,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        aiJson: Value(aiJson),
        query: Value(query),
        desc: Value(desc),
        confidence: Value(confidence),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setImagePaths({
    required String id,
    required String? imagePath,
    required String? thumbPath,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        imagePath: Value(imagePath),
        thumbPath: Value(thumbPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ScanItem>> listPendingMarketSync({int limit = 25}) {
    final query = select(scanItems)
      ..where((t) => t.status.equals(ScanItemStatus.pendingSync.name))
      ..where((t) => t.query.isNotNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.asc),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<void> setMarketStats({
    required String id,
    required double medianPrice,
    required double minPrice,
    required double maxPrice,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        medianPrice: Value(medianPrice),
        minPrice: Value(minPrice),
        maxPrice: Value(maxPrice),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setPurchasePrice({
    required String id,
    required double? purchasePrice,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        purchasePrice: Value(purchasePrice),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setConditionMultiplier({
    required String id,
    required double conditionMultiplier,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        conditionMultiplier: Value(conditionMultiplier),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setQuery({required String id, required String? query}) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(query: Value(query), updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> queueReadyToSyncInHaul({required String haulId}) {
    return (update(scanItems)
          ..where((t) => t.haulId.equals(haulId))
          ..where(
            (t) =>
                t.status.equals(ScanItemStatus.pendingIdentify.name) |
                t.status.equals(ScanItemStatus.failed.name),
          )
          ..where(
            (t) => t.query.isNotNull() & t.query.length.isBiggerThanValue(0),
          ))
        .write(
          ScanItemsCompanion(
            status: const Value(ScanItemStatus.pendingSync),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> upsertFromCloud({
    required String id,
    required String haulId,
    required String? aiJson,
    required String? query,
    required String? desc,
    required double? confidence,
    required double? purchasePrice,
    required double? conditionMultiplier,
    required double? medianPrice,
    required double? minPrice,
    required double? maxPrice,
    required int? demandScore,
    required int? daysToSellEst,
    required String? status,
    required DateTime updatedAt,
  }) async {
    ScanItemStatus? parsedStatus;
    if (status != null) {
      for (final s in ScanItemStatus.values) {
        if (s.name == status) {
          parsedStatus = s;
          break;
        }
      }
    }

    final existing = await getById(id);

    await into(scanItems).insertOnConflictUpdate(
      ScanItemsCompanion(
        id: Value(id),
        haulId: Value(haulId),
        imagePath: existing?.imagePath == null
            ? const Value.absent()
            : Value(existing!.imagePath),
        thumbPath: existing?.thumbPath == null
            ? const Value.absent()
            : Value(existing!.thumbPath),
        aiJson: Value(aiJson),
        query: Value(query),
        desc: Value(desc),
        confidence: Value(confidence),
        purchasePrice: Value(purchasePrice),
        conditionMultiplier: conditionMultiplier == null
            ? const Value.absent()
            : Value(conditionMultiplier),
        medianPrice: Value(medianPrice),
        minPrice: Value(minPrice),
        maxPrice: Value(maxPrice),
        demandScore: Value(demandScore),
        daysToSellEst: Value(daysToSellEst),
        status: parsedStatus == null
            ? const Value.absent()
            : Value(parsedStatus),
        updatedAt: Value(updatedAt),
      ),
    );
  }
}
