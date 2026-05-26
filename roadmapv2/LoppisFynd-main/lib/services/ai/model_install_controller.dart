import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/database/daos/app_settings_dao.dart';
import 'inference/flutter_gemma_backend.dart';
import 'model_manager.dart';

const String kGemmaConsentKeyV1 = 'gemma_consent_v1';

sealed class ModelInstallControllerState {
  const ModelInstallControllerState();

  const factory ModelInstallControllerState.idle() =
      ModelInstallControllerStateIdle;
  const factory ModelInstallControllerState.notConsented() =
      ModelInstallControllerStateNotConsented;
  const factory ModelInstallControllerState.downloading({
    required int received,
    required int? total,
  }) = ModelInstallControllerStateDownloading;
  const factory ModelInstallControllerState.installing() =
      ModelInstallControllerStateInstalling;
  const factory ModelInstallControllerState.ready() =
      ModelInstallControllerStateReady;
  const factory ModelInstallControllerState.failed({required String error}) =
      ModelInstallControllerStateFailed;
}

class ModelInstallControllerStateIdle extends ModelInstallControllerState {
  const ModelInstallControllerStateIdle();
}

class ModelInstallControllerStateNotConsented
    extends ModelInstallControllerState {
  const ModelInstallControllerStateNotConsented();
}

class ModelInstallControllerStateDownloading
    extends ModelInstallControllerState {
  const ModelInstallControllerStateDownloading({
    required this.received,
    required this.total,
  });

  final int received;
  final int? total;

  double get progress {
    final total = this.total;
    if (total == null || total <= 0) return 0.0;
    return (received / total).clamp(0.0, 1.0);
  }

  int? get percent {
    final total = this.total;
    if (total == null || total <= 0) return null;
    return (progress * 100).toInt();
  }
}

class ModelInstallControllerStateInstalling
    extends ModelInstallControllerState {
  const ModelInstallControllerStateInstalling();
}

class ModelInstallControllerStateReady extends ModelInstallControllerState {
  const ModelInstallControllerStateReady();
}

class ModelInstallControllerStateFailed extends ModelInstallControllerState {
  const ModelInstallControllerStateFailed({required this.error});

  final String error;
}

class ModelInstallController
    extends StateNotifier<ModelInstallControllerState> {
  ModelInstallController({
    required AppSettingsDao settingsDao,
    required AppConfig config,
    required ModelManager modelManager,
  }) : _settingsDao = settingsDao,
       _config = config,
       _modelManager = modelManager,
       super(const ModelInstallControllerState.idle());

  final AppSettingsDao _settingsDao;
  final AppConfig _config;
  final ModelManager _modelManager;

  var _gemmaInstalledThisSession = false;
  var _lastProgressUpdateMs = 0;
  var _lastProgressFraction = 0.0;

  Future<void> startIfNeeded({bool force = false}) async {
    if (state is ModelInstallControllerStateDownloading) return;
    if (state is ModelInstallControllerStateInstalling) return;

    if (!_config.hasGemmaModelUrl) {
      state = const ModelInstallControllerState.idle();
      return;
    }

    // Hard-check persisted consent before any download.
    final consent = await _settingsDao.getInt(kGemmaConsentKeyV1) ?? 0;
    if (consent != 1) {
      state = const ModelInstallControllerState.notConsented();
      return;
    }

    final current = await _modelManager.state();
    if (current.installed && _gemmaInstalledThisSession && !force) {
      state = const ModelInstallControllerState.ready();
      return;
    }

    try {
      if (current.installed && !force) {
        state = const ModelInstallControllerState.installing();
        final file = current.file ?? await _modelManager.modelFile();
        await installGemmaModel(modelPath: file.path);
        _gemmaInstalledThisSession = true;
        state = const ModelInstallControllerState.ready();
        return;
      }

      await _downloadAndInstall(url: Uri.parse(_config.gemmaModelUrl));
    } catch (e) {
      state = ModelInstallControllerState.failed(error: e.toString());
    }
  }

  Future<void> retry() => startIfNeeded(force: true);

  Future<void> _downloadAndInstall({required Uri url}) async {
    state = const ModelInstallControllerState.downloading(
      received: 0,
      total: null,
    );

    _lastProgressUpdateMs = 0;
    _lastProgressFraction = 0.0;

    await _modelManager.downloadFromUrl(
      url: url,
      onProgress: (received, total) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final shouldUpdateTime = now - _lastProgressUpdateMs > 120;

        var shouldUpdatePercent = false;
        if (total != null && total > 0) {
          final fraction = (received / total).clamp(0.0, 1.0);
          shouldUpdatePercent =
              (fraction - _lastProgressFraction).abs() >= 0.01;
          if (shouldUpdatePercent) {
            _lastProgressFraction = fraction;
          }
        }

        if (!shouldUpdateTime && !shouldUpdatePercent) return;
        _lastProgressUpdateMs = now;
        state = ModelInstallControllerState.downloading(
          received: received,
          total: total,
        );
      },
    );

    final downloaded = await _modelManager.modelFile();
    state = const ModelInstallControllerState.installing();
    await installGemmaModel(modelPath: downloaded.path);
    _gemmaInstalledThisSession = true;
    state = const ModelInstallControllerState.ready();
  }
}
