import 'package:flutter/material.dart';

import 'atmospheric_background.dart';

/// Contract-named Nature Distilled background primitive.
///
/// Keep this widget layout-free: callers compose it in a Stack.
class NatureBackground extends StatelessWidget {
  const NatureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const AtmosphericBackground();
  }
}
