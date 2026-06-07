import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Circular fyndfaktor (score) ring, matching the redesign ScoreRing.
///
/// [score] 0–100.  [size] diameter.  [stroke] arc width.
/// [color] overrides the automatic score-based colour.
class ScoreRing extends StatefulWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 96,
    this.stroke = 9,
    this.color,
    this.animate = true,
  });

  final int score;
  final double size;
  final double stroke;
  final Color? color;
  final bool animate;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ScoreRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _defaultColor(int score) {
    if (score >= 70) return AppColors.sageDeep;
    if (score >= 45) return AppColors.mustard;
    return AppColors.copperOak;
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.color ?? _defaultColor(widget.score);
    final fraction = (widget.score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final sweepFraction = widget.animate
              ? _anim.value * fraction
              : fraction;
          return CustomPaint(
            painter: _ScoreRingPainter(
              fraction: sweepFraction,
              stroke: widget.stroke,
              color: col,
              trackColor: AppColors.deepSapphire.withValues(alpha: 0.10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.score}',
                    style: TextStyle(
                      fontFamily: AppTypography.metricsFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.size * 0.30,
                      color: col,
                      height: 1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'FYNDFAKTOR',
                    style: TextStyle(
                      fontFamily: AppTypography.uiFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.size * 0.10,
                      color: AppColors.textMuted,
                      letterSpacing: 0.04 * widget.size * 0.10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.fraction,
    required this.stroke,
    required this.color,
    required this.trackColor,
  });

  final double fraction;
  final double stroke;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Full track.
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);
    // Score arc.
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.stroke != stroke ||
      old.trackColor != trackColor;
}
