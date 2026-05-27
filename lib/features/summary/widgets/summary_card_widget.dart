import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/navigation/spring_route.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';
import '../../../shared/widgets/bento_card.dart';
import '../../drafts/draft_editor_screen.dart';
import '../../drafts/drafts_screen.dart';
import 'inline_row_button.dart';

class DraftsSummaryCard extends StatelessWidget {
  const DraftsSummaryCard({
    super.key,
    required this.db,
    required this.haulId,
    required this.userId,
  });

  final AppDatabase db;
  final String haulId;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: StreamBuilder<List<({DraftListing draft, ScanItem item})>>(
        stream: db.draftListingsDao.watchByHaulId(
          haulId: haulId,
          userId: userId,
        ),
        builder: (context, draftSnapshot) {
          final drafts = draftSnapshot.data ?? const [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.haulSummaryDraftsTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
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
              if (drafts.isEmpty)
                Text(
                  l10n.haulSummaryNoDraftsYet,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...drafts.take(3).map((row) {
                  final title = row.draft.title?.trim();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: InlineRowButton(
                      icon: Icons.edit_note_rounded,
                      label: (title == null || title.isEmpty)
                          ? l10n.dashboardUntitledDraft
                          : title,
                      onTap: () {
                        Navigator.of(context).push(
                          SpringRoute(
                            builder: (_) =>
                                DraftEditorScreen(scanItemId: row.item.id),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
