import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../shared/widgets/glass_overlay.dart';
import '../../../gen/app_localizations.dart';

class BarcodeDetection {
  const BarcodeDetection({required this.value, required this.boundingBox});

  final String value;
  final Rect boundingBox;
}

class BarcodeDetectionFrame {
  const BarcodeDetectionFrame({
    required this.imageSize,
    required this.detections,
    required this.revision,
  });

  final Size imageSize;
  final List<BarcodeDetection> detections;
  final int revision;
}

class BarcodeArOverlay extends StatelessWidget {
  const BarcodeArOverlay({
    super.key,
    required this.frame,
    this.onBarcodeTap,
    this.hint,
  });

  final BarcodeDetectionFrame? frame;
  final ValueChanged<String>? onBarcodeTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveHint =
        hint ??
        (l10n?.scannerBarcodeAimHint ??
            'Aim at a barcode to detect instantly.');

    final detections = frame?.detections ?? const <BarcodeDetection>[];
    final values = _dedupeValues(detections);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: CustomPaint(
            painter: _BarcodeBoxesPainter(
              imageSize: frame?.imageSize,
              detections: detections,
              revision: frame?.revision ?? -1,
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
          child: GlassOverlay(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            fillColor: AppColors.glassFill.withValues(alpha: 0.2),
            blurSigma: 10,
            child: values.isEmpty
                ? _NoBarcodeHint(hint: effectiveHint)
                : _DetectedBarcodeTray(
                    values: values,
                    onBarcodeTap: onBarcodeTap,
                  ),
          ),
        ),
      ],
    );
  }

  List<String> _dedupeValues(List<BarcodeDetection> detections) {
    final unique = <String>[];
    for (final detection in detections) {
      final normalized = detection.value.trim();
      if (normalized.isEmpty || unique.contains(normalized)) {
        continue;
      }
      unique.add(normalized);
      if (unique.length >= 8) {
        break;
      }
    }
    return unique;
  }
}

class _NoBarcodeHint extends StatelessWidget {
  const _NoBarcodeHint({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.center_focus_weak_rounded,
          size: 16,
          color: AppColors.textOnDark,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            hint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetectedBarcodeTray extends StatelessWidget {
  const _DetectedBarcodeTray({required this.values, this.onBarcodeTap});

  final List<String> values;
  final ValueChanged<String>? onBarcodeTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final value = values[index];
          return _BarcodeChip(
            value: value,
            onTap: onBarcodeTap == null ? null : () => onBarcodeTap!(value),
          );
        },
      ),
    );
  }
}

class _BarcodeChip extends StatelessWidget {
  const _BarcodeChip({required this.value, this.onTap});

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          constraints: const BoxConstraints(minWidth: 72, maxWidth: 190),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.pressed,
          ),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarcodeBoxesPainter extends CustomPainter {
  _BarcodeBoxesPainter({
    required this.imageSize,
    required this.detections,
    required this.revision,
  });

  final Size? imageSize;
  final List<BarcodeDetection> detections;
  final int revision;

  @override
  void paint(Canvas canvas, Size size) {
    final sourceSize = imageSize;
    if (sourceSize == null || sourceSize.isEmpty || detections.isEmpty) {
      return;
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppColors.alertProfit.withValues(alpha: 0.22);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.textOnDark;

    for (final detection in detections) {
      final projected = _projectRect(
        rect: detection.boundingBox,
        source: sourceSize,
        destination: size,
      );
      if (projected == null || projected.width < 1 || projected.height < 1) {
        continue;
      }

      final box = RRect.fromRectAndRadius(
        projected,
        const Radius.circular(AppRadius.md),
      );
      canvas.drawRRect(box, glowPaint);
      canvas.drawRRect(box, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodeBoxesPainter oldDelegate) {
    return oldDelegate.revision != revision ||
        oldDelegate.imageSize != imageSize ||
        !identical(oldDelegate.detections, detections);
  }

  Rect? _projectRect({
    required Rect rect,
    required Size source,
    required Size destination,
  }) {
    final scale =
        (destination.width / source.width).clamp(0.0, double.infinity) >
            (destination.height / source.height).clamp(0.0, double.infinity)
        ? destination.width / source.width
        : destination.height / source.height;

    final scaledWidth = source.width * scale;
    final scaledHeight = source.height * scale;
    final dx = (destination.width - scaledWidth) / 2;
    final dy = (destination.height - scaledHeight) / 2;

    final projected = Rect.fromLTWH(
      rect.left * scale + dx,
      rect.top * scale + dy,
      rect.width * scale,
      rect.height * scale,
    );

    final clipped = projected.intersect(Offset.zero & destination);
    if (clipped.isEmpty) {
      return null;
    }
    return clipped;
  }
}
