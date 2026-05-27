import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables/scan_items.dart';
import '../../../core/navigation/spring_route.dart';
import '../../../core/settings/app_settings_keys.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';
import '../../../shared/widgets/bento_card.dart';
import '../../../shared/widgets/cloud_identification_disclosure.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../drafts/draft_editor_screen.dart';
import '../../settings/settings_screen.dart';
import 'keyword_chips.dart';
import 'price_chart.dart';
import 'stat_line.dart';

class MarketStatsWidget extends ConsumerStatefulWidget {
  const MarketStatsWidget({
    super.key,
    required this.item,
    required this.db,
  });

  final ScanItem item;
  final AppDatabase db;

  @override
  ConsumerState<MarketStatsWidget> createState() => _MarketStatsWidgetState();
}

class _MarketStatsWidgetState extends ConsumerState<MarketStatsWidget> {
  final _queryController = TextEditingController();
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    _queryController.text = widget.item.query ?? '';
    _lastQuery = widget.item.query;
  }

  @override
  void didUpdateWidget(MarketStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final query = widget.item.query;
    if (query != _lastQuery) {
      _lastQuery = query;
      _queryController.text = query ?? '';
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _openSettings() {
    Navigator.of(context).push(SpringRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _queueSync(AppDatabase db) async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    await db.scanItemsDao.setQuery(
      id: widget.item.id,
      query: query,
    );
    await db.scanItemsDao.transitionStatus(
      id: widget.item.id,
      to: ScanItemStatus.pendingSync,
    );
  }

  Future<void> _showOfflineCloudIdentifySheet() {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cloudIdentifyOfflineTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.cloudIdentifyOfflineBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: l10n.buttonRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassButton(
                        label: l10n.commonOpenSettings,
                        tone: GlassButtonTone.neutral,
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCloudIdentifyTap({required bool isOnline}) async {
    final db = widget.db;
    final enabled =
        (await db.appSettingsDao.getInt(kPrivacyCloudIdentificationEnabledKeyV1)) ??
            1;
    if (enabled != 1) return;

    if (!isOnline) {
      await _showOfflineCloudIdentifySheet();
      return;
    }

    final choice =
        (await db.appSettingsDao.getInt(kCloudIdentificationDisclosureChoiceKeyV1)) ??
            0;
    if (choice != 1) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      final next = await showCloudIdentificationDisclosure(
        context,
        l10n: l10n,
        previewImage: null,
      );
      if (!mounted || next == null) return;
      await db.appSettingsDao.setInt(
        kCloudIdentificationDisclosureChoiceKeyV1,
        next,
      );
      if (next != 1) return;

      await db.appSettingsDao.setInt(
        kPrivacyCloudIdentificationEnabledKeyV1,
        1,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cloud identification not available')),
    );
  }

  Future<void> _setQuery(AppDatabase db, String query) {
    final trimmed = query.trim();
    _queryController.text = trimmed;
    return db.scanItemsDao.setQuery(
      id: widget.item.id,
      query: trimmed.isEmpty ? null : trimmed,
    );
  }

  List<String> _tokensFromQuery(String? query) {
    final q = (query ?? '').trim();
    if (q.isEmpty) return const [];
    return q
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(5)
        .toList(growable: false);
  }

  Future<String?> _promptForToken({
    required BuildContext context,
    String? initial,
  }) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(
            initial == null
                ? l10n.itemDetailKeywordAddTitle
                : l10n.itemDetailKeywordEditTitle,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.itemDetailKeywordHint),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final db = widget.db;
    final l10n = AppLocalizations.of(context)!;
    final syncScheduler = ref.watch(syncSchedulerProvider);
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.maybeWhen(
      data: (v) => v,
      orElse: () => true,
    );
    final cloudIdentificationEnabled = ref
        .watch(cloudIdentificationEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    final compsEnabled = ref
        .watch(fetchSoldPriceCompsEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    final isOnlineForComps = isOnlineAsync.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );
    final config = ref.watch(appConfigProvider);
    final hasTraderaProxy = config.hasTraderaProxy;
    final compsActionsEnabled =
        compsEnabled && isOnlineForComps && hasTraderaProxy;

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.itemDetailMarketTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (item.confidence != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.itemDetailAiConfidence(
                (item.confidence! * 100).round(),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder(
            stream: db.scanItemCompsDao.watchByScanItemId(item.id),
            builder: (context, snapshot) {
              final comps = snapshot.data;
              final fetchedAt = comps?.fetchedAt;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PriceChart(
                    min: item.minPrice,
                    median: item.medianPrice,
                    max: item.maxPrice,
                    compsRawJson: comps?.rawJson,
                  ),
                  if (fetchedAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Last updated: ${_formatTimestamp(context, fetchedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatLine(
                  label: l10n.itemDetailStatMin,
                  value: _formatSek(item.minPrice),
                ),
              ),
              Expanded(
                child: StatLine(
                  label: l10n.itemDetailStatMedian,
                  value: _formatSek(item.medianPrice),
                ),
              ),
              Expanded(
                child: StatLine(
                  label: l10n.itemDetailStatMax,
                  value: _formatSek(item.maxPrice),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: l10n.itemDetailIdentifyNow,
                  icon: const Icon(Icons.psychology_alt_rounded),
                  onPressed: !cloudIdentificationEnabled
                      ? null
                      : () async {
                          await _handleCloudIdentifyTap(isOnline: isOnline);
                        },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassButton(
                  label: l10n.itemDetailDraftListing,
                  tone: GlassButtonTone.neutral,
                  icon: const Icon(Icons.edit_note_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      SpringRoute(
                        builder: (_) =>
                            DraftEditorScreen(scanItemId: item.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (!cloudIdentificationEnabled) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.cloudIdentifyDisabledHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            GlassButton(
              label: l10n.commonOpenSettings,
              tone: GlassButtonTone.neutral,
              icon: const Icon(Icons.settings_rounded),
              onPressed: _openSettings,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          GlassButton(
            label: l10n.itemDetailDraftListing,
            tone: GlassButtonTone.neutral,
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () {
              Navigator.of(context).push(
                SpringRoute(
                  builder: (_) =>
                      DraftEditorScreen(scanItemId: item.id),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          KeywordChips(
            tokens: _tokensFromQuery(item.query),
            onAdd: () async {
              final v = await _promptForToken(context: context);
              if (v == null) return;
              final nextToken = v.trim();
              if (nextToken.isEmpty) return;
              final tokens = [..._tokensFromQuery(item.query)];
              if (tokens.length >= 5) return;
              tokens.add(nextToken);
              await _setQuery(db, tokens.join(' '));
            },
            onEdit: (index) async {
              final tokens = [..._tokensFromQuery(item.query)];
              if (index < 0 || index >= tokens.length) return;
              final v = await _promptForToken(
                context: context,
                initial: tokens[index],
              );
              if (v == null) return;
              final next = v.trim();
              if (next.isEmpty) return;
              tokens[index] = next;
              await _setQuery(db, tokens.join(' '));
            },
            onDelete: (index) async {
              final tokens = [..._tokensFromQuery(item.query)];
              if (index < 0 || index >= tokens.length) return;
              tokens.removeAt(index);
              await _setQuery(db, tokens.join(' '));
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              labelText: l10n.itemDetailTraderaQueryLabel,
              hintText: l10n.itemDetailTraderaQueryHint,
            ),
            onSubmitted: (v) => _setQuery(db, v),
            onEditingComplete: () =>
                _setQuery(db, _queryController.text),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: l10n.itemDetailQueueSync,
                  onPressed: !compsActionsEnabled
                      ? null
                      : () async {
                          final messenger =
                              ScaffoldMessenger.of(context);
                          await _queueSync(db);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.itemDetailQueuedForSync,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.cloud_upload_rounded),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassButton(
                  label: l10n.settingsSyncNow,
                  tone: GlassButtonTone.neutral,
                  onPressed: !compsActionsEnabled
                      ? null
                      : () async {
                          final messenger =
                              ScaffoldMessenger.of(context);
                          await _queueSync(db);
                          await syncScheduler.syncOnce();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.itemDetailSyncCompleted,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.sync_rounded),
                ),
              ),
            ],
          ),
          if (!compsActionsEnabled) ...[
            const SizedBox(height: AppSpacing.xs),
            if (!compsEnabled) ...[
              Text(
                '${l10n.settingsFetchSoldPriceCompsToggleTitle}: ${l10n.commonOff}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.settingsFetchSoldPriceCompsToggleSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              GlassButton(
                label: l10n.commonOpenSettings,
                tone: GlassButtonTone.neutral,
                icon: const Icon(Icons.settings_rounded),
                onPressed: _openSettings,
              ),
            ] else if (!isOnlineForComps) ...[
              Text(
                l10n.bannerOffline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else if (!hasTraderaProxy) ...[
              Text(
                l10n.settingsTraderaProxyNotConfigured,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
          StreamBuilder(
            stream: db.scanItemSyncStatesDao.watchByScanItemId(item.id),
            builder: (context, snapshot) {
              final state = snapshot.data;
              final lastError = state?.lastError?.trim();
              if (!compsEnabled) return const SizedBox.shrink();
              if (lastError == null || lastError.isEmpty) {
                return const SizedBox.shrink();
              }

              final nextAttemptAt = state?.nextAttemptAt;

              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.dopamineRed.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.dopamineRed.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.dopamineRed,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Last sync failed',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        lastError,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (nextAttemptAt != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Next attempt: ${_formatTimestamp(context, nextAttemptAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(BuildContext context, DateTime dt) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(dt);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(dt),
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
  return '$date $time';
}

String _formatSek(double? value) {
  if (value == null) return '—';
  final v = value.round();
  return '$v SEK';
}
