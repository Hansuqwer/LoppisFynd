import 'package:drift/drift.dart';

class PriceButtonConfig extends Table {
  IntColumn get position => integer()();
  IntColumn get priceSek => integer()();

  @override
  Set<Column> get primaryKey => {position};
}
