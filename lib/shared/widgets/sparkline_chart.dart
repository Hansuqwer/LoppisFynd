import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Sold-price history sparkline matching the redesign Sparkline primitive.
///
/// Draws a line + area-fill + terminal dot from a list of [prices].
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.prices,
    this.color,
    this.height = 50,
  });

  final List<double> prices;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (prices.length < 2) return SizedBox(height: height);
    final col = color ?? AppColors.sageDeep;
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(prices: prices, color: col),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.prices, required this.color});

  final List<double> prices;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final mn = prices.reduce((a, b) => a < b ? a : b);
    final mx = prices.reduce((a, b) => a > b ? a : b);
    final rng = (mx - mn).abs();
    final safeRng = rng == 0 ? 1.0 : rng;
    final pad = 4.0;

    Offset pt(int i) {
      final x = (i / (prices.length - 1)) * w;
      final y = h - ((prices[i] - mn) / safeRng) * (h - pad * 2) - pad;
      return Offset(x, y);
    }

    final pts = List.generate(prices.length, pt);

    // Area fill.
    final areaPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(pts.last.dx, h)
      ..lineTo(pts.first.dx, h)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Line.
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Terminal dot.
    canvas.drawCircle(pts.last, 3.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.prices != prices || old.color != color;
}
