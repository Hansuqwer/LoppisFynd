import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

class LoppisTrackPainter extends CustomPainter {
  const LoppisTrackPainter({required this.color, this.opacity = 0.06});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // A soft "L"-like track with two curves.
    path.moveTo(size.width * 0.82, size.height * 1.02);
    path.cubicTo(
      size.width * 0.82,
      size.height * 0.70,
      size.width * 0.18,
      size.height * 0.82,
      size.width * 0.18,
      size.height * 0.52,
    );
    path.cubicTo(
      size.width * 0.18,
      size.height * 0.30,
      size.width * 0.56,
      size.height * 0.22,
      size.width * 0.56,
      size.height * 0.06,
    );

    canvas.drawPath(path, paint);

    // A secondary whisper stroke to add depth.
    final secondary = Paint()
      ..color = AppColors.atmosphericFog.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, secondary);
  }

  @override
  bool shouldRepaint(covariant LoppisTrackPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}
