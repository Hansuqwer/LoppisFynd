import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<LocationPermission> ensurePermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm;
  }

  Future<Position> getCurrentPosition({
    Duration timeout = const Duration(seconds: 10),
  }) {
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: timeout,
      ),
    );
  }
}
