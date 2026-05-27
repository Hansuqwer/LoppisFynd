import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/glass_board.dart';
import '../../shared/widgets/glass_surface.dart';
import '../summary/haul_summary_screen.dart';
import '../analyzer/item_detail_screen.dart';
import '../../gen/app_localizations.dart';

class HaulScreen extends ConsumerWidget {
  const HaulScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final haulId = ref.watch(defaultHaulIdProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        child: StackedBackplates(
          child: GlassBoard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: StreamBuilder<List<ScanItem>>(
              stream: db.scanItemsDao.watchByHaulId(haulId, userId: userId),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <ScanItem>[];
                final total = _totalValue(items);
                final totalText =
                    '${_formatSek(total, locale: intl.Intl.getCurrentLocale())} kr';

                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.haulTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _HaulSummaryRow(
                            label: _totalValueLabel(l10n),
                            valueText: totalText,
                            onOpenSummary: () {
                              Navigator.of(context).push(
                                SpringRoute(
                                  builder: (_) =>
                                      HaulSummaryScreen(haulId: haulId),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (items.isEmpty)
                            Text(
                              l10n.scannerNoScansYet,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            )
                          else
                            ...items.map(
                              (it) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: _HaulItemRow(
                                  item: it,
                                  title:
                                      (it.desc ?? it.query)
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                      ? (it.desc ?? it.query)!.trim()
                                      : l10n.haulUnnamedFind,
                                  statusLabel: _statusLabel(l10n, it.status),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      SpringRoute(
                                        builder: (_) =>
                                            ItemDetailScreen(scanItemId: it.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _CameraFab(
                        onPressed: () {
                          ref.read(deepLinkTabIndexProvider.notifier).set(1);
                        },
                        semanticLabel: l10n.homeHeroTitle,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

double _totalValue(List<ScanItem> items) {
  var total = 0.0;
  for (final it in items) {
    final m = it.medianPrice;
    if (m == null) continue;
    total += (m * it.conditionMultiplier);
  }
  return total;
}

String _formatSek(double value, {required String locale}) {
  final f = intl.NumberFormat.decimalPattern(locale);
  return f.format(value.round());
}

String _totalValueLabel(AppLocalizations l10n) {
  return l10n.haulTotalValue('').trimRight();
}

String _statusLabel(AppLocalizations l10n, ScanItemStatus status) {
  return switch (status) {
    ScanItemStatus.pendingIdentify ||
    ScanItemStatus.pendingSync ||
    ScanItemStatus.syncing => l10n.haulStatusIdentifying,
    ScanItemStatus.complete => l10n.haulStatusSaved,
    ScanItemStatus.failed => l10n.itemDetailStatusValue(status.name),
  };
}

class _HaulSummaryRow extends StatelessWidget {
  const _HaulSummaryRow({
    required this.label,
    required this.valueText,
    required this.onOpenSummary,
  });

  final String label;
  final String valueText;
  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      blurSigma: AppBlur.tileSigma,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      fillOpacity: AppOpacity.glassTile,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  valueText,
                  style: AppTypography.metricsFrom(
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ) ??
                        const TextStyle(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _IconSquareButton(
            semanticLabel: AppLocalizations.of(context)!.haulOpenSummary,
            icon: Icons.bar_chart_rounded,
            onPressed: onOpenSummary,
          ),
        ],
      ),
    );
  }
}

class _HaulItemRow extends StatelessWidget {
  const _HaulItemRow({
    required this.item,
    required this.title,
    required this.statusLabel,
    required this.onTap,
  });

  final ScanItem item;
  final String title;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      blurSigma: AppBlur.tileSigma,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      fillOpacity: AppOpacity.glassTile,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: item.thumbPath == null
                  ? Container(
                      width: 56,
                      height: 56,
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_rounded),
                    )
                  : Image.file(
                      File(item.thumbPath!),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      cacheWidth: 112,
                      cacheHeight: 112,
                      errorBuilder: (context, _, _) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: AppColors.surface,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  _StatusChip(label: statusLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.eucalyptus.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.inkDeep.withValues(alpha: 0.80),
        ),
      ),
    );
  }
}

class _CameraFab extends StatelessWidget {
  const _CameraFab({required this.onPressed, required this.semanticLabel});

  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return _IconSquareButton(
      semanticLabel: semanticLabel,
      icon: Icons.camera_alt_rounded,
      onPressed: onPressed,
    );
  }
}

class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.dopamineRed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icon,
              color: AppColors.textOnPrimary.withValues(alpha: 0.92),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
