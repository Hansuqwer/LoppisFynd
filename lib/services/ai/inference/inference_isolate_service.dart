import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'ai_prompts.dart';
import 'ai_types.dart';
import 'ai_pipeline.dart';
import 'flutter_gemma_backend.dart';

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

enum AiBackendKind { notImplemented, flutterGemma }

class AiInferenceIsolateService {
  AiInferenceIsolateService({
    AiBackendKind backendKind = AiBackendKind.notImplemented,
    AiPipeline pipeline = const AiPipeline(),
    String? modelPath,
    RootIsolateToken? rootIsolateToken,
  }) : _backendKind = backendKind,
       _pipeline = pipeline,
       _modelPath = modelPath,
       _rootIsolateToken = rootIsolateToken ?? ServicesBinding.rootIsolateToken;

  final String? _modelPath;
  final RootIsolateToken? _rootIsolateToken;

  final AiBackendKind _backendKind;
  final AiPipeline _pipeline;

  Future<AiInferenceResult> run(AiInferenceRequest request) async {
    final prompt = switch (request.task) {
      SingleItemTask() => AiPrompts.singleItemJsonPrompt(),
      BatchShelfTask() => AiPrompts.batchShelfJsonPrompt(),
    };

    final resultRaw = await _runInIsolate(
      _backendKind,
      _rootIsolateToken,
      _modelPath,
      prompt,
      request.imageFile.path,
    );

    return _pipeline.process(task: request.task, modelOutput: resultRaw);
  }
}

Future<String> _runInIsolate(
  AiBackendKind backendKind,
  RootIsolateToken? rootIsolateToken,
  String? modelPath,
  String prompt,
  String imagePath,
) async {
  final ready = Completer<String>();
  final receivePort = ReceivePort();

  late final Isolate isolate;

  receivePort.listen((message) {
    if (message is _IsolateResult) {
      if (message.error != null) {
        ready.completeError(message.error!, message.stackTrace);
      } else {
        ready.complete(message.value!);
      }
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
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
    ),
  );

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
  });

  final SendPort sendPort;
  final AiBackendKind backendKind;
  final RootIsolateToken? rootIsolateToken;
  final String? modelPath;
  final String prompt;
  final String imagePath;
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
}) async {
  switch (backendKind) {
    case AiBackendKind.notImplemented:
      throw const ModelNotInstalledException(
        'AI backend not wired yet. Install model + add runtime in FL-031.',
      );
    case AiBackendKind.flutterGemma:
      return inferJsonWithFlutterGemma(
        rootIsolateToken: rootIsolateToken,
        modelPath: modelPath,
        prompt: prompt,
        imagePath: imagePath,
      );
  }
}
