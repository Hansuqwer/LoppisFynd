import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

InputImage? inputImageFromCameraImage({
  required dynamic image,
  required int sensorOrientation,
  required DeviceOrientation deviceOrientation,
  required dynamic lensDirection,
}) {
  // ML Kit commons guidance:
  // - Android: use NV21 with 1 plane
  // - iOS: use BGRA8888 with 1 plane
  return null;
}
