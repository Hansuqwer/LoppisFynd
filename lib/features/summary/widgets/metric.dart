import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';

class Metric extends StatelessWidget {
  const Metric({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final valueBase =
        (emphasize
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.bodyLarge)
            ?.copyWith(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            );
    final valueStyle =
        valueBase == null ? null : AppTypography.metricsFrom(valueBase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: valueStyle),
      ],
    );
  }
}
