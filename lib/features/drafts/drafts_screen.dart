import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../analyzer/item_detail_screen.dart';
import 'draft_editor_screen.dart';

class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.draftsTitle)),
      body: SafeArea(
        child: StreamBuilder<List<({DraftListing draft, ScanItem item})>>(
          stream: db.draftListingsDao.watchAllForUser(userId: userId),
          builder: (context, snapshot) {
            final rows = snapshot.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (rows.isEmpty)
                  EmptyState(
                    title: l10n.draftsEmptyTitle,
                    message: l10n.draftsEmptyMessage,
                    icon: Icons.edit_note_rounded,
                  )
                else
                  ...rows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: BentoCard(
                        onTap: () {
                          Navigator.of(context).push(
                            SpringRoute(
                              builder: (_) =>
                                  DraftEditorScreen(scanItemId: row.item.id),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: _DraftRow(
                          draft: row.draft,
                          item: row.item,
                          onOpenAnalyzer: () {
                            Navigator.of(context).push(
                              SpringRoute(
                                builder: (_) =>
                                    ItemDetailScreen(scanItemId: row.item.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.draft,
    required this.item,
    required this.onOpenAnalyzer,
  });

  final DraftListing draft;
  final ScanItem item;
  final VoidCallback onOpenAnalyzer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final thumbPath = item.thumbPath;
    final title = draft.title?.trim();
    final subtitle = (item.desc?.trim().isNotEmpty ?? false)
        ? item.desc!.trim()
        : (item.query?.trim().isNotEmpty ?? false)
        ? item.query!.trim()
        : l10n.draftsItemFallback;

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
                title == null || title.isEmpty ? l10n.draftsUntitled : title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _Pill(
                    icon: Icons.open_in_new_rounded,
                    label: l10n.draftsOpenAnalyzer,
                    onTap: onOpenAnalyzer,
                  ),
                  if (draft.askingPriceSek != null)
                    _Pill(
                      icon: Icons.sell_rounded,
                      label: l10n.draftsAskingPrice(
                        draft.askingPriceSek!.round(),
                      ),
                      onTap: null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
