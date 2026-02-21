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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    userId,
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
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
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
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
  final String? userId;
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
    this.userId,
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
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
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
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
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
      userId: serializer.fromJson<String?>(json['userId']),
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
      'userId': serializer.toJson<String?>(userId),
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
    Value<String?> userId = const Value.absent(),
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
    userId: userId.present ? userId.value : this.userId,
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
      userId: data.userId.present ? data.userId.value : this.userId,
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
          ..write('userId: $userId, ')
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
    userId,
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
          other.userId == this.userId &&
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
  final Value<String?> userId;
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
    this.userId = const Value.absent(),
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
    this.userId = const Value.absent(),
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
    Expression<String>? userId,
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
      if (userId != null) 'user_id': userId,
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
    Value<String?>? userId,
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
      userId: userId ?? this.userId,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
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
          ..write('userId: $userId, ')
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
  static const VerificationMeta _fixedFeesSekMeta = const VerificationMeta(
    'fixedFeesSek',
  );
  @override
  late final GeneratedColumn<double> fixedFeesSek = GeneratedColumn<double>(
    'fixed_fees_sek',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shippingPaidBySellerSekMeta =
      const VerificationMeta('shippingPaidBySellerSek');
  @override
  late final GeneratedColumn<double> shippingPaidBySellerSek =
      GeneratedColumn<double>(
        'shipping_paid_by_seller_sek',
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
    userId,
    haulId,
    imagePath,
    thumbPath,
    aiJson,
    query,
    desc,
    category,
    notes,
    confidence,
    purchasePrice,
    fixedFeesSek,
    shippingPaidBySellerSek,
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('fixed_fees_sek')) {
      context.handle(
        _fixedFeesSekMeta,
        fixedFeesSek.isAcceptableOrUnknown(
          data['fixed_fees_sek']!,
          _fixedFeesSekMeta,
        ),
      );
    }
    if (data.containsKey('shipping_paid_by_seller_sek')) {
      context.handle(
        _shippingPaidBySellerSekMeta,
        shippingPaidBySellerSek.isAcceptableOrUnknown(
          data['shipping_paid_by_seller_sek']!,
          _shippingPaidBySellerSekMeta,
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
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
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
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      ),
      fixedFeesSek: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fixed_fees_sek'],
      ),
      shippingPaidBySellerSek: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shipping_paid_by_seller_sek'],
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
  final String? userId;
  final String haulId;
  final String? imagePath;
  final String? thumbPath;
  final String? aiJson;
  final String? query;
  final String? desc;
  final String? category;
  final String? notes;
  final double? confidence;
  final double? purchasePrice;
  final double? fixedFeesSek;
  final double? shippingPaidBySellerSek;
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
    this.userId,
    required this.haulId,
    this.imagePath,
    this.thumbPath,
    this.aiJson,
    this.query,
    this.desc,
    this.category,
    this.notes,
    this.confidence,
    this.purchasePrice,
    this.fixedFeesSek,
    this.shippingPaidBySellerSek,
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
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
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
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    if (!nullToAbsent || fixedFeesSek != null) {
      map['fixed_fees_sek'] = Variable<double>(fixedFeesSek);
    }
    if (!nullToAbsent || shippingPaidBySellerSek != null) {
      map['shipping_paid_by_seller_sek'] = Variable<double>(
        shippingPaidBySellerSek,
      );
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
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
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
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      fixedFeesSek: fixedFeesSek == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedFeesSek),
      shippingPaidBySellerSek: shippingPaidBySellerSek == null && nullToAbsent
          ? const Value.absent()
          : Value(shippingPaidBySellerSek),
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
      userId: serializer.fromJson<String?>(json['userId']),
      haulId: serializer.fromJson<String>(json['haulId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      aiJson: serializer.fromJson<String?>(json['aiJson']),
      query: serializer.fromJson<String?>(json['query']),
      desc: serializer.fromJson<String?>(json['desc']),
      category: serializer.fromJson<String?>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      fixedFeesSek: serializer.fromJson<double?>(json['fixedFeesSek']),
      shippingPaidBySellerSek: serializer.fromJson<double?>(
        json['shippingPaidBySellerSek'],
      ),
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
      'userId': serializer.toJson<String?>(userId),
      'haulId': serializer.toJson<String>(haulId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'aiJson': serializer.toJson<String?>(aiJson),
      'query': serializer.toJson<String?>(query),
      'desc': serializer.toJson<String?>(desc),
      'category': serializer.toJson<String?>(category),
      'notes': serializer.toJson<String?>(notes),
      'confidence': serializer.toJson<double?>(confidence),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'fixedFeesSek': serializer.toJson<double?>(fixedFeesSek),
      'shippingPaidBySellerSek': serializer.toJson<double?>(
        shippingPaidBySellerSek,
      ),
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
    Value<String?> userId = const Value.absent(),
    String? haulId,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> thumbPath = const Value.absent(),
    Value<String?> aiJson = const Value.absent(),
    Value<String?> query = const Value.absent(),
    Value<String?> desc = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<double?> purchasePrice = const Value.absent(),
    Value<double?> fixedFeesSek = const Value.absent(),
    Value<double?> shippingPaidBySellerSek = const Value.absent(),
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
    userId: userId.present ? userId.value : this.userId,
    haulId: haulId ?? this.haulId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    aiJson: aiJson.present ? aiJson.value : this.aiJson,
    query: query.present ? query.value : this.query,
    desc: desc.present ? desc.value : this.desc,
    category: category.present ? category.value : this.category,
    notes: notes.present ? notes.value : this.notes,
    confidence: confidence.present ? confidence.value : this.confidence,
    purchasePrice: purchasePrice.present
        ? purchasePrice.value
        : this.purchasePrice,
    fixedFeesSek: fixedFeesSek.present ? fixedFeesSek.value : this.fixedFeesSek,
    shippingPaidBySellerSek: shippingPaidBySellerSek.present
        ? shippingPaidBySellerSek.value
        : this.shippingPaidBySellerSek,
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
      userId: data.userId.present ? data.userId.value : this.userId,
      haulId: data.haulId.present ? data.haulId.value : this.haulId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      aiJson: data.aiJson.present ? data.aiJson.value : this.aiJson,
      query: data.query.present ? data.query.value : this.query,
      desc: data.desc.present ? data.desc.value : this.desc,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      fixedFeesSek: data.fixedFeesSek.present
          ? data.fixedFeesSek.value
          : this.fixedFeesSek,
      shippingPaidBySellerSek: data.shippingPaidBySellerSek.present
          ? data.shippingPaidBySellerSek.value
          : this.shippingPaidBySellerSek,
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
          ..write('userId: $userId, ')
          ..write('haulId: $haulId, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('aiJson: $aiJson, ')
          ..write('query: $query, ')
          ..write('desc: $desc, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('confidence: $confidence, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('fixedFeesSek: $fixedFeesSek, ')
          ..write('shippingPaidBySellerSek: $shippingPaidBySellerSek, ')
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
  int get hashCode => Object.hashAll([
    id,
    userId,
    haulId,
    imagePath,
    thumbPath,
    aiJson,
    query,
    desc,
    category,
    notes,
    confidence,
    purchasePrice,
    fixedFeesSek,
    shippingPaidBySellerSek,
    conditionMultiplier,
    medianPrice,
    minPrice,
    maxPrice,
    demandScore,
    daysToSellEst,
    status,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanItem &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.haulId == this.haulId &&
          other.imagePath == this.imagePath &&
          other.thumbPath == this.thumbPath &&
          other.aiJson == this.aiJson &&
          other.query == this.query &&
          other.desc == this.desc &&
          other.category == this.category &&
          other.notes == this.notes &&
          other.confidence == this.confidence &&
          other.purchasePrice == this.purchasePrice &&
          other.fixedFeesSek == this.fixedFeesSek &&
          other.shippingPaidBySellerSek == this.shippingPaidBySellerSek &&
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
  final Value<String?> userId;
  final Value<String> haulId;
  final Value<String?> imagePath;
  final Value<String?> thumbPath;
  final Value<String?> aiJson;
  final Value<String?> query;
  final Value<String?> desc;
  final Value<String?> category;
  final Value<String?> notes;
  final Value<double?> confidence;
  final Value<double?> purchasePrice;
  final Value<double?> fixedFeesSek;
  final Value<double?> shippingPaidBySellerSek;
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
    this.userId = const Value.absent(),
    this.haulId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.aiJson = const Value.absent(),
    this.query = const Value.absent(),
    this.desc = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.confidence = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.fixedFeesSek = const Value.absent(),
    this.shippingPaidBySellerSek = const Value.absent(),
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
    this.userId = const Value.absent(),
    required String haulId,
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.aiJson = const Value.absent(),
    this.query = const Value.absent(),
    this.desc = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.confidence = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.fixedFeesSek = const Value.absent(),
    this.shippingPaidBySellerSek = const Value.absent(),
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
    Expression<String>? userId,
    Expression<String>? haulId,
    Expression<String>? imagePath,
    Expression<String>? thumbPath,
    Expression<String>? aiJson,
    Expression<String>? query,
    Expression<String>? desc,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<double>? confidence,
    Expression<double>? purchasePrice,
    Expression<double>? fixedFeesSek,
    Expression<double>? shippingPaidBySellerSek,
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
      if (userId != null) 'user_id': userId,
      if (haulId != null) 'haul_id': haulId,
      if (imagePath != null) 'image_path': imagePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (aiJson != null) 'ai_json': aiJson,
      if (query != null) 'query': query,
      if (desc != null) 'desc': desc,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (confidence != null) 'confidence': confidence,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (fixedFeesSek != null) 'fixed_fees_sek': fixedFeesSek,
      if (shippingPaidBySellerSek != null)
        'shipping_paid_by_seller_sek': shippingPaidBySellerSek,
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
    Value<String?>? userId,
    Value<String>? haulId,
    Value<String?>? imagePath,
    Value<String?>? thumbPath,
    Value<String?>? aiJson,
    Value<String?>? query,
    Value<String?>? desc,
    Value<String?>? category,
    Value<String?>? notes,
    Value<double?>? confidence,
    Value<double?>? purchasePrice,
    Value<double?>? fixedFeesSek,
    Value<double?>? shippingPaidBySellerSek,
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
      userId: userId ?? this.userId,
      haulId: haulId ?? this.haulId,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      aiJson: aiJson ?? this.aiJson,
      query: query ?? this.query,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      fixedFeesSek: fixedFeesSek ?? this.fixedFeesSek,
      shippingPaidBySellerSek:
          shippingPaidBySellerSek ?? this.shippingPaidBySellerSek,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (fixedFeesSek.present) {
      map['fixed_fees_sek'] = Variable<double>(fixedFeesSek.value);
    }
    if (shippingPaidBySellerSek.present) {
      map['shipping_paid_by_seller_sek'] = Variable<double>(
        shippingPaidBySellerSek.value,
      );
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
          ..write('userId: $userId, ')
          ..write('haulId: $haulId, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('aiJson: $aiJson, ')
          ..write('query: $query, ')
          ..write('desc: $desc, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('confidence: $confidence, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('fixedFeesSek: $fixedFeesSek, ')
          ..write('shippingPaidBySellerSek: $shippingPaidBySellerSek, ')
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

class $ScanItemPhotosTable extends ScanItemPhotos
    with TableInfo<$ScanItemPhotosTable, ScanItemPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanItemPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    scanItemId,
    localPath,
    thumbPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_item_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanItemPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  ScanItemPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanItemPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scanItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_item_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScanItemPhotosTable createAlias(String alias) {
    return $ScanItemPhotosTable(attachedDatabase, alias);
  }
}

class ScanItemPhoto extends DataClass implements Insertable<ScanItemPhoto> {
  final String id;
  final String scanItemId;
  final String localPath;
  final String? thumbPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ScanItemPhoto({
    required this.id,
    required this.scanItemId,
    required this.localPath,
    this.thumbPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scan_item_id'] = Variable<String>(scanItemId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || thumbPath != null) {
      map['thumb_path'] = Variable<String>(thumbPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScanItemPhotosCompanion toCompanion(bool nullToAbsent) {
    return ScanItemPhotosCompanion(
      id: Value(id),
      scanItemId: Value(scanItemId),
      localPath: Value(localPath),
      thumbPath: thumbPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScanItemPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanItemPhoto(
      id: serializer.fromJson<String>(json['id']),
      scanItemId: serializer.fromJson<String>(json['scanItemId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scanItemId': serializer.toJson<String>(scanItemId),
      'localPath': serializer.toJson<String>(localPath),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScanItemPhoto copyWith({
    String? id,
    String? scanItemId,
    String? localPath,
    Value<String?> thumbPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ScanItemPhoto(
    id: id ?? this.id,
    scanItemId: scanItemId ?? this.scanItemId,
    localPath: localPath ?? this.localPath,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScanItemPhoto copyWithCompanion(ScanItemPhotosCompanion data) {
    return ScanItemPhoto(
      id: data.id.present ? data.id.value : this.id,
      scanItemId: data.scanItemId.present
          ? data.scanItemId.value
          : this.scanItemId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanItemPhoto(')
          ..write('id: $id, ')
          ..write('scanItemId: $scanItemId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scanItemId, localPath, thumbPath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanItemPhoto &&
          other.id == this.id &&
          other.scanItemId == this.scanItemId &&
          other.localPath == this.localPath &&
          other.thumbPath == this.thumbPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScanItemPhotosCompanion extends UpdateCompanion<ScanItemPhoto> {
  final Value<String> id;
  final Value<String> scanItemId;
  final Value<String> localPath;
  final Value<String?> thumbPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScanItemPhotosCompanion({
    this.id = const Value.absent(),
    this.scanItemId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanItemPhotosCompanion.insert({
    required String id,
    required String scanItemId,
    required String localPath,
    this.thumbPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scanItemId = Value(scanItemId),
       localPath = Value(localPath);
  static Insertable<ScanItemPhoto> custom({
    Expression<String>? id,
    Expression<String>? scanItemId,
    Expression<String>? localPath,
    Expression<String>? thumbPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanItemId != null) 'scan_item_id': scanItemId,
      if (localPath != null) 'local_path': localPath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanItemPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? scanItemId,
    Value<String>? localPath,
    Value<String?>? thumbPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScanItemPhotosCompanion(
      id: id ?? this.id,
      scanItemId: scanItemId ?? this.scanItemId,
      localPath: localPath ?? this.localPath,
      thumbPath: thumbPath ?? this.thumbPath,
      createdAt: createdAt ?? this.createdAt,
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
    if (scanItemId.present) {
      map['scan_item_id'] = Variable<String>(scanItemId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ScanItemPhotosCompanion(')
          ..write('id: $id, ')
          ..write('scanItemId: $scanItemId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanItemCompsTable extends ScanItemComps
    with TableInfo<$ScanItemCompsTable, ScanItemComp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanItemCompsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    rawJson,
    medianPrice,
    minPrice,
    maxPrice,
    demandScore,
    daysToSellEst,
    fetchedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_item_comps';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanItemComp> instance, {
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
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
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
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
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
  ScanItemComp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanItemComp(
      scanItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_item_id'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
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
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScanItemCompsTable createAlias(String alias) {
    return $ScanItemCompsTable(attachedDatabase, alias);
  }
}

class ScanItemComp extends DataClass implements Insertable<ScanItemComp> {
  final String scanItemId;
  final String rawJson;
  final double? medianPrice;
  final double? minPrice;
  final double? maxPrice;
  final int? demandScore;
  final int? daysToSellEst;
  final DateTime fetchedAt;
  final DateTime updatedAt;
  const ScanItemComp({
    required this.scanItemId,
    required this.rawJson,
    this.medianPrice,
    this.minPrice,
    this.maxPrice,
    this.demandScore,
    this.daysToSellEst,
    required this.fetchedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scan_item_id'] = Variable<String>(scanItemId);
    map['raw_json'] = Variable<String>(rawJson);
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
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScanItemCompsCompanion toCompanion(bool nullToAbsent) {
    return ScanItemCompsCompanion(
      scanItemId: Value(scanItemId),
      rawJson: Value(rawJson),
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
      fetchedAt: Value(fetchedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScanItemComp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanItemComp(
      scanItemId: serializer.fromJson<String>(json['scanItemId']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      medianPrice: serializer.fromJson<double?>(json['medianPrice']),
      minPrice: serializer.fromJson<double?>(json['minPrice']),
      maxPrice: serializer.fromJson<double?>(json['maxPrice']),
      demandScore: serializer.fromJson<int?>(json['demandScore']),
      daysToSellEst: serializer.fromJson<int?>(json['daysToSellEst']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scanItemId': serializer.toJson<String>(scanItemId),
      'rawJson': serializer.toJson<String>(rawJson),
      'medianPrice': serializer.toJson<double?>(medianPrice),
      'minPrice': serializer.toJson<double?>(minPrice),
      'maxPrice': serializer.toJson<double?>(maxPrice),
      'demandScore': serializer.toJson<int?>(demandScore),
      'daysToSellEst': serializer.toJson<int?>(daysToSellEst),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScanItemComp copyWith({
    String? scanItemId,
    String? rawJson,
    Value<double?> medianPrice = const Value.absent(),
    Value<double?> minPrice = const Value.absent(),
    Value<double?> maxPrice = const Value.absent(),
    Value<int?> demandScore = const Value.absent(),
    Value<int?> daysToSellEst = const Value.absent(),
    DateTime? fetchedAt,
    DateTime? updatedAt,
  }) => ScanItemComp(
    scanItemId: scanItemId ?? this.scanItemId,
    rawJson: rawJson ?? this.rawJson,
    medianPrice: medianPrice.present ? medianPrice.value : this.medianPrice,
    minPrice: minPrice.present ? minPrice.value : this.minPrice,
    maxPrice: maxPrice.present ? maxPrice.value : this.maxPrice,
    demandScore: demandScore.present ? demandScore.value : this.demandScore,
    daysToSellEst: daysToSellEst.present
        ? daysToSellEst.value
        : this.daysToSellEst,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScanItemComp copyWithCompanion(ScanItemCompsCompanion data) {
    return ScanItemComp(
      scanItemId: data.scanItemId.present
          ? data.scanItemId.value
          : this.scanItemId,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
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
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanItemComp(')
          ..write('scanItemId: $scanItemId, ')
          ..write('rawJson: $rawJson, ')
          ..write('medianPrice: $medianPrice, ')
          ..write('minPrice: $minPrice, ')
          ..write('maxPrice: $maxPrice, ')
          ..write('demandScore: $demandScore, ')
          ..write('daysToSellEst: $daysToSellEst, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    scanItemId,
    rawJson,
    medianPrice,
    minPrice,
    maxPrice,
    demandScore,
    daysToSellEst,
    fetchedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanItemComp &&
          other.scanItemId == this.scanItemId &&
          other.rawJson == this.rawJson &&
          other.medianPrice == this.medianPrice &&
          other.minPrice == this.minPrice &&
          other.maxPrice == this.maxPrice &&
          other.demandScore == this.demandScore &&
          other.daysToSellEst == this.daysToSellEst &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt);
}

class ScanItemCompsCompanion extends UpdateCompanion<ScanItemComp> {
  final Value<String> scanItemId;
  final Value<String> rawJson;
  final Value<double?> medianPrice;
  final Value<double?> minPrice;
  final Value<double?> maxPrice;
  final Value<int?> demandScore;
  final Value<int?> daysToSellEst;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScanItemCompsCompanion({
    this.scanItemId = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.medianPrice = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.maxPrice = const Value.absent(),
    this.demandScore = const Value.absent(),
    this.daysToSellEst = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanItemCompsCompanion.insert({
    required String scanItemId,
    required String rawJson,
    this.medianPrice = const Value.absent(),
    this.minPrice = const Value.absent(),
    this.maxPrice = const Value.absent(),
    this.demandScore = const Value.absent(),
    this.daysToSellEst = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scanItemId = Value(scanItemId),
       rawJson = Value(rawJson);
  static Insertable<ScanItemComp> custom({
    Expression<String>? scanItemId,
    Expression<String>? rawJson,
    Expression<double>? medianPrice,
    Expression<double>? minPrice,
    Expression<double>? maxPrice,
    Expression<int>? demandScore,
    Expression<int>? daysToSellEst,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scanItemId != null) 'scan_item_id': scanItemId,
      if (rawJson != null) 'raw_json': rawJson,
      if (medianPrice != null) 'median_price': medianPrice,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (demandScore != null) 'demand_score': demandScore,
      if (daysToSellEst != null) 'days_to_sell_est': daysToSellEst,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanItemCompsCompanion copyWith({
    Value<String>? scanItemId,
    Value<String>? rawJson,
    Value<double?>? medianPrice,
    Value<double?>? minPrice,
    Value<double?>? maxPrice,
    Value<int?>? demandScore,
    Value<int?>? daysToSellEst,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScanItemCompsCompanion(
      scanItemId: scanItemId ?? this.scanItemId,
      rawJson: rawJson ?? this.rawJson,
      medianPrice: medianPrice ?? this.medianPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      demandScore: demandScore ?? this.demandScore,
      daysToSellEst: daysToSellEst ?? this.daysToSellEst,
      fetchedAt: fetchedAt ?? this.fetchedAt,
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
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
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
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
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
    return (StringBuffer('ScanItemCompsCompanion(')
          ..write('scanItemId: $scanItemId, ')
          ..write('rawJson: $rawJson, ')
          ..write('medianPrice: $medianPrice, ')
          ..write('minPrice: $minPrice, ')
          ..write('maxPrice: $maxPrice, ')
          ..write('demandScore: $demandScore, ')
          ..write('daysToSellEst: $daysToSellEst, ')
          ..write('fetchedAt: $fetchedAt, ')
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

class $EntitySyncStatusesTable extends EntitySyncStatuses
    with TableInfo<$EntitySyncStatusesTable, EntitySyncStatuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitySyncStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    entityKey,
    status,
    lastError,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_sync_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitySyncStatuse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
  Set<GeneratedColumn> get $primaryKey => {entityKey};
  @override
  EntitySyncStatuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitySyncStatuse(
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
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
  $EntitySyncStatusesTable createAlias(String alias) {
    return $EntitySyncStatusesTable(attachedDatabase, alias);
  }
}

class EntitySyncStatuse extends DataClass
    implements Insertable<EntitySyncStatuse> {
  final String entityKey;
  final String status;
  final String? lastError;
  final DateTime updatedAt;
  const EntitySyncStatuse({
    required this.entityKey,
    required this.status,
    this.lastError,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_key'] = Variable<String>(entityKey);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntitySyncStatusesCompanion toCompanion(bool nullToAbsent) {
    return EntitySyncStatusesCompanion(
      entityKey: Value(entityKey),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntitySyncStatuse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitySyncStatuse(
      entityKey: serializer.fromJson<String>(json['entityKey']),
      status: serializer.fromJson<String>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityKey': serializer.toJson<String>(entityKey),
      'status': serializer.toJson<String>(status),
      'lastError': serializer.toJson<String?>(lastError),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntitySyncStatuse copyWith({
    String? entityKey,
    String? status,
    Value<String?> lastError = const Value.absent(),
    DateTime? updatedAt,
  }) => EntitySyncStatuse(
    entityKey: entityKey ?? this.entityKey,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EntitySyncStatuse copyWithCompanion(EntitySyncStatusesCompanion data) {
    return EntitySyncStatuse(
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitySyncStatuse(')
          ..write('entityKey: $entityKey, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityKey, status, lastError, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitySyncStatuse &&
          other.entityKey == this.entityKey &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.updatedAt == this.updatedAt);
}

class EntitySyncStatusesCompanion extends UpdateCompanion<EntitySyncStatuse> {
  final Value<String> entityKey;
  final Value<String> status;
  final Value<String?> lastError;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EntitySyncStatusesCompanion({
    this.entityKey = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitySyncStatusesCompanion.insert({
    required String entityKey,
    required String status,
    this.lastError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityKey = Value(entityKey),
       status = Value(status);
  static Insertable<EntitySyncStatuse> custom({
    Expression<String>? entityKey,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityKey != null) 'entity_key': entityKey,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitySyncStatusesCompanion copyWith({
    Value<String>? entityKey,
    Value<String>? status,
    Value<String?>? lastError,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EntitySyncStatusesCompanion(
      entityKey: entityKey ?? this.entityKey,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('EntitySyncStatusesCompanion(')
          ..write('entityKey: $entityKey, ')
          ..write('status: $status, ')
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
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
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
  List<GeneratedColumn> get $columns => [key, intValue, textValue, updatedAt];
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
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
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
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
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
  final String? textValue;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    this.intValue,
    this.textValue,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || intValue != null) {
      map['int_value'] = Variable<int>(intValue);
    }
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
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
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
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
      textValue: serializer.fromJson<String?>(json['textValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'intValue': serializer.toJson<int?>(intValue),
      'textValue': serializer.toJson<String?>(textValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<int?> intValue = const Value.absent(),
    Value<String?> textValue = const Value.absent(),
    DateTime? updatedAt,
  }) => AppSetting(
    key: key ?? this.key,
    intValue: intValue.present ? intValue.value : this.intValue,
    textValue: textValue.present ? textValue.value : this.textValue,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      intValue: data.intValue.present ? data.intValue.value : this.intValue,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('intValue: $intValue, ')
          ..write('textValue: $textValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, intValue, textValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.intValue == this.intValue &&
          other.textValue == this.textValue &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<int?> intValue;
  final Value<String?> textValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.intValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.intValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<int>? intValue,
    Expression<String>? textValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (intValue != null) 'int_value': intValue,
      if (textValue != null) 'text_value': textValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<int?>? intValue,
    Value<String?>? textValue,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      intValue: intValue ?? this.intValue,
      textValue: textValue ?? this.textValue,
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
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
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
          ..write('textValue: $textValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftListingsTable extends DraftListings
    with TableInfo<$DraftListingsTable, DraftListing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftListingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tradera'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _askingPriceSekMeta = const VerificationMeta(
    'askingPriceSek',
  );
  @override
  late final GeneratedColumn<double> askingPriceSek = GeneratedColumn<double>(
    'asking_price_sek',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    platform,
    title,
    description,
    askingPriceSek,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_listings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftListing> instance, {
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
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('asking_price_sek')) {
      context.handle(
        _askingPriceSekMeta,
        askingPriceSek.isAcceptableOrUnknown(
          data['asking_price_sek']!,
          _askingPriceSekMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  DraftListing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftListing(
      scanItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_item_id'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      askingPriceSek: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}asking_price_sek'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DraftListingsTable createAlias(String alias) {
    return $DraftListingsTable(attachedDatabase, alias);
  }
}

class DraftListing extends DataClass implements Insertable<DraftListing> {
  final String scanItemId;
  final String platform;
  final String? title;
  final String? description;
  final double? askingPriceSek;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DraftListing({
    required this.scanItemId,
    required this.platform,
    this.title,
    this.description,
    this.askingPriceSek,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scan_item_id'] = Variable<String>(scanItemId);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || askingPriceSek != null) {
      map['asking_price_sek'] = Variable<double>(askingPriceSek);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftListingsCompanion toCompanion(bool nullToAbsent) {
    return DraftListingsCompanion(
      scanItemId: Value(scanItemId),
      platform: Value(platform),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      askingPriceSek: askingPriceSek == null && nullToAbsent
          ? const Value.absent()
          : Value(askingPriceSek),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftListing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftListing(
      scanItemId: serializer.fromJson<String>(json['scanItemId']),
      platform: serializer.fromJson<String>(json['platform']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      askingPriceSek: serializer.fromJson<double?>(json['askingPriceSek']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scanItemId': serializer.toJson<String>(scanItemId),
      'platform': serializer.toJson<String>(platform),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'askingPriceSek': serializer.toJson<double?>(askingPriceSek),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftListing copyWith({
    String? scanItemId,
    String? platform,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> askingPriceSek = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DraftListing(
    scanItemId: scanItemId ?? this.scanItemId,
    platform: platform ?? this.platform,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    askingPriceSek: askingPriceSek.present
        ? askingPriceSek.value
        : this.askingPriceSek,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DraftListing copyWithCompanion(DraftListingsCompanion data) {
    return DraftListing(
      scanItemId: data.scanItemId.present
          ? data.scanItemId.value
          : this.scanItemId,
      platform: data.platform.present ? data.platform.value : this.platform,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      askingPriceSek: data.askingPriceSek.present
          ? data.askingPriceSek.value
          : this.askingPriceSek,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftListing(')
          ..write('scanItemId: $scanItemId, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('askingPriceSek: $askingPriceSek, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    scanItemId,
    platform,
    title,
    description,
    askingPriceSek,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftListing &&
          other.scanItemId == this.scanItemId &&
          other.platform == this.platform &&
          other.title == this.title &&
          other.description == this.description &&
          other.askingPriceSek == this.askingPriceSek &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DraftListingsCompanion extends UpdateCompanion<DraftListing> {
  final Value<String> scanItemId;
  final Value<String> platform;
  final Value<String?> title;
  final Value<String?> description;
  final Value<double?> askingPriceSek;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftListingsCompanion({
    this.scanItemId = const Value.absent(),
    this.platform = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.askingPriceSek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftListingsCompanion.insert({
    required String scanItemId,
    this.platform = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.askingPriceSek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scanItemId = Value(scanItemId);
  static Insertable<DraftListing> custom({
    Expression<String>? scanItemId,
    Expression<String>? platform,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? askingPriceSek,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scanItemId != null) 'scan_item_id': scanItemId,
      if (platform != null) 'platform': platform,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (askingPriceSek != null) 'asking_price_sek': askingPriceSek,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftListingsCompanion copyWith({
    Value<String>? scanItemId,
    Value<String>? platform,
    Value<String?>? title,
    Value<String?>? description,
    Value<double?>? askingPriceSek,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftListingsCompanion(
      scanItemId: scanItemId ?? this.scanItemId,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      description: description ?? this.description,
      askingPriceSek: askingPriceSek ?? this.askingPriceSek,
      createdAt: createdAt ?? this.createdAt,
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
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (askingPriceSek.present) {
      map['asking_price_sek'] = Variable<double>(askingPriceSek.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('DraftListingsCompanion(')
          ..write('scanItemId: $scanItemId, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('askingPriceSek: $askingPriceSek, ')
          ..write('createdAt: $createdAt, ')
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

class $PendingCloudSyncEntitiesTable extends PendingCloudSyncEntities
    with TableInfo<$PendingCloudSyncEntitiesTable, PendingCloudSyncEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingCloudSyncEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [entityKey, entityType, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_cloud_sync_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingCloudSyncEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
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
  Set<GeneratedColumn> get $primaryKey => {entityKey};
  @override
  PendingCloudSyncEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingCloudSyncEntity(
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PendingCloudSyncEntitiesTable createAlias(String alias) {
    return $PendingCloudSyncEntitiesTable(attachedDatabase, alias);
  }
}

class PendingCloudSyncEntity extends DataClass
    implements Insertable<PendingCloudSyncEntity> {
  final String entityKey;
  final String entityType;
  final DateTime updatedAt;
  const PendingCloudSyncEntity({
    required this.entityKey,
    required this.entityType,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_key'] = Variable<String>(entityKey);
    map['entity_type'] = Variable<String>(entityType);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PendingCloudSyncEntitiesCompanion toCompanion(bool nullToAbsent) {
    return PendingCloudSyncEntitiesCompanion(
      entityKey: Value(entityKey),
      entityType: Value(entityType),
      updatedAt: Value(updatedAt),
    );
  }

  factory PendingCloudSyncEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingCloudSyncEntity(
      entityKey: serializer.fromJson<String>(json['entityKey']),
      entityType: serializer.fromJson<String>(json['entityType']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityKey': serializer.toJson<String>(entityKey),
      'entityType': serializer.toJson<String>(entityType),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PendingCloudSyncEntity copyWith({
    String? entityKey,
    String? entityType,
    DateTime? updatedAt,
  }) => PendingCloudSyncEntity(
    entityKey: entityKey ?? this.entityKey,
    entityType: entityType ?? this.entityType,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PendingCloudSyncEntity copyWithCompanion(
    PendingCloudSyncEntitiesCompanion data,
  ) {
    return PendingCloudSyncEntity(
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingCloudSyncEntity(')
          ..write('entityKey: $entityKey, ')
          ..write('entityType: $entityType, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityKey, entityType, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingCloudSyncEntity &&
          other.entityKey == this.entityKey &&
          other.entityType == this.entityType &&
          other.updatedAt == this.updatedAt);
}

class PendingCloudSyncEntitiesCompanion
    extends UpdateCompanion<PendingCloudSyncEntity> {
  final Value<String> entityKey;
  final Value<String> entityType;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PendingCloudSyncEntitiesCompanion({
    this.entityKey = const Value.absent(),
    this.entityType = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingCloudSyncEntitiesCompanion.insert({
    required String entityKey,
    required String entityType,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityKey = Value(entityKey),
       entityType = Value(entityType);
  static Insertable<PendingCloudSyncEntity> custom({
    Expression<String>? entityKey,
    Expression<String>? entityType,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityKey != null) 'entity_key': entityKey,
      if (entityType != null) 'entity_type': entityType,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingCloudSyncEntitiesCompanion copyWith({
    Value<String>? entityKey,
    Value<String>? entityType,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PendingCloudSyncEntitiesCompanion(
      entityKey: entityKey ?? this.entityKey,
      entityType: entityType ?? this.entityType,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
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
    return (StringBuffer('PendingCloudSyncEntitiesCompanion(')
          ..write('entityKey: $entityKey, ')
          ..write('entityType: $entityType, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $ScanItemPhotosTable scanItemPhotos = $ScanItemPhotosTable(this);
  late final $ScanItemCompsTable scanItemComps = $ScanItemCompsTable(this);
  late final $ScanItemSyncStatesTable scanItemSyncStates =
      $ScanItemSyncStatesTable(this);
  late final $EntitySyncStatusesTable entitySyncStatuses =
      $EntitySyncStatusesTable(this);
  late final $SyncQuotasTable syncQuotas = $SyncQuotasTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DraftListingsTable draftListings = $DraftListingsTable(this);
  late final $MarketStatsCacheTable marketStatsCache = $MarketStatsCacheTable(
    this,
  );
  late final $PendingCloudSyncEntitiesTable pendingCloudSyncEntities =
      $PendingCloudSyncEntitiesTable(this);
  late final HaulsDao haulsDao = HaulsDao(this as AppDatabase);
  late final ScanItemsDao scanItemsDao = ScanItemsDao(this as AppDatabase);
  late final ScanItemPhotosDao scanItemPhotosDao = ScanItemPhotosDao(
    this as AppDatabase,
  );
  late final ScanItemCompsDao scanItemCompsDao = ScanItemCompsDao(
    this as AppDatabase,
  );
  late final ScanItemSyncStatesDao scanItemSyncStatesDao =
      ScanItemSyncStatesDao(this as AppDatabase);
  late final EntitySyncStatusesDao entitySyncStatusesDao =
      EntitySyncStatusesDao(this as AppDatabase);
  late final SyncQuotasDao syncQuotasDao = SyncQuotasDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final DraftListingsDao draftListingsDao = DraftListingsDao(
    this as AppDatabase,
  );
  late final MarketStatsCacheDao marketStatsCacheDao = MarketStatsCacheDao(
    this as AppDatabase,
  );
  late final PendingCloudSyncEntitiesDao pendingCloudSyncEntitiesDao =
      PendingCloudSyncEntitiesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hauls,
    scanItems,
    scanItemPhotos,
    scanItemComps,
    scanItemSyncStates,
    entitySyncStatuses,
    syncQuotas,
    appSettings,
    draftListings,
    marketStatsCache,
    pendingCloudSyncEntities,
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
      result: [TableUpdate('scan_item_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scan_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_item_comps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scan_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_item_sync_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scan_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('draft_listings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HaulsTableCreateCompanionBuilder =
    HaulsCompanion Function({
      required String id,
      Value<String?> userId,
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
      Value<String?> userId,
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

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
                Value<String?> userId = const Value.absent(),
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
                userId: userId,
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
                Value<String?> userId = const Value.absent(),
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
                userId: userId,
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
      Value<String?> userId,
      required String haulId,
      Value<String?> imagePath,
      Value<String?> thumbPath,
      Value<String?> aiJson,
      Value<String?> query,
      Value<String?> desc,
      Value<String?> category,
      Value<String?> notes,
      Value<double?> confidence,
      Value<double?> purchasePrice,
      Value<double?> fixedFeesSek,
      Value<double?> shippingPaidBySellerSek,
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
      Value<String?> userId,
      Value<String> haulId,
      Value<String?> imagePath,
      Value<String?> thumbPath,
      Value<String?> aiJson,
      Value<String?> query,
      Value<String?> desc,
      Value<String?> category,
      Value<String?> notes,
      Value<double?> confidence,
      Value<double?> purchasePrice,
      Value<double?> fixedFeesSek,
      Value<double?> shippingPaidBySellerSek,
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

  static MultiTypedResultKey<$ScanItemPhotosTable, List<ScanItemPhoto>>
  _scanItemPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanItemPhotos,
    aliasName: $_aliasNameGenerator(
      db.scanItems.id,
      db.scanItemPhotos.scanItemId,
    ),
  );

  $$ScanItemPhotosTableProcessedTableManager get scanItemPhotosRefs {
    final manager = $$ScanItemPhotosTableTableManager(
      $_db,
      $_db.scanItemPhotos,
    ).filter((f) => f.scanItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanItemPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScanItemCompsTable, List<ScanItemComp>>
  _scanItemCompsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanItemComps,
    aliasName: $_aliasNameGenerator(
      db.scanItems.id,
      db.scanItemComps.scanItemId,
    ),
  );

  $$ScanItemCompsTableProcessedTableManager get scanItemCompsRefs {
    final manager = $$ScanItemCompsTableTableManager(
      $_db,
      $_db.scanItemComps,
    ).filter((f) => f.scanItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanItemCompsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  static MultiTypedResultKey<$DraftListingsTable, List<DraftListing>>
  _draftListingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.draftListings,
    aliasName: $_aliasNameGenerator(
      db.scanItems.id,
      db.draftListings.scanItemId,
    ),
  );

  $$DraftListingsTableProcessedTableManager get draftListingsRefs {
    final manager = $$DraftListingsTableTableManager(
      $_db,
      $_db.draftListings,
    ).filter((f) => f.scanItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_draftListingsRefsTable($_db));
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnFilters<double> get fixedFeesSek => $composableBuilder(
    column: $table.fixedFeesSek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shippingPaidBySellerSek => $composableBuilder(
    column: $table.shippingPaidBySellerSek,
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

  Expression<bool> scanItemPhotosRefs(
    Expression<bool> Function($$ScanItemPhotosTableFilterComposer f) f,
  ) {
    final $$ScanItemPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItemPhotos,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemPhotosTableFilterComposer(
            $db: $db,
            $table: $db.scanItemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scanItemCompsRefs(
    Expression<bool> Function($$ScanItemCompsTableFilterComposer f) f,
  ) {
    final $$ScanItemCompsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItemComps,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemCompsTableFilterComposer(
            $db: $db,
            $table: $db.scanItemComps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<bool> draftListingsRefs(
    Expression<bool> Function($$DraftListingsTableFilterComposer f) f,
  ) {
    final $$DraftListingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draftListings,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftListingsTableFilterComposer(
            $db: $db,
            $table: $db.draftListings,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<double> get fixedFeesSek => $composableBuilder(
    column: $table.fixedFeesSek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shippingPaidBySellerSek => $composableBuilder(
    column: $table.shippingPaidBySellerSek,
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fixedFeesSek => $composableBuilder(
    column: $table.fixedFeesSek,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shippingPaidBySellerSek => $composableBuilder(
    column: $table.shippingPaidBySellerSek,
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

  Expression<T> scanItemPhotosRefs<T extends Object>(
    Expression<T> Function($$ScanItemPhotosTableAnnotationComposer a) f,
  ) {
    final $$ScanItemPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItemPhotos,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.scanItemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scanItemCompsRefs<T extends Object>(
    Expression<T> Function($$ScanItemCompsTableAnnotationComposer a) f,
  ) {
    final $$ScanItemCompsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanItemComps,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanItemCompsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanItemComps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<T> draftListingsRefs<T extends Object>(
    Expression<T> Function($$DraftListingsTableAnnotationComposer a) f,
  ) {
    final $$DraftListingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draftListings,
      getReferencedColumn: (t) => t.scanItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DraftListingsTableAnnotationComposer(
            $db: $db,
            $table: $db.draftListings,
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
          PrefetchHooks Function({
            bool haulId,
            bool scanItemPhotosRefs,
            bool scanItemCompsRefs,
            bool scanItemSyncStatesRefs,
            bool draftListingsRefs,
          })
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
                Value<String?> userId = const Value.absent(),
                Value<String> haulId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> aiJson = const Value.absent(),
                Value<String?> query = const Value.absent(),
                Value<String?> desc = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double?> fixedFeesSek = const Value.absent(),
                Value<double?> shippingPaidBySellerSek = const Value.absent(),
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
                userId: userId,
                haulId: haulId,
                imagePath: imagePath,
                thumbPath: thumbPath,
                aiJson: aiJson,
                query: query,
                desc: desc,
                category: category,
                notes: notes,
                confidence: confidence,
                purchasePrice: purchasePrice,
                fixedFeesSek: fixedFeesSek,
                shippingPaidBySellerSek: shippingPaidBySellerSek,
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
                Value<String?> userId = const Value.absent(),
                required String haulId,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> aiJson = const Value.absent(),
                Value<String?> query = const Value.absent(),
                Value<String?> desc = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double?> fixedFeesSek = const Value.absent(),
                Value<double?> shippingPaidBySellerSek = const Value.absent(),
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
                userId: userId,
                haulId: haulId,
                imagePath: imagePath,
                thumbPath: thumbPath,
                aiJson: aiJson,
                query: query,
                desc: desc,
                category: category,
                notes: notes,
                confidence: confidence,
                purchasePrice: purchasePrice,
                fixedFeesSek: fixedFeesSek,
                shippingPaidBySellerSek: shippingPaidBySellerSek,
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
              ({
                haulId = false,
                scanItemPhotosRefs = false,
                scanItemCompsRefs = false,
                scanItemSyncStatesRefs = false,
                draftListingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scanItemPhotosRefs) db.scanItemPhotos,
                    if (scanItemCompsRefs) db.scanItemComps,
                    if (scanItemSyncStatesRefs) db.scanItemSyncStates,
                    if (draftListingsRefs) db.draftListings,
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
                      if (scanItemPhotosRefs)
                        await $_getPrefetchedData<
                          ScanItem,
                          $ScanItemsTable,
                          ScanItemPhoto
                        >(
                          currentTable: table,
                          referencedTable: $$ScanItemsTableReferences
                              ._scanItemPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScanItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).scanItemPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scanItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scanItemCompsRefs)
                        await $_getPrefetchedData<
                          ScanItem,
                          $ScanItemsTable,
                          ScanItemComp
                        >(
                          currentTable: table,
                          referencedTable: $$ScanItemsTableReferences
                              ._scanItemCompsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScanItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).scanItemCompsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scanItemId == item.id,
                              ),
                          typedResults: items,
                        ),
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
                      if (draftListingsRefs)
                        await $_getPrefetchedData<
                          ScanItem,
                          $ScanItemsTable,
                          DraftListing
                        >(
                          currentTable: table,
                          referencedTable: $$ScanItemsTableReferences
                              ._draftListingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScanItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).draftListingsRefs,
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
      PrefetchHooks Function({
        bool haulId,
        bool scanItemPhotosRefs,
        bool scanItemCompsRefs,
        bool scanItemSyncStatesRefs,
        bool draftListingsRefs,
      })
    >;
typedef $$ScanItemPhotosTableCreateCompanionBuilder =
    ScanItemPhotosCompanion Function({
      required String id,
      required String scanItemId,
      required String localPath,
      Value<String?> thumbPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ScanItemPhotosTableUpdateCompanionBuilder =
    ScanItemPhotosCompanion Function({
      Value<String> id,
      Value<String> scanItemId,
      Value<String> localPath,
      Value<String?> thumbPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ScanItemPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $ScanItemPhotosTable, ScanItemPhoto> {
  $$ScanItemPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScanItemsTable _scanItemIdTable(_$AppDatabase db) =>
      db.scanItems.createAlias(
        $_aliasNameGenerator(db.scanItemPhotos.scanItemId, db.scanItems.id),
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

class $$ScanItemPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ScanItemPhotosTable> {
  $$ScanItemPhotosTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$ScanItemPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanItemPhotosTable> {
  $$ScanItemPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$ScanItemPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanItemPhotosTable> {
  $$ScanItemPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

class $$ScanItemPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanItemPhotosTable,
          ScanItemPhoto,
          $$ScanItemPhotosTableFilterComposer,
          $$ScanItemPhotosTableOrderingComposer,
          $$ScanItemPhotosTableAnnotationComposer,
          $$ScanItemPhotosTableCreateCompanionBuilder,
          $$ScanItemPhotosTableUpdateCompanionBuilder,
          (ScanItemPhoto, $$ScanItemPhotosTableReferences),
          ScanItemPhoto,
          PrefetchHooks Function({bool scanItemId})
        > {
  $$ScanItemPhotosTableTableManager(
    _$AppDatabase db,
    $ScanItemPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanItemPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanItemPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanItemPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scanItemId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemPhotosCompanion(
                id: id,
                scanItemId: scanItemId,
                localPath: localPath,
                thumbPath: thumbPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scanItemId,
                required String localPath,
                Value<String?> thumbPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemPhotosCompanion.insert(
                id: id,
                scanItemId: scanItemId,
                localPath: localPath,
                thumbPath: thumbPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanItemPhotosTableReferences(db, table, e),
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
                                referencedTable: $$ScanItemPhotosTableReferences
                                    ._scanItemIdTable(db),
                                referencedColumn:
                                    $$ScanItemPhotosTableReferences
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

typedef $$ScanItemPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanItemPhotosTable,
      ScanItemPhoto,
      $$ScanItemPhotosTableFilterComposer,
      $$ScanItemPhotosTableOrderingComposer,
      $$ScanItemPhotosTableAnnotationComposer,
      $$ScanItemPhotosTableCreateCompanionBuilder,
      $$ScanItemPhotosTableUpdateCompanionBuilder,
      (ScanItemPhoto, $$ScanItemPhotosTableReferences),
      ScanItemPhoto,
      PrefetchHooks Function({bool scanItemId})
    >;
typedef $$ScanItemCompsTableCreateCompanionBuilder =
    ScanItemCompsCompanion Function({
      required String scanItemId,
      required String rawJson,
      Value<double?> medianPrice,
      Value<double?> minPrice,
      Value<double?> maxPrice,
      Value<int?> demandScore,
      Value<int?> daysToSellEst,
      Value<DateTime> fetchedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ScanItemCompsTableUpdateCompanionBuilder =
    ScanItemCompsCompanion Function({
      Value<String> scanItemId,
      Value<String> rawJson,
      Value<double?> medianPrice,
      Value<double?> minPrice,
      Value<double?> maxPrice,
      Value<int?> demandScore,
      Value<int?> daysToSellEst,
      Value<DateTime> fetchedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ScanItemCompsTableReferences
    extends BaseReferences<_$AppDatabase, $ScanItemCompsTable, ScanItemComp> {
  $$ScanItemCompsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScanItemsTable _scanItemIdTable(_$AppDatabase db) =>
      db.scanItems.createAlias(
        $_aliasNameGenerator(db.scanItemComps.scanItemId, db.scanItems.id),
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

class $$ScanItemCompsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanItemCompsTable> {
  $$ScanItemCompsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
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

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
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

class $$ScanItemCompsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanItemCompsTable> {
  $$ScanItemCompsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
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

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
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

class $$ScanItemCompsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanItemCompsTable> {
  $$ScanItemCompsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

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

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

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

class $$ScanItemCompsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanItemCompsTable,
          ScanItemComp,
          $$ScanItemCompsTableFilterComposer,
          $$ScanItemCompsTableOrderingComposer,
          $$ScanItemCompsTableAnnotationComposer,
          $$ScanItemCompsTableCreateCompanionBuilder,
          $$ScanItemCompsTableUpdateCompanionBuilder,
          (ScanItemComp, $$ScanItemCompsTableReferences),
          ScanItemComp,
          PrefetchHooks Function({bool scanItemId})
        > {
  $$ScanItemCompsTableTableManager(_$AppDatabase db, $ScanItemCompsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanItemCompsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanItemCompsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanItemCompsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scanItemId = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<double?> medianPrice = const Value.absent(),
                Value<double?> minPrice = const Value.absent(),
                Value<double?> maxPrice = const Value.absent(),
                Value<int?> demandScore = const Value.absent(),
                Value<int?> daysToSellEst = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemCompsCompanion(
                scanItemId: scanItemId,
                rawJson: rawJson,
                medianPrice: medianPrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
                demandScore: demandScore,
                daysToSellEst: daysToSellEst,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scanItemId,
                required String rawJson,
                Value<double?> medianPrice = const Value.absent(),
                Value<double?> minPrice = const Value.absent(),
                Value<double?> maxPrice = const Value.absent(),
                Value<int?> demandScore = const Value.absent(),
                Value<int?> daysToSellEst = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanItemCompsCompanion.insert(
                scanItemId: scanItemId,
                rawJson: rawJson,
                medianPrice: medianPrice,
                minPrice: minPrice,
                maxPrice: maxPrice,
                demandScore: demandScore,
                daysToSellEst: daysToSellEst,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanItemCompsTableReferences(db, table, e),
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
                                referencedTable: $$ScanItemCompsTableReferences
                                    ._scanItemIdTable(db),
                                referencedColumn: $$ScanItemCompsTableReferences
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

typedef $$ScanItemCompsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanItemCompsTable,
      ScanItemComp,
      $$ScanItemCompsTableFilterComposer,
      $$ScanItemCompsTableOrderingComposer,
      $$ScanItemCompsTableAnnotationComposer,
      $$ScanItemCompsTableCreateCompanionBuilder,
      $$ScanItemCompsTableUpdateCompanionBuilder,
      (ScanItemComp, $$ScanItemCompsTableReferences),
      ScanItemComp,
      PrefetchHooks Function({bool scanItemId})
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
typedef $$EntitySyncStatusesTableCreateCompanionBuilder =
    EntitySyncStatusesCompanion Function({
      required String entityKey,
      required String status,
      Value<String?> lastError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$EntitySyncStatusesTableUpdateCompanionBuilder =
    EntitySyncStatusesCompanion Function({
      Value<String> entityKey,
      Value<String> status,
      Value<String?> lastError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EntitySyncStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $EntitySyncStatusesTable> {
  $$EntitySyncStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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
}

class $$EntitySyncStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitySyncStatusesTable> {
  $$EntitySyncStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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
}

class $$EntitySyncStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitySyncStatusesTable> {
  $$EntitySyncStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EntitySyncStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitySyncStatusesTable,
          EntitySyncStatuse,
          $$EntitySyncStatusesTableFilterComposer,
          $$EntitySyncStatusesTableOrderingComposer,
          $$EntitySyncStatusesTableAnnotationComposer,
          $$EntitySyncStatusesTableCreateCompanionBuilder,
          $$EntitySyncStatusesTableUpdateCompanionBuilder,
          (
            EntitySyncStatuse,
            BaseReferences<
              _$AppDatabase,
              $EntitySyncStatusesTable,
              EntitySyncStatuse
            >,
          ),
          EntitySyncStatuse,
          PrefetchHooks Function()
        > {
  $$EntitySyncStatusesTableTableManager(
    _$AppDatabase db,
    $EntitySyncStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitySyncStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitySyncStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitySyncStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitySyncStatusesCompanion(
                entityKey: entityKey,
                status: status,
                lastError: lastError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityKey,
                required String status,
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitySyncStatusesCompanion.insert(
                entityKey: entityKey,
                status: status,
                lastError: lastError,
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

typedef $$EntitySyncStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitySyncStatusesTable,
      EntitySyncStatuse,
      $$EntitySyncStatusesTableFilterComposer,
      $$EntitySyncStatusesTableOrderingComposer,
      $$EntitySyncStatusesTableAnnotationComposer,
      $$EntitySyncStatusesTableCreateCompanionBuilder,
      $$EntitySyncStatusesTableUpdateCompanionBuilder,
      (
        EntitySyncStatuse,
        BaseReferences<
          _$AppDatabase,
          $EntitySyncStatusesTable,
          EntitySyncStatuse
        >,
      ),
      EntitySyncStatuse,
      PrefetchHooks Function()
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
      Value<String?> textValue,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<int?> intValue,
      Value<String?> textValue,
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

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
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

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
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

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

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
                Value<String?> textValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                intValue: intValue,
                textValue: textValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int?> intValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                intValue: intValue,
                textValue: textValue,
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
typedef $$DraftListingsTableCreateCompanionBuilder =
    DraftListingsCompanion Function({
      required String scanItemId,
      Value<String> platform,
      Value<String?> title,
      Value<String?> description,
      Value<double?> askingPriceSek,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$DraftListingsTableUpdateCompanionBuilder =
    DraftListingsCompanion Function({
      Value<String> scanItemId,
      Value<String> platform,
      Value<String?> title,
      Value<String?> description,
      Value<double?> askingPriceSek,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DraftListingsTableReferences
    extends BaseReferences<_$AppDatabase, $DraftListingsTable, DraftListing> {
  $$DraftListingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScanItemsTable _scanItemIdTable(_$AppDatabase db) =>
      db.scanItems.createAlias(
        $_aliasNameGenerator(db.draftListings.scanItemId, db.scanItems.id),
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

class $$DraftListingsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftListingsTable> {
  $$DraftListingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get askingPriceSek => $composableBuilder(
    column: $table.askingPriceSek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$DraftListingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftListingsTable> {
  $$DraftListingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get askingPriceSek => $composableBuilder(
    column: $table.askingPriceSek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$DraftListingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftListingsTable> {
  $$DraftListingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get askingPriceSek => $composableBuilder(
    column: $table.askingPriceSek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

class $$DraftListingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftListingsTable,
          DraftListing,
          $$DraftListingsTableFilterComposer,
          $$DraftListingsTableOrderingComposer,
          $$DraftListingsTableAnnotationComposer,
          $$DraftListingsTableCreateCompanionBuilder,
          $$DraftListingsTableUpdateCompanionBuilder,
          (DraftListing, $$DraftListingsTableReferences),
          DraftListing,
          PrefetchHooks Function({bool scanItemId})
        > {
  $$DraftListingsTableTableManager(_$AppDatabase db, $DraftListingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftListingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftListingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftListingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scanItemId = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> askingPriceSek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftListingsCompanion(
                scanItemId: scanItemId,
                platform: platform,
                title: title,
                description: description,
                askingPriceSek: askingPriceSek,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scanItemId,
                Value<String> platform = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> askingPriceSek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftListingsCompanion.insert(
                scanItemId: scanItemId,
                platform: platform,
                title: title,
                description: description,
                askingPriceSek: askingPriceSek,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DraftListingsTableReferences(db, table, e),
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
                                referencedTable: $$DraftListingsTableReferences
                                    ._scanItemIdTable(db),
                                referencedColumn: $$DraftListingsTableReferences
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

typedef $$DraftListingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftListingsTable,
      DraftListing,
      $$DraftListingsTableFilterComposer,
      $$DraftListingsTableOrderingComposer,
      $$DraftListingsTableAnnotationComposer,
      $$DraftListingsTableCreateCompanionBuilder,
      $$DraftListingsTableUpdateCompanionBuilder,
      (DraftListing, $$DraftListingsTableReferences),
      DraftListing,
      PrefetchHooks Function({bool scanItemId})
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
typedef $$PendingCloudSyncEntitiesTableCreateCompanionBuilder =
    PendingCloudSyncEntitiesCompanion Function({
      required String entityKey,
      required String entityType,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PendingCloudSyncEntitiesTableUpdateCompanionBuilder =
    PendingCloudSyncEntitiesCompanion Function({
      Value<String> entityKey,
      Value<String> entityType,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PendingCloudSyncEntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingCloudSyncEntitiesTable> {
  $$PendingCloudSyncEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingCloudSyncEntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingCloudSyncEntitiesTable> {
  $$PendingCloudSyncEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingCloudSyncEntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingCloudSyncEntitiesTable> {
  $$PendingCloudSyncEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PendingCloudSyncEntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingCloudSyncEntitiesTable,
          PendingCloudSyncEntity,
          $$PendingCloudSyncEntitiesTableFilterComposer,
          $$PendingCloudSyncEntitiesTableOrderingComposer,
          $$PendingCloudSyncEntitiesTableAnnotationComposer,
          $$PendingCloudSyncEntitiesTableCreateCompanionBuilder,
          $$PendingCloudSyncEntitiesTableUpdateCompanionBuilder,
          (
            PendingCloudSyncEntity,
            BaseReferences<
              _$AppDatabase,
              $PendingCloudSyncEntitiesTable,
              PendingCloudSyncEntity
            >,
          ),
          PendingCloudSyncEntity,
          PrefetchHooks Function()
        > {
  $$PendingCloudSyncEntitiesTableTableManager(
    _$AppDatabase db,
    $PendingCloudSyncEntitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingCloudSyncEntitiesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingCloudSyncEntitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingCloudSyncEntitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityKey = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingCloudSyncEntitiesCompanion(
                entityKey: entityKey,
                entityType: entityType,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityKey,
                required String entityType,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingCloudSyncEntitiesCompanion.insert(
                entityKey: entityKey,
                entityType: entityType,
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

typedef $$PendingCloudSyncEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingCloudSyncEntitiesTable,
      PendingCloudSyncEntity,
      $$PendingCloudSyncEntitiesTableFilterComposer,
      $$PendingCloudSyncEntitiesTableOrderingComposer,
      $$PendingCloudSyncEntitiesTableAnnotationComposer,
      $$PendingCloudSyncEntitiesTableCreateCompanionBuilder,
      $$PendingCloudSyncEntitiesTableUpdateCompanionBuilder,
      (
        PendingCloudSyncEntity,
        BaseReferences<
          _$AppDatabase,
          $PendingCloudSyncEntitiesTable,
          PendingCloudSyncEntity
        >,
      ),
      PendingCloudSyncEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HaulsTableTableManager get hauls =>
      $$HaulsTableTableManager(_db, _db.hauls);
  $$ScanItemsTableTableManager get scanItems =>
      $$ScanItemsTableTableManager(_db, _db.scanItems);
  $$ScanItemPhotosTableTableManager get scanItemPhotos =>
      $$ScanItemPhotosTableTableManager(_db, _db.scanItemPhotos);
  $$ScanItemCompsTableTableManager get scanItemComps =>
      $$ScanItemCompsTableTableManager(_db, _db.scanItemComps);
  $$ScanItemSyncStatesTableTableManager get scanItemSyncStates =>
      $$ScanItemSyncStatesTableTableManager(_db, _db.scanItemSyncStates);
  $$EntitySyncStatusesTableTableManager get entitySyncStatuses =>
      $$EntitySyncStatusesTableTableManager(_db, _db.entitySyncStatuses);
  $$SyncQuotasTableTableManager get syncQuotas =>
      $$SyncQuotasTableTableManager(_db, _db.syncQuotas);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DraftListingsTableTableManager get draftListings =>
      $$DraftListingsTableTableManager(_db, _db.draftListings);
  $$MarketStatsCacheTableTableManager get marketStatsCache =>
      $$MarketStatsCacheTableTableManager(_db, _db.marketStatsCache);
  $$PendingCloudSyncEntitiesTableTableManager get pendingCloudSyncEntities =>
      $$PendingCloudSyncEntitiesTableTableManager(
        _db,
        _db.pendingCloudSyncEntities,
      );
}
