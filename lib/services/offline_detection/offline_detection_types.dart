import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class NormalizedRect {
  const NormalizedRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Left coordinate, normalized to 0..1.
  final double left;

  /// Top coordinate, normalized to 0..1.
  final double top;

  /// Right coordinate, normalized to 0..1.
  final double right;

  /// Bottom coordinate, normalized to 0..1.
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  NormalizedRect clamp01() {
    return NormalizedRect(
      left: _clamp01(left),
      top: _clamp01(top),
      right: _clamp01(right),
      bottom: _clamp01(bottom),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NormalizedRect &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() {
    return 'NormalizedRect(left: $left, top: $top, right: $right, bottom: $bottom)';
  }

  Map<String, Object> toJson() => {
    'left': left,
    'top': top,
    'right': right,
    'bottom': bottom,
  };

  factory NormalizedRect.fromJson(Map<String, Object?> json) {
    return NormalizedRect(
      left: _readDouble(json['left']),
      top: _readDouble(json['top']),
      right: _readDouble(json['right']),
      bottom: _readDouble(json['bottom']),
    );
  }
}

@immutable
class OfflineDetection {
  const OfflineDetection({
    required this.label,
    required this.score,
    required this.box,
  });

  final String label;

  /// 0..1 (inclusive).
  final double score;

  final NormalizedRect box;

  @override
  bool operator ==(Object other) {
    return other is OfflineDetection &&
        other.label == label &&
        other.score == score &&
        other.box == box;
  }

  @override
  int get hashCode => Object.hash(label, score, box);

  @override
  String toString() {
    return 'OfflineDetection(label: $label, score: $score, box: $box)';
  }

  Map<String, Object> toJson() => {
    'label': label,
    'score': score,
    'box': box.toJson(),
  };

  factory OfflineDetection.fromJson(Map<String, Object?> json) {
    final boxAny = json['box'];
    if (boxAny is! Map) {
      throw const FormatException('OfflineDetection.box must be an object');
    }
    return OfflineDetection(
      label: _readString(json['label']),
      score: _readDouble(json['score']),
      box: NormalizedRect.fromJson(boxAny.cast<String, Object?>()),
    );
  }
}

String offlineDetectionsToJson(List<OfflineDetection> detections) {
  return jsonEncode(detections.map((d) => d.toJson()).toList(growable: false));
}

List<OfflineDetection> offlineDetectionsFromJson(String jsonText) {
  final decoded = jsonDecode(jsonText);
  if (decoded is! List) {
    throw const FormatException('Offline detections payload must be a list');
  }
  return decoded
      .whereType<Map>()
      .map((v) => OfflineDetection.fromJson(v.cast<String, Object?>()))
      .toList(growable: false);
}

/// Hard confidence cutoff (OFF-03): detections below this are not surfaced.
///
/// Locked behavior in Phase 4 context: the UI must NOT re-implement this.
const double kOfflineDetectionMinScore = 0.35;

enum OfflineConfidenceBand { low, medium, high }

@immutable
class OfflineConfidenceInfo {
  const OfflineConfidenceInfo({required this.percent, required this.band});

  /// 0..100 integer percent (rounded).
  final int percent;
  final OfflineConfidenceBand band;

  String get label {
    return switch (band) {
      OfflineConfidenceBand.high => 'High',
      OfflineConfidenceBand.medium => 'Med',
      OfflineConfidenceBand.low => 'Low',
    };
  }

  String get percentLabel => '$percent%';
}

/// Centralized, deterministic confidence mapping used by UI.
OfflineConfidenceInfo confidenceInfoForScore(double score) {
  final clamped = _clamp01(score);
  final percent = (clamped * 100).round();

  final band = clamped >= 0.80
      ? OfflineConfidenceBand.high
      : (clamped >= 0.60
            ? OfflineConfidenceBand.medium
            : OfflineConfidenceBand.low);

  return OfflineConfidenceInfo(percent: percent, band: band);
}

double _clamp01(double v) {
  if (v.isNaN) return 0;
  if (v < 0) return 0;
  if (v > 1) return 1;
  return v;
}

double _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw const FormatException('Expected numeric value');
}

String _readString(Object? value) {
  if (value is String) return value;
  throw const FormatException('Expected string value');
}
