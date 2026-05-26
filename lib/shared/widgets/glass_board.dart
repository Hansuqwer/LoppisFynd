import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';
import 'glass_surface.dart';

/// Large glass container primitive used for "board" layouts.
class GlassBoard extends StatelessWidget {
  const GlassBoard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: padding,
      borderRadius: BorderRadius.circular(AppRadius.board),
      blurSigma: AppBlur.cardSigma,
      fillOpacity: AppOpacity.glassBoard,
      child: child,
    );
  }
}

/// Stack helper that renders translucent backplates behind [child].
class StackedBackplates extends StatelessWidget {
  const StackedBackplates({super.key, required this.child, this.layers = 3});

  final Widget child;
  final int layers;

  @override
  Widget build(BuildContext context) {
    final backplate = GlassSurface(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadius.board),
      blurSigma: AppBlur.cardSigma,
      fillOpacity: AppOpacity.glassBackplate,
      boxShadow: const [],
      showInnerHighlight: false,
      child: const SizedBox.expand(),
    );

    return Stack(
      children: [
        for (var i = layers; i >= 1; i--)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(i * AppSpacing.xs, i * AppSpacing.sm),
              child: backplate,
            ),
          ),
        child,
      ],
    );
  }
}
