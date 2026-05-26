import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/price_button_config.dart';

part 'price_button_config_dao.g.dart';

@DriftAccessor(tables: [PriceButtonConfig])
class PriceButtonConfigDao extends DatabaseAccessor<AppDatabase>
    with _$PriceButtonConfigDaoMixin {
  PriceButtonConfigDao(super.db);

  Future<List<PriceButtonConfigData>> getAll() {
    return (select(
      priceButtonConfig,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
  }

  Stream<List<PriceButtonConfigData>> watchAll() {
    return (select(
      priceButtonConfig,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).watch();
  }

  Future<void> upsert({required int position, required int priceSek}) {
    return into(priceButtonConfig).insertOnConflictUpdate(
      PriceButtonConfigCompanion(
        position: Value(position),
        priceSek: Value(priceSek),
      ),
    );
  }

  Future<void> seedDefaults() async {
    const defaults = [5, 10, 15, 20, 25, 30];
    for (var i = 0; i < defaults.length; i++) {
      final existing = await (select(
        priceButtonConfig,
      )..where((t) => t.position.equals(i))).getSingleOrNull();
      if (existing == null) {
        await upsert(position: i, priceSek: defaults[i]);
      }
    }
  }
}
