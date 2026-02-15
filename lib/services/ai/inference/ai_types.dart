import 'dart:io';

sealed class AiTask {
  const AiTask();
}

class SingleItemTask extends AiTask {
  const SingleItemTask();
}

class BatchShelfTask extends AiTask {
  const BatchShelfTask();
}

class AiInferenceRequest {
  const AiInferenceRequest({required this.task, required this.imageFile});

  final AiTask task;
  final File imageFile;
}

class AiSingleItemResult {
  const AiSingleItemResult({
    required this.desc,
    required this.query,
    required this.confidence,
    required this.attributes,
    required this.rawJson,
  });

  final String desc;
  final String query;
  final double confidence;
  final Map<String, String> attributes;
  final String rawJson;
}

class AiBatchItem {
  const AiBatchItem({
    required this.desc,
    required this.query,
    required this.confidence,
  });

  final String desc;
  final String query;
  final double confidence;
}

class AiBatchShelfResult {
  const AiBatchShelfResult({required this.items, required this.rawJson});

  final List<AiBatchItem> items;
  final String rawJson;
}

class ModelNotInstalledException implements Exception {
  const ModelNotInstalledException(this.message);

  final String message;

  @override
  String toString() => 'ModelNotInstalledException: $message';
}

class AiJsonValidationException implements Exception {
  const AiJsonValidationException(this.message);

  final String message;

  @override
  String toString() => 'AiJsonValidationException: $message';
}

class AiConfidenceTooLowException implements Exception {
  const AiConfidenceTooLowException(this.message);

  final String message;

  @override
  String toString() => 'AiConfidenceTooLowException: $message';
}
