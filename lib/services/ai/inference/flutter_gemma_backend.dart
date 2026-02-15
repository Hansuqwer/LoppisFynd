import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'ai_types.dart';

Future<String> inferJsonWithFlutterGemma({
  required RootIsolateToken? rootIsolateToken,
  required String? modelPath,
  required String prompt,
  required String imagePath,
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

  await FlutterGemma.initialize();

  // Note: ModelType selection is used by the plugin to choose runtime settings.
  // For now, we follow the plugin's documented Gemma install path.
  await FlutterGemma.installModel(
    modelType: ModelType.gemmaIt,
  ).fromFile(modelPath).install();

  final model = await FlutterGemma.getActiveModel(
    maxTokens: 1024,
    supportImage: true,
    maxNumImages: 1,
  );

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
