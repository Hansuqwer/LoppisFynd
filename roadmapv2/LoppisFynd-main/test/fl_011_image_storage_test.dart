import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:fynd_loppis/core/storage/scan_image_storage.dart';

void main() {
  test('ScanImageStorage imports image and generates thumbnail', () async {
    final root = await Directory.systemTemp.createTemp('fynd_loppis_test_');
    addTearDown(() async => root.delete(recursive: true));

    final sourceImage = img.Image(width: 800, height: 600);
    img.fill(sourceImage, color: img.ColorRgb8(240, 238, 233));
    final sourceBytes = img.encodeJpg(sourceImage, quality: 90);

    final sourceFile = File('${root.path}/source.jpg');
    await sourceFile.writeAsBytes(sourceBytes, flush: true);

    final storage = ScanImageStorage(rootDir: root);
    final stored = await storage.importImage(
      scanId: 'scan-1',
      sourceImage: sourceFile,
    );

    expect(File(stored.imagePath).existsSync(), isTrue);
    expect(File(stored.thumbPath).existsSync(), isTrue);

    final thumbBytes = await File(stored.thumbPath).readAsBytes();
    final decodedThumb = img.decodeImage(thumbBytes);
    expect(decodedThumb, isNotNull);

    final maxEdge = decodedThumb!.width > decodedThumb.height
        ? decodedThumb.width
        : decodedThumb.height;
    expect(maxEdge, lessThanOrEqualTo(320));
  });
}
