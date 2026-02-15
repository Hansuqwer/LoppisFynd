import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

import 'package:uuid/uuid.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../core/navigation/spring_route.dart';
import '../../features/summary/haul_summary_screen.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/empty_state.dart';
import '../../gen/app_localizations.dart';
import 'widgets/haul_pins_map.dart';

enum _PinFilter { all, profit, loss }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _filter = _PinFilter.all;

  Future<void> _createHaul(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);
    final titleController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        var suggesting = false;
        String? suggestError;

        Future<void> suggestName(StateSetter setState) async {
          final lat = double.tryParse(latController.text.trim());
          final lng = double.tryParse(lngController.text.trim());
          if (lat == null || lng == null) {
            setState(() => suggestError = l10n.historyEnterLatLngFirst);
            return;
          }

          setState(() {
            suggesting = true;
            suggestError = null;
          });
          try {
            final places = await placemarkFromCoordinates(lat, lng);
            final p = places.isEmpty ? null : places.first;
            final locality = p?.locality?.trim();
            final subLocality = p?.subLocality?.trim();
            final admin = p?.administrativeArea?.trim();

            final name = (subLocality != null && subLocality.isNotEmpty)
                ? (locality != null && locality.isNotEmpty
                      ? '$subLocality, $locality'
                      : subLocality)
                : (locality != null && locality.isNotEmpty
                      ? locality
                      : (admin ?? l10n.commonHaul));

            titleController.text = name;
          } catch (e) {
            setState(() => suggestError = '$e');
          } finally {
            setState(() => suggesting = false);
          }
        }

        return AlertDialog(
          title: Text(l10n.historyNewHaulTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: l10n.historyHaulTitleLabel,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton(
                            tooltip: l10n.historySuggestNameTooltip,
                            onPressed: suggesting
                                ? null
                                : () => suggestName(setState),
                            icon: suggesting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome_rounded),
                          ),
                        ],
                      ),
                      if (suggestError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          suggestError!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primaryAction),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: l10n.historyHaulLatitudeOptionalLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: lngController,
                decoration: InputDecoration(
                  labelText: l10n.historyHaulLongitudeOptionalLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonCreate),
            ),
          ],
        );
      },
    );

    final title = titleController.text.trim();
    final lat = double.tryParse(latController.text.trim());
    final lng = double.tryParse(lngController.text.trim());

    titleController.dispose();
    latController.dispose();
    lngController.dispose();

    if (ok != true) return;
    if (title.isEmpty) return;

    final id = const Uuid().v4();
    await db.haulsDao.insertNew(id: id, title: title, lat: lat, lng: lng);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final defaultHaulId = ref.watch(defaultHaulIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: StreamBuilder(
        stream: db.haulsDao.watchAll(),
        builder: (context, snapshot) {
          final hauls = snapshot.data ?? const [];
          return StreamBuilder(
            stream: db.scanItemsDao.watchAll(),
            builder: (context, scanSnapshot) {
              final items = scanSnapshot.data ?? const [];
              final profitByHaul = <String, double>{};
              for (final it in items) {
                final p = it.purchasePrice;
                final m = it.medianPrice;
                if (p == null || m == null) continue;
                profitByHaul[it.haulId] =
                    (profitByHaul[it.haulId] ?? 0) +
                    ((m * it.conditionMultiplier) - p);
              }

              final pinsAll = hauls
                  .where((h) => h.lat != null && h.lng != null)
                  .map((h) {
                    final profit = profitByHaul[h.id] ?? 0;
                    return HaulPin(
                      lat: h.lat!,
                      lng: h.lng!,
                      label: h.id == defaultHaulId ? l10n.haulTitle : h.title,
                      profitSek: profit,
                    );
                  })
                  .toList();

              final pins = switch (_filter) {
                _PinFilter.all => pinsAll,
                _PinFilter.profit =>
                  pinsAll.where((p) => p.profitSek > 0).toList(),
                _PinFilter.loss =>
                  pinsAll.where((p) => p.profitSek < 0).toList(),
              };

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  BentoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.historyTreasureMapTitle,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _createHaul(context, ref),
                              icon: const Icon(Icons.add_rounded),
                              tooltip: l10n.historyNewHaulTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.historyFilterAll),
                              selected: _filter == _PinFilter.all,
                              onSelected: (_) =>
                                  setState(() => _filter = _PinFilter.all),
                            ),
                            ChoiceChip(
                              label: Text(l10n.historyFilterProfit),
                              selected: _filter == _PinFilter.profit,
                              onSelected: (_) =>
                                  setState(() => _filter = _PinFilter.profit),
                            ),
                            ChoiceChip(
                              label: Text(l10n.historyFilterLoss),
                              selected: _filter == _PinFilter.loss,
                              onSelected: (_) =>
                                  setState(() => _filter = _PinFilter.loss),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        HaulPinsMap(pins: pins),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.historyPinnedHaulsCount(pins.length),
                          style: Theme.of(context).textTheme.bodyMedium,
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
                          l10n.historyHistoryTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (hauls.isEmpty)
                          EmptyState(
                            title: l10n.historyEmptyTitle,
                            message: l10n.historyEmptyMessage,
                            icon: Icons.shopping_bag_outlined,
                          )
                        else
                          ...hauls.map((h) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: GlassButton(
                                label: h.id == defaultHaulId
                                    ? l10n.haulTitle
                                    : h.title,
                                tone: GlassButtonTone.neutral,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    SpringRoute(
                                      builder: (_) =>
                                          HaulSummaryScreen(haulId: h.id),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_bag_rounded),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
