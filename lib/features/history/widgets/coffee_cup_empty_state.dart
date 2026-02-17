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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.bento,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 84,
            height: 84,
            child: CustomPaint(painter: _CoffeeCupPainter()),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
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
      ..color = AppColors.accentEarth.withValues(alpha: 0.55)
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
      ..color = AppColors.atmosphericFog.withValues(alpha: 0.30)
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
