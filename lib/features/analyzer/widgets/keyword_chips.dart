import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';

class KeywordChips extends StatelessWidget {
  const KeywordChips({
    super.key,
    required this.tokens,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<String> tokens;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.itemDetailKeywordsTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < tokens.length; i++)
              InputChip(
                label: Text(tokens[i]),
                onPressed: () => onEdit(i),
                onDeleted: () => onDelete(i),
              ),
            ActionChip(
              label: Text(l10n.commonAdd),
              onPressed: tokens.length >= 5 ? null : onAdd,
              avatar: const Icon(Icons.add_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
