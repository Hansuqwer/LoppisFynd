import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/ai/model_manager.dart';
import 'package:fynd_loppis/services/offline_detection/offline_model_download_controller.dart';
import 'package:fynd_loppis/services/offline_detection/offline_model_catalog.dart';

void main() {
  test('controller start -> progress -> installed', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_offline_dl_');
    addTearDown(() async => temp.delete(recursive: true));

    final payload = List<int>.generate(64 * 1024, (i) => i % 251);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      final range = request.headers.value(HttpHeaders.rangeHeader);
      final match = range == null
          ? null
          : RegExp(r'^bytes=(\d+)-$').firstMatch(range);
      if (match != null) {
        final start = int.parse(match.group(1)!);
        final end = payload.length - 1;

        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${payload.length}',
        );
        request.response.contentLength = payload.length - start;
        request.response.add(payload.sublist(start));
        await request.response.close();
        return;
      }

      request.response.statusCode = 200;
      request.response.contentLength = payload.length;
      request.response.add(payload);
      await request.response.close();
    });

    final digest = sha256.convert(payload).toString();

    final spec = OfflineModelSpec(
      id: 'test',
      displayName: 'Test',
      version: 'v1',
      fileName: 'test_offline.tflite',
      url: Uri.parse('http://${server.address.host}:${server.port}/model'),
      expectedBytes: payload.length,
      sha256Hex: digest,
      licenseSummary: 'Test',
      weightsSourceUrl: Uri.parse('https://example.com/weights'),
      weightsLicenseSourceUrl: Uri.parse('https://example.com/license'),
      weightsLicenseFullText: 'Apache 2.0',
      runtimeLicenseSourceUrl: Uri.parse('https://example.com/runtime'),
      runtimeLicenseFullText: 'Apache 2.0',
      datasetAttributionSourceUrl: Uri.parse('https://example.com/dataset'),
      datasetAttributionFullText: 'CC BY 4.0',
    );

    final controller = OfflineModelDownloadController(
      spec: spec,
      baseDirProvider: () async => temp,
    );

    var sawDownloading = false;
    void onState() {
      if (controller.state.value is OfflineModelDownloading) {
        sawDownloading = true;
      }
    }

    controller.state.addListener(onState);
    await controller.startOrResume();
    controller.state.removeListener(onState);

    // Depending on timing, we may only observe the final state here.
    expect(controller.state.value, isA<OfflineModelInstalled>());
    expect(
      (controller.state.value as OfflineModelInstalled).bytes,
      payload.length,
    );

    // Ensure file exists and matches.
    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'test_offline.tflite'),
      baseDirProvider: () async => temp,
    );
    final file = (await manager.state()).file!;
    expect(await file.readAsBytes(), payload);
    expect(sawDownloading, isTrue);
  });

  test('controller pause keeps partial and resume completes', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_offline_dl_');
    addTearDown(() async => temp.delete(recursive: true));

    final payload = List<int>.generate(128 * 1024, (i) => i % 251);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      final range = request.headers.value(HttpHeaders.rangeHeader);
      final match = range == null
          ? null
          : RegExp(r'^bytes=(\d+)-$').firstMatch(range);
      if (match != null) {
        final start = int.parse(match.group(1)!);
        final end = payload.length - 1;

        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${payload.length}',
        );
        request.response.contentLength = payload.length - start;
        request.response.add(payload.sublist(start));
        await request.response.close();
        return;
      }

      request.response.statusCode = 200;
      request.response.contentLength = payload.length;

      const chunkSize = 1024;
      try {
        for (var i = 0; i < payload.length; i += chunkSize) {
          final end = (i + chunkSize) > payload.length
              ? payload.length
              : (i + chunkSize);
          request.response.add(payload.sublist(i, end));
          await request.response.flush();
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }
      } catch (_) {
        // Client may abort early on pause.
      } finally {
        try {
          await request.response.close();
        } catch (_) {
          // Best effort.
        }
      }
    });

    final digest = sha256.convert(payload).toString();
    final spec = OfflineModelSpec(
      id: 'test',
      displayName: 'Test',
      version: 'v1',
      fileName: 'test_pause.tflite',
      url: Uri.parse('http://${server.address.host}:${server.port}/model'),
      expectedBytes: payload.length,
      sha256Hex: digest,
      licenseSummary: 'Test',
      weightsSourceUrl: Uri.parse('https://example.com/weights'),
      weightsLicenseSourceUrl: Uri.parse('https://example.com/license'),
      weightsLicenseFullText: 'Apache 2.0',
      runtimeLicenseSourceUrl: Uri.parse('https://example.com/runtime'),
      runtimeLicenseFullText: 'Apache 2.0',
      datasetAttributionSourceUrl: Uri.parse('https://example.com/dataset'),
      datasetAttributionFullText: 'CC BY 4.0',
    );

    final controller = OfflineModelDownloadController(
      spec: spec,
      baseDirProvider: () async => temp,
    );

    var pauseTriggered = false;
    void onState() {
      final s = controller.state.value;
      if (pauseTriggered) return;
      if (s is OfflineModelDownloading && s.received >= 12 * 1024) {
        pauseTriggered = true;
        controller.pause();
      }
    }

    controller.state.addListener(onState);
    await controller.startOrResume();
    controller.state.removeListener(onState);
    expect(pauseTriggered, isTrue);
    expect(controller.state.value, isA<OfflineModelPaused>());

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'test_pause.tflite'),
      baseDirProvider: () async => temp,
    );
    final installed = await manager.modelFile();
    final partial = File('${installed.path}.partial');
    expect(await partial.exists(), isTrue);

    // Resume completes.
    await controller.startOrResume();
    expect(controller.state.value, isA<OfflineModelInstalled>());
    final file = (await manager.state()).file!;
    expect(await file.readAsBytes(), payload);
    expect(await partial.exists(), isFalse);
  });

  test('controller cancel deletes partial', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_offline_dl_');
    addTearDown(() async => temp.delete(recursive: true));

    final payload = List<int>.generate(128 * 1024, (i) => i % 251);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = 200;
      request.response.contentLength = payload.length;

      const chunkSize = 1024;
      try {
        for (var i = 0; i < payload.length; i += chunkSize) {
          final end = (i + chunkSize) > payload.length
              ? payload.length
              : (i + chunkSize);
          request.response.add(payload.sublist(i, end));
          await request.response.flush();
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }
      } catch (_) {
        // Client may abort early on cancel.
      } finally {
        try {
          await request.response.close();
        } catch (_) {
          // Best effort.
        }
      }
    });

    final spec = OfflineModelSpec(
      id: 'test',
      displayName: 'Test',
      version: 'v1',
      fileName: 'test_cancel.tflite',
      url: Uri.parse('http://${server.address.host}:${server.port}/model'),
      expectedBytes: payload.length,
      sha256Hex: null,
      licenseSummary: 'Test',
      weightsSourceUrl: Uri.parse('https://example.com/weights'),
      weightsLicenseSourceUrl: Uri.parse('https://example.com/license'),
      weightsLicenseFullText: 'Apache 2.0',
      runtimeLicenseSourceUrl: Uri.parse('https://example.com/runtime'),
      runtimeLicenseFullText: 'Apache 2.0',
      datasetAttributionSourceUrl: Uri.parse('https://example.com/dataset'),
      datasetAttributionFullText: 'CC BY 4.0',
    );

    final controller = OfflineModelDownloadController(
      spec: spec,
      baseDirProvider: () async => temp,
    );

    // Kick off download and cancel shortly after.
    final future = controller.startOrResume();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await controller.cancel();
    await future;

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'test_cancel.tflite'),
      baseDirProvider: () async => temp,
    );
    final installed = await manager.modelFile();
    final partial = File('${installed.path}.partial');
    expect(await partial.exists(), isFalse);
    expect(controller.state.value, isA<OfflineModelIdle>());
  });
}
