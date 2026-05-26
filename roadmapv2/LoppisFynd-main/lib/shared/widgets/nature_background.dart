import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';
import 'atmospheric_background.dart';

/// Contract-named Nature Distilled background primitive.
///
/// Keep this widget layout-free: callers compose it in a Stack.
class NatureBackground extends StatelessWidget {
  const NatureBackground({
    super.key,
    this.backgroundAsset,
    this.photoOpacity = 0.72,
    this.textureAsset = AppAssets.texturePaperRamp,
    this.textureOpacity = 0.10,
    this.showMotif = false,
  });

  /// Photo background token (light).
  ///
  /// Design system default: `asset.background.market.day.1`.
  final String? backgroundAsset;

  /// Optional photo opacity (helps keep UI readable).
  final double photoOpacity;

  /// Optional texture token.
  ///
  /// Design system default: `texture.paper.ramp`.
  final String? textureAsset;

  /// Texture overlay opacity (design system suggests ~8–12%).
  final double textureOpacity;

  /// Optional logo motif overlay.
  final bool showMotif;

  @override
  Widget build(BuildContext context) {
    return AtmosphericBackground(
      backgroundAsset: backgroundAsset ?? AppAssets.backgroundMarketDay1,
      photoOpacity: photoOpacity,
      textureAsset: textureAsset,
      textureOpacity: textureOpacity,
      showMotif: showMotif,
    );
  }
}
