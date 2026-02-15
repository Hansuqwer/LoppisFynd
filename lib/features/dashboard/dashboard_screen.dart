import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app/providers.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
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

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.dashboardSubtitle),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: l10n.dashboardQuickScan,
            icon: const Icon(Icons.camera_alt_rounded),
            onPressed: () {
              // Switch to Scan tab via the deep-link skeleton provider.
              ref.read(deepLinkTabIndexProvider.notifier).state = 1;
            },
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.sm),
          GlassButton(
            label: l10n.dashboardHaulSummary,
            tone: GlassButtonTone.neutral,
            icon: const Icon(Icons.assessment_rounded),
            onPressed: () {
              Navigator.of(context).push(
                SpringRoute(
                  builder: (_) => HaulSummaryScreen(haulId: defaultHaulId),
                ),
              );
            },
          ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.lg),
          StreamBuilder(
            stream: db.draftListingsDao.watchAllForUser(userId: userId),
            builder: (context, snapshot) {
              final rows = snapshot.data ?? const [];
              final shown = rows.length > 3 ? rows.take(3).toList() : rows;

              return BentoCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.dashboardDraftsTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              SpringRoute(builder: (_) => const DraftsScreen()),
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
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: GlassButton(
                            tone: GlassButtonTone.neutral,
                            icon: const Icon(Icons.edit_note_rounded),
                            label: (row.draft.title?.trim().isNotEmpty ?? false)
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
                  ],
                ),
              );
            },
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}
