import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_board.dart';
import '../../features/model_manager/widgets/model_download_card.dart';
import '../../gen/app_localizations.dart';
import '../summary/haul_summary_screen.dart';
import '../drafts/drafts_screen.dart';
import '../analyzer/profit_calculator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final defaultHaulId = ref.watch(defaultHaulIdProvider);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.dashboardTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: AppColors.inkDeep.withValues(alpha: 0.70),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _HeroCtaCard(
                  title: l10n.homeHeroTitle,
                  body: l10n.homeHeroBody,
                  onTap: () {
                    ref.read(deepLinkTabIndexProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<List<ScanItem>>(
                  stream: db.scanItemsDao.watchByHaulId(
                    defaultHaulId,
                    userId: userId,
                  ),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <ScanItem>[];
                    final profit = _estimateNetProfit(items);
                    final profitText = profit == null
                        ? '—'
                        : '${_formatSek(profit, locale: intl.Intl.getCurrentLocale())} kr';

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1,
                      children: [
                        _HomeTile(
                          icon: Icons.shopping_bag_outlined,
                          title: l10n.homeTileActiveFinds,
                          value: '${items.length}',
                          onTap: () {
                            ref.read(deepLinkTabIndexProvider.notifier).state =
                                2;
                          },
                        ),
                        _HomeTile(
                          icon: Icons.trending_up_rounded,
                          title: l10n.homeTileProfitEst,
                          value: profitText,
                          onTap: () {
                            Navigator.of(context).push(
                              SpringRoute(
                                builder: (_) =>
                                    HaulSummaryScreen(haulId: defaultHaulId),
                              ),
                            );
                          },
                        ),
                        _HomeTile(
                          icon: Icons.bookmark_border_rounded,
                          title: l10n.commonSave,
                          subtitle: l10n.homeTileDrafts,
                          onTap: () {
                            Navigator.of(context).push(
                              SpringRoute(builder: (_) => const DraftsScreen()),
                            );
                          },
                        ),
                        _HomeTile(
                          icon: Icons.history_toggle_off_rounded,
                          title: l10n.homeTileHistory,
                          subtitle: l10n.homeTileCtaSeeAll,
                          onTap: () {
                            ref.read(deepLinkTabIndexProvider.notifier).state =
                                3;
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const _ModelPreflightCard(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCtaCard extends StatelessWidget {
  const _HeroCtaCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.lg);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.dopamineRed,
              AppColors.terracottaClay.withValues(alpha: 0.96),
            ],
          ),
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.bento,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -44,
                  top: -44,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textOnPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              body,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textOnPrimary.withValues(
                                      alpha: 0.88,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.textOnPrimary.withValues(
                              alpha: 0.22,
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 40,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatSek(double value, {required String locale}) {
  final f = intl.NumberFormat.decimalPattern(locale);
  return f.format(value.round());
}

double? _estimateNetProfit(List<ScanItem> items) {
  var any = false;
  var total = 0.0;
  for (final it in items) {
    final purchase = it.purchasePrice;
    final median = it.medianPrice;
    if (purchase == null || median == null) continue;
    final net = ProfitCalculator.netProfit(
      purchasePrice: purchase,
      expectedSalePrice: median * it.conditionMultiplier,
      fixedFeesSek: it.fixedFeesSek ?? 0,
      shippingPaidBySellerSek: it.shippingPaidBySellerSek ?? 0,
    );
    if (net == null) continue;
    any = true;
    total += net;
  }
  return any ? total : null;
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final valueText = value;

    return BentoCard(
      backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.34),
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: AppColors.inkDeep.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (valueText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              valueText,
              style: AppTypography.metricsFrom(
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ) ??
                    const TextStyle(),
              ),
            ),
          ] else if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModelPreflightCard extends ConsumerWidget {
  const _ModelPreflightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    if (!config.hasGemmaModelUrl) return const SizedBox.shrink();

    final consent = ref
        .watch(gemmaConsentProvider)
        .maybeWhen(data: (v) => v, orElse: () => 0);
    if (consent != 1) return const SizedBox.shrink();

    return const ModelInstallDownloadCard();
  }
}
