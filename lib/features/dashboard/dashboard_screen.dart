import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app/providers.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../features/model_manager/widgets/model_download_card.dart';
import '../../gen/app_localizations.dart';
import '../summary/haul_summary_screen.dart';
import '../drafts/drafts_screen.dart';
import '../drafts/draft_editor_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final defaultHaulId = ref.watch(defaultHaulIdProvider);
    final l10n = AppLocalizations.of(context)!;

    final width = MediaQuery.sizeOf(context).width;
    final twoUp = width >= 380;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.dashboardSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkDeep.withValues(alpha: 0.72),
              ),
            ).animate().fadeIn(duration: 310.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: AppSpacing.lg),
            const _ModelPreflightCard()
                .animate()
                .fadeIn(duration: 340.ms)
                .slideY(begin: 0.06, end: 0),
            const SizedBox(height: AppSpacing.md),

            // Predictive hero action: Start Scanner.
            BentoCard(
              backgroundColor: AppColors.glassFill,
              padding: const EdgeInsets.all(AppSpacing.lg),
              onTap: () {
                ref.read(deepLinkTabIndexProvider.notifier).state = 1;
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.atmosphericFog.withValues(alpha: 0.10),
                            AppColors.cloudDancer.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: -12,
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 150,
                      color: AppColors.inkDeep.withValues(alpha: 0.06),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardQuickScan,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.scannerSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkDeep.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: () {
                          ref.read(deepLinkTabIndexProvider.notifier).state = 1;
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.inkDeep,
                          foregroundColor: AppColors.cloudDancer,
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(l10n.dashboardQuickScan),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.06, end: 0),
            const SizedBox(height: AppSpacing.md),

            if (twoUp)
              Row(
                children: [
                  Expanded(
                    child: BentoCard(
                      backgroundColor: AppColors.glassFill,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dashboardHaulSummary,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.haulTitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GlassButton(
                            label: l10n.dashboardHaulSummary,
                            tone: GlassButtonTone.neutral,
                            icon: const Icon(Icons.assessment_rounded),
                            onPressed: () {
                              Navigator.of(context).push(
                                SpringRoute(
                                  builder: (_) =>
                                      HaulSummaryScreen(haulId: defaultHaulId),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _DraftsMiniCard(dbUserId: userId)),
                ],
              )
            else ...[
              BentoCard(
                backgroundColor: AppColors.glassFill,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dashboardHaulSummary,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.haulTitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GlassButton(
                      label: l10n.dashboardHaulSummary,
                      tone: GlassButtonTone.neutral,
                      icon: const Icon(Icons.assessment_rounded),
                      onPressed: () {
                        Navigator.of(context).push(
                          SpringRoute(
                            builder: (_) =>
                                HaulSummaryScreen(haulId: defaultHaulId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _DraftsMiniCard(dbUserId: userId),
            ],
            const SizedBox(height: AppSpacing.md),

            StreamBuilder(
              stream: db.draftListingsDao.watchAllForUser(userId: userId),
              builder: (context, snapshot) {
                final rows = snapshot.data ?? const [];
                final shown = rows.length > 3 ? rows.take(3).toList() : rows;

                return BentoCard(
                  backgroundColor: AppColors.glassFill,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.dashboardDraftsTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                SpringRoute(
                                  builder: (_) => const DraftsScreen(),
                                ),
                              );
                            },
                            child: Text(l10n.dashboardSeeAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (rows.isEmpty)
                        Text(
                          l10n.dashboardNoDraftsYet,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        ...shown.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: GlassButton(
                              tone: GlassButtonTone.neutral,
                              icon: const Icon(Icons.edit_note_rounded),
                              label:
                                  (row.draft.title?.trim().isNotEmpty ?? false)
                                  ? row.draft.title!.trim()
                                  : l10n.dashboardUntitledDraft,
                              onPressed: () {
                                Navigator.of(context).push(
                                  SpringRoute(
                                    builder: (_) => DraftEditorScreen(
                                      scanItemId: row.item.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.dashboardTitle,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.inkDeep.withValues(alpha: 0.34),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06, end: 0),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _DraftsMiniCard extends ConsumerWidget {
  const _DraftsMiniCard({required this.dbUserId});

  final String? dbUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: db.draftListingsDao.watchAllForUser(userId: dbUserId),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        return BentoCard(
          backgroundColor: AppColors.glassFill,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardDraftsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                rows.isEmpty
                    ? l10n.dashboardNoDraftsYet
                    : '${rows.length} ${l10n.dashboardDraftsTitle}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkDeep.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                label: l10n.dashboardSeeAll,
                tone: GlassButtonTone.neutral,
                icon: const Icon(Icons.edit_note_rounded),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(SpringRoute(builder: (_) => const DraftsScreen()));
                },
              ),
            ],
          ),
        );
      },
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
