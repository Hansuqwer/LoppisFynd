import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/ai/model_manager.dart';

void main() {
  test('ModelManager installs and reports state', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
    addTearDown(() async => temp.delete(recursive: true));

    final source = File('${temp.path}/model.bin');
    await source.writeAsBytes(List<int>.filled(1024, 7), flush: true);

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'test.bin'),
      baseDirProvider: () async => temp,
    );

    await manager.deleteInstalled();
    final before = await manager.state();
    expect(before.installed, isFalse);

    await manager.installFromFile(source: source);
    final after = await manager.state();
    expect(after.installed, isTrue);
    expect(after.bytes, 1024);
    expect(after.file, isNotNull);
    expect(await after.file!.exists(), isTrue);
  });

  test('ModelManager downloadFromUrl reports progress and installs', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
    addTearDown(() async => temp.delete(recursive: true));

    final payload = List<int>.generate(2048, (i) => i % 251);

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = 200;
      request.response.contentLength = payload.length;

      const chunkSize = 256;
      for (var i = 0; i < payload.length; i += chunkSize) {
        final end = (i + chunkSize) > payload.length
            ? payload.length
            : (i + chunkSize);
        request.response.add(payload.sublist(i, end));
        await request.response.flush();
      }
      await request.response.close();
    });

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'download.bin'),
      baseDirProvider: () async => temp,
    );

    final receivedValues = <int>[];
    final totals = <int?>[];
    await manager.downloadFromUrl(
      url: Uri.parse('http://${server.address.host}:${server.port}/model'),
      onProgress: (received, total) {
        receivedValues.add(received);
        totals.add(total);
      },
    );

    expect(receivedValues, isNotEmpty);
    for (var i = 1; i < receivedValues.length; i++) {
      expect(receivedValues[i], greaterThanOrEqualTo(receivedValues[i - 1]));
    }
    expect(totals.whereType<int>().toSet(), {payload.length});
    expect(receivedValues.last, payload.length);

    final state = await manager.state();
    expect(state.installed, isTrue);
    expect(state.bytes, payload.length);
    expect(await state.file!.exists(), isTrue);
  });

  test('ModelManager downloadFromUrl resumes from existing partial', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
    addTearDown(() async => temp.delete(recursive: true));

    final payload = List<int>.generate(2048, (i) => i % 251);
    const resumeAt = 768;

    String? seenRange;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      seenRange = request.headers.value(HttpHeaders.rangeHeader);
      final range = seenRange;
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

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'resume.bin'),
      baseDirProvider: () async => temp,
    );
    await manager.deleteInstalled();

    final installed = await manager.modelFile();
    final partial = File('${installed.path}.partial');
    await partial.writeAsBytes(payload.sublist(0, resumeAt), flush: true);
    expect(await partial.length(), resumeAt);

    final receivedValues = <int>[];
    final totals = <int?>[];
    await manager.downloadFromUrl(
      url: Uri.parse('http://${server.address.host}:${server.port}/model'),
      onProgress: (received, total) {
        receivedValues.add(received);
        totals.add(total);
      },
    );

    expect(seenRange, 'bytes=$resumeAt-');
    expect(receivedValues, isNotEmpty);
    expect(receivedValues.first, resumeAt);
    for (var i = 1; i < receivedValues.length; i++) {
      expect(receivedValues[i], greaterThanOrEqualTo(receivedValues[i - 1]));
    }
    expect(totals.whereType<int>().toSet(), {payload.length});
    expect(receivedValues.last, payload.length);

    final state = await manager.state();
    expect(state.installed, isTrue);
    expect(state.bytes, payload.length);
    expect(await state.file!.readAsBytes(), payload);
    expect(await File('${installed.path}.partial').exists(), isFalse);
  });

  test(
    'ModelManager downloadFromUrl supports pause and resumes later',
    () async {
      final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
      addTearDown(() async => temp.delete(recursive: true));

      final payload = List<int>.generate(128 * 1024, (i) => i % 251);
      const pauseAt = 12 * 1024;

      final seenRanges = <String?>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async => server.close(force: true));
      server.listen((request) async {
        final range = request.headers.value(HttpHeaders.rangeHeader);
        seenRanges.add(range);

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

      final manager = ModelManager(
        spec: const ModelSpec(id: 'test', fileName: 'pause.bin'),
        baseDirProvider: () async => temp,
      );

      final installed = await manager.modelFile();
      await installed.writeAsBytes(List<int>.filled(123, 1), flush: true);
      final beforeBytes = await installed.readAsBytes();

      var paused = false;
      await expectLater(
        () => manager.downloadFromUrl(
          url: Uri.parse('http://${server.address.host}:${server.port}/model'),
          onProgress: (received, total) {
            if (total != null && received < total && received >= pauseAt) {
              paused = true;
            }
          },
          isPaused: () => paused,
        ),
        throwsA(isA<Exception>()),
      );

      expect(await installed.readAsBytes(), beforeBytes);
      final partial = File('${installed.path}.partial');
      expect(await partial.exists(), isTrue);
      final partialLen = await partial.length();
      expect(partialLen, greaterThan(0));
      expect(partialLen, lessThan(payload.length));

      paused = false;
      await manager.downloadFromUrl(
        url: Uri.parse('http://${server.address.host}:${server.port}/model'),
      );

      expect(
        seenRanges.whereType<String>().toList(),
        contains('bytes=$partialLen-'),
      );
      final state = await manager.state();
      expect(state.installed, isTrue);
      expect(state.bytes, payload.length);
      expect(await state.file!.readAsBytes(), payload);
      expect(await File('${installed.path}.partial').exists(), isFalse);
    },
  );

  test('ModelManager downloadFromUrl cleans up partial on error', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
    addTearDown(() async => temp.delete(recursive: true));

    // Bind then close to guarantee a refused connection on a known port.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close(force: true);

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'error.bin'),
      baseDirProvider: () async => temp,
    );

    final installed = await manager.modelFile();
    await installed.writeAsBytes(List<int>.filled(321, 3), flush: true);
    final beforeBytes = await installed.readAsBytes();

    final partial = File('${installed.path}.partial');
    await partial.writeAsBytes(List<int>.filled(12, 9), flush: true);
    expect(await partial.exists(), isTrue);

    await expectLater(
      () => manager.downloadFromUrl(
        url: Uri.parse(
          'http://${InternetAddress.loopbackIPv4.address}:$port/model',
        ),
      ),
      throwsA(isA<Exception>()),
    );

    expect(await installed.readAsBytes(), beforeBytes);
    expect(await partial.exists(), isFalse);
  });

  test(
    'ModelManager downloadFromUrl supports cancellation and cleans up',
    () async {
      final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
      addTearDown(() async => temp.delete(recursive: true));

      final payload = List<int>.filled(4096, 7);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async => server.close(force: true));
      server.listen((request) async {
        request.response.statusCode = 200;
        request.response.contentLength = payload.length;
        request.response.add(payload);
        await request.response.close();
      });

      final manager = ModelManager(
        spec: const ModelSpec(id: 'test', fileName: 'cancel.bin'),
        baseDirProvider: () async => temp,
      );

      final installed = await manager.modelFile();
      await installed.writeAsBytes(List<int>.filled(123, 1), flush: true);
      final beforeBytes = await installed.readAsBytes();
      expect(beforeBytes.length, 123);

      var cancelled = false;
      var progressEvents = 0;

      await expectLater(
        () => manager.downloadFromUrl(
          url: Uri.parse('http://${server.address.host}:${server.port}/model'),
          onProgress: (received, total) {
            progressEvents++;
            if (received > 0) {
              cancelled = true;
            }
          },
          isCancelled: () => cancelled,
        ),
        throwsA(isA<Exception>()),
      );

      expect(progressEvents, greaterThanOrEqualTo(1));
      expect(await installed.readAsBytes(), beforeBytes);
      expect(await File('${installed.path}.partial').exists(), isFalse);
    },
  );
}
