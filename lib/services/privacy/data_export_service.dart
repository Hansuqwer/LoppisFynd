import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/database/app_database.dart';

class DataExportService {
  DataExportService({Future<Directory> Function()? documentsDirProvider})
    : _documentsDirProvider = documentsDirProvider;

  final Future<Directory> Function()? _documentsDirProvider;

  Future<Directory> _documentsDir() async {
    return _documentsDirProvider == null
        ? getApplicationDocumentsDirectory()
        : _documentsDirProvider();
  }

  Future<File> exportJson({
    required AppDatabase db,
    required String? userId,
  }) async {
    final now = DateTime.now();
    final scope = userId ?? 'guest';

    final hauls = await db.haulsDao.listAll(userId: userId);
    final scanItems = await db.scanItemsDao.listAll(userId: userId);
    final drafts = await db.draftListingsDao.listAllForUser(userId: userId);

    final payload = {
      'exportedAt': now.toIso8601String(),
      'scope': scope,
      'hauls': hauls
          .map(
            (h) => {
              'id': h.id,
              'userId': h.userId,
              'title': h.title,
              'startedAt': h.startedAt.toIso8601String(),
              'endedAt': h.endedAt?.toIso8601String(),
              'lat': h.lat,
              'lng': h.lng,
              'totalInvested': h.totalInvested,
              'grossValue': h.grossValue,
              'netProfit': h.netProfit,
              'co2SavedKg': h.co2SavedKg,
              'updatedAt': h.updatedAt.toIso8601String(),
            },
          )
          .toList(growable: false),
      'scanItems': scanItems
          .map(
            (s) => {
              'id': s.id,
              'userId': s.userId,
              'haulId': s.haulId,
              'imagePath': s.imagePath,
              'thumbPath': s.thumbPath,
              'aiJson': s.aiJson,
              'query': s.query,
              'desc': s.desc,
              'category': s.category,
              'notes': s.notes,
              'confidence': s.confidence,
              'purchasePrice': s.purchasePrice,
              'fixedFeesSek': s.fixedFeesSek,
              'shippingPaidBySellerSek': s.shippingPaidBySellerSek,
              'conditionMultiplier': s.conditionMultiplier,
              'medianPrice': s.medianPrice,
              'minPrice': s.minPrice,
              'maxPrice': s.maxPrice,
              'demandScore': s.demandScore,
              'daysToSellEst': s.daysToSellEst,
              'status': s.status.name,
              'updatedAt': s.updatedAt.toIso8601String(),
            },
          )
          .toList(growable: false),
      'draftListings': drafts
          .map(
            (d) => {
              'scanItemId': d.draft.scanItemId,
              'platform': d.draft.platform,
              'title': d.draft.title,
              'description': d.draft.description,
              'askingPriceSek': d.draft.askingPriceSek,
              'createdAt': d.draft.createdAt.toIso8601String(),
              'updatedAt': d.draft.updatedAt.toIso8601String(),
            },
          )
          .toList(growable: false),
    };

    final jsonText = const JsonEncoder.withIndent('  ').convert(payload);
    final dir = await _documentsDir();
    final fileName = _fileName(now: now, scope: scope, ext: 'json');
    final file = File(p.join(dir.path, fileName));
    return file.writeAsString(jsonText, flush: true);
  }

  Future<File> exportCsv({
    required AppDatabase db,
    required String? userId,
  }) async {
    final now = DateTime.now();
    final scope = userId ?? 'guest';

    final hauls = await db.haulsDao.listAll(userId: userId);
    final scanItems = await db.scanItemsDao.listAll(userId: userId);

    final lines = <String>[];
    lines.add(
      'type,id,haulId,title,startedAt,status,category,purchasePriceSek,medianPriceSek,netProfitSek,query,notes,updatedAt',
    );

    for (final h in hauls) {
      lines.add(
        _csv([
          'haul',
          h.id,
          '',
          h.title,
          h.startedAt.toIso8601String(),
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          h.updatedAt.toIso8601String(),
        ]),
      );
    }

    for (final it in scanItems) {
      final net = _netProfit(it);
      lines.add(
        _csv([
          'item',
          it.id,
          it.haulId,
          it.desc ?? '',
          '',
          it.status.name,
          it.category ?? '',
          _num(it.purchasePrice),
          _num(it.medianPrice),
          _num(net),
          it.query ?? '',
          it.notes ?? '',
          it.updatedAt.toIso8601String(),
        ]),
      );
    }

    final dir = await _documentsDir();
    final fileName = _fileName(now: now, scope: scope, ext: 'csv');
    final file = File(p.join(dir.path, fileName));
    return file.writeAsString(lines.join('\n'), flush: true);
  }
}

double? _netProfit(ScanItem it) {
  final p = it.purchasePrice;
  final m = it.medianPrice;
  if (p == null || m == null) return null;
  final expected = m * it.conditionMultiplier;
  final feeRate = 0.10;
  final platformFee = expected * feeRate;
  return expected -
      platformFee -
      (it.fixedFeesSek ?? 0) -
      (it.shippingPaidBySellerSek ?? 0) -
      p;
}

String _num(double? value) =>
    value == null ? '' : value.toStringAsFixed(value % 1 == 0 ? 0 : 2);

String _fileName({
  required DateTime now,
  required String scope,
  required String ext,
}) {
  String two(int v) => v.toString().padLeft(2, '0');
  final stamp =
      '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}';
  final safeScope = scope.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  return 'loppisfynd_export_${safeScope}_$stamp.$ext';
}

String _csv(List<String> fields) {
  return fields.map(_csvField).join(',');
}

String _csvField(String value) {
  final needsQuotes =
      value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  if (!needsQuotes) return value;
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}
