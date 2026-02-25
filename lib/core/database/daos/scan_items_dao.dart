import 'package:drift/drift.dart';

import '../app_database.dart';
import '../scan_item_state_machine.dart';
import '../tables/scan_items.dart';
import '../../text/keyword_query_sanitizer.dart';
import '../../../services/sync/cloud/entity_keys.dart';

part 'scan_items_dao.g.dart';

@DriftAccessor(tables: [ScanItems])
class ScanItemsDao extends DatabaseAccessor<AppDatabase>
    with _$ScanItemsDaoMixin {
  ScanItemsDao(super.db);

  Future<void> _markDirty(String id) {
    return attachedDatabase.pendingCloudSyncEntitiesDao.markDirty(
      entityKey: scanItemEntityKey(id),
      entityType: 'scan_item',
    );
  }

  Expression<bool> _userScope(ScanItems t, String? userId) {
    return userId == null ? t.userId.isNull() : t.userId.equals(userId);
  }

  Stream<List<ScanItem>> watchAll({String? userId}) {
    final query = select(scanItems)
      ..where((t) => _userScope(t, userId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<List<ScanItem>> watchByHaulId(String haulId, {String? userId}) {
    final query = select(scanItems)
      ..where((t) => t.haulId.equals(haulId))
      ..where((t) => _userScope(t, userId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<List<ScanItem>> listAll({String? userId}) {
    final query = select(scanItems)
      ..where((t) => _userScope(t, userId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<List<ScanItem>> listByIds(Iterable<String> ids, {String? userId}) {
    final list = ids.toList(growable: false);
    if (list.isEmpty) return Future.value(const []);
    final query = select(scanItems)
      ..where((t) => _userScope(t, userId))
      ..where((t) => t.id.isIn(list));
    return query.get();
  }

  Future<ScanItem?> getById(String id, {String? userId}) {
    final query = select(scanItems)..where((t) => t.id.equals(id));
    query.where((t) => _userScope(t, userId));
    return query.getSingleOrNull();
  }

  Stream<ScanItem?> watchById(String id, {String? userId}) {
    final query = select(scanItems)..where((t) => t.id.equals(id));
    query.where((t) => _userScope(t, userId));
    return query.watchSingleOrNull();
  }

  Future<void> insertNew({
    required String id,
    required String haulId,
    String? userId,
    required String imagePath,
    required String thumbPath,
    ScanItemStatus? status,
  }) async {
    await into(scanItems).insert(
      ScanItemsCompanion.insert(
        id: id,
        userId: userId == null ? const Value.absent() : Value(userId),
        haulId: haulId,
        imagePath: Value(imagePath),
        thumbPath: Value(thumbPath),
        status: status == null ? const Value.absent() : Value(status),
      ),
    );
    await _markDirty(id);
    await attachedDatabase.pendingCloudSyncEntitiesDao.markDirty(
      entityKey: scanPhotoEntityKey(id),
      entityType: 'scan_photo',
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
    await _markDirty(id);
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
    await _markDirty(id);
    await attachedDatabase.pendingCloudSyncEntitiesDao.markDirty(
      entityKey: scanPhotoEntityKey(id),
      entityType: 'scan_photo',
    );
  }

  Future<void> setAiResult({
    required String id,
    required String? aiJson,
    required String? query,
    required String? desc,
    required double? confidence,
  }) async {
    final sanitizedQuery = sanitizeKeywordQuery(query);
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        aiJson: Value(aiJson),
        query: Value(sanitizedQuery),
        desc: Value(desc),
        confidence: Value(confidence),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> setOfflineDetections({
    required String id,
    required String? detectionsJson,
    required DateTime? fetchedAt,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        offlineDetectionsJson: Value(detectionsJson),
        offlineDetectionsFetchedAt: Value(fetchedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
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
    await _markDirty(id);
    await attachedDatabase.pendingCloudSyncEntitiesDao.markDirty(
      entityKey: scanPhotoEntityKey(id),
      entityType: 'scan_photo',
    );
  }

  Future<List<ScanItem>> listPendingMarketSync({
    String? userId,
    int limit = 25,
  }) {
    final query = select(scanItems)
      ..where((t) => t.status.equals(ScanItemStatus.pendingSync.name))
      ..where((t) => t.query.isNotNull())
      ..where((t) => _userScope(t, userId))
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
    await _markDirty(id);
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
    await _markDirty(id);
  }

  Future<void> setFees({
    required String id,
    required double? fixedFeesSek,
    required double? shippingPaidBySellerSek,
  }) async {
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        fixedFeesSek: Value(fixedFeesSek),
        shippingPaidBySellerSek: Value(shippingPaidBySellerSek),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
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
    await _markDirty(id);
  }

  Future<void> setQuery({required String id, required String? query}) async {
    final sanitizedQuery = sanitizeKeywordQuery(query);
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        query: Value(sanitizedQuery),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> setNotes({required String id, required String? notes}) async {
    final trimmed = notes?.trim();
    await (update(scanItems)..where((t) => t.id.equals(id))).write(
      ScanItemsCompanion(
        notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _markDirty(id);
  }

  Future<void> setCategory({required String id, required String? category}) {
    final trimmed = category?.trim();
    return (update(scanItems)..where((t) => t.id.equals(id)))
        .write(
          ScanItemsCompanion(
            category: Value(
              trimmed == null || trimmed.isEmpty ? null : trimmed,
            ),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((_) => _markDirty(id));
  }

  Future<int> queueReadyToSyncInHaul({required String haulId, String? userId}) {
    return (update(scanItems)
          ..where((t) => t.haulId.equals(haulId))
          ..where((t) => _userScope(t, userId))
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
        )
        .then((count) async {
          final rows =
              await (select(scanItems)
                    ..where((t) => t.haulId.equals(haulId))
                    ..where((t) => _userScope(t, userId)))
                  .get();
          for (final it in rows) {
            await _markDirty(it.id);
          }
          return count;
        });
  }

  Future<int> claimGuestDataForUser(String userId) {
    return (update(scanItems)..where((t) => t.userId.isNull())).write(
      ScanItemsCompanion(
        userId: Value(userId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertFromCloud({
    required String id,
    required String userId,
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
    final sanitizedQuery = sanitizeKeywordQuery(query);
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
        userId: Value(userId),
        haulId: Value(haulId),
        imagePath: existing?.imagePath == null
            ? const Value.absent()
            : Value(existing!.imagePath),
        thumbPath: existing?.thumbPath == null
            ? const Value.absent()
            : Value(existing!.thumbPath),
        aiJson: Value(aiJson),
        query: Value(sanitizedQuery),
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

  Future<int> deleteAllForUser({required String? userId}) {
    return (delete(scanItems)..where((t) => _userScope(t, userId))).go();
  }

  Future<int> deleteById({required String id, String? userId}) {
    final stmt = delete(scanItems)..where((t) => t.id.equals(id));
    stmt.where((t) => _userScope(t, userId));
    return stmt.go();
  }
}
