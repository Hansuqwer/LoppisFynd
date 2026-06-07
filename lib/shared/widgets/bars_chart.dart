import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Mini vertical bar chart, matching the redesign Bars primitive.
///
/// [data] list of values.  The last bar is accent-coloured when
/// [accentLast] is true.  All other bars render at low opacity.
class BarsChart extends StatelessWidget {
  const BarsChart({
    super.key,
    required this.data,
    this.color = AppColors.cloudDancer,
    this.accentColor,
    this.accentLast = false,
    this.height = 44,
  });

  final List<double> data;
  final Color color;
  final Color? accentColor;
  final bool accentLast;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BarsPainter(
          data: data,
          color: color,
          accentColor: accentColor ?? AppColors.dopamineRed,
          accentLast: accentLast,
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.data,
    required this.color,
    required this.accentColor,
    required this.accentLast,
  });

  final List<double> data;
  final Color color;
  final Color accentColor;
  final bool accentLast;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || data.isEmpty) return;

    final mx = data.reduce((a, b) => a > b ? a : b);
    final safeMx = mx == 0 ? 1.0 : mx;
    const gap = 6.0;
    final bw = (size.width - gap * (data.length - 1)) / data.length;

    for (var i = 0; i < data.length; i++) {
      final bh = _mathMax(3.0, (data[i] / safeMx) * size.height);
      final isLast = accentLast && i == data.length - 1;
      final paint = Paint()
        ..color = isLast ? accentColor : color.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;

      final rx = (bw / 2.5).clamp(0.0, _mathMax(0.0, (bw / 2).clamp(0.0, bh / 2)));
      final left = i * (bw + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - bh, bw, bh),
        Radius.circular(rx),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.data != data ||
      old.color != color ||
      old.accentColor != accentColor ||
      old.accentLast != accentLast;
}

double _mathMax(double a, double b) => a > b ? a : b;
