import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../analyzer/widgets/market_stats_widget.dart';
import '../../core/database/app_database.dart';
import '../../core/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineDetectionScreen extends ConsumerWidget {
  const OfflineDetectionScreen({super.key, required this.scanItemId});

  final String scanItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineIdentifyTitle)),
      body: StreamBuilder<ScanItem?>(
        stream: db.scanItemsDao.watchById(scanItemId, userId: userId),
        builder: (context, snapshot) {
          final item = snapshot.data;
          if (item == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                l10n.offlineIdentifyWorkingOverlay,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              MarketStatsWidget(item: item, db: db),
            ],
          );
        },
      ),
    );
  }
}
