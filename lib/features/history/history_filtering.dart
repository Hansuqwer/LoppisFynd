import '../../core/database/app_database.dart';

enum HistorySort { recent, profit }

List<Haul> filterAndSortHauls({
  required Iterable<Haul> hauls,
  required Map<String, double> profitByHaul,
  required Map<String, Set<String>> categoriesByHaul,
  required String search,
  required String? category,
  required HistorySort sort,
}) {
  final q = search.trim().toLowerCase();
  final out = hauls
      .where((h) {
        if (q.isNotEmpty && !h.title.toLowerCase().contains(q)) return false;
        if (category != null) {
          final cats = categoriesByHaul[h.id];
          if (cats == null || !cats.contains(category)) return false;
        }
        return true;
      })
      .toList(growable: false);

  if (sort == HistorySort.profit) {
    out.sort((a, b) {
      final pa = profitByHaul[a.id] ?? 0;
      final pb = profitByHaul[b.id] ?? 0;
      return pb.compareTo(pa);
    });
  }
  return out;
}
