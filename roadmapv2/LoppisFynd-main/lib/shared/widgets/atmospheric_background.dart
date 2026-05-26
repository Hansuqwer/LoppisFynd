import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';
import '../painters/loppis_track_painter.dart';
import 'logo_motif_overlay.dart';

class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({
    super.key,
    this.backgroundAsset,
    this.photoOpacity = 0.72,
    this.textureAsset,
    this.textureOpacity = 0.0,
    this.showMotif = false,
  });

  /// Optional photo background.
  final String? backgroundAsset;

  /// Photo background opacity.
  final double photoOpacity;

  /// Optional texture overlay.
  final String? textureAsset;

  /// Texture opacity (8–12% recommended in the design system).
  final double textureOpacity;

  /// Optional motif overlay.
  final bool showMotif;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.neutral0),
        ),
        if (backgroundAsset != null)
          Opacity(
            opacity: photoOpacity,
            child: Image.asset(backgroundAsset!, fit: BoxFit.cover),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cool0.withValues(alpha: 0.22),
                Colors.transparent,
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        if (textureAsset != null && textureOpacity > 0)
          Opacity(
            opacity: textureOpacity,
            child: Image.asset(textureAsset!, fit: BoxFit.cover),
          ),
        if (showMotif) const LogoMotifOverlay(),
        IgnorePointer(
          child: CustomPaint(
            painter: const LoppisTrackPainter(color: AppColors.cool0),
          ),
        ),
      ],
    );
  }
}
