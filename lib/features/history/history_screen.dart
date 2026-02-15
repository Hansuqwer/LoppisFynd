import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:uuid/uuid.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/tokens/app_tokens.dart';
import '../../core/navigation/spring_route.dart';
import '../../features/summary/haul_summary_screen.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/empty_state.dart';
import '../../gen/app_localizations.dart';
import '../analyzer/profit_calculator.dart';
import '../../services/location/location_service.dart';
import '../../services/location/reverse_geocode_cache_service.dart';
import '../../services/sync/cloud/entity_keys.dart';
import 'widgets/haul_pins_map.dart';
import 'history_filtering.dart';

enum _PinFilter { all, profit, loss }

enum _HistoryView { both, map, list }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _filter = _PinFilter.all;
  var _view = _HistoryView.both;
  var _sort = HistorySort.recent;
  var _search = '';
  String? _category;

  static const _kLocationEducated = 'location_permission_educated_v1';

  Future<void> _createHaul(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(activeUserIdProvider);
    final titleController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        var suggesting = false;
        var locating = false;
        String? suggestError;
        String? locateError;

        Future<bool> educateLocation() async {
          final educated = await db.appSettingsDao.getInt(_kLocationEducated);
          if (educated == 1) return true;

          if (!context.mounted) return false;

          final ok = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(l10n.historyLocationPermissionTitle),
                content: Text(l10n.historyLocationPermissionBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.historyLocationPermissionNotNow),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.historyLocationPermissionContinue),
                  ),
                ],
              );
            },
          );

          if (ok == true) {
            await db.appSettingsDao.setInt(_kLocationEducated, 1);
            return true;
          }
          return false;
        }

        Future<void> fillFromLocation(StateSetter setState) async {
          if (locating) return;
          setState(() {
            locating = true;
            locateError = null;
          });
          try {
            final proceed = await educateLocation();
            if (!proceed) {
              setState(() => locating = false);
              return;
            }

            final perm = await LocationService().ensurePermission();
            if (perm == LocationPermission.denied) {
              setState(() {
                locateError = l10n.historyLocationPermissionDenied;
              });
              return;
            }
            if (perm == LocationPermission.deniedForever) {
              setState(() {
                locateError = l10n.historyLocationPermissionPermanentlyDenied;
              });
              await Geolocator.openAppSettings();
              return;
            }

            final pos = await LocationService().getCurrentPosition();
            final lat = pos.latitude;
            final lng = pos.longitude;
            latController.text = lat.toStringAsFixed(6);
            lngController.text = lng.toStringAsFixed(6);

            if (titleController.text.trim().isEmpty) {
              final suggested = await ReverseGeocodeCacheService(
                db: db,
              ).suggestName(lat: lat, lng: lng, fallback: l10n.commonHaul);
              if (suggested != null && suggested.trim().isNotEmpty) {
                titleController.text = suggested;
              }
            }
          } catch (e) {
            setState(() => locateError = '$e');
          } finally {
            setState(() => locating = false);
          }
        }

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
            final name = await ReverseGeocodeCacheService(
              db: db,
            ).suggestName(lat: lat, lng: lng, fallback: l10n.commonHaul);
            if (name == null) {
              setState(() => suggestError = l10n.historySuggestNameFailed);
              return;
            }
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
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.historyLocationOptionalHint,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: locating
                                ? null
                                : () => fillFromLocation(setState),
                            icon: locating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            label: Text(
                              locating
                                  ? l10n.historyLocationFetching
                                  : l10n.historyUseCurrentLocation,
                            ),
                          ),
                        ],
                      ),
                      if (locateError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          locateError!,
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
    await db.haulsDao.insertNew(
      id: id,
      userId: userId,
      title: title,
      lat: lat,
      lng: lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final defaultHaulId = ref.watch(defaultHaulIdProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: StreamBuilder(
        stream: db.haulsDao.watchAll(userId: userId),
        builder: (context, snapshot) {
          final hauls = snapshot.data ?? const [];
          return StreamBuilder(
            stream: db.scanItemsDao.watchAll(userId: userId),
            builder: (context, scanSnapshot) {
              final items = scanSnapshot.data ?? const [];
              final profitByHaul = <String, double>{};
              final categoriesByHaul = <String, Set<String>>{};
              for (final it in items) {
                final cat = it.category?.trim();
                if (cat != null && cat.isNotEmpty) {
                  (categoriesByHaul[it.haulId] ??= <String>{}).add(cat);
                }

                final p = it.purchasePrice;
                final m = it.medianPrice;
                if (p == null || m == null) continue;
                final expectedSale = m * it.conditionMultiplier;
                final net = ProfitCalculator.netProfit(
                  purchasePrice: p,
                  expectedSalePrice: expectedSale,
                  fixedFeesSek: it.fixedFeesSek ?? 0,
                  shippingPaidBySellerSek: it.shippingPaidBySellerSek ?? 0,
                );
                if (net == null) continue;
                profitByHaul[it.haulId] = (profitByHaul[it.haulId] ?? 0) + net;
              }

              final allCategories =
                  categoriesByHaul.values
                      .expand((s) => s)
                      .toSet()
                      .toList(growable: false)
                    ..sort();

              if (_category != null && !allCategories.contains(_category)) {
                _category = null;
              }

              final filteredHauls = filterAndSortHauls(
                hauls: hauls,
                profitByHaul: profitByHaul,
                categoriesByHaul: categoriesByHaul,
                search: _search,
                category: _category,
                sort: _sort,
              );

              final pinsAll = filteredHauls
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
                                l10n.historyHistoryTitle,
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
                          runSpacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.historyViewBoth),
                              selected: _view == _HistoryView.both,
                              onSelected: (_) =>
                                  setState(() => _view = _HistoryView.both),
                            ),
                            ChoiceChip(
                              label: Text(l10n.historyViewMap),
                              selected: _view == _HistoryView.map,
                              onSelected: (_) =>
                                  setState(() => _view = _HistoryView.map),
                            ),
                            ChoiceChip(
                              label: Text(l10n.historyViewList),
                              selected: _view == _HistoryView.list,
                              onSelected: (_) =>
                                  setState(() => _view = _HistoryView.list),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            ChoiceChip(
                              label: Text(l10n.historySortRecent),
                              selected: _sort == HistorySort.recent,
                              onSelected: (_) =>
                                  setState(() => _sort = HistorySort.recent),
                            ),
                            ChoiceChip(
                              label: Text(l10n.historySortProfit),
                              selected: _sort == HistorySort.profit,
                              onSelected: (_) =>
                                  setState(() => _sort = HistorySort.profit),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          decoration: InputDecoration(
                            labelText: l10n.historySearchLabel,
                            hintText: l10n.historySearchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                        if (allCategories.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              ChoiceChip(
                                label: Text(l10n.historyCategoryAll),
                                selected: _category == null,
                                onSelected: (_) =>
                                    setState(() => _category = null),
                              ),
                              ...allCategories.map(
                                (c) => ChoiceChip(
                                  label: Text(c),
                                  selected: _category == c,
                                  onSelected: (_) =>
                                      setState(() => _category = c),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_view == _HistoryView.both ||
                      _view == _HistoryView.map) ...[
                    const SizedBox(height: AppSpacing.lg),
                    BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.historyTreasureMapTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
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
                  ],
                  if (_view == _HistoryView.both ||
                      _view == _HistoryView.list) ...[
                    const SizedBox(height: AppSpacing.lg),
                    BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.historyHaulsTitle,
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
                          else if (filteredHauls.isEmpty)
                            EmptyState(
                              title: l10n.historyNoMatchesTitle,
                              message: l10n.historyNoMatchesMessage,
                              icon: Icons.filter_alt_off_rounded,
                            )
                          else
                            StreamBuilder<Map<String, EntitySyncStatuse>>(
                              stream: db.entitySyncStatusesDao.watchMany(
                                filteredHauls.map((h) => haulEntityKey(h.id)),
                              ),
                              builder: (context, statusSnapshot) {
                                final statuses =
                                    statusSnapshot.data ?? const {};

                                IconData iconFor(String entityKey) {
                                  final s = statuses[entityKey]?.status;
                                  return switch (s) {
                                    'syncing' => Icons.cloud_upload_rounded,
                                    'failed' => Icons.cloud_off_rounded,
                                    'conflict' => Icons.warning_amber_rounded,
                                    _ => Icons.shopping_bag_rounded,
                                  };
                                }

                                return Column(
                                  children: [
                                    for (final h in filteredHauls)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm,
                                        ),
                                        child: GlassButton(
                                          label: () {
                                            final title = h.id == defaultHaulId
                                                ? l10n.haulTitle
                                                : h.title;
                                            final profit = profitByHaul[h.id];
                                            final profitText = profit == null
                                                ? ''
                                                : (profit >= 0
                                                      ? ' +${profit.round()} SEK'
                                                      : ' ${profit.round()} SEK');
                                            return '$title$profitText';
                                          }(),
                                          tone: GlassButtonTone.neutral,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              SpringRoute(
                                                builder: (_) =>
                                                    HaulSummaryScreen(
                                                      haulId: h.id,
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            iconFor(haulEntityKey(h.id)),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
