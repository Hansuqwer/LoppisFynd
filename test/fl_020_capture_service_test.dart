import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/database/tables/scan_items.dart';
import 'package:fynd_loppis/core/settings/app_settings_keys.dart';
import 'package:fynd_loppis/core/storage/scan_image_storage.dart';
import 'package:fynd_loppis/features/scanner/scan_capture_service.dart';
import 'package:fynd_loppis/services/ai/cloud_ai_proxy_client.dart';
import 'package:fynd_loppis/services/ai/inference/ai_types.dart';
import 'package:fynd_loppis/services/analytics/analytics_service.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';

class _FakeAiInferenceIsolateService extends AiInferenceIsolateService {
  int runCount = 0;

  @override
  Future<AiInferenceResult> run(
    AiInferenceRequest request, {
    AiCancelToken? cancelToken,
  }) async {
    runCount++;
    return const SingleItemInferenceResult(
      AiSingleItemResult(
        desc: 'Test item',
        query: 'test query',
        confidence: 0.9,
        attributes: {},
        rawJson: '{"desc":"Test item"}',
      ),
    );
  }
}

class _ThrowingAiInferenceIsolateService extends AiInferenceIsolateService {
  _ThrowingAiInferenceIsolateService(this.error);

  final Object error;

  @override
  Future<AiInferenceResult> run(
    AiInferenceRequest request, {
    AiCancelToken? cancelToken,
  }) async {
    throw error;
  }
}

const _configProxyConfigured = AppConfig(
  appEnv: 'test',
  traderaProxyUrl: '',
  cloudAiProxyUrl: 'https://example.invalid/cloud',
  supabaseUrl: '',
  supabaseAnonKey: '',
  sentryDsn: '',
);

const _configProxyNotConfigured = AppConfig(
  appEnv: 'test',
  traderaProxyUrl: '',
  cloudAiProxyUrl: '',
  supabaseUrl: '',
  supabaseAnonKey: '',
  sentryDsn: '',
);

Future<File> _createSourceJpg(Directory root) async {
  final sourceImage = img.Image(width: 640, height: 480);
  img.fill(sourceImage, color: img.ColorRgb8(232, 228, 222));
  final sourceFile = File('${root.path}/source.jpg');
  await sourceFile.writeAsBytes(img.encodeJpg(sourceImage), flush: true);
  return sourceFile;
}

void main() {
  test('ScanCaptureService stores image + inserts ScanItem', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
    final storage = ScanImageStorage(rootDir: root);
    final ai = _FakeAiInferenceIsolateService();
    final service = ScanCaptureService(
      config: _configProxyNotConfigured,
      db: db,
      imageStorage: storage,
      aiInference: ai,
      analytics: const NoopAnalyticsService(),
      isOnline: () async => true,
    );

    final sourceFile = await _createSourceJpg(root);

    final captured = await service.persistCapturedImage(
      haulId: 'haul-1',
      userId: null,
      sourceImage: sourceFile,
      scanId: 'scan-1',
    );

    expect(captured.id, 'scan-1');

    final scan = await db.scanItemsDao.getById('scan-1');
    expect(scan, isNotNull);
    expect(File(scan!.imagePath!).existsSync(), isTrue);
    expect(File(scan.thumbPath!).existsSync(), isTrue);

    await captured.backgroundWork;
    expect(ai.runCount, 0);

    final scanAfterThumb = await db.scanItemsDao.getById('scan-1');
    expect(scanAfterThumb, isNotNull);
    expect(scanAfterThumb!.thumbPath, isNot(scanAfterThumb.imagePath));
    expect(File(scanAfterThumb.thumbPath!).existsSync(), isTrue);
  });

  test('ScanCaptureService requests sync after save and AI result', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
    await db.appSettingsDao.setInt(kPrivacyCloudIdentificationEnabledKeyV1, 1);
    await db.appSettingsDao.setInt(
      kCloudIdentificationDisclosureChoiceKeyV1,
      1,
    );

    final storage = ScanImageStorage(rootDir: root);
    final ai = _FakeAiInferenceIsolateService();
    var syncRequests = 0;
    final service = ScanCaptureService(
      config: _configProxyConfigured,
      db: db,
      imageStorage: storage,
      aiInference: ai,
      analytics: const NoopAnalyticsService(),
      isOnline: () async => true,
      requestSync: () async {
        syncRequests += 1;
      },
    );

    final sourceFile = await _createSourceJpg(root);
    final captured = await service.persistCapturedImage(
      haulId: 'haul-1',
      userId: null,
      sourceImage: sourceFile,
      scanId: 'scan-1',
    );

    await captured.backgroundWork;

    expect(ai.runCount, 1);
    expect(syncRequests, 2);

    final item = await db.scanItemsDao.getById('scan-1');
    expect(item, isNotNull);
    expect(item!.status, ScanItemStatus.pendingSync);
  });

  test(
    'Background inference skips when disclosure choice is not accepted',
    () async {
      final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
      addTearDown(() async => root.delete(recursive: true));

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
      await db.appSettingsDao.setInt(
        kPrivacyCloudIdentificationEnabledKeyV1,
        1,
      );
      await db.appSettingsDao.setInt(
        kCloudIdentificationDisclosureChoiceKeyV1,
        2,
      );

      final storage = ScanImageStorage(rootDir: root);
      final ai = _FakeAiInferenceIsolateService();
      final service = ScanCaptureService(
        config: _configProxyConfigured,
        db: db,
        imageStorage: storage,
        aiInference: ai,
        analytics: const NoopAnalyticsService(),
        isOnline: () async => true,
      );

      final sourceFile = await _createSourceJpg(root);
      final captured = await service.persistCapturedImage(
        haulId: 'haul-1',
        userId: null,
        sourceImage: sourceFile,
        scanId: 'scan-1',
      );

      await captured.backgroundWork;
      expect(ai.runCount, 0);
    },
  );

  test('Background inference skips when cloud toggle is off', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
    await db.appSettingsDao.setInt(kPrivacyCloudIdentificationEnabledKeyV1, 0);
    await db.appSettingsDao.setInt(
      kCloudIdentificationDisclosureChoiceKeyV1,
      1,
    );

    final storage = ScanImageStorage(rootDir: root);
    final ai = _FakeAiInferenceIsolateService();
    final service = ScanCaptureService(
      config: _configProxyConfigured,
      db: db,
      imageStorage: storage,
      aiInference: ai,
      analytics: const NoopAnalyticsService(),
      isOnline: () async => true,
    );

    final sourceFile = await _createSourceJpg(root);
    final captured = await service.persistCapturedImage(
      haulId: 'haul-1',
      userId: null,
      sourceImage: sourceFile,
      scanId: 'scan-1',
    );

    await captured.backgroundWork;
    expect(ai.runCount, 0);
  });

  test(
    'Background inference runs when disclosure accepted + toggle on + proxy configured + online',
    () async {
      final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
      addTearDown(() async => root.delete(recursive: true));

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
      await db.appSettingsDao.setInt(
        kPrivacyCloudIdentificationEnabledKeyV1,
        1,
      );
      await db.appSettingsDao.setInt(
        kCloudIdentificationDisclosureChoiceKeyV1,
        1,
      );

      final storage = ScanImageStorage(rootDir: root);
      final ai = _FakeAiInferenceIsolateService();
      final service = ScanCaptureService(
        config: _configProxyConfigured,
        db: db,
        imageStorage: storage,
        aiInference: ai,
        analytics: const NoopAnalyticsService(),
        isOnline: () async => true,
      );

      final sourceFile = await _createSourceJpg(root);
      final captured = await service.persistCapturedImage(
        haulId: 'haul-1',
        userId: null,
        sourceImage: sourceFile,
        scanId: 'scan-1',
      );

      await captured.backgroundWork;
      expect(ai.runCount, 1);
    },
  );

  test('Background inference treats unknown connectivity as offline', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
    await db.appSettingsDao.setInt(kPrivacyCloudIdentificationEnabledKeyV1, 1);
    await db.appSettingsDao.setInt(
      kCloudIdentificationDisclosureChoiceKeyV1,
      1,
    );

    final storage = ScanImageStorage(rootDir: root);
    final ai = _FakeAiInferenceIsolateService();
    final service = ScanCaptureService(
      config: _configProxyConfigured,
      db: db,
      imageStorage: storage,
      aiInference: ai,
      analytics: const NoopAnalyticsService(),
      isOnline: () async {
        throw StateError('connectivity unknown');
      },
    );

    final sourceFile = await _createSourceJpg(root);
    final captured = await service.persistCapturedImage(
      haulId: 'haul-1',
      userId: null,
      sourceImage: sourceFile,
      scanId: 'scan-1',
    );

    await captured.backgroundWork;
    expect(ai.runCount, 0);
  });

  test(
    'Background inference skips when cloud proxy is not configured',
    () async {
      final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
      addTearDown(() async => root.delete(recursive: true));

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
      await db.appSettingsDao.setInt(
        kPrivacyCloudIdentificationEnabledKeyV1,
        1,
      );
      await db.appSettingsDao.setInt(
        kCloudIdentificationDisclosureChoiceKeyV1,
        1,
      );

      final storage = ScanImageStorage(rootDir: root);
      final ai = _FakeAiInferenceIsolateService();
      final service = ScanCaptureService(
        config: _configProxyNotConfigured,
        db: db,
        imageStorage: storage,
        aiInference: ai,
        analytics: const NoopAnalyticsService(),
        isOnline: () async => true,
      );

      final sourceFile = await _createSourceJpg(root);
      final captured = await service.persistCapturedImage(
        haulId: 'haul-1',
        userId: null,
        sourceImage: sourceFile,
        scanId: 'scan-1',
      );

      await captured.backgroundWork;
      expect(ai.runCount, 0);
    },
  );

  test('Cloud proxy failure keeps saved item available locally', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Test haul');
    await db.appSettingsDao.setInt(kPrivacyCloudIdentificationEnabledKeyV1, 1);
    await db.appSettingsDao.setInt(
      kCloudIdentificationDisclosureChoiceKeyV1,
      1,
    );

    final storage = ScanImageStorage(rootDir: root);
    final ai = _ThrowingAiInferenceIsolateService(
      const CloudAiProxyException('proxy unavailable'),
    );
    final service = ScanCaptureService(
      config: _configProxyConfigured,
      db: db,
      imageStorage: storage,
      aiInference: ai,
      analytics: const NoopAnalyticsService(),
      isOnline: () async => true,
    );

    final sourceFile = await _createSourceJpg(root);
    final captured = await service.persistCapturedImage(
      haulId: 'haul-1',
      userId: null,
      sourceImage: sourceFile,
      scanId: 'scan-1',
    );

    await captured.backgroundWork;

    final item = await db.scanItemsDao.getById('scan-1');
    expect(item, isNotNull);
    expect(item!.status, ScanItemStatus.pendingIdentify);
    expect(item.query, isNull);
  });
}
