import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../tokens/app_tokens.dart';

class SpringRoute<T> extends PageRouteBuilder<T> {
  SpringRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: AppMotion.spring,
        reverseTransitionDuration: AppMotion.springReverse,
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final springy = CurvedAnimation(
            parent: animation,
            curve: _SpringCurve(
              seconds: AppMotion.spring.inMilliseconds / 1000.0,
            ),
            reverseCurve: Curves.easeInCubic,
          );

          final opacity = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: springy, curve: Curves.linear));

          final slide = Tween<Offset>(
            begin: const Offset(0.00, 0.04),
            end: Offset.zero,
          ).animate(springy);

          return FadeTransition(
            opacity: opacity,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );
}

class _SpringCurve extends Curve {
  const _SpringCurve({required this.seconds});

  final double seconds;

  static const _desc = SpringDescription(
    mass: 1.0,
    stiffness: 380.0,
    damping: 28.0,
  );

  @override
  double transformInternal(double t) {
    final sim = SpringSimulation(_desc, 0.0, 1.0, 0.0);
    final x = sim.x(t * seconds);
    return x.clamp(0.0, 1.0);
  }
}
