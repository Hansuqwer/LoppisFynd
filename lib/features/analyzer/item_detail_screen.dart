import 'dart:io';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/cloud_identification_disclosure.dart';
import '../../services/ai/inference/ai_types.dart';
import '../../services/ai/inference/inference_isolate_service.dart';
import '../drafts/draft_editor_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/navigation/spring_route.dart';
import '../../gen/app_localizations.dart';
import 'flip_factor.dart';
import 'profit_calculator.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.scanItemId});

  final String scanItemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final _purchaseController = TextEditingController();
  final _fixedFeesController = TextEditingController();
  final _shippingController = TextEditingController();
  final _queryController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  double? _lastPurchase;
  double? _lastFixedFees;
  double? _lastShipping;
  String? _lastQuery;
  String? _lastCategory;
  String? _lastNotes;

  var _identifying = false;
  AiCancelToken? _identifyCancel;

  @override
  void dispose() {
    _purchaseController.dispose();
    _fixedFeesController.dispose();
    _shippingController.dispose();
    _queryController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePurchasePrice(AppDatabase db, String text) async {
    final trimmed = text.trim();
    final parsed = trimmed.isEmpty ? null : double.tryParse(trimmed);
    await db.scanItemsDao.setPurchasePrice(
      id: widget.scanItemId,
      purchasePrice: parsed,
    );
  }

  Future<void> _saveFees(AppDatabase db) async {
    double? parseNullable(String text) {
      final trimmed = text.trim();
      return trimmed.isEmpty ? null : double.tryParse(trimmed);
    }

    await db.scanItemsDao.setFees(
      id: widget.scanItemId,
      fixedFeesSek: parseNullable(_fixedFeesController.text),
      shippingPaidBySellerSek: parseNullable(_shippingController.text),
    );
  }

  Future<void> _saveNotes(AppDatabase db, String text) {
    return db.scanItemsDao.setNotes(id: widget.scanItemId, notes: text);
  }

  Future<void> _saveCategory(AppDatabase db, String text) {
    return db.scanItemsDao.setCategory(id: widget.scanItemId, category: text);
  }

  Future<void> _queueSync(AppDatabase db) async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    await db.scanItemsDao.setQuery(id: widget.scanItemId, query: query);
    await db.scanItemsDao.transitionStatus(
      id: widget.scanItemId,
      to: ScanItemStatus.pendingSync,
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(SpringRoute(builder: (_) => const SettingsScreen()));
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

  Future<void> _handleCloudIdentifyTap(
    ScanItem item, {
    required bool isOnline,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final enabled =
        (await db.appSettingsDao.getInt(
          kPrivacyCloudIdentificationEnabledKeyV1,
        )) ??
        1;
    if (enabled != 1) return;

    if (!isOnline) {
      await _showOfflineCloudIdentifySheet();
      return;
    }

    final choice =
        (await db.appSettingsDao.getInt(
          kCloudIdentificationDisclosureChoiceKeyV1,
        )) ??
        0;
    if (choice != 1) {
      File? preview;
      final path = item.imagePath;
      if (path != null && path.trim().isNotEmpty) {
        preview = File(path);
      }

      final l10n = AppLocalizations.of(context)!;
      final next = await showCloudIdentificationDisclosure(
        context,
        l10n: l10n,
        previewImage: preview,
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.cloudIdentifyNotAvailableYet)));
  }

  Future<String?> _identifyNow({
    required AppDatabase db,
    required AiInferenceIsolateService ai,
    required String scanItemId,
    required String? userId,
    required String? imagePath,
  }) async {
    if (_identifying) return null;
    if (imagePath == null || imagePath.trim().isEmpty) return 'No image.';

    final file = File(imagePath);
    if (!await file.exists()) return 'No image.';

    final modeKey = userId == null
        ? 'ai_accuracy_mode_guest'
        : 'ai_accuracy_mode_$userId';
    final mode = await db.appSettingsDao.getInt(modeKey) ?? 1;
    final maxTokens = mode == 0 ? 384 : 1024;

    final token = AiCancelToken();
    setState(() {
      _identifying = true;
      _identifyCancel = token;
    });

    String? outcome;
    try {
      final result = await ai.run(
        AiInferenceRequest(
          task: const SingleItemTask(),
          imageFile: file,
          maxTokens: maxTokens,
        ),
        cancelToken: token,
      );

      if (result is SingleItemInferenceResult) {
        await db.scanItemsDao.setAiResult(
          id: scanItemId,
          aiJson: result.value.rawJson,
          query: result.value.query,
          desc: result.value.desc,
          confidence: result.value.confidence,
        );
        await db.scanItemsDao.transitionStatus(
          id: scanItemId,
          to: ScanItemStatus.pendingSync,
        );
      }
      outcome = 'Keywords updated.';
    } on AiCancelledException {
      outcome = 'Cancelled.';
    } on ModelNotInstalledException {
      outcome = 'Model not installed.';
    } catch (e) {
      outcome = 'Identify failed: $e';
    } finally {
      if (mounted) {
        setState(() {
          _identifying = false;
          _identifyCancel = null;
        });
      }
    }

    return outcome;
  }

  Future<void> _setQuery(AppDatabase db, String query) {
    final trimmed = query.trim();
    _queryController.text = trimmed;
    return db.scanItemsDao.setQuery(
      id: widget.scanItemId,
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
    final db = ref.watch(appDatabaseProvider);
    final syncScheduler = ref.watch(syncSchedulerProvider);
    final userId = ref.watch(activeUserIdProvider);
    final cloudIdentificationEnabled = ref
        .watch(cloudIdentificationEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    final isOnline = ref
        .watch(isOnlineProvider)
        .maybeWhen(data: (v) => v, orElse: () => true);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.itemDetailTitle)),
      body: SafeArea(
        child: StreamBuilder<ScanItem?>(
          stream: db.scanItemsDao.watchById(widget.scanItemId, userId: userId),
          builder: (context, snapshot) {
            final item = snapshot.data;
            if (item == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchase = item.purchasePrice;
            if (purchase != _lastPurchase) {
              _lastPurchase = purchase;
              _purchaseController.text = purchase == null
                  ? ''
                  : purchase.toStringAsFixed(purchase % 1 == 0 ? 0 : 2);
            }

            final fixedFees = item.fixedFeesSek;
            if (fixedFees != _lastFixedFees) {
              _lastFixedFees = fixedFees;
              _fixedFeesController.text = fixedFees == null
                  ? ''
                  : fixedFees.toStringAsFixed(fixedFees % 1 == 0 ? 0 : 2);
            }

            final shipping = item.shippingPaidBySellerSek;
            if (shipping != _lastShipping) {
              _lastShipping = shipping;
              _shippingController.text = shipping == null
                  ? ''
                  : shipping.toStringAsFixed(shipping % 1 == 0 ? 0 : 2);
            }

            final query = item.query;
            if (query != _lastQuery) {
              _lastQuery = query;
              _queryController.text = query ?? '';
            }

            final category = item.category;
            if (category != _lastCategory) {
              _lastCategory = category;
              _categoryController.text = category ?? '';
            }

            final notes = item.notes;
            if (notes != _lastNotes) {
              _lastNotes = notes;
              _notesController.text = notes ?? '';
            }

            final expected = item.medianPrice;
            final adjustedExpected = expected == null
                ? null
                : expected * item.conditionMultiplier;
            final profit = ProfitCalculator.grossProfit(
              purchasePrice: purchase,
              expectedSalePrice: adjustedExpected,
            );
            final netProfit = ProfitCalculator.netProfit(
              purchasePrice: purchase,
              expectedSalePrice: adjustedExpected,
              fixedFeesSek: fixedFees ?? 0,
              shippingPaidBySellerSek: shipping ?? 0,
            );
            final grade = (purchase != null && expected != null)
                ? FlipFactor.grade(
                    purchasePrice: purchase,
                    expectedSalePrice: adjustedExpected ?? expected,
                  )
                : '—';

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                BentoCard(
                  onTap: () {},
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: item.thumbPath == null
                            ? Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surface,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_rounded),
                              )
                            : Image.file(
                                File(item.thumbPath!),
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                cacheWidth: 144,
                                cacheHeight: 144,
                                errorBuilder: (context, _, _) {
                                  return Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.surface,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
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
                              item.desc ??
                                  item.query ??
                                  l10n.itemDetailUnnamedItem,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.itemDetailStatusValue(item.status.name),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itemDetailMarketTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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
                          return _PriceChart(
                            min: item.minPrice,
                            median: item.medianPrice,
                            max: item.maxPrice,
                            compsRawJson: comps?.rawJson,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _StatLine(
                              label: l10n.itemDetailStatMin,
                              value: _formatSek(item.minPrice),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: l10n.itemDetailStatMedian,
                              value: _formatSek(item.medianPrice),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
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
                                      await _handleCloudIdentifyTap(
                                        item,
                                        isOnline: isOnline,
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
                      _KeywordChips(
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
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await _queueSync(db);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.itemDetailQueuedForSync),
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
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await _queueSync(db);
                                await syncScheduler.syncOnce();
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.itemDetailSyncCompleted),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.sync_rounded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itemDetailProfitTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _purchaseController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.itemDetailPurchasePriceLabel,
                        ),
                        onSubmitted: (v) => _savePurchasePrice(db, v),
                        onEditingComplete: () =>
                            _savePurchasePrice(db, _purchaseController.text),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fixedFeesController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.itemDetailFixedFeesLabel,
                              ),
                              onSubmitted: (_) => _saveFees(db),
                              onEditingComplete: () => _saveFees(db),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextField(
                              controller: _shippingController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.itemDetailShippingSellerLabel,
                              ),
                              onSubmitted: (_) => _saveFees(db),
                              onEditingComplete: () => _saveFees(db),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ConditionAdjuster(
                        value: item.conditionMultiplier,
                        onChanged: (v) async {
                          await db.scanItemsDao.setConditionMultiplier(
                            id: item.id,
                            conditionMultiplier: v,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: l10n.itemDetailCategoryLabel,
                          hintText: l10n.itemDetailCategoryHint,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (v) => _saveCategory(db, v),
                        onEditingComplete: () =>
                            _saveCategory(db, _categoryController.text),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.itemDetailNotesLabel,
                          hintText: l10n.itemDetailNotesHint,
                        ),
                        onSubmitted: (v) => _saveNotes(db, v),
                        onEditingComplete: () =>
                            _saveNotes(db, _notesController.text),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _StatLine(
                              label: 'Expected',
                              value: _formatSek(adjustedExpected),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: 'Gross',
                              value: profit == null ? '—' : _formatSek(profit),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: 'Net (est.)',
                              value: netProfit == null
                                  ? '—'
                                  : _formatSek(netProfit),
                              emphasize: true,
                            ),
                          ),
                          Expanded(
                            child: _StatLine(label: 'Flip', value: grade),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final valueStyle = emphasize
        ? Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700);

    final valueStyleMetrics = valueStyle == null
        ? null
        : AppTypography.metricsFrom(valueStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: valueStyleMetrics),
      ],
    );
  }
}

class _ConditionAdjuster extends StatelessWidget {
  const _ConditionAdjuster({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clamped = value.clamp(0.7, 1.1);
    final label = _conditionLabel(l10n, clamped);
    final percent = ((clamped - 1.0) * 100).round();
    final sign = percent > 0 ? '+' : '';
    final percentText = percent == 0 ? '0' : '$sign$percent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.itemDetailConditionTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              l10n.itemDetailConditionValue(label, percentText),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Slider(
          value: clamped,
          min: 0.7,
          max: 1.1,
          divisions: 8,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _KeywordChips extends StatelessWidget {
  const _KeywordChips({
    required this.tokens,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<String> tokens;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.itemDetailKeywordsTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < tokens.length; i++)
              InputChip(
                label: Text(tokens[i]),
                onPressed: () => onEdit(i),
                onDeleted: () => onDelete(i),
              ),
            ActionChip(
              label: Text(l10n.commonAdd),
              onPressed: tokens.length >= 5 ? null : onAdd,
              avatar: const Icon(Icons.add_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

String _conditionLabel(AppLocalizations l10n, double multiplier) {
  if (multiplier >= 1.05) return l10n.itemDetailConditionMint;
  if (multiplier >= 0.95) return l10n.itemDetailConditionGood;
  if (multiplier >= 0.85) return l10n.itemDetailConditionFair;
  return l10n.itemDetailConditionRough;
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({
    required this.min,
    required this.median,
    required this.max,
    required this.compsRawJson,
  });

  final double? min;
  final double? median;
  final double? max;
  final String? compsRawJson;

  List<({DateTime at, double priceSek})> _salePointsFromRawJson(
    String rawJson,
  ) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return const [];
      final salesAny = decoded['sales'];
      if (salesAny is! List) return const [];

      final out = <({DateTime at, double priceSek})>[];
      for (final s in salesAny) {
        if (s is! Map) continue;
        final priceAny = s['priceSek'];
        final endAny = s['endDate'];
        final price = priceAny is num ? priceAny.toDouble() : null;
        final at = endAny is String ? DateTime.tryParse(endAny) : null;
        if (price == null || at == null) continue;
        out.add((at: at, priceSek: price));
      }

      out.sort((a, b) => a.at.compareTo(b.at));
      return out;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = compsRawJson;
    final sales = raw == null
        ? const <({DateTime at, double priceSek})>[]
        : _salePointsFromRawJson(raw);

    if (sales.length >= 2) {
      final spots = <FlSpot>[];
      for (var i = 0; i < sales.length; i += 1) {
        spots.add(FlSpot(i.toDouble(), sales[i].priceSek));
      }

      final minY = sales.map((p) => p.priceSek).reduce((a, b) => a < b ? a : b);
      final maxY = sales.map((p) => p.priceSek).reduce((a, b) => a > b ? a : b);

      return SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            minY: (minY * 0.9).clamp(0, double.infinity),
            maxY: (maxY * 1.1).clamp(0, double.infinity),
            backgroundColor: Colors.transparent,
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.deepSapphire,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3.5,
                      color: AppColors.primaryAction,
                      strokeWidth: 2,
                      strokeColor: AppColors.cloudDancer,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.deepSapphire.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
          duration: AppMotion.normal,
          curve: AppMotion.curve,
        ),
      );
    }

    if (min == null || median == null || max == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Text(AppLocalizations.of(context)!.itemDetailNoMarketDataYet),
      );
    }

    final points = <FlSpot>[
      FlSpot(0, min!),
      FlSpot(1, median!),
      FlSpot(2, max!),
    ];

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final label = switch (value.toInt()) {
                    0 => 'Min',
                    1 => 'Median',
                    2 => 'Max',
                    _ => '',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: AppColors.deepSapphire,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryAction,
                    strokeWidth: 2,
                    strokeColor: AppColors.cloudDancer,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.deepSapphire.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        duration: AppMotion.normal,
        curve: AppMotion.curve,
      ),
    );
  }
}

String _formatSek(double? value) {
  if (value == null) return '—';
  final v = value.round();
  return '$v SEK';
}
