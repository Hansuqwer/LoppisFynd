import 'offline_detection_types.dart';

typedef OfflineLabelResolver = String Function(int classIndex);

/// Parse typical SSD/EfficientDet TFLite outputs into stable evidence.
///
/// Expected box order per detection: `[top, left, bottom, right]`.
List<OfflineDetection> parseDetections({
  required List<List<num>> boxes,
  required List<num> scores,
  required List<num> classes,
  required int count,
  required OfflineLabelResolver resolveLabel,
}) {
  if (count <= 0) return const <OfflineDetection>[];

  final n = _min4(count, boxes.length, scores.length, classes.length);
  if (n <= 0) return const <OfflineDetection>[];

  final out = <OfflineDetection>[];
  for (var i = 0; i < n; i++) {
    final score = _clamp01(scores[i].toDouble());
    if (score < kOfflineDetectionMinScore) continue;

    final rawBox = boxes[i];
    if (rawBox.length < 4) continue;

    final top = _clamp01(rawBox[0].toDouble());
    final left = _clamp01(rawBox[1].toDouble());
    final bottom = _clamp01(rawBox[2].toDouble());
    final right = _clamp01(rawBox[3].toDouble());

    final clampedLeft = left < right ? left : right;
    final clampedRight = left < right ? right : left;
    final clampedTop = top < bottom ? top : bottom;
    final clampedBottom = top < bottom ? bottom : top;

    final classIndex = classes[i].toInt();
    out.add(
      OfflineDetection(
        label: resolveLabel(classIndex),
        score: score,
        box: NormalizedRect(
          left: clampedLeft,
          top: clampedTop,
          right: clampedRight,
          bottom: clampedBottom,
        ),
      ),
    );
  }

  out.sort((a, b) => b.score.compareTo(a.score));
  return out;
}

int _min4(int a, int b, int c, int d) {
  var m = a;
  if (b < m) m = b;
  if (c < m) m = c;
  if (d < m) m = d;
  return m;
}

double _clamp01(double v) {
  if (v.isNaN) return 0;
  if (v < 0) return 0;
  if (v > 1) return 1;
  return v;
}
