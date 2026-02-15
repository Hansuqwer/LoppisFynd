import 'package:geocoding/geocoding.dart';

import '../../core/database/app_database.dart';

class ReverseGeocodeCacheService {
  ReverseGeocodeCacheService({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<String?> suggestName({
    required double lat,
    required double lng,
    required String fallback,
  }) async {
    final key = _key(lat: lat, lng: lng);
    final cached = await _db.appSettingsDao.getString(key);
    if (cached != null && cached.trim().isNotEmpty) {
      return cached.trim();
    }

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
                : (admin ?? fallback));

      final out = name.trim();
      if (out.isNotEmpty) {
        await _db.appSettingsDao.setString(key, out);
        return out;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

String _key({required double lat, required double lng}) {
  String f(double v) => v.toStringAsFixed(3);
  return 'rg_${f(lat)}_${f(lng)}';
}
