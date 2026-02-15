import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/storage/scan_image_storage.dart';
import 'package:fynd_loppis/features/scanner/scan_capture_service.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';

void main() {
  test('ScanCaptureService stores image + inserts ScanItem', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
    final storage = ScanImageStorage(rootDir: root);
    final service = ScanCaptureService(
      db: db,
      imageStorage: storage,
      aiInference: AiInferenceIsolateService(),
    );

    final sourceImage = img.Image(width: 640, height: 480);
    img.fill(sourceImage, color: img.ColorRgb8(232, 228, 222));
    final sourceFile = File('${root.path}/source.jpg');
    await sourceFile.writeAsBytes(img.encodeJpg(sourceImage), flush: true);

    final captured = await service.persistCapturedImage(
      haulId: 'haul-1',
      sourceImage: sourceFile,
      scanId: 'scan-1',
    );

    expect(captured.id, 'scan-1');

    final scan = await db.scanItemsDao.getById('scan-1');
    expect(scan, isNotNull);
    expect(File(scan!.imagePath!).existsSync(), isTrue);
    expect(File(scan.thumbPath!).existsSync(), isTrue);

    await captured.backgroundWork;
    final scanAfterThumb = await db.scanItemsDao.getById('scan-1');
    expect(scanAfterThumb, isNotNull);
    expect(scanAfterThumb!.thumbPath, isNot(scanAfterThumb.imagePath));
    expect(File(scanAfterThumb.thumbPath!).existsSync(), isTrue);
  });
}
