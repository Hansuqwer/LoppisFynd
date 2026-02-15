import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/ai/inference/ai_pipeline.dart';
import 'package:fynd_loppis/services/ai/inference/ai_types.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';

void main() {
  test('AiPipeline extracts JSON from noisy output', () {
    final pipeline = AiPipeline();
    const output =
        'Here you go!\n'
        '{"desc":"Vas","query":"glasvas","confidence":0.9,'
        '"attributes":{"brand":"","model":"","material":"glass","era":""}}'
        '\nThanks.';

    final result = pipeline.process(
      task: const SingleItemTask(),
      modelOutput: output,
    );
    expect(result, isA<SingleItemInferenceResult>());
  });

  test('AiPipeline gates low confidence', () {
    final pipeline = AiPipeline();
    const output =
        '{"desc":"Ok","query":"ok","confidence":0.1,'
        '"attributes":{"brand":"","model":"","material":"","era":""}}';

    expect(
      () => pipeline.process(task: const SingleItemTask(), modelOutput: output),
      throwsA(isA<AiConfidenceTooLowException>()),
    );
  });
}
