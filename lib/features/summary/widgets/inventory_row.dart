import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';
import 'badge.dart';

String formatSek(double value) => '${value.round()} SEK';

class InventoryRow extends StatelessWidget {
  const InventoryRow({
    super.key,
    required this.item,
    required this.net,
    required this.cloudStatus,
    required this.onOpenDraft,
  });

  final ScanItem item;
  final double? net;
  final String? cloudStatus;
  final VoidCallback onOpenDraft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final thumbPath = item.thumbPath;
    final headline = (item.desc?.trim().isNotEmpty ?? false)
        ? item.desc!.trim()
        : (item.query?.trim().isNotEmpty ?? false)
            ? item.query!.trim()
            : l10n.haulSummaryUnnamedItem;

    final netText = net == null ? '—' : formatSek(net!);
    final netBase = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: (net ?? 0) >= 0 ? AppColors.textPrimary : AppColors.primaryAction,
    );
    final netStyle =
        netBase == null ? null : AppTypography.metricsFrom(netBase);

    final cloud = cloudStatus;
    final cloudIcon = switch (cloud) {
      'syncing' => Icons.cloud_upload_rounded,
      'failed' => Icons.cloud_off_rounded,
      'conflict' => Icons.warning_amber_rounded,
      _ => null,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: thumbPath == null
                ? Container(
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_rounded),
                  )
                : Image.file(
                    File(thumbPath),
                    fit: BoxFit.cover,
                    cacheWidth: 112,
                    cacheHeight: 112,
                    errorBuilder: (context, _, _) {
                      return Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusBadge(label: item.status.name),
                  if (item.category?.trim().isNotEmpty ?? false)
                    StatusBadge(label: item.category!.trim()),
                  if (item.daysToSellEst != null)
                    StatusBadge(
                      label: l10n.haulSummaryDaysToSell(item.daysToSellEst!),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(netText, style: netStyle),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cloudIcon != null)
                  Icon(
                    cloudIcon,
                    size: 18,
                    color: AppColors.textPrimary.withValues(alpha: 0.75),
                  ),
                IconButton(
                  onPressed: onOpenDraft,
                  tooltip: l10n.draftEditorTitle,
                  icon: const Icon(Icons.edit_note_rounded),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textPrimary.withValues(alpha: 0.65),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
