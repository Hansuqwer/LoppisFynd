import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/offline_detection/offline_detection_types.dart';
import 'package:fynd_loppis/services/offline_detection/offline_detector_parser.dart';

void main() {
  test('parseDetections filters below threshold and sorts by score', () {
    final detections = parseDetections(
      boxes: const [
        [0.0, 0.0, 1.0, 1.0],
        [0.1, 0.1, 0.5, 0.5],
        [0.2, 0.2, 0.4, 0.4],
      ],
      scores: const [0.9, 0.2, 0.6],
      classes: const [1, 2, 3],
      count: 3,
      resolveLabel: (i) => 'c$i',
    );

    expect(detections.length, 2);
    expect(detections[0].label, 'c1');
    expect(detections[0].score, 0.9);
    expect(detections[1].label, 'c3');
    expect(detections[1].score, 0.6);

    // Ensure the hard cutoff constant is enforced.
    expect(kOfflineDetectionMinScore, greaterThan(0));
    expect(
      detections.every((d) => d.score >= kOfflineDetectionMinScore),
      isTrue,
    );
  });

  test('parseDetections clamps and orders normalized box coordinates', () {
    final detections = parseDetections(
      boxes: const [
        // [top,left,bottom,right] with out-of-range + swapped coords.
        [1.2, -0.4, -0.1, 0.8],
      ],
      scores: const [0.99],
      classes: const [7],
      count: 1,
      resolveLabel: (i) => 'c$i',
    );

    expect(detections, hasLength(1));
    final box = detections.single.box;
    expect(box.left, inInclusiveRange(0, 1));
    expect(box.top, inInclusiveRange(0, 1));
    expect(box.right, inInclusiveRange(0, 1));
    expect(box.bottom, inInclusiveRange(0, 1));
    expect(box.left, lessThanOrEqualTo(box.right));
    expect(box.top, lessThanOrEqualTo(box.bottom));
  });
}
