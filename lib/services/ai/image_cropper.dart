import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageCropperException implements Exception {
  const ImageCropperException(this.message);

  final String message;

  @override
  String toString() => 'ImageCropperException: $message';
}

class ImageCropper {
  const ImageCropper({
    this.maxDimension = 768,
    this.maxUploadBytes = 420 * 1024,
    this.jpegQuality = 85,
  });

  final int maxDimension;
  final int maxUploadBytes;
  final int jpegQuality;

  Future<Uint8List> centerSquareJpegFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageCropperException('Unable to decode image');
    }

    final w = decoded.width;
    final h = decoded.height;
    if (w <= 0 || h <= 0) {
      throw const ImageCropperException('Invalid image dimensions');
    }

    final size = math.min(w, h);
    final cropX = ((w - size) / 2).round();
    final cropY = ((h - size) / 2).round();
    img.Image cropped = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: size,
      height: size,
    );

    var targetDim = maxDimension;
    if (size > targetDim) {
      cropped = img.copyResize(
        cropped,
        width: targetDim,
        height: targetDim,
        interpolation: img.Interpolation.cubic,
      );
    }

    var quality = jpegQuality.clamp(40, 95);
    Uint8List encoded = Uint8List.fromList(
      img.encodeJpg(cropped, quality: quality),
    );

    // Enforce upload budget; re-encode at smaller dimensions/quality.
    var attempts = 0;
    while (encoded.lengthInBytes > maxUploadBytes && attempts < 4) {
      attempts += 1;
      targetDim = math.max(256, (targetDim * 0.85).floor());
      quality = math.max(55, quality - 7);

      final resized = img.copyResize(
        cropped,
        width: targetDim,
        height: targetDim,
        interpolation: img.Interpolation.linear,
      );
      encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    if (encoded.lengthInBytes > maxUploadBytes) {
      throw ImageCropperException(
        'Image crop too large (${encoded.lengthInBytes} bytes). Try a closer photo.',
      );
    }

    return encoded;
  }
}
