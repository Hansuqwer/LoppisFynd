import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/scan_items.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../shared/widgets/bento_card.dart';
import '../../../gen/app_localizations.dart';

class BatchTray extends StatelessWidget {
  const BatchTray({
    super.key,
    required this.items,
    this.maxItems = 12,
    this.onItemTap,
  });

  final List<ScanItem> items;
  final int maxItems;
  final ValueChanged<String>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return BentoCard(child: Text(l10n.scannerNoScansYet));
    }

    final shown = items.length > maxItems
        ? items.take(maxItems).toList()
        : items;

    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.scannerBatchTrayTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                items.length.toString(),
                style: AppTypography.metricsFrom(
                  Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = shown[index];
                return _TrayItem(
                  item: item,
                  onTap: onItemTap == null ? null : () => onItemTap!(item.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.item, this.onTap});

  final ScanItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final thumbPath = item.thumbPath;
    return SizedBox(
      width: 76,
      height: 76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            children: [
              Positioned.fill(
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
                          cacheWidth: 152,
                          cacheHeight: 152,
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
              Positioned(
                right: 6,
                bottom: 6,
                child: _StatusBadge(status: item.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ScanItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = switch (status) {
      ScanItemStatus.pendingIdentify => (
        Icons.psychology_alt_rounded,
        AppColors.deepSapphire,
        AppColors.textOnDark,
      ),
      ScanItemStatus.pendingSync => (
        Icons.cloud_upload_rounded,
        AppColors.deepSapphire,
        AppColors.textOnDark,
      ),
      ScanItemStatus.syncing => (
        Icons.sync_rounded,
        AppColors.deepSapphire,
        AppColors.textOnDark,
      ),
      ScanItemStatus.complete => (
        Icons.check_rounded,
        AppColors.success,
        AppColors.textPrimary,
      ),
      ScanItemStatus.failed => (
        Icons.error_outline_rounded,
        AppColors.dopamineRed,
        AppColors.textOnPrimary,
      ),
    };

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.pressed,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Icon(icon, size: 16, color: fg),
    );
  }
}
