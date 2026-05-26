import 'ai_types.dart';

class AiConfidenceGate {
  const AiConfidenceGate({this.minSingleItem = 0.55, this.minBatchItem = 0.50});

  final double minSingleItem;
  final double minBatchItem;

  void assertSingleItem(double confidence) {
    if (confidence < minSingleItem) {
      throw AiConfidenceTooLowException(
        'confidence $confidence < minSingleItem $minSingleItem',
      );
    }
  }

  void assertBatchItem(double confidence) {
    if (confidence < minBatchItem) {
      throw AiConfidenceTooLowException(
        'confidence $confidence < minBatchItem $minBatchItem',
      );
    }
  }
}
