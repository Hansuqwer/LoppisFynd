import 'dart:convert';

import 'ai_types.dart';

class AiJsonParser {
  static AiSingleItemResult parseSingleItem(String rawJson) {
    final root = _decodeObject(rawJson);
    final desc = _readBoundedString(root['desc'], 'desc', min: 2, max: 80);
    final query = _readBoundedString(root['query'], 'query', min: 2, max: 80);
    final confidence = _readConfidence(root['confidence']);

    final attrsAny = root['attributes'];
    if (attrsAny is! Map) {
      throw const AiJsonValidationException('attributes must be an object');
    }

    final brand = _readOptionalBoundedString(
      attrsAny['brand'],
      'attributes.brand',
    );
    final model = _readOptionalBoundedString(
      attrsAny['model'],
      'attributes.model',
    );
    final material = _readOptionalBoundedString(
      attrsAny['material'],
      'attributes.material',
    );
    final era = _readOptionalBoundedString(attrsAny['era'], 'attributes.era');

    return AiSingleItemResult(
      desc: desc,
      query: query,
      confidence: confidence,
      attributes: {
        'brand': brand,
        'model': model,
        'material': material,
        'era': era,
      },
      rawJson: rawJson,
    );
  }

  static AiBatchShelfResult parseBatchShelf(String rawJson) {
    final root = _decodeObject(rawJson);
    final itemsAny = root['items'];
    if (itemsAny is! List) {
      throw const AiJsonValidationException('items must be a list');
    }
    if (itemsAny.length > 5) {
      throw const AiJsonValidationException('items max length is 5');
    }

    final items = <AiBatchItem>[];
    for (var i = 0; i < itemsAny.length; i++) {
      final v = itemsAny[i];
      if (v is! Map) {
        throw AiJsonValidationException('items[$i] must be an object');
      }
      final desc = _readBoundedString(
        v['desc'],
        'items[$i].desc',
        min: 2,
        max: 80,
      );
      final query = _readBoundedString(
        v['query'],
        'items[$i].query',
        min: 2,
        max: 80,
      );
      final confidence = _readConfidence(v['confidence']);
      items.add(AiBatchItem(desc: desc, query: query, confidence: confidence));
    }

    return AiBatchShelfResult(items: items, rawJson: rawJson);
  }
}

Map<String, Object?> _decodeObject(String rawJson) {
  final decoded = jsonDecode(rawJson);
  if (decoded is! Map) {
    throw const AiJsonValidationException('Root must be a JSON object');
  }
  return decoded.cast<String, Object?>();
}

String _readBoundedString(
  Object? value,
  String field, {
  required int min,
  required int max,
}) {
  if (value is! String) {
    throw AiJsonValidationException('$field must be a string');
  }
  final trimmed = value.trim();
  if (trimmed.length < min || trimmed.length > max) {
    throw AiJsonValidationException('$field length must be $min..$max');
  }
  return trimmed;
}

String _readOptionalBoundedString(Object? value, String field) {
  if (value == null) return '';
  if (value is! String) {
    throw AiJsonValidationException('$field must be a string');
  }
  final trimmed = value.trim();
  if (trimmed.length > 80) {
    throw AiJsonValidationException('$field length must be 0..80');
  }
  return trimmed;
}

double _readConfidence(Object? value) {
  if (value is! num) {
    throw const AiJsonValidationException('confidence must be a number');
  }
  final d = value.toDouble();
  if (d.isNaN || d < 0.0 || d > 1.0) {
    throw const AiJsonValidationException('confidence must be 0.0..1.0');
  }
  return d;
}
