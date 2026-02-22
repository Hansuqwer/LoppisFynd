import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../cloud_ai_proxy_client.dart';
import '../image_cropper.dart';

import '../../../core/utils/serial_task_queue.dart';
import 'ai_prompts.dart';
import 'ai_types.dart';
import 'ai_pipeline.dart';

sealed class AiInferenceResult {
  const AiInferenceResult();
}

class SingleItemInferenceResult extends AiInferenceResult {
  const SingleItemInferenceResult(this.value);
  final AiSingleItemResult value;
}

class BatchShelfInferenceResult extends AiInferenceResult {
  const BatchShelfInferenceResult(this.value);
  final AiBatchShelfResult value;
}

enum AiBackendKind { notImplemented, cloudGemini }

class AiInferenceIsolateService {
  AiInferenceIsolateService({
    AiBackendKind backendKind = AiBackendKind.notImplemented,
    AiPipeline pipeline = const AiPipeline(),
    String? modelPath,
    Uri? cloudAiProxyUrl,
    CloudAiProxyClient? cloudClient,
    ImageCropper? imageCropper,
    RootIsolateToken? rootIsolateToken,
  }) : _backendKind = backendKind,
       _pipeline = pipeline,
       _modelPath = modelPath,
       _cloudClient = cloudClient,
       _cloudAiProxyUrl = cloudAiProxyUrl,
       _imageCropper = imageCropper ?? const ImageCropper(),
       _rootIsolateToken = rootIsolateToken ?? ServicesBinding.rootIsolateToken;

  final String? _modelPath;
  final RootIsolateToken? _rootIsolateToken;

  final AiBackendKind _backendKind;
  final AiPipeline _pipeline;

  final Uri? _cloudAiProxyUrl;
  final CloudAiProxyClient? _cloudClient;
  final ImageCropper _imageCropper;

  final _queue = SerialTaskQueue();

  Future<AiInferenceResult> run(
    AiInferenceRequest request, {
    AiCancelToken? cancelToken,
  }) async {
    return _queue.add(() async {
      final prompt = switch (request.task) {
        SingleItemTask() => AiPrompts.singleItemJsonPrompt(),
        BatchShelfTask() => AiPrompts.batchShelfJsonPrompt(),
      };

      if (_backendKind == AiBackendKind.cloudGemini) {
        final token = cancelToken;
        if (token?.isCancelled ?? false) {
          throw const AiCancelledException();
        }

        final url = _cloudAiProxyUrl;
        if (url == null || url.toString().trim().isEmpty) {
          throw const ModelNotInstalledException(
            'Cloud AI proxy not configured. Provide CLOUD_AI_PROXY_URL.',
          );
        }

        final client = _cloudClient ?? CloudAiProxyClient(functionUrl: url);

        final cropBytes = await _imageCropper.centerSquareJpegFromFile(
          request.imageFile,
        );

        if (token?.isCancelled ?? false) {
          throw const AiCancelledException();
        }

        String rawText;
        try {
          rawText = await client.generate(
            prompt: prompt,
            imageJpegBytes: cropBytes,
            maxTokens: request.maxTokens,
            cancel: token?.cancelled,
          );
        } catch (_) {
          if (token?.isCancelled ?? false) {
            throw const AiCancelledException();
          }
          rethrow;
        }

        if (token?.isCancelled ?? false) {
          throw const AiCancelledException();
        }

        return _pipeline.process(task: request.task, modelOutput: rawText);
      }

      final resultRaw = await _runInIsolate(
        _backendKind,
        _rootIsolateToken,
        _modelPath,
        prompt,
        request.imageFile.path,
        request.maxTokens,
        cancelToken,
      );

      return _pipeline.process(task: request.task, modelOutput: resultRaw);
    });
  }

  Future<void> warmUp() {
    return _queue.add(() async {
      await _warmUpIsolate(_rootIsolateToken);
    });
  }
}

Future<void> _warmUpIsolate(RootIsolateToken? rootIsolateToken) async {
  final ready = Completer<void>();
  final receivePort = ReceivePort();

  late final Isolate isolate;

  receivePort.listen((message) {
    if (message == true) {
      ready.complete();
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
    }
  });

  isolate = await Isolate.spawn(
    _warmUpIsolateEntry,
    _WarmUpArgs(
      sendPort: receivePort.sendPort,
      rootIsolateToken: rootIsolateToken,
    ),
  );

  return ready.future;
}

class _WarmUpArgs {
  const _WarmUpArgs({required this.sendPort, required this.rootIsolateToken});
  final SendPort sendPort;
  final RootIsolateToken? rootIsolateToken;
}

Future<void> _warmUpIsolateEntry(_WarmUpArgs args) async {
  try {
    if (args.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(
        args.rootIsolateToken!,
      );
    }
    DartPluginRegistrant.ensureInitialized();
  } finally {
    args.sendPort.send(true);
  }
}

Future<String> _runInIsolate(
  AiBackendKind backendKind,
  RootIsolateToken? rootIsolateToken,
  String? modelPath,
  String prompt,
  String imagePath,
  int? maxTokens,
  AiCancelToken? cancelToken,
) async {
  final token = cancelToken;
  if (token?.isCancelled ?? false) {
    throw const AiCancelledException();
  }

  final ready = Completer<String>();
  final receivePort = ReceivePort();

  Isolate? isolate;

  var cancelled = false;
  token?.cancelled.then((_) {
    cancelled = true;
    if (ready.isCompleted) return;
    receivePort.close();
    isolate?.kill(priority: Isolate.immediate);
    ready.completeError(const AiCancelledException());
  });

  receivePort.listen((message) {
    if (message is _IsolateResult) {
      if (message.error != null) {
        ready.completeError(message.error!, message.stackTrace);
      } else {
        ready.complete(message.value!);
      }
      receivePort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  });

  isolate = await Isolate.spawn(
    _isolateEntry,
    _IsolateArgs(
      sendPort: receivePort.sendPort,
      backendKind: backendKind,
      rootIsolateToken: rootIsolateToken,
      modelPath: modelPath,
      prompt: prompt,
      imagePath: imagePath,
      maxTokens: maxTokens,
    ),
  );

  if (cancelled && !ready.isCompleted) {
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
    ready.completeError(const AiCancelledException());
  }

  return ready.future;
}

class _IsolateArgs {
  const _IsolateArgs({
    required this.sendPort,
    required this.backendKind,
    required this.rootIsolateToken,
    required this.modelPath,
    required this.prompt,
    required this.imagePath,
    required this.maxTokens,
  });

  final SendPort sendPort;
  final AiBackendKind backendKind;
  final RootIsolateToken? rootIsolateToken;
  final String? modelPath;
  final String prompt;
  final String imagePath;
  final int? maxTokens;
}

class _IsolateResult {
  const _IsolateResult({this.value, this.error, this.stackTrace});

  final String? value;
  final Object? error;
  final StackTrace? stackTrace;
}

Future<void> _isolateEntry(_IsolateArgs args) async {
  try {
    final raw = await _infer(
      backendKind: args.backendKind,
      rootIsolateToken: args.rootIsolateToken,
      modelPath: args.modelPath,
      prompt: args.prompt,
      imagePath: args.imagePath,
      maxTokens: args.maxTokens,
    );
    args.sendPort.send(_IsolateResult(value: raw));
  } catch (e, st) {
    args.sendPort.send(_IsolateResult(error: e, stackTrace: st));
  }
}

Future<String> _infer({
  required AiBackendKind backendKind,
  required RootIsolateToken? rootIsolateToken,
  required String? modelPath,
  required String prompt,
  required String imagePath,
  required int? maxTokens,
}) async {
  switch (backendKind) {
    case AiBackendKind.notImplemented:
      throw const ModelNotInstalledException(
        'AI backend not wired yet. Install model + add runtime in FL-031.',
      );
    case AiBackendKind.cloudGemini:
      throw const ModelNotInstalledException(
        'Cloud AI cannot run in isolate. Use cloudGemini via run() path.',
      );
  }
}
