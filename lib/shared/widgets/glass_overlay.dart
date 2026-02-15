import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

class GlassOverlay extends StatelessWidget {
  const GlassOverlay({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.blurSigma = 15,
    this.fillColor = AppColors.glassFill,
  });

  final Widget child;
  final EdgeInsets padding;
  final double blurSigma;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.glassStroke),
          ),
          child: child,
        ),
      ),
    );
  }
}
