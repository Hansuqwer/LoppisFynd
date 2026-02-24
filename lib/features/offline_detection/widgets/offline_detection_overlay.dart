import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../services/offline_detection/offline_detection_types.dart';

class OfflineDetectionOverlay extends StatelessWidget {
  const OfflineDetectionOverlay({
    super.key,
    required this.detections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<OfflineDetection> detections;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final p = details.localPosition;
            if (size.width <= 0 || size.height <= 0) return;
            final nx = (p.dx / size.width).clamp(0, 1);
            final ny = (p.dy / size.height).clamp(0, 1);

            int? hit;
            for (var i = 0; i < detections.length; i++) {
              final d = detections[i];
              final r = d.box;
              if (nx >= r.left &&
                  nx <= r.right &&
                  ny >= r.top &&
                  ny <= r.bottom) {
                hit = i;
                break;
              }
            }
            if (hit != null) onSelected(hit);
          },
          child: CustomPaint(
            painter: _OfflineBoxesPainter(
              detections: detections,
              selectedIndex: selectedIndex,
            ),
          ),
        );
      },
    );
  }
}

class _OfflineBoxesPainter extends CustomPainter {
  const _OfflineBoxesPainter({
    required this.detections,
    required this.selectedIndex,
  });

  final List<OfflineDetection> detections;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final selected = selectedIndex;
    if (detections.isEmpty) return;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.alertProfit.withValues(alpha: 0.80);

    final selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.primaryAction.withValues(alpha: 0.92);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryAction.withValues(alpha: 0.10);

    for (var i = 0; i < detections.length; i++) {
      final d = detections[i];
      final r = _rectFromNormalized(d.box, size);

      if (selected != null && i == selected) {
        canvas.drawRect(r, fillPaint);
        canvas.drawRect(r, selectedPaint);
      } else {
        canvas.drawRect(r, basePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OfflineBoxesPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.detections != detections;
  }
}

Rect _rectFromNormalized(NormalizedRect r, Size size) {
  final left = (r.left * size.width).clamp(0.0, size.width).toDouble();
  final right = (r.right * size.width).clamp(0.0, size.width).toDouble();
  final top = (r.top * size.height).clamp(0.0, size.height).toDouble();
  final bottom = (r.bottom * size.height).clamp(0.0, size.height).toDouble();

  return Rect.fromLTRB(left, top, right, bottom);
}
