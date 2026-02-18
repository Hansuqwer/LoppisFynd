import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/glass_button.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(appDatabaseProvider);
    final isOnline = ref
        .watch(isOnlineProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncStatusTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            BentoCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.syncStatusActionsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isOnline ? l10n.syncStatusOnline : l10n.syncStatusOffline,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  FutureBuilder<int?>(
                    future: db.appSettingsDao.getInt('dev_mode_enabled_v1'),
                    builder: (context, snapshot) {
                      final isDev = (snapshot.data ?? 0) == 1;
                      if (!isDev) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: GlassButton(
                          label: l10n.syncStatusSyncNow,
                          icon: const Icon(Icons.sync_rounded),
                          onPressed: () {
                            ref
                                .read(cloudSyncCoordinatorProvider)
                                .syncIfNeeded(isOnline: isOnline, force: true);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            StreamBuilder(
              stream: db.entitySyncStatusesDao.watchProblems(),
              builder: (context, snapshot) {
                final rows = snapshot.data ?? const [];
                if (rows.isEmpty) {
                  return EmptyState(
                    title: l10n.syncStatusAllGoodTitle,
                    message: l10n.syncStatusAllGoodMessage,
                    icon: Icons.cloud_done_rounded,
                  );
                }

                return BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.syncStatusProblemsTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...rows.map((r) {
                        final icon = switch (r.status) {
                          'syncing' => Icons.cloud_upload_rounded,
                          'failed' => Icons.cloud_off_rounded,
                          'conflict' => Icons.warning_amber_rounded,
                          _ => Icons.cloud_rounded,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.glassFill,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(icon, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.entityKey,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        l10n.syncStatusRowStatusUpdated(
                                          r.status,
                                          r.updatedAt.toIso8601String(),
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      if (r.lastError != null &&
                                          r.lastError!.trim().isNotEmpty) ...[
                                        const SizedBox(height: AppSpacing.xxs),
                                        Text(
                                          r.lastError!,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
