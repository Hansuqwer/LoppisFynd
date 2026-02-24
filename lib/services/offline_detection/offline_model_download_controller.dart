import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../ai/model_manager.dart';
import 'offline_model_catalog.dart';

sealed class OfflineModelDownloadState {
  const OfflineModelDownloadState();
}

class OfflineModelIdle extends OfflineModelDownloadState {
  const OfflineModelIdle();
}

class OfflineModelDownloading extends OfflineModelDownloadState {
  const OfflineModelDownloading({required this.received, required this.total});

  final int received;
  final int? total;
}

class OfflineModelPaused extends OfflineModelDownloadState {
  const OfflineModelPaused({required this.received, required this.total});

  final int received;
  final int? total;
}

class OfflineModelInstalled extends OfflineModelDownloadState {
  const OfflineModelInstalled({required this.bytes});

  final int bytes;
}

class OfflineModelFailed extends OfflineModelDownloadState {
  const OfflineModelFailed(this.message);

  final String message;
}

class OfflineModelDownloadController {
  OfflineModelDownloadController({
    OfflineModelSpec? spec,
    Future<Directory> Function()? baseDirProvider,
  }) : spec = spec ?? kOfflineDetectionModel,
       _manager = ModelManager(
         spec: ModelSpec(
           id: (spec ?? kOfflineDetectionModel).id,
           fileName: (spec ?? kOfflineDetectionModel).fileName,
         ),
         baseDirProvider: baseDirProvider,
       );

  final OfflineModelSpec spec;
  final ModelManager _manager;

  final ValueNotifier<OfflineModelDownloadState> state = ValueNotifier(
    const OfflineModelIdle(),
  );

  bool _pauseRequested = false;
  bool _cancelRequested = false;
  bool _running = false;

  Future<ModelInstallState> currentInstallState() => _manager.state();

  Future<void> startOrResume() async {
    if (_running) return;
    _running = true;

    _pauseRequested = false;
    _cancelRequested = false;

    int lastReceived = 0;
    int? lastTotal;

    try {
      final install = await _manager.state();
      if (install.installed) {
        state.value = OfflineModelInstalled(bytes: install.bytes ?? 0);
        return;
      }

      if (spec.expectedBytes > kOfflineModelMaxBytes) {
        state.value = OfflineModelFailed(
          'Model is too large (${spec.sizeLabel}). Maximum is 10 MiB.',
        );
        return;
      }

      state.value = const OfflineModelDownloading(received: 0, total: null);
      await _manager.downloadFromUrl(
        url: spec.url,
        isCancelled: () => _cancelRequested,
        isPaused: () => _pauseRequested,
        onProgress: (received, total) {
          lastReceived = received;
          lastTotal = total;

          if (total != null && total > kOfflineModelMaxBytes) {
            throw const _OfflineModelTooLargeException();
          }

          state.value = OfflineModelDownloading(
            received: received,
            total: total,
          );
        },
      );

      if (_cancelRequested) {
        state.value = const OfflineModelIdle();
        return;
      }

      if (_pauseRequested) {
        state.value = OfflineModelPaused(
          received: lastReceived,
          total: lastTotal,
        );
        return;
      }

      final file = await _manager.modelFile();
      final bytes = await file.length();
      if (spec.sha256Hex != null) {
        final digest = await sha256.bind(file.openRead()).first;
        final actual = digest.toString().toLowerCase();
        final expected = spec.sha256Hex!.toLowerCase();
        if (actual != expected) {
          await _manager.deleteInstalled();
          state.value = OfflineModelFailed(
            'Downloaded model hash mismatch (expected $expected, got $actual).',
          );
          return;
        }
      }

      state.value = OfflineModelInstalled(bytes: bytes);
    } on _OfflineModelTooLargeException {
      await _bestEffortDeletePartial();
      state.value = const OfflineModelFailed(
        'Model exceeds the 10 MiB budget.',
      );
    } catch (e) {
      if (_cancelRequested) {
        state.value = const OfflineModelIdle();
      } else if (_pauseRequested) {
        state.value = OfflineModelPaused(
          received: lastReceived,
          total: lastTotal,
        );
      } else {
        state.value = OfflineModelFailed('$e');
      }
    } finally {
      _running = false;
    }
  }

  void pause() {
    _pauseRequested = true;

    final s = state.value;
    if (s is OfflineModelDownloading) {
      state.value = OfflineModelPaused(received: s.received, total: s.total);
    }
  }

  Future<void> cancel() async {
    _cancelRequested = true;
    _pauseRequested = false;
    await _bestEffortDeletePartial();
    state.value = const OfflineModelIdle();
  }

  void dispose() {
    state.dispose();
  }

  Future<void> _bestEffortDeletePartial() async {
    try {
      final file = await _manager.modelFile();
      final partial = File('${file.path}.partial');
      if (await partial.exists()) {
        await partial.delete();
      }
    } catch (_) {
      // Best effort.
    }
  }
}

class _OfflineModelTooLargeException implements Exception {
  const _OfflineModelTooLargeException();

  @override
  String toString() => 'Offline model too large';
}
