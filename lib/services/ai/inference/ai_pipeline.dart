import 'ai_confidence_gate.dart';
import 'ai_json_extractor.dart';
import 'ai_json_parser.dart';
import 'ai_types.dart';
import 'inference_isolate_service.dart';

class AiPipeline {
  const AiPipeline({AiConfidenceGate gate = const AiConfidenceGate()})
    : _gate = gate;

  final AiConfidenceGate _gate;

  AiInferenceResult process({
    required AiTask task,
    required String modelOutput,
  }) {
    final json = AiJsonExtractor.extractFirstJsonObject(modelOutput);

    return switch (task) {
      SingleItemTask() => _processSingle(json),
      BatchShelfTask() => _processBatch(json),
    };
  }

  SingleItemInferenceResult _processSingle(String rawJson) {
    final parsed = AiJsonParser.parseSingleItem(rawJson);
    _gate.assertSingleItem(parsed.confidence);
    return SingleItemInferenceResult(parsed);
  }

  BatchShelfInferenceResult _processBatch(String rawJson) {
    final parsed = AiJsonParser.parseBatchShelf(rawJson);
    for (final item in parsed.items) {
      _gate.assertBatchItem(item.confidence);
    }
    return BatchShelfInferenceResult(parsed);
  }
}
