import 'dart:io';
import 'dart:async';

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
  const AiInferenceRequest({
    required this.task,
    required this.imageFile,
    this.maxTokens,
  });

  final AiTask task;
  final File imageFile;
  final int? maxTokens;
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

class AiCancelToken {
  bool _cancelled = false;
  final _completer = Completer<void>();

  bool get isCancelled => _cancelled;
  Future<void> get cancelled => _completer.future;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _completer.complete();
  }
}

class AiCancelledException implements Exception {
  const AiCancelledException();
  @override
  String toString() => 'AiCancelledException';
}
