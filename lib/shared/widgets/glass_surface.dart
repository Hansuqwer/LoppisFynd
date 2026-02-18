import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Canonical Nature Distilled glass surface.
///
/// Guarantees blur is clipped by construction.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.blurSigma = AppBlur.cardSigma,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.xxl)),
    this.fillColor = AppColors.textOnPrimary,
    this.fillOpacity = AppOpacity.glassTile,
    this.strokeColor = AppColors.glassStroke,
    this.strokeWidth = 1.0,
    this.boxShadow = AppShadows.soft,
    this.gradient,
    this.showInnerHighlight = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final double blurSigma;
  final BorderRadius borderRadius;

  /// Base color for the glass fill (alpha is applied via [fillOpacity]).
  final Color fillColor;
  final double fillOpacity;

  final Color strokeColor;
  final double strokeWidth;
  final List<BoxShadow> boxShadow;

  final Gradient? gradient;
  final bool showInnerHighlight;

  @override
  Widget build(BuildContext context) {
    final baseAlpha = fillColor.a / 255.0;
    final alpha = (baseAlpha * fillOpacity).clamp(0.0, 1.0);
    final fill = fillOpacity == 1.0
        ? fillColor
        : fillColor.withValues(alpha: alpha);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: fill,
            gradient: gradient,
            border: Border.all(color: strokeColor, width: strokeWidth),
            boxShadow: boxShadow,
          ),
          child: Stack(
            children: [
              if (showInnerHighlight)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.textOnPrimary.withValues(
                              alpha: alpha / 2,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
