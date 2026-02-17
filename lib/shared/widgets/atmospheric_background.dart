import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';
import '../painters/loppis_track_painter.dart';

class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.cloudDancer),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cloudDancer,
                AppColors.atmosphericFog.withValues(alpha: 0.08),
                AppColors.eucalyptus.withValues(alpha: 0.06),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: const LoppisTrackPainter(color: AppColors.accentEarth),
          ),
        ),
      ],
    );
  }
}
