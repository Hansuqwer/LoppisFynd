import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';

/// Returns 1 (accepted) or 2 (not now).
Future<int?> showCloudIdentificationDisclosure(
  BuildContext context, {
  required AppLocalizations l10n,
  File? previewImage,
}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.cloudDisclosureTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bullet(text: l10n.cloudDisclosureBullet1),
            const SizedBox(height: AppSpacing.xs),
            _Bullet(text: l10n.cloudDisclosureBullet2),
            const SizedBox(height: AppSpacing.xs),
            _Bullet(text: l10n.cloudDisclosureBullet3),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (context) {
                    return SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cloudDisclosureLearnMoreTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.cloudDisclosureLearnMoreIntro,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _PreviewCard(
                              label: l10n.cloudDisclosurePreviewLabel,
                              image: previewImage,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _Bullet(text: l10n.cloudDisclosureLearnMoreBullet1),
                            const SizedBox(height: AppSpacing.xs),
                            _Bullet(text: l10n.cloudDisclosureLearnMoreBullet2),
                            const SizedBox(height: AppSpacing.xs),
                            _Bullet(text: l10n.cloudDisclosureLearnMoreBullet3),
                            const SizedBox(height: AppSpacing.xs),
                            _Bullet(text: l10n.cloudDisclosureLearnMoreBullet4),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text(l10n.cloudDisclosureLearnMoreCta),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(2),
            child: Text(l10n.cloudDisclosureNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(1),
            child: Text(l10n.cloudDisclosureEnable),
          ),
        ],
      );
    },
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: Icon(Icons.circle, size: 6, color: AppColors.textMuted),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.label, required this.image});

  final String label;
  final File? image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: (image != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, _, _) {
                      return _PreviewPlaceholder();
                    },
                  ),
                )
              : _PreviewPlaceholder(),
        ),
      ],
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.crop_rounded,
          color: AppColors.inkDeep.withValues(alpha: 0.55),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppLocalizations.of(context)!.cloudDisclosurePreviewPlaceholder,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
