import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';

class CoffeeCupEmptyState extends StatelessWidget {
  const CoffeeCupEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(painter: _CoffeeCupPainter()),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CoffeeCupPainter extends CustomPainter {
  const _CoffeeCupPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.inkDeep.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final cup = Path();
    cup.moveTo(w * 0.18, h * 0.30);
    cup.quadraticBezierTo(w * 0.16, h * 0.64, w * 0.30, h * 0.74);
    cup.quadraticBezierTo(w * 0.50, h * 0.86, w * 0.70, h * 0.74);
    cup.quadraticBezierTo(w * 0.84, h * 0.64, w * 0.82, h * 0.30);
    cup.quadraticBezierTo(w * 0.55, h * 0.24, w * 0.18, h * 0.30);
    canvas.drawPath(cup, stroke);

    final rim = Path();
    rim.moveTo(w * 0.20, h * 0.28);
    rim.quadraticBezierTo(w * 0.50, h * 0.20, w * 0.80, h * 0.28);
    canvas.drawPath(rim, stroke..strokeWidth = 4);

    final handle = Path();
    handle.moveTo(w * 0.78, h * 0.42);
    handle.quadraticBezierTo(w * 0.96, h * 0.46, w * 0.88, h * 0.62);
    handle.quadraticBezierTo(w * 0.80, h * 0.70, w * 0.72, h * 0.58);
    canvas.drawPath(handle, stroke..strokeWidth = 5);

    final plate = Path();
    plate.moveTo(w * 0.22, h * 0.86);
    plate.quadraticBezierTo(w * 0.50, h * 0.94, w * 0.78, h * 0.86);
    canvas.drawPath(plate, stroke..strokeWidth = 4);

    final steam = Paint()
      ..color = AppColors.dopamineRed.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in [0.36, 0.50, 0.64]) {
      final s = Path();
      s.moveTo(w * x, h * 0.14);
      s.quadraticBezierTo(w * (x - 0.03), h * 0.10, w * x, h * 0.06);
      s.quadraticBezierTo(w * (x + 0.03), h * 0.02, w * x, 0);
      canvas.drawPath(s, steam);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
