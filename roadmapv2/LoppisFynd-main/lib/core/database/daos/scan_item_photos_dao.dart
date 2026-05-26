import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/scan_item_photos.dart';

part 'scan_item_photos_dao.g.dart';

@DriftAccessor(tables: [ScanItemPhotos])
class ScanItemPhotosDao extends DatabaseAccessor<AppDatabase>
    with _$ScanItemPhotosDaoMixin {
  ScanItemPhotosDao(super.db);

  Stream<List<ScanItemPhoto>> watchByScanItemId(String scanItemId) {
    final q = select(scanItemPhotos)
      ..where((t) => t.scanItemId.equals(scanItemId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
      ]);
    return q.watch();
  }

  Future<void> insertNew({
    required String id,
    required String scanItemId,
    required String localPath,
    String? thumbPath,
  }) async {
    await into(scanItemPhotos).insert(
      ScanItemPhotosCompanion.insert(
        id: id,
        scanItemId: scanItemId,
        localPath: localPath,
        thumbPath: thumbPath == null ? const Value.absent() : Value(thumbPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setThumbPath({required String id, required String thumbPath}) {
    return (update(scanItemPhotos)..where((t) => t.id.equals(id))).write(
      ScanItemPhotosCompanion(
        thumbPath: Value(thumbPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ScanItemPhoto>> listAll() {
    return select(scanItemPhotos).get();
  }

  Future<List<ScanItemPhoto>> listByScanItemIds(Iterable<String> scanItemIds) {
    final ids = scanItemIds.toList(growable: false);
    if (ids.isEmpty) return Future.value(const []);
    return (select(scanItemPhotos)
          ..where((t) => t.scanItemId.isIn(ids))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }
}
