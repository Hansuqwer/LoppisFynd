import 'package:flutter/material.dart';

import '../../../gen/app_localizations.dart';

class ConditionAdjuster extends StatelessWidget {
  const ConditionAdjuster({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clamped = value.clamp(0.7, 1.1);
    final label = _conditionLabel(l10n, clamped);
    final percent = ((clamped - 1.0) * 100).round();
    final sign = percent > 0 ? '+' : '';
    final percentText = percent == 0 ? '0' : '$sign$percent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.itemDetailConditionTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              l10n.itemDetailConditionValue(label, percentText),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: clamped,
          min: 0.7,
          max: 1.1,
          divisions: 8,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

String _conditionLabel(AppLocalizations l10n, double multiplier) {
  if (multiplier >= 1.05) return l10n.itemDetailConditionMint;
  if (multiplier >= 0.95) return l10n.itemDetailConditionGood;
  if (multiplier >= 0.85) return l10n.itemDetailConditionFair;
  return l10n.itemDetailConditionRough;
}
