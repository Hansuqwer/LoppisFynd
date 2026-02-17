import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key, this.color = AppColors.accentEarth});

  final Color color;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScannerOverlayPainter(
          color: widget.color,
          animation: _controller,
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.color, required this.animation})
    : super(repaint: animation);

  final Color color;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final boxSize = (shortest * 0.72).clamp(220.0, 320.0);
    final corner = (boxSize * 0.15).clamp(34.0, 46.0);

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: boxSize,
      height: boxSize,
    );

    // Scrim with a clear window.
    final scrimPaint = Paint()
      ..color = AppColors.inkDeep.withValues(alpha: 0.42);
    final scrimPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectXY(rect, AppRadius.lg, AppRadius.lg));
    canvas.drawPath(scrimPath, scrimPaint);

    // Corner brackets.
    final bracket = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    Path cornerPath(Offset a, Offset b, Offset c) {
      return Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy);
    }

    canvas.drawPath(
      cornerPath(
        Offset(rect.left, rect.top + corner),
        Offset(rect.left, rect.top),
        Offset(rect.left + corner, rect.top),
      ),
      bracket,
    );
    canvas.drawPath(
      cornerPath(
        Offset(rect.right - corner, rect.top),
        Offset(rect.right, rect.top),
        Offset(rect.right, rect.top + corner),
      ),
      bracket,
    );
    canvas.drawPath(
      cornerPath(
        Offset(rect.right, rect.bottom - corner),
        Offset(rect.right, rect.bottom),
        Offset(rect.right - corner, rect.bottom),
      ),
      bracket,
    );
    canvas.drawPath(
      cornerPath(
        Offset(rect.left + corner, rect.bottom),
        Offset(rect.left, rect.bottom),
        Offset(rect.left, rect.bottom - corner),
      ),
      bracket,
    );

    // Breathing laser line.
    final t = Curves.easeInOut.transform(animation.value);
    final y = rect.top + (rect.height * t);
    final breath = 0.55 + (0.45 * math.sin(animation.value * math.pi));
    final opacity = (0.55 + (0.35 * breath)).clamp(0.0, 1.0);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.20 * opacity)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawLine(
      Offset(rect.left + 10, y),
      Offset(rect.right - 10, y),
      glowPaint,
    );

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.82 * opacity)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(rect.left + 10, y),
      Offset(rect.right - 10, y),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.animation != animation;
  }
}
