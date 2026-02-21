import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';

class HaulPin {
  const HaulPin({
    required this.lat,
    required this.lng,
    required this.label,
    required this.profitSek,
  });

  final double lat;
  final double lng;
  final String label;
  final double profitSek;
}

class HaulPinsMap extends StatelessWidget {
  const HaulPinsMap({super.key, required this.pins, this.height = 180});

  final List<HaulPin> pins;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (pins.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Text(l10n.historyNoPinnedHaulsYet),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: CustomPaint(
        painter: _PinsPainter(pins: pins),
        child: SizedBox(height: height),
      ),
    );
  }
}

class _PinsPainter extends CustomPainter {
  const _PinsPainter({required this.pins});

  final List<HaulPin> pins;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.background;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(AppRadius.lg),
      ),
      bg,
    );

    final gridPaint = Paint()
      ..color = AppColors.borderSubtle
      ..strokeWidth = 1;

    const step = 28.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    var minLat = pins.first.lat;
    var maxLat = pins.first.lat;
    var minLng = pins.first.lng;
    var maxLng = pins.first.lng;

    for (final p in pins) {
      minLat = min(minLat, p.lat);
      maxLat = max(maxLat, p.lat);
      minLng = min(minLng, p.lng);
      maxLng = max(maxLng, p.lng);
    }

    final latSpan = max(0.00001, maxLat - minLat);
    final lngSpan = max(0.00001, maxLng - minLng);

    final dotStroke = Paint()
      ..color = AppColors.cloudDancer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in pins) {
      final x = ((p.lng - minLng) / lngSpan) * (size.width - 24) + 12;
      final y = (1 - ((p.lat - minLat) / latSpan)) * (size.height - 24) + 12;
      final center = Offset(x, y);

      final fillColor = p.profitSek >= 0
          ? AppColors.success
          : AppColors.primaryAction;
      final dotFill = Paint()..color = fillColor;

      final strength = (p.profitSek.abs() / 500.0).clamp(0.0, 1.0);
      final r = 6.0 + (strength * 3.0);
      canvas.drawCircle(center, r, dotFill);
      canvas.drawCircle(center, r, dotStroke);
    }
  }

  @override
  bool shouldRepaint(_PinsPainter oldDelegate) {
    return oldDelegate.pins != pins;
  }
}
