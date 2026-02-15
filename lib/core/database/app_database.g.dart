// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HaulsTable extends Hauls with TableInfo<$HaulsTable, Haul> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HaulsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalInvestedMeta = const VerificationMeta(
    'totalInvested',
  );
  @override
  late final GeneratedColumn<double> totalInvested = GeneratedColumn<double>(
    'total_invested',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grossValueMeta = const VerificationMeta(
    'grossValue',
  );
  @override
  late final GeneratedColumn<double> grossValue = GeneratedColumn<double>(
    'gross_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netProfitMeta = const VerificationMeta(
    'netProfit',
  );
  @override
  late final GeneratedColumn<double> netProfit = GeneratedColumn<double>(
    'net_profit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2SavedKgMeta = const VerificationMeta(
    'co2SavedKg',
  );
  @override
  late final GeneratedColumn<double> co2SavedKg = GeneratedColumn<double>(
    'co2_saved_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    startedAt,
    endedAt,
    lat,
    lng,
    totalInvested,
    grossValue,
    netProfit,
    co2SavedKg,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hauls';
  @override
  VerificationContext validateIntegrity(
    Insertable<Haul> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('total_invested')) {
      context.handle(
        _totalInvestedMeta,
        totalInvested.isAcceptableOrUnknown(
          data['total_invested']!,
          _totalInvestedMeta,
        ),
      );
    }
    if (data.containsKey('gross_value')) {
      context.handle(
        _grossValueMeta,
        grossValue.isAcceptableOrUnknown(data['gross_value']!, _grossValueMeta),
      );
    }
    if (data.containsKey('net_profit')) {
      context.handle(
        _netProfitMeta,
        netProfit.isAcceptableOrUnknown(data['net_profit']!, _netProfitMeta),
      );
    }
    if (data.containsKey('co2_saved_kg')) {
      context.handle(
        _co2SavedKgMeta,
        co2SavedKg.isAcceptableOrUnknown(
          data['co2_saved_kg']!,
          _co2SavedKgMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Haul map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Haul(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      totalInvested: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_invested'],
      ),
      grossValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_value'],
      ),
      netProfit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_profit'],
      ),
      co2SavedKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2_saved_kg'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HaulsTable createAlias(String alias) {
    return $HaulsTable(attachedDatabase, alias);
  }
}

class Haul extends DataClass implements Insertable<Haul> {
  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? lat;
  final double? lng;
  final double? totalInvested;
  final double? grossValue;
  final double? netProfit;
  final double? co2SavedKg;
  final DateTime updatedAt;
  const Haul({
    required this.id,
    required this.title,
    required this.startedAt,
    this.endedAt,
    this.lat,
    this.lng,
    this.totalInvested,
    this.grossValue,
    this.netProfit,
    this.co2SavedKg,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || totalInvested != null) {
      map['total_invested'] = Variable<double>(totalInvested);
    }
    if (!nullToAbsent || grossValue != null) {
      map['gross_value'] = Variable<double>(grossValue);
    }
    if (!nullToAbsent || netProfit != null) {
      map['net_profit'] = Variable<double>(netProfit);
    }
    if (!nullToAbsent || co2SavedKg != null) {
      map['co2_saved_kg'] = Variable<double>(co2SavedKg);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HaulsCompanion toCompanion(bool nullToAbsent) {
    return HaulsCompanion(
      id: Value(id),
      title: Value(title),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      totalInvested: totalInvested == null && nullToAbsent
          ? const Value.absent()
          : Value(totalInvested),
      grossValue: grossValue == null && nullToAbsent
          ? const Value.absent()
          : Value(grossValue),
      netProfit: netProfit == null && nullToAbsent
          ? const Value.absent()
          : Value(netProfit),
      co2SavedKg: co2SavedKg == null && nullToAbsent
          ? const Value.absent()
          : Value(co2SavedKg),
      updatedAt: Value(updatedAt),
    );
  }

  factory Haul.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Haul(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      totalInvested: serializer.fromJson<double?>(json['totalInvested']),
      grossValue: serializer.fromJson<double?>(json['grossValue']),
      netProfit: serializer.fromJson<double?>(json['netProfit']),
      co2SavedKg: serializer.fromJson<double?>(json['co2SavedKg']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'totalInvested': serializer.toJson<double?>(totalInvested),
      'grossValue': serializer.toJson<double?>(grossValue),
      'netProfit': serializer.toJson<double?>(netProfit),
      'co2SavedKg': serializer.toJson<double?>(co2SavedKg),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Haul copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> totalInvested = const Value.absent(),
    Value<double?> grossValue = const Value.absent(),
    Value<double?> netProfit = const Value.absent(),
    Value<double?> co2SavedKg = const Value.absent(),
    DateTime? updatedAt,
  }) => Haul(
    id: id ?? this.id,
    title: title ?? this.title,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    totalInvested: totalInvested.present
        ? totalInvested.value
        : this.totalInvested,
    grossValue: grossValue.present ? grossValue.value : this.grossValue,
    netProfit: netProfit.present ? netProfit.value : this.netProfit,
    co2SavedKg: co2SavedKg.present ? co2SavedKg.value : this.co2SavedKg,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Haul copyWithCompanion(HaulsCompanion data) {
    return Haul(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      totalInvested: data.totalInvested.present
          ? data.totalInvested.value
          : this.totalInvested,
      grossValue: data.grossValue.present
          ? data.grossValue.value
          : this.grossValue,
      netProfit: data.netProfit.present ? data.netProfit.value : this.netProfit,
      co2SavedKg: data.co2SavedKg.present
          ? data.co2SavedKg.value
          : this.co2SavedKg,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Haul(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('totalInvested: $totalInvested, ')
          ..write('grossValue: $grossValue, ')
          ..write('netProfit: $netProfit, ')
          ..write('co2SavedKg: $co2SavedKg, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    startedAt,
    endedAt,
    lat,
    lng,
    totalInvested,
    grossValue,
    netProfit,
    co2SavedKg,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Haul &&
          other.id == this.id &&
          other.title == this.title &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.totalInvested == this.totalInvested &&
          other.grossValue == this.grossValue &&
          other.netProfit == this.netProfit &&
          other.co2SavedKg == this.co2SavedKg &&
          other.updatedAt == this.updatedAt);
}

class HaulsCompanion extends UpdateCompanion<Haul> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> totalInvested;
  final Value<double?> grossValue;
  final Value<double?> netProfit;
  final Value<double?> co2SavedKg;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HaulsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.totalInvested = const Value.absent(),
    this.grossValue = const Value.absent(),
    this.netProfit = const Value.absent(),
    this.co2SavedKg = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HaulsCompanion.insert({
    required String id,
    required String title,
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.totalInvested = const Value.absent(),
    this.grossValue = const Value.absent(),
    this.netProfit = const Value.absent(),
    this.co2SavedKg = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<Haul> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? totalInvested,
    Expression<double>? grossValue,
    Expression<double>? netProfit,
    Expression<double>? co2SavedKg,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (totalInvested != null) 'total_invested': totalInvested,
      if (grossValue != null) 'gross_value': grossValue,
      if (netProfit != null) 'net_profit': netProfit,
      if (co2SavedKg != null) 'co2_saved_kg': co2SavedKg,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HaulsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? totalInvested,
    Value<double?>? grossValue,
    Value<double?>? netProfit,
    Value<double?>? co2SavedKg,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HaulsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      totalInvested: totalInvested ?? this.totalInvested,
      grossValue: grossValue ?? this.grossValue,
      netProfit: netProfit ?? this.netProfit,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (totalInvested.present) {
      map['total_invested'] = Variable<double>(totalInvested.value);
    }
    if (grossValue.present) {
      map['gross_value'] = Variable<double>(grossValue.value);
    }
    if (netProfit.present) {
      map['net_profit'] = Variable<double>(netProfit.value);
    }
    if (co2SavedKg.present) {
      map['co2_saved_kg'] = Variable<double>(co2SavedKg.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HaulsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('totalInvested: $totalInvested, ')
          ..write('grossValue: $grossValue, ')
          ..write('netProfit: $netProfit, ')
          ..write('co2SavedKg: $co2SavedKg, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanItemsTable extends ScanItems
    with TableInfo<$ScanItemsTable, ScanItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _haulIdMeta = const VerificationMeta('haulId');
  @override
  late final GeneratedColumn<String> haulId = GeneratedColumn<String>(
    'haul_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hauls (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta(
    'thumbPath',
  );
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiJsonMeta = const VerificationMeta('aiJson');
  @override
  late final GeneratedColumn<String> aiJson = GeneratedColumn<String>(
    'ai_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descMeta = const VerificationMeta('desc');
  @override
  late final GeneratedColumn<String> desc = GeneratedColumn<String>(
    'desc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionMultiplierMeta =
      const VerificationMeta('conditionMultiplier');
  @override
  late final GeneratedColumn<double> conditionMultiplier =
      GeneratedColumn<double>(
        'condition_multiplier',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _medianPriceMeta = const VerificationMeta(
    'medianPrice',
  );
  @override
  late final GeneratedColumn<double> medianPrice = GeneratedColumn<double>(
    'median_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minPriceMeta = const VerificationMeta(
    'minPrice',
  );
  @override
  late final GeneratedColumn<double> minPrice = GeneratedColumn<double>(
    'min_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPriceMeta = const VerificationMeta(
    'maxPrice',
  );
  @override
  late final GeneratedColumn<double> maxPrice = GeneratedColumn<double>(
    'max_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _demandScoreMeta = const VerificationMeta(
    'demandScore',
  );
  @override
  late final GeneratedColumn<int> demandScore = GeneratedColumn<int>(
    'demand_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysToSellEstMeta = const VerificationMeta(
    'daysToSellEst',
  );
  @override
  late final GeneratedColumn<int> daysToSellEst = GeneratedColumn<int>(
    'days_to_sell_est',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScanItemStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pendingIdentify'),
      ).withConverter<ScanItemStatus>($ScanItemsTable.$converterstatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    haulId,
    imagePath,
    thumbPath,
    aiJson,
    query,
    desc,
    confidence,
    purchasePrice,
    conditionMultiplier,
    medianPrice,
    minPrice,
    maxPrice,
    demandScore,
    daysToSellEst,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('haul_id')) {
      context.handle(
        _haulIdMeta,
        haulId.isAcceptableOrUnknown(data['haul_id']!, _haulIdMeta),
      );
    } else if (isInserting) {
      context.missing(_haulIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
      );
    }
    if (data.containsKey('ai_json')) {
      context.handle(
        _aiJsonMeta,
        aiJson.isAcceptableOrUnknown(data['ai_json']!, _aiJsonMeta),
      );
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    }
    if (data.containsKey('desc')) {
      context.handle(
        _descMeta,
        desc.isAcceptableOrUnknown(data['desc']!, _descMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('condition_multiplier')) {
      context.handle(
        _conditionMultiplierMeta,
        conditionMultiplier.isAcceptableOrUnknown(
          data['condition_multiplier']!,
          _conditionMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('median_price')) {
      context.handle(
        _medianPriceMeta,
        medianPrice.isAcceptableOrUnknown(
          data['median_price']!,
          _medianPriceMeta,
        ),
      );
    }
    if (data.containsKey('min_price')) {
      context.handle(
        _minPriceMeta,
        minPrice.isAcceptableOrUnknown(data['min_price']!, _minPriceMeta),
      );
    }
    if (data.containsKey('max_price')) {
      context.handle(
        _maxPriceMeta,
        maxPrice.isAcceptableOrUnknown(data['max_price']!, _maxPriceMeta),
      );
    }
    if (data.containsKey('demand_score')) {
      context.handle(
        _demandScoreMeta,
        demandScore.isAcceptableOrUnknown(
          data['demand_score']!,
          _demandScoreMeta,
        ),
      );
    }
    if (data.containsKey('days_to_sell_est')) {
      context.handle(
        _daysToSellEstMeta,
        daysToSellEst.isAcceptableOrUnknown(
          data['days_to_sell_est']!,
          _daysToSellEstMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      haulId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}haul_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      ),
      aiJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_json'],
      ),
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      ),
      desc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desc'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      ),
      conditionMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}condition_multiplier'],
      )!,
      medianPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}median_price'],
      ),
      minPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_price'],
      ),
      maxPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_price'],
      ),
      demandScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}demand_score'],
      ),
      daysToSellEst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_to_sell_est'],
      ),
      status: $ScanItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScanItemsTable createAlias(String alias) {
    return $ScanItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<ScanItemStatus, String> $converterstatus =
      const ScanItemStatusConverter();
}

class ScanItem extends DataClass implements Insertable<ScanItem> {
  final String id;
  final String haulId;
  final String? imagePath;
  final String? thumbPath;
  final String? aiJson;
  final String? query;
  final String? desc;
  final double? confidence;
  final double? purchasePrice;
  final double conditionMultiplier;
  final double? medianPrice;
  final double? minPrice;
  final double? maxPrice;
  final int? demandScore;
  final int? daysToSellEst;
  final ScanItemStatus status;
  final DateTime updatedAt;
  const ScanItem({
    required this.id,
    required this.haulId,
    this.imagePath,
    this.thumbPath,
    this.aiJson,
    this.query,
    this.desc,
    this.confidence,
    this.purchasePrice,
    required this.conditionMultiplier,
    this.medianPrice,
    this.minPrice,
    this.maxPrice,
    this.demandScore,
    this.daysToSellEst,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['haul_id'] = Variable<String>(haulId);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || thumbPath != null) {
      map['thumb_path'] = Variable<String>(thumbPath);
    }
    if (!nullToAbsent || aiJson != null) {
      map['ai_json'] = Variable<String>(aiJson);
    }
    if (!nullToAbsent || query != null) {
      map['query'] = Variable<String>(query);
    }
    if (!nullToAbsent || desc != null) {
      map['desc'] = Variable<String>(desc);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    map['condition_multiplier'] = Variable<double>(conditionMultiplier);
    if (!nullToAbsent || medianPrice != null) {
      map['median_price'] = Variable<double>(medianPrice);
    }
    if (!nullToAbsent || minPrice != null) {
      map['min_price'] = Variable<double>(minPrice);
    }
    if (!nullToAbsent || maxPrice != null) {
      map['max_price'] = Variable<double>(maxPrice);
    }
    if (!nullToAbsent || demandScore != null) {
      map['demand_score'] = Variable<int>(demandScore);
    }
    if (!nullToAbsent || daysToSellEst != null) {
      map['days_to_sell_est'] = Variable<int>(daysToSellEst);
    }
    {
      map['status'] = Variable<String>(
        $ScanItemsTable.$converterstatus.toSql(status),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScanItemsCompanion toCompanion(bool nullToAbsent) {
    return ScanItemsCompanion(
      id: Value(id),
      haulId: Value(haulId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      thumbPath: thumbPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbPath),
      aiJson: aiJson == null && nullToAbsent
          ? const Value.absent()
          : Value(aiJson),
      query: query == null && nullToAbsent
          ? const Value.absent()
          : Value(query),
      desc: desc == null && nullToAbsent ? const Value.absent() : Value(desc),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      conditionMultiplier: Value(conditionMultiplier),
      medianPrice: medianPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(medianPrice),
      minPrice: minPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(minPrice),
      maxPrice: maxPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPrice),
      demandScore: demandScore == null && nullToAbsent
          ? const Value.absent()
          : Value(demandScore),
      daysToSellEst: daysToSellEst == null && nullToAbsent
          ? const Value.absent()
          : Value(daysToSellEst),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScanItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanItem(
      id: serializer.fromJson<String>(json['id']),
      haulId: serializer.fromJson<String>(json['haulId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      aiJson: serializer.fromJson<String?>(json['aiJson']),
      query: serializer.fromJson<String?>(json['query']),
      desc: serializer.fromJson<String?>(json['desc']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      conditionMultiplier: serializer.fromJson<double>(
        json['conditionMultiplier'],
      ),
      medianPrice: serializer.fromJson<double?>(json['medianPrice']),
      minPrice: serializer.fromJson<double?>(json['minPrice']),
      maxPrice: serializer.fromJson<double?>(json['maxPrice']),
      demandScore: serializer.fromJson<int?>(json['demandScore']),
      daysToSellEst: serializer.fromJson<int?>(json['daysToSellEst']),
      status: serializer.fromJson<ScanItemStatus>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'haulId': serializer.toJson<String>(haulId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'aiJson': serializer.toJson<String?>(aiJson),
      'query': serializer.toJson<String?>(query),
      'desc': serializer.toJson<String?>(desc),
      'confidence': serializer.toJson<double?>(confidence),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'conditionMultiplier': serializer.toJson<double>(conditionMultiplier),
      'medianPrice': serializer.toJson<double?>(medianPrice),
      'minPrice': serializer.toJson<double?>(minPrice),
      'maxPrice': serializer.toJson<double?>(maxPrice),
      'demandScore': serializer.toJson<int?>(demandScore),
      'daysToSellEst': serializer.toJson<int?>(daysToSellEst),
      'status': serializer.toJson<ScanItemStatus>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScanItem copyWith({
    String? id,
    String? haulId,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> thumbPath = const Value.absent(),
    Value<String?> aiJson = const Value.absent(),
    Value<String?> query = const Value.absent(),
    Value<String?> desc = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<double?> purchasePrice = const Value.absent(),
    double? conditionMultiplier,
    Value<double?> medianPrice = const Value.absent(),
    Value<double?> minPrice = const Value.absent(),
    Value<double?> maxPrice = const Value.absent(),
    Value<int?> demandScore = const Value.absent(),
    Value<int?> daysToSellEst = const Value.absent(),
    ScanItemStatus? status,
    DateTime? updatedAt,
  }) => ScanItem(
    id: id ?? this.id,
    haulId: haulId ?? this.haulId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    aiJson: aiJson.present ? aiJson.value : this.aiJson,
    query: query.present ? query.value : this.query,
    desc: desc.present ? desc.value : this.desc,
    confidence: confidence.present ? confidence.value : this.confidence,
    purchasePrice: purchasePrice.present
        ? purchasePrice.value
        : this.purchasePrice,
    conditionMultiplier: conditionMultiplier ?? this.conditionMultiplier,
    medianPrice: medianPrice.present ? medianPrice.value : this.medianPrice,
    minPrice: minPrice.present ? minPrice.value : this.minPrice,
    maxPrice: maxPrice.present ? maxPrice.value : this.maxPrice,
    demandScore: demandScore.present ? demandScore.value : this.demandScore,
    daysToSellEst: daysToSellEst.present
        ? daysToSellEst.value
        : this.daysToSellEst,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScanItem copyWithCompanion(ScanItemsCompanion data) {
    return ScanItem(
      id: data.id.present ? data.id.value : this.id,
      haulId: data.haulId.present ? data.haulId.value : this.haulId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      aiJson: data.aiJson.present ? data.aiJson.value : this.aiJson,
      query: data.query.present ? data.query.value : this.query,
      desc: data.desc.present ? data.desc.value : this.desc,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      conditionMultiplier: data.conditionMultiplier.present
          ? data.conditionMultiplier.value
          : this.conditionMultiplier,
      medianPrice: data.medianPrice.present
          ? data.medianPrice.value
          : this.medianPrice,
      minPrice: data.minPrice.present ? data.minPrice.value : this.minPrice,
      maxPrice: data.maxPrice.present ? data.maxPrice.value : this.maxPrice,
      demandScore: data.demandScore.present
          ? data.demandScore.value
          : this.demandScore,
      daysToSellEst: data.daysToSellEst.present
          ? data.daysToSellEst.value
          : this.daysToSellEst,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanItem(')
          ..write('id: $id, ')
          ..write('haulId: $haulId, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('aiJson: $aiJson, ')
          ..write('query: $query, ')
          ..write('desc: $desc, ')
          ..write('confidence: $confidence, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('conditionMultiplier: $conditionMultiplier, ')
          ..write('medianPrice: $medianPrice, ')
          ..write('minPrice: $minPrice, ')
          ..write('maxPrice: $maxPrice, ')
          ..write('demandScore: $demandScore, ')
          ..write('daysToSellEst: $daysToSellEst, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    haulId,
    imagePath,
    thumbPath,
    aiJson,
    query,
    desc,
    confidence,
    purchasePrice,
    conditionMultiplier,
    medianPrice,
    minPrice,
    maxPrice,
    demandScore,
    daysToSellEst,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanItem &&
          other.id == this.id &&
          other.haulId == this.haulId &&
          other.imagePath == this.imagePath &&
          other.thumbPath == this.thumbPath &&
          other.aiJson == this.aiJson &&
          other.query == this.query &&
          other.desc == this.desc &&
          other.confidence == this.confidence &&
          other.purchasePrice == this.purchasePrice &&
          other.conditionMultiplier == this.conditionMultiplier &&
          other.medianPrice == this.medianPrice &&
          other.minPrice == this.minPrice &&
          other.maxPrice == this.maxPrice &&
          other.demandScore == this.demandScore &&
          other.daysToSellEst == this.daysToSellEst &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class ScanItemsCompanion extends UpdateCompanion<ScanItem> {
  final Value<String> id;
  final Value<String> haulId;
  final Value<String?> imagePath;
  final Value<String?> thumbPath;
  final Value<String?> aiJson;
  final Value<String?> query;
  final Value<String?> desc;
  final Value<double?> confidence;
  final Value<double?> purchasePrice;
  final Value<double> conditionMultiplier;
  final Value<double?> medianPrice;
  final Value<double?> minPrice;
  final Value<double?> maxPrice;
  final Value<int?> demandScore;
  final Value<int?> daysToSellEst;
  final Value<ScanItemStatus> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScanItemsCompanion({
    this.id = const Value.absent(),
    this.haulId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.aiJson = const Value.absent(),
    this.query = const Value.absent(),
    this.desc = const Value.absent(),
    this.confidence = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.conditionMultiplier = const Value.absent(),
    this.medianPrice = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.maxPrice = const Value.absent(),
    this.demandScore = const Value.absent(),
    this.daysToSellEst = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanItemsCompanion.insert({
    required String id,
    required String haulId,
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.aiJson = const Value.absent(),
    this.query = const Value.absent(),
    this.desc = const Value.absent(),
    this.confidence = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.conditionMultiplier = const Value.absent(),
    this.medianPrice = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.maxPrice = const Value.absent(),
    this.demandScore = const Value.absent(),
    this.daysToSellEst = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       haulId = Value(haulId);
  static Insertable<ScanItem> custom({
    Expression<String>? id,
    Expression<String>? haulId,
    Expression<String>? imagePath,
    Expression<String>? thumbPath,
    Expression<String>? aiJson,
    Expression<String>? query,
    Expression<String>? desc,
    Expression<double>? confidence,
    Expression<double>? purchasePrice,
    Expression<double>? conditionMultiplier,
    Expression<double>? medianPrice,
    Expression<double>? minPrice,
    Expression<double>? maxPrice,
    Expression<int>? demandScore,
    Expression<int>? daysToSellEst,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (haulId != null) 'haul_id': haulId,
      if (imagePath != null) 'image_path': imagePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (aiJson != null) 'ai_json': aiJson,
      if (query != null) 'query': query,
      if (desc != null) 'desc': desc,
      if (confidence != null) 'confidence': confidence,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (conditionMultiplier != null)
        'condition_multiplier': conditionMultiplier,
      if (medianPrice != null) 'median_price': medianPrice,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (demandScore != null) 'demand_score': demandScore,
      if (daysToSellEst != null) 'days_to_sell_est': daysToSellEst,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? haulId,
    Value<String?>? imagePath,
    Value<String?>? thumbPath,
    Value<String?>? aiJson,
    Value<String?>? query,
    Value<String?>? desc,
    Value<double?>? confidence,
    Value<double?>? purchasePrice,
    Value<double>? conditionMultiplier,
    Value<double?>? medianPrice,
    Value<double?>? minPrice,
    Value<double?>? maxPrice,
    Value<int?>? demandScore,
    Value<int?>? daysToSellEst,
    Value<ScanItemStatus>? status,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScanItemsCompanion(
      id: id ?? this.id,
      haulId: haulId ?? this.haulId,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      aiJson: aiJson ?? this.aiJson,
      query: query ?? this.query,
      desc: desc ?? this.desc,
      confidence: confidence ?? this.confidence,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      conditionMultiplier: conditionMultiplier ?? this.conditionMultiplier,
      medianPrice: medianPrice ?? this.medianPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      demandScore: demandScore ?? this.demandScore,
      daysToSellEst: daysToSellEst ?? this.daysToSellEst,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (haulId.present) {
      map['haul_id'] = Variable<String>(haulId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (aiJson.present) {
      map['ai_json'] = Variable<String>(aiJson.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (desc.present) {
      map['desc'] = Variable<String>(desc.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (conditionMultiplier.present) {
      map['condition_multiplier'] = Variable<double>(conditionMultiplier.value);
    }
    if (medianPrice.present) {
      map['median_price'] = Variable<double>(medianPrice.value);
    }
    if (minPrice.present) {
      map['min_price'] = Variable<double>(minPrice.value);
    }
    if (maxPrice.present) {
      map['max_price'] = Variable<double>(maxPrice.value);
    }
    if (demandScore.present) {
      map['demand_score'] = Variable<int>(demandScore.value);
    }
    if (daysToSellEst.present) {
      map['days_to_sell_est'] = Variable<int>(daysToSellEst.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ScanItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanItemsCompanion(')
          ..write('id: $id, ')
          ..write('haulId: $haulId, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('aiJson: $aiJson, ')
          ..write('query: $query, ')
          ..write('desc: $desc, ')
          ..write('confidence: $confidence, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('conditionMultiplier: $conditionMultiplier, ')
          ..write('medianPrice: $medianPrice, ')
          ..write('minPrice: $minPrice, ')
          ..write('maxPrice: $maxPrice, ')
          ..write('demandScore: $demandScore, ')
          ..write('daysToSellEst: $daysToSellEst, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanItemSyncStatesTable extends ScanItemSyncStates
    with TableInfo<$ScanItemSyncStatesTable, ScanItemSyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanItemSyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scanItemIdMeta = const VerificationMeta(
    'scanItemId',
  );
  @override
  late final GeneratedColumn<String> scanItemId = GeneratedColumn<String>(
    'scan_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scan_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    scanItemId,
    attempts,
    nextAttemptAt,
    lastError,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_item_sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanItemSyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scan_item_id')) {
      context.handle(
        _scanItemIdMeta,
        scanItemId.isAcceptableOrUnknown(
          data['scan_item_id']!,
          _scanItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scanItemIdMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scanItemId};
  @override
  ScanItemSyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanItemSyncState(
      scanItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_item_id'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScanItemSyncStatesTable createAlias(String alias) {
    return $ScanItemSyncStatesTable(attachedDatabase, alias);
  }
}

class ScanItemSyncState extends DataClass
    implements Insertable<ScanItemSyncState> {
  final String scanItemId;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastError;
  final DateTime updatedAt;
  const ScanItemSyncState({
    required this.scanItemId,
    required this.attempts,
    this.nextAttemptAt,
    this.lastError,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scan_item_id'] = Variable<String>(scanItemId);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScanItemSyncStatesCompanion toCompanion(bool nullToAbsent) {
    return ScanItemSyncStatesCompanion(
      scanItemId: Value(scanItemId),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScanItemSyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanItemSyncState(
      scanItemId: serializer.fromJson<String>(json['scanItemId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scanItemId': serializer.toJson<String>(scanItemId),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScanItemSyncState copyWith({
    String? scanItemId,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? updatedAt,
  }) => ScanItemSyncState(
    scanItemId: scanItemId ?? this.scanItemId,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScanItemSyncState copyWithCompanion(ScanItemSyncStatesCompanion data) {
    return ScanItemSyncState(
      scanItemId: data.scanItemId.present
          ? data.scanItemId.value
          : this.scanItemId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanItemSyncState(')
          ..write('scanItemId: $scanItemId, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(scanItemId, attempts, nextAttemptAt, lastError, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanItemSyncState &&
          other.scanItemId == this.scanItemId &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.updatedAt == this.updatedAt);
}

class ScanItemSyncStatesCompanion extends UpdateCompanion<ScanItemSyncState> {
  final Value<String> scanItemId;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScanItemSyncStatesCompanion({
    this.scanItemId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanItemSyncStatesCompanion.insert({
    required String scanItemId,
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scanItemId = Value(scanItemId);
  static Insertable<ScanItemSyncState> custom({
    Expression<String>? scanItemId,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scanItemId != null) 'scan_item_id': scanItemId,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanItemSyncStatesCompanion copyWith({
    Value<String>? scanItemId,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScanItemSyncStatesCompanion(
      scanItemId: scanItemId ?? this.scanItemId,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scanItemId.present) {
      map['scan_item_id'] = Variable<String>(scanItemId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanItemSyncStatesCompanion(')
          ..write('scanItemId: $scanItemId, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQuotasTable extends SyncQuotas
    with TableInfo<$SyncQuotasTable, SyncQuota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQuotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedMeta = const VerificationMeta('used');
  @override
  late final GeneratedColumn<int> used = GeneratedColumn<int>(
    'used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [dayKey, used, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_quotas';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQuota> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('used')) {
      context.handle(
        _usedMeta,
        used.isAcceptableOrUnknown(data['used']!, _usedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  SyncQuota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQuota(
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      used: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}used'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncQuotasTable createAlias(String alias) {
    return $SyncQuotasTable(attachedDatabase, alias);
  }
}

class SyncQuota extends DataClass implements Insertable<SyncQuota> {
  final String dayKey;
  final int used;
  final DateTime updatedAt;
  const SyncQuota({
    required this.dayKey,
    required this.used,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<String>(dayKey);
    map['used'] = Variable<int>(used);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncQuotasCompanion toCompanion(bool nullToAbsent) {
    return SyncQuotasCompanion(
      dayKey: Value(dayKey),
      used: Value(used),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncQuota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQuota(
      dayKey: serializer.fromJson<String>(json['dayKey']),
      used: serializer.fromJson<int>(json['used']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<String>(dayKey),
      'used': serializer.toJson<int>(used),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncQuota copyWith({String? dayKey, int? used, DateTime? updatedAt}) =>
      SyncQuota(
        dayKey: dayKey ?? this.dayKey,
        used: used ?? this.used,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncQuota copyWithCompanion(SyncQuotasCompanion data) {
    return SyncQuota(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      used: data.used.present ? data.used.value : this.used,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQuota(')
          ..write('dayKey: $dayKey, ')
          ..write('used: $used, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, used, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQuota &&
          other.dayKey == this.dayKey &&
          other.used == this.used &&
          other.updatedAt == this.updatedAt);
}

class SyncQuotasCompanion extends UpdateCompanion<SyncQuota> {
  final Value<String> dayKey;
  final Value<int> used;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncQuotasCompanion({
    this.dayKey = const Value.absent(),
    this.used = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQuotasCompanion.insert({
    required String dayKey,
    this.used = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayKey = Value(dayKey);
  static Insertable<SyncQuota> custom({
    Expression<String>? dayKey,
    Expression<int>? used,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (used != null) 'used': used,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQuotasCompanion copyWith({
    Value<String>? dayKey,
    Value<int>? used,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncQuotasCompanion(
      dayKey: dayKey ?? this.dayKey,
      used: used ?? this.used,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (used.present) {
      map['used'] = Variable<int>(used.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQuotasCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('used: $used, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intValueMeta = const VerificationMeta(
    'intValue',
  );
  @override
  late final GeneratedColumn<int> intValue = GeneratedColumn<int>(
    'int_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, intValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('int_value')) {
      context.handle(
        _intValueMeta,
        intValue.isAcceptableOrUnknown(data['int_value']!, _intValueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      intValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_value'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final int? intValue;
  final DateTime updatedAt;
  const AppSetting({required this.key, this.intValue, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || intValue != null) {
      map['int_value'] = Variable<int>(intValue);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      intValue: intValue == null && nullToAbsent
          ? const Value.absent()
          : Value(intValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      intValue: serializer.fromJson<int?>(json['intValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'intValue': serializer.toJson<int?>(intValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<int?> intValue = const Value.absent(),
    DateTime? updatedAt,
  }) => AppSetting(
    key: key ?? this.key,
    intValue: intValue.present ? intValue.value : this.intValue,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      intValue: data.intValue.present ? data.intValue.value : this.intValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('intValue: $intValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, intValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.intValue == this.intValue &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<int?> intValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.intValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.intValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<int>? intValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (intValue != null) 'int_value': intValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<int?>? intValue,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      intValue: intValue ?? this.intValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (intValue.present) {
      map['int_value'] = Variable<int>(intValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('intValue: $intValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarketStatsCacheTable extends MarketStatsCache
    with TableInfo<$MarketStatsCacheTable, MarketStatsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketStatsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryKeyMeta = const VerificationMeta(
    'queryKey',
  );
  @override
  late final GeneratedColumn<String> queryKey = GeneratedColumn<String>(
    'query_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minSekMeta = const VerificationMeta('minSek');
  @override
  late final GeneratedColumn<double> minSek = GeneratedColumn<double>(
    'min_sek',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medianSekMeta = const VerificationMeta(
    'medianSek',
  );
  @override
  late final GeneratedColumn<double> medianSek = GeneratedColumn<double>(
    'median_sek',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxSekMeta = const VerificationMeta('maxSek');
  @override
  late final GeneratedColumn<double> maxSek = GeneratedColumn<double>(
    'max_sek',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    queryKey,
    count,
    minSek,
    medianSek,
    maxSek,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_stats_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketStatsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query_key')) {
      context.handle(
        _queryKeyMeta,
        queryKey.isAcceptableOrUnknown(data['query_key']!, _queryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_queryKeyMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('min_sek')) {
      context.handle(
        _minSekMeta,
        minSek.isAcceptableOrUnknown(data['min_sek']!, _minSekMeta),
      );
    } else if (isInserting) {
      context.missing(_minSekMeta);
    }
    if (data.containsKey('median_sek')) {
      context.handle(
        _medianSekMeta,
        medianSek.isAcceptableOrUnknown(data['median_sek']!, _medianSekMeta),
      );
    } else if (isInserting) {
      context.missing(_medianSekMeta);
    }
    if (data.containsKey('max_sek')) {
      context.handle(
        _maxSekMeta,
        maxSek.isAcceptableOrUnknown(data['max_sek']!, _maxSekMeta),
      );
    } else if (isInserting) {
      context.missing(_maxSekMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queryKey};
  @override
  MarketStatsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketStatsCacheData(
      queryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query_key'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      minSek: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_sek'],
      )!,
      medianSek: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}median_sek'],
      )!,
      maxSek: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_sek'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $MarketStatsCacheTable createAlias(String alias) {
    return $MarketStatsCacheTable(attachedDatabase, alias);
  }
}

class MarketStatsCacheData extends DataClass
    implements Insertable<MarketStatsCacheData> {
  final String queryKey;
  final int count;
  final double minSek;
  final double medianSek;
  final double maxSek;
  final DateTime fetchedAt;
  const MarketStatsCacheData({
    required this.queryKey,
    required this.count,
    required this.minSek,
    required this.medianSek,
    required this.maxSek,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query_key'] = Variable<String>(queryKey);
    map['count'] = Variable<int>(count);
    map['min_sek'] = Variable<double>(minSek);
    map['median_sek'] = Variable<double>(medianSek);
    map['max_sek'] = Variable<double>(maxSek);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  MarketStatsCacheCompanion toCompanion(bool nullToAbsent) {
    return MarketStatsCacheCompanion(
      queryKey: Value(queryKey),
      count: Value(count),
      minSek: Value(minSek),
      medianSek: Value(medianSek),
      maxSek: Value(maxSek),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory MarketStatsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketStatsCacheData(
      queryKey: serializer.fromJson<String>(json['queryKey']),
      count: serializer.fromJson<int>(json['count']),
      minSek: serializer.fromJson<double>(json['minSek']),
      medianSek: serializer.fromJson<double>(json['medianSek']),
      maxSek: serializer.fromJson<double>(json['maxSek']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queryKey': serializer.toJson<String>(queryKey),
      'count': serializer.toJson<int>(count),
      'minSek': serializer.toJson<double>(minSek),
      'medianSek': serializer.toJson<double>(medianSek),
      'maxSek': serializer.toJson<double>(maxSek),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  MarketStatsCacheData copyWith({
    String? queryKey,
    int? count,
    double? minSek,
    double? medianSek,
    double? maxSek,
    DateTime? fetchedAt,
  }) => MarketStatsCacheData(
    queryKey: queryKey ?? this.queryKey,
    count: count ?? this.count,
    minSek: minSek ?? this.minSek,
    medianSek: medianSek ?? this.medianSek,
    maxSek: maxSek ?? this.maxSek,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  MarketStatsCacheData copyWithCompanion(MarketStatsCacheCompanion data) {
    return MarketStatsCacheData(
      queryKey: data.queryKey.present ? data.queryKey.value : this.queryKey,
      count: data.count.present ? data.count.value : this.count,
      minSek: data.minSek.present ? data.minSek.value : this.minSek,
      medianSek: data.medianSek.present ? data.medianSek.value : this.medianSek,
      maxSek: data.maxSek.present ? data.maxSek.value : this.maxSek,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketStatsCacheData(')
          ..write('queryKey: $queryKey, ')
          ..write('count: $count, ')
          ..write('minSek: $minSek, ')
          ..write('medianSek: $medianSek, ')
          ..write('maxSek: $maxSek, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(queryKey, count, minSek, medianSek, maxSek, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketStatsCacheData &&
          other.queryKey == this.queryKey &&
          other.count == this.count &&
          other.minSek == this.minSek &&
          other.medianSek == this.medianSek &&
          other.maxSek == this.maxSek &&
          other.fetchedAt == this.fetchedAt);
}

class MarketStatsCacheCompanion extends UpdateCompanion<MarketStatsCacheData> {
  final Value<String> queryKey;
  final Value<int> count;
  final Value<double> minSek;
  final Value<double> medianSek;
  final Value<double> maxSek;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const MarketStatsCacheCompanion({
    this.queryKey = const Value.absent(),
    this.count = const Value.absent(),
    this.minSek = const Value.absent(),
    this.medianSek = const Value.absent(),
    this.maxSek = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketStatsCacheCompanion.insert({
    required String queryKey,
    required int count,
    required double minSek,
    required double medianSek,
    required double maxSek,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : queryKey = Value(queryKey),
       count = Value(count),
       minSek = Value(minSek),
       medianSek = Value(medianSek),
       maxSek = Value(maxSek),
       fetchedAt = Value(fetchedAt);
  static Insertable<MarketStatsCacheData> custom({
    Expression<String>? queryKey,
    Expression<int>? count,
    Expression<double>? minSek,
    Expression<double>? medianSek,
    Expression<double>? maxSek,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (queryKey != null) 'query_key': queryKey,
      if (count != null) 'count': count,
      if (minSek != null) 'min_sek': minSek,
      if (medianSek != null) 'median_sek': medianSek,
      if (maxSek != null) 'max_sek': maxSek,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketStatsCacheCompanion copyWith({
    Value<String>? queryKey,
    Value<int>? count,
    Value<double>? minSek,
    Value<double>? medianSek,
    Value<double>? maxSek,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return MarketStatsCacheCompanion(
      queryKey: queryKey ?? this.queryKey,
      count: count ?? this.count,
      minSek: minSek ?? this.minSek,
      medianSek: medianSek ?? this.medianSek,
      maxSek: maxSek ?? this.maxSek,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queryKey.present) {
      map['query_key'] = Variable<String>(queryKey.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (minSek.present) {
      map['min_sek'] = Variable<double>(minSek.value);
    }
    if (medianSek.present) {
      map['median_sek'] = Variable<double>(medianSek.value);
    }
    if (maxSek.present) {
      map['max_sek'] = Variable<double>(maxSek.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketStatsCacheCompanion(')
          ..write('queryKey: $queryKey, ')
          ..write('count: $count, ')
          ..write('minSek: $minSek, ')
          ..write('medianSek: $medianSek, ')
          ..write('maxSek: $maxSek, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HaulsTable hauls = $HaulsTable(this);
  late final $ScanItemsTable scanItems = $ScanItemsTable(this);
  late final $ScanItemSyncStatesTable scanItemSyncStates =
      $ScanItemSyncStatesTable(this);
  late final $SyncQuotasTable syncQuotas = $SyncQuotasTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $MarketStatsCacheTable marketStatsCache = $MarketStatsCacheTable(
    this,
  );
  late final HaulsDao haulsDao = HaulsDao(this as AppDatabase);
  late final ScanItemsDao scanItemsDao = ScanItemsDao(this as AppDatabase);
  late final ScanItemSyncStatesDao scanItemSyncStatesDao =
      ScanItemSyncStatesDao(this as AppDatabase);
  late final SyncQuotasDao syncQuotasDao = SyncQuotasDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final MarketStatsCacheDao marketStatsCacheDao = MarketStatsCacheDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hauls,
    scanItems,
    scanItemSyncStates,
    syncQuotas,
    appSettings,
    marketStatsCache,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hauls',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scan_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_item_sync_states', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HaulsTableCreateCompanionBuilder =
    HaulsCompanion Function({
      required String id,
      required String title,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> totalInvested,
      Value<double?> grossValue,
      Value<double?> netProfit,
      Value<double?> co2SavedKg,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$HaulsTableUpdateCompanionBuilder =
    HaulsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> totalInvested,
      Value<double?> grossValue,
      Value<double?> netProfit,
      Value<double?> co2SavedKg,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$HaulsTableReferences
    extends BaseReferences<_$AppDatabase, $HaulsTable, Haul> {
  $$HaulsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScanItemsTable, List<ScanItem>>
  _scanItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanItems,
    aliasName: $_aliasNameGenerator(db.hauls.id, db.scanItems.haulId),
  );

  $$ScanItemsTableProcessedTableManager get scanItemsRefs {
    final manager = $$ScanItemsTableTableManager(
      $_db,
      $_db.scanItems,
    ).filter((f) => f.haulId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HaulsTableFilterComposer extends Composer<_$AppDatabase, $HaulsTable> {
  $$HaulsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalInvested => $composableBuilder(
    column: $table.totalInvested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossValue => $composableBuilder(
    column: $table.grossValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netProfit => $composableBuilder(
    column: $table.netProfit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get co2SavedKg => $composableBuilder(
    column: $table.co2SavedKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scanItemsRefs(
    Expression<bool> Function($$ScanItemsTableFilterComposer f) f,
  ) {
    final $$ScanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItems,
      getReferencedColumn: (t) => t.haulId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemsTableFilterComposer(
            $db: $db,
            $table: $db.scanItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HaulsTableOrderingComposer
    extends Composer<_$AppDatabase, $HaulsTable> {
  $$HaulsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalInvested => $composableBuilder(
    column: $table.totalInvested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossValue => $composableBuilder(
    column: $table.grossValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netProfit => $composableBuilder(
    column: $table.netProfit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get co2SavedKg => $composableBuilder(
    column: $table.co2SavedKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HaulsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HaulsTable> {
  $$HaulsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get totalInvested => $composableBuilder(
    column: $table.totalInvested,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grossValue => $composableBuilder(
    column: $table.grossValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netProfit =>
      $composableBuilder(column: $table.netProfit, builder: (column) => column);

  GeneratedColumn<double> get co2SavedKg => $composableBuilder(
    column: $table.co2SavedKg,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> scanItemsRefs<T extends Object>(
    Expression<T> Function($$ScanItemsTableAnnotationComposer a) f,
  ) {
    final $$ScanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItems,
      getReferencedColumn: (t) => t.haulId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HaulsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HaulsTable,
          Haul,
          $$HaulsTableFilterComposer,
          $$HaulsTableOrderingComposer,
          $$HaulsTableAnnotationComposer,
          $$HaulsTableCreateCompanionBuilder,
          $$HaulsTableUpdateCompanionBuilder,
          (Haul, $$HaulsTableReferences),
          Haul,
          PrefetchHooks Function({bool scanItemsRefs})
        > {
  $$HaulsTableTableManager(_$AppDatabase db, $HaulsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HaulsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HaulsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HaulsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> totalInvested = const Value.absent(),
                Value<double?> grossValue = const Value.absent(),
                Value<double?> netProfit = const Value.absent(),
                Value<double?> co2SavedKg = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HaulsCompanion(
                id: id,
                title: title,
                startedAt: startedAt,
                endedAt: endedAt,
                lat: lat,
                lng: lng,
                totalInvested: totalInvested,
                grossValue: grossValue,
                netProfit: netProfit,
                co2SavedKg: co2SavedKg,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> totalInvested = const Value.absent(),
                Value<double?> grossValue = const Value.absent(),
                Value<double?> netProfit = const Value.absent(),
                Value<double?> co2SavedKg = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HaulsCompanion.insert(
                id: id,
                title: title,
                startedAt: startedAt,
                endedAt: endedAt,
                lat: lat,
                lng: lng,
                totalInvested: totalInvested,
                grossValue: grossValue,
                netProfit: netProfit,
                co2SavedKg: co2SavedKg,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HaulsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({scanItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scanItemsRefs) db.scanItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scanItemsRefs)
                    await $_getPrefetchedData<Haul, $HaulsTable, ScanItem>(
                      currentTable: table,
                      referencedTable: $$HaulsTableReferences
                          ._scanItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HaulsTableReferences(db, table, p0).scanItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.haulId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HaulsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HaulsTable,
      Haul,
      $$HaulsTableFilterComposer,
      $$HaulsTableOrderingComposer,
      $$HaulsTableAnnotationComposer,
      $$HaulsTableCreateCompanionBuilder,
      $$HaulsTableUpdateCompanionBuilder,
      (Haul, $$HaulsTableReferences),
      Haul,
      PrefetchHooks Function({bool scanItemsRefs})
    >;
typedef $$ScanItemsTableCreateCompanionBuilder =
    ScanItemsCompanion Function({
      required String id,
      required String haulId,
      Value<String?> imagePath,
      Value<String?> thumbPath,
      Value<String?> aiJson,
      Value<String?> query,
      Value<String?> desc,
      Value<double?> confidence,
      Value<double?> purchasePrice,
      Value<double> conditionMultiplier,
      Value<double?> medianPrice,
      Value<double?> minPrice,
      Value<double?> maxPrice,
      Value<int?> demandScore,
      Value<int?> daysToSellEst,
      Value<ScanItemStatus> status,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ScanItemsTableUpdateCompanionBuilder =
    ScanItemsCompanion Function({
      Value<String> id,
      Value<String> haulId,
      Value<String?> imagePath,
      Value<String?> thumbPath,
      Value<String?> aiJson,
      Value<String?> query,
      Value<String?> desc,
      Value<double?> confidence,
      Value<double?> purchasePrice,
      Value<double> conditionMultiplier,
      Value<double?> medianPrice,
      Value<double?> minPrice,
      Value<double?> maxPrice,
      Value<int?> demandScore,
      Value<int?> daysToSellEst,
      Value<ScanItemStatus> status,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ScanItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ScanItemsTable, ScanItem> {
  $$ScanItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HaulsTable _haulIdTable(_$AppDatabase db) => db.hauls.createAlias(
    $_aliasNameGenerator(db.scanItems.haulId, db.hauls.id),
  );

  $$HaulsTableProcessedTableManager get haulId {
    final $_column = $_itemColumn<String>('haul_id')!;

    final manager = $$HaulsTableTableManager(
      $_db,
      $_db.hauls,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_haulIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScanItemSyncStatesTable, List<ScanItemSyncState>>
  _scanItemSyncStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scanItemSyncStates,
        aliasName: $_aliasNameGenerator(
          db.scanItems.id,
          db.scanItemSyncStates.scanItemId,
        ),
      );

  $$ScanItemSyncStatesTableProcessedTableManager get scanItemSyncStatesRefs {
    final manager = $$ScanItemSyncStatesTableTableManager(
      $_db,
      $_db.scanItemSyncStates,
    ).filter((f) => f.scanItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scanItemSyncStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanItemsTable> {
  $$ScanItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiJson => $composableBuilder(
    column: $table.aiJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desc => $composableBuilder(
    column: $table.desc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get conditionMultiplier => $composableBuilder(
    column: $table.conditionMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get medianPrice => $composableBuilder(
    column: $table.medianPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minPrice => $composableBuilder(
    column: $table.minPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxPrice => $composableBuilder(
    column: $table.maxPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get demandScore => $composableBuilder(
    column: $table.demandScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysToSellEst => $composableBuilder(
    column: $table.daysToSellEst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScanItemStatus, ScanItemStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HaulsTableFilterComposer get haulId {
    final $$HaulsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.haulId,
      referencedTable: $db.hauls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaulsTableFilterComposer(
            $db: $db,
            $table: $db.hauls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scanItemSyncStatesRefs(
    Expression<bool> Function($$ScanItemSyncStatesTableFilterComposer f) f,
  ) {
    final $$ScanItemSyncStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItemSyncStates,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemSyncStatesTableFilterComposer(
            $db: $db,
            $table: $db.scanItemSyncStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanItemsTable> {
  $$ScanItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiJson => $composableBuilder(
    column: $table.aiJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desc => $composableBuilder(
    column: $table.desc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get conditionMultiplier => $composableBuilder(
    column: $table.conditionMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get medianPrice => $composableBuilder(
    column: $table.medianPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minPrice => $composableBuilder(
    column: $table.minPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxPrice => $composableBuilder(
    column: $table.maxPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get demandScore => $composableBuilder(
    column: $table.demandScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysToSellEst => $composableBuilder(
    column: $table.daysToSellEst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HaulsTableOrderingComposer get haulId {
    final $$HaulsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.haulId,
      referencedTable: $db.hauls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaulsTableOrderingComposer(
            $db: $db,
            $table: $db.hauls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanItemsTable> {
  $$ScanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get aiJson =>
      $composableBuilder(column: $table.aiJson, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get desc =>
      $composableBuilder(column: $table.desc, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get conditionMultiplier => $composableBuilder(
    column: $table.conditionMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get medianPrice => $composableBuilder(
    column: $table.medianPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minPrice =>
      $composableBuilder(column: $table.minPrice, builder: (column) => column);

  GeneratedColumn<double> get maxPrice =>
      $composableBuilder(column: $table.maxPrice, builder: (column) => column);

  GeneratedColumn<int> get demandScore => $composableBuilder(
    column: $table.demandScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysToSellEst => $composableBuilder(
    column: $table.daysToSellEst,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ScanItemStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$HaulsTableAnnotationComposer get haulId {
    final $$HaulsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.haulId,
      referencedTable: $db.hauls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaulsTableAnnotationComposer(
            $db: $db,
            $table: $db.hauls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scanItemSyncStatesRefs<T extends Object>(
    Expression<T> Function($$ScanItemSyncStatesTableAnnotationComposer a) f,
  ) {
    final $$ScanItemSyncStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scanItemSyncStates,
          getReferencedColumn: (t) => t.scanItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScanItemSyncStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.scanItemSyncStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanItemsTable,
          ScanItem,
          $$ScanItemsTableFilterComposer,
          $$ScanItemsTableOrderingComposer,
          $$ScanItemsTableAnnotationComposer,
          $$ScanItemsTableCreateCompanionBuilder,
          $$ScanItemsTableUpdateCompanionBuilder,
          (ScanItem, $$ScanItemsTableReferences),
          ScanItem,
          PrefetchHooks Function({bool haulId, bool scanItemSyncStatesRefs})
        > {
  $$ScanItemsTableTableManager(_$AppDatabase db, $ScanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> haulId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> aiJson = const Value.absent(),
                Value<String?> query = const Value.absent(),
                Value<String?> desc = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double> conditionMultiplier = const Value.absent(),
                Value<double?> medianPrice = const Value.absent(),
                Value<double?> minPrice = const Value.absent(),
                Value<double?> maxPrice = const Value.absent(),
                Value<int?> demandScore = const Value.absent(),
                Value<int?> daysToSellEst = const Value.absent(),
                Value<ScanItemStatus> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemsCompanion(
                id: id,
                haulId: haulId,
                imagePath: imagePath,
                thumbPath: thumbPath,
                aiJson: aiJson,
                query: query,
                desc: desc,
                confidence: confidence,
                purchasePrice: purchasePrice,
                conditionMultiplier: conditionMultiplier,
                medianPrice: medianPrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
                demandScore: demandScore,
                daysToSellEst: daysToSellEst,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String haulId,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> aiJson = const Value.absent(),
                Value<String?> query = const Value.absent(),
                Value<String?> desc = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double> conditionMultiplier = const Value.absent(),
                Value<double?> medianPrice = const Value.absent(),
                Value<double?> minPrice = const Value.absent(),
                Value<double?> maxPrice = const Value.absent(),
                Value<int?> demandScore = const Value.absent(),
                Value<int?> daysToSellEst = const Value.absent(),
                Value<ScanItemStatus> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemsCompanion.insert(
                id: id,
                haulId: haulId,
                imagePath: imagePath,
                thumbPath: thumbPath,
                aiJson: aiJson,
                query: query,
                desc: desc,
                confidence: confidence,
                purchasePrice: purchasePrice,
                conditionMultiplier: conditionMultiplier,
                medianPrice: medianPrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
                demandScore: demandScore,
                daysToSellEst: daysToSellEst,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({haulId = false, scanItemSyncStatesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scanItemSyncStatesRefs) db.scanItemSyncStates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (haulId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.haulId,
                                    referencedTable: $$ScanItemsTableReferences
                                        ._haulIdTable(db),
                                    referencedColumn: $$ScanItemsTableReferences
                                        ._haulIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scanItemSyncStatesRefs)
                        await $_getPrefetchedData<
                          ScanItem,
                          $ScanItemsTable,
                          ScanItemSyncState
                        >(
                          currentTable: table,
                          referencedTable: $$ScanItemsTableReferences
                              ._scanItemSyncStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScanItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).scanItemSyncStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scanItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanItemsTable,
      ScanItem,
      $$ScanItemsTableFilterComposer,
      $$ScanItemsTableOrderingComposer,
      $$ScanItemsTableAnnotationComposer,
      $$ScanItemsTableCreateCompanionBuilder,
      $$ScanItemsTableUpdateCompanionBuilder,
      (ScanItem, $$ScanItemsTableReferences),
      ScanItem,
      PrefetchHooks Function({bool haulId, bool scanItemSyncStatesRefs})
    >;
typedef $$ScanItemSyncStatesTableCreateCompanionBuilder =
    ScanItemSyncStatesCompanion Function({
      required String scanItemId,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ScanItemSyncStatesTableUpdateCompanionBuilder =
    ScanItemSyncStatesCompanion Function({
      Value<String> scanItemId,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ScanItemSyncStatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScanItemSyncStatesTable,
          ScanItemSyncState
        > {
  $$ScanItemSyncStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScanItemsTable _scanItemIdTable(_$AppDatabase db) =>
      db.scanItems.createAlias(
        $_aliasNameGenerator(db.scanItemSyncStates.scanItemId, db.scanItems.id),
      );

  $$ScanItemsTableProcessedTableManager get scanItemId {
    final $_column = $_itemColumn<String>('scan_item_id')!;

    final manager = $$ScanItemsTableTableManager(
      $_db,
      $_db.scanItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanItemSyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ScanItemSyncStatesTable> {
  $$ScanItemSyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScanItemsTableFilterComposer get scanItemId {
    final $$ScanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanItemId,
      referencedTable: $db.scanItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemsTableFilterComposer(
            $db: $db,
            $table: $db.scanItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanItemSyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanItemSyncStatesTable> {
  $$ScanItemSyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScanItemsTableOrderingComposer get scanItemId {
    final $$ScanItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanItemId,
      referencedTable: $db.scanItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemsTableOrderingComposer(
            $db: $db,
            $table: $db.scanItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanItemSyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanItemSyncStatesTable> {
  $$ScanItemSyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScanItemsTableAnnotationComposer get scanItemId {
    final $$ScanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanItemId,
      referencedTable: $db.scanItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanItemSyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanItemSyncStatesTable,
          ScanItemSyncState,
          $$ScanItemSyncStatesTableFilterComposer,
          $$ScanItemSyncStatesTableOrderingComposer,
          $$ScanItemSyncStatesTableAnnotationComposer,
          $$ScanItemSyncStatesTableCreateCompanionBuilder,
          $$ScanItemSyncStatesTableUpdateCompanionBuilder,
          (ScanItemSyncState, $$ScanItemSyncStatesTableReferences),
          ScanItemSyncState,
          PrefetchHooks Function({bool scanItemId})
        > {
  $$ScanItemSyncStatesTableTableManager(
    _$AppDatabase db,
    $ScanItemSyncStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanItemSyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanItemSyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanItemSyncStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> scanItemId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemSyncStatesCompanion(
                scanItemId: scanItemId,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scanItemId,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemSyncStatesCompanion.insert(
                scanItemId: scanItemId,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanItemSyncStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanItemId,
                                referencedTable:
                                    $$ScanItemSyncStatesTableReferences
                                        ._scanItemIdTable(db),
                                referencedColumn:
                                    $$ScanItemSyncStatesTableReferences
                                        ._scanItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanItemSyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanItemSyncStatesTable,
      ScanItemSyncState,
      $$ScanItemSyncStatesTableFilterComposer,
      $$ScanItemSyncStatesTableOrderingComposer,
      $$ScanItemSyncStatesTableAnnotationComposer,
      $$ScanItemSyncStatesTableCreateCompanionBuilder,
      $$ScanItemSyncStatesTableUpdateCompanionBuilder,
      (ScanItemSyncState, $$ScanItemSyncStatesTableReferences),
      ScanItemSyncState,
      PrefetchHooks Function({bool scanItemId})
    >;
typedef $$SyncQuotasTableCreateCompanionBuilder =
    SyncQuotasCompanion Function({
      required String dayKey,
      Value<int> used,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SyncQuotasTableUpdateCompanionBuilder =
    SyncQuotasCompanion Function({
      Value<String> dayKey,
      Value<int> used,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncQuotasTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQuotasTable> {
  $$SyncQuotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQuotasTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQuotasTable> {
  $$SyncQuotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQuotasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQuotasTable> {
  $$SyncQuotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get used =>
      $composableBuilder(column: $table.used, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncQuotasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQuotasTable,
          SyncQuota,
          $$SyncQuotasTableFilterComposer,
          $$SyncQuotasTableOrderingComposer,
          $$SyncQuotasTableAnnotationComposer,
          $$SyncQuotasTableCreateCompanionBuilder,
          $$SyncQuotasTableUpdateCompanionBuilder,
          (
            SyncQuota,
            BaseReferences<_$AppDatabase, $SyncQuotasTable, SyncQuota>,
          ),
          SyncQuota,
          PrefetchHooks Function()
        > {
  $$SyncQuotasTableTableManager(_$AppDatabase db, $SyncQuotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQuotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQuotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQuotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayKey = const Value.absent(),
                Value<int> used = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQuotasCompanion(
                dayKey: dayKey,
                used: used,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayKey,
                Value<int> used = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQuotasCompanion.insert(
                dayKey: dayKey,
                used: used,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQuotasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQuotasTable,
      SyncQuota,
      $$SyncQuotasTableFilterComposer,
      $$SyncQuotasTableOrderingComposer,
      $$SyncQuotasTableAnnotationComposer,
      $$SyncQuotasTableCreateCompanionBuilder,
      $$SyncQuotasTableUpdateCompanionBuilder,
      (SyncQuota, BaseReferences<_$AppDatabase, $SyncQuotasTable, SyncQuota>),
      SyncQuota,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<int?> intValue,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<int?> intValue,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get intValue =>
      $composableBuilder(column: $table.intValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int?> intValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                intValue: intValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int?> intValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                intValue: intValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$MarketStatsCacheTableCreateCompanionBuilder =
    MarketStatsCacheCompanion Function({
      required String queryKey,
      required int count,
      required double minSek,
      required double medianSek,
      required double maxSek,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$MarketStatsCacheTableUpdateCompanionBuilder =
    MarketStatsCacheCompanion Function({
      Value<String> queryKey,
      Value<int> count,
      Value<double> minSek,
      Value<double> medianSek,
      Value<double> maxSek,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$MarketStatsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $MarketStatsCacheTable> {
  $$MarketStatsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get queryKey => $composableBuilder(
    column: $table.queryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minSek => $composableBuilder(
    column: $table.minSek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get medianSek => $composableBuilder(
    column: $table.medianSek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSek => $composableBuilder(
    column: $table.maxSek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketStatsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketStatsCacheTable> {
  $$MarketStatsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get queryKey => $composableBuilder(
    column: $table.queryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minSek => $composableBuilder(
    column: $table.minSek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get medianSek => $composableBuilder(
    column: $table.medianSek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSek => $composableBuilder(
    column: $table.maxSek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketStatsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketStatsCacheTable> {
  $$MarketStatsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<double> get minSek =>
      $composableBuilder(column: $table.minSek, builder: (column) => column);

  GeneratedColumn<double> get medianSek =>
      $composableBuilder(column: $table.medianSek, builder: (column) => column);

  GeneratedColumn<double> get maxSek =>
      $composableBuilder(column: $table.maxSek, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$MarketStatsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketStatsCacheTable,
          MarketStatsCacheData,
          $$MarketStatsCacheTableFilterComposer,
          $$MarketStatsCacheTableOrderingComposer,
          $$MarketStatsCacheTableAnnotationComposer,
          $$MarketStatsCacheTableCreateCompanionBuilder,
          $$MarketStatsCacheTableUpdateCompanionBuilder,
          (
            MarketStatsCacheData,
            BaseReferences<
              _$AppDatabase,
              $MarketStatsCacheTable,
              MarketStatsCacheData
            >,
          ),
          MarketStatsCacheData,
          PrefetchHooks Function()
        > {
  $$MarketStatsCacheTableTableManager(
    _$AppDatabase db,
    $MarketStatsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketStatsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketStatsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketStatsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> queryKey = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<double> minSek = const Value.absent(),
                Value<double> medianSek = const Value.absent(),
                Value<double> maxSek = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketStatsCacheCompanion(
                queryKey: queryKey,
                count: count,
                minSek: minSek,
                medianSek: medianSek,
                maxSek: maxSek,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String queryKey,
                required int count,
                required double minSek,
                required double medianSek,
                required double maxSek,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => MarketStatsCacheCompanion.insert(
                queryKey: queryKey,
                count: count,
                minSek: minSek,
                medianSek: medianSek,
                maxSek: maxSek,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketStatsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketStatsCacheTable,
      MarketStatsCacheData,
      $$MarketStatsCacheTableFilterComposer,
      $$MarketStatsCacheTableOrderingComposer,
      $$MarketStatsCacheTableAnnotationComposer,
      $$MarketStatsCacheTableCreateCompanionBuilder,
      $$MarketStatsCacheTableUpdateCompanionBuilder,
      (
        MarketStatsCacheData,
        BaseReferences<
          _$AppDatabase,
          $MarketStatsCacheTable,
          MarketStatsCacheData
        >,
      ),
      MarketStatsCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db, _db.scanItems);
  $$ScanItemSyncStatesTableTableManager get scanItemSyncStates =>
      $$ScanItemSyncStatesTableTableManager(_db, _db.scanItemSyncStates);
  $$SyncQuotasTableTableManager get syncQuotas =>
      $$SyncQuotasTableTableManager(_db, _db.syncQuotas);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$MarketStatsCacheTableTableManager get marketStatsCache =>
      $$MarketStatsCacheTableTableManager(_db, _db.marketStatsCache);
}
