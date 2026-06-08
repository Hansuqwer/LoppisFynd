import 'dart:ui';

import 'package:flutter/material.dart';

import 'atmospheric_background.dart';

/// Contract-named Nature Distilled background primitive.
///
/// Keep this widget layout-free: callers compose it in a Stack.
class NatureBackground extends StatelessWidget {
  const NatureBackground({super.key});

  static const _backgroundImage =
      'Images/Background/background_photo.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AtmosphericBackground(),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
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
