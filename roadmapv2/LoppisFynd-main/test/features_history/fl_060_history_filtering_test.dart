import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/features/history/history_filtering.dart';

Haul _haul({
  required String id,
  required String title,
  required DateTime startedAt,
}) {
  return Haul(
    id: id,
    userId: null,
    title: title,
    startedAt: startedAt,
    endedAt: null,
    lat: null,
    lng: null,
    totalInvested: null,
    grossValue: null,
    netProfit: null,
    co2SavedKg: null,
    updatedAt: startedAt,
  );
}

void main() {
  test('filterAndSortHauls filters by search + category', () {
    final hauls = [
      _haul(id: 'h1', title: 'Alpha haul', startedAt: DateTime(2026, 1, 1)),
      _haul(id: 'h2', title: 'Ceramics run', startedAt: DateTime(2026, 1, 2)),
      _haul(id: 'h3', title: 'Books', startedAt: DateTime(2026, 1, 3)),
    ];

    final profits = {'h1': 10.0, 'h2': 100.0, 'h3': -5.0};
    final cats = {
      'h2': {'ceramics'},
      'h3': {'books'},
    };

    final bySearch = filterAndSortHauls(
      hauls: hauls,
      profitByHaul: profits,
      categoriesByHaul: cats,
      search: 'cer',
      category: null,
      sort: HistorySort.recent,
    );
    expect(bySearch.map((h) => h.id).toList(), ['h2']);

    final byCategory = filterAndSortHauls(
      hauls: hauls,
      profitByHaul: profits,
      categoriesByHaul: cats,
      search: '',
      category: 'books',
      sort: HistorySort.recent,
    );
    expect(byCategory.map((h) => h.id).toList(), ['h3']);
  });

  test('filterAndSortHauls sorts by profit when requested', () {
    final hauls = [
      _haul(id: 'h1', title: 'A', startedAt: DateTime(2026, 1, 1)),
      _haul(id: 'h2', title: 'B', startedAt: DateTime(2026, 1, 2)),
      _haul(id: 'h3', title: 'C', startedAt: DateTime(2026, 1, 3)),
    ];
    final profits = {'h1': 10.0, 'h2': 100.0, 'h3': -5.0};

    final out = filterAndSortHauls(
      hauls: hauls,
      profitByHaul: profits,
      categoriesByHaul: const {},
      search: '',
      category: null,
      sort: HistorySort.profit,
    );
    expect(out.map((h) => h.id).toList(), ['h2', 'h1', 'h3']);
  });
}
