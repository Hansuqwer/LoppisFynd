import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

InputImage? inputImageFromCameraImage({
  required CameraImage image,
  required int sensorOrientation,
}) {
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  if (rotation == null) return null;

  final bytes = _concatenatePlanes(image.planes);
  final metadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    format: format,
    bytesPerRow: image.planes.first.bytesPerRow,
  );

  return InputImage.fromBytes(bytes: bytes, metadata: metadata);
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final writeBuffer = WriteBuffer();
  for (final p in planes) {
    writeBuffer.putUint8List(p.bytes);
  }
  return writeBuffer.done().buffer.asUint8List();
}
