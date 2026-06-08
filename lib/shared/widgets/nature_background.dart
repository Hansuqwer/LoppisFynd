import 'dart:ui';

import 'package:flutter/material.dart';

import 'atmospheric_background.dart';

/// Contract-named Nature Distilled background primitive.
///
/// Keep this widget layout-free: callers compose it in a Stack.
class NatureBackground extends StatelessWidget {
  const NatureBackground({super.key});

  static const _backgroundImage =
      'Images/Background/5d7e351e-1188-4614-8c22-1bea2cad7d50.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AtmosphericBackground(),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Image.asset(
            _backgroundImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
