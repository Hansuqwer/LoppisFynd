import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Contract-named motif overlay primitive.
///
/// Intended usage: place inside a Stack above a background but behind glass.
class LogoMotifOverlay extends StatelessWidget {
  const LogoMotifOverlay({
    super.key,
    this.opacity = 1.0,
    this.assetImage = const AssetImage('Assets/unnamed.jpg'),
  });

  final double opacity;
  final ImageProvider assetImage;

  static const _marks = <_MotifMarkSpec>[
    _MotifMarkSpec(x: 0.10, y: 0.14, size: 56, rotation: -0.20, opacity: 0.16),
    _MotifMarkSpec(x: 0.26, y: 0.08, size: 48, rotation: 0.12, opacity: 0.14),
    _MotifMarkSpec(x: 0.42, y: 0.15, size: 62, rotation: -0.08, opacity: 0.18),
    _MotifMarkSpec(x: 0.64, y: 0.10, size: 52, rotation: 0.22, opacity: 0.15),
    _MotifMarkSpec(x: 0.82, y: 0.18, size: 58, rotation: -0.18, opacity: 0.17),
    _MotifMarkSpec(x: 0.14, y: 0.34, size: 44, rotation: 0.28, opacity: 0.13),
    _MotifMarkSpec(x: 0.32, y: 0.36, size: 60, rotation: -0.10, opacity: 0.17),
    _MotifMarkSpec(x: 0.54, y: 0.31, size: 50, rotation: 0.06, opacity: 0.14),
    _MotifMarkSpec(x: 0.78, y: 0.34, size: 64, rotation: -0.24, opacity: 0.19),
    _MotifMarkSpec(x: 0.08, y: 0.58, size: 60, rotation: -0.12, opacity: 0.18),
    _MotifMarkSpec(x: 0.22, y: 0.70, size: 50, rotation: 0.16, opacity: 0.15),
    _MotifMarkSpec(x: 0.46, y: 0.64, size: 44, rotation: 0.30, opacity: 0.13),
    _MotifMarkSpec(x: 0.62, y: 0.58, size: 58, rotation: -0.06, opacity: 0.17),
    _MotifMarkSpec(x: 0.86, y: 0.64, size: 52, rotation: 0.20, opacity: 0.15),
    _MotifMarkSpec(x: 0.16, y: 0.88, size: 56, rotation: -0.22, opacity: 0.16),
    _MotifMarkSpec(x: 0.50, y: 0.86, size: 62, rotation: 0.10, opacity: 0.18),
    _MotifMarkSpec(x: 0.82, y: 0.88, size: 48, rotation: -0.14, opacity: 0.14),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Opacity(
          opacity: opacity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  for (final spec in _marks)
                    Positioned(
                      left: (w * spec.x) - (spec.size / 2),
                      top: (h * spec.y) - (spec.size / 2),
                      child: Opacity(
                        opacity: spec.opacity,
                        child: Transform.rotate(
                          angle: spec.rotation * math.pi,
                          child: _MotifMark(size: spec.size, image: assetImage),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MotifMarkSpec {
  const _MotifMarkSpec({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.opacity,
  });

  final double x;
  final double y;
  final double size;
  final double rotation;
  final double opacity;
}

class _MotifMark extends StatelessWidget {
  const _MotifMark({required this.size, required this.image});

  final double size;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.glassStroke.withAlpha(0x2E),
            width: 1,
          ),
          boxShadow: AppShadows.motifOverlay,
        ),
        child: ClipOval(
          child: Transform.scale(
            scale: 1.7,
            alignment: const Alignment(0.0, -0.35),
            child: Image(image: image, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
