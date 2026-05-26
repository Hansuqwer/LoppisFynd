import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'ai_types.dart';

Future<InferenceModel> _getActiveModelForVision({
  required int maxTokens,
}) async {
  Future<InferenceModel> create(PreferredBackend? backend) {
    return FlutterGemma.getActiveModel(
      maxTokens: maxTokens,
      preferredBackend: backend,
      supportImage: true,
      maxNumImages: 1,
    );
  }

  // Vision models may require GPU backends (LiteRT-LM constraint mismatch
  // otherwise). Prefer GPU first, then fall back based on error text.
  try {
    return await create(PreferredBackend.gpu);
  } on PlatformException catch (e) {
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('requires one of [cpu]') &&
        msg.contains('backend is gpu')) {
      return await create(PreferredBackend.cpu);
    }
    if (msg.contains('requires one of [gpu]') &&
        msg.contains('backend is cpu')) {
      return await create(PreferredBackend.gpu);
    }
    rethrow;
  }
}

Future<void> installGemmaModel({required String modelPath}) async {
  await FlutterGemma.initialize();
  await FlutterGemma.installModel(
    modelType: ModelType.gemmaIt,
  ).fromFile(modelPath).install();
}

Future<String> inferJsonWithFlutterGemma({
  required RootIsolateToken? rootIsolateToken,
  required String? modelPath,
  required String prompt,
  required String imagePath,
  int? maxTokens,
}) async {
  if (rootIsolateToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }
  DartPluginRegistrant.ensureInitialized();

  if (modelPath == null || modelPath.trim().isEmpty) {
    throw const ModelNotInstalledException('Model path not configured');
  }

  final modelFile = File(modelPath);
  if (!await modelFile.exists()) {
    throw ModelNotInstalledException('Model not installed at: $modelPath');
  }

  // Note: ModelType selection is used by the plugin to choose runtime settings.
  // For now, we follow the plugin's documented Gemma install path.
  await installGemmaModel(modelPath: modelPath);

  final model = await _getActiveModelForVision(maxTokens: maxTokens ?? 1024);

  final Uint8List imageBytes = await File(imagePath).readAsBytes();
  final chat = await model.createChat();

  await chat.addQueryChunk(
    Message.withImage(text: prompt, imageBytes: imageBytes, isUser: true),
  );

  final response = await chat.generateChatResponse();
  if (response is TextResponse) {
    return response.token;
  }

  throw StateError(
    'Unexpected flutter_gemma response: ${response.runtimeType}',
  );
}
