import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../utils/serial_task_queue.dart';

class StoredScanImage {
  const StoredScanImage({required this.imagePath, required this.thumbPath});

  final String imagePath;
  final String thumbPath;
}

class DeferredStoredScanImage {
  const DeferredStoredScanImage({
    required this.imagePath,
    required this.thumbPath,
    required this.thumbReady,
  });

  final String imagePath;
  final String thumbPath;
  final Future<String> thumbReady;
}

class ScanImageStorage {
  ScanImageStorage({
    required Directory rootDir,
    this.thumbMaxEdgePx = 320,
    this.thumbJpegQuality = 75,
    this.maxDecodePixels = 40 * 1000 * 1000,
  }) : _rootDir = rootDir;

  final Directory _rootDir;
  final SerialTaskQueue _queue = SerialTaskQueue();
  final int thumbMaxEdgePx;
  final int thumbJpegQuality;

  /// A guardrail against huge images; used after decode.
  final int maxDecodePixels;

  Directory get _scansDir => Directory(p.join(_rootDir.path, 'scans'));

  Future<DeferredStoredScanImage> importImageDeferred({
    required String scanId,
    required File sourceImage,
  }) async {
    await _scansDir.create(recursive: true);

    final safeId = _sanitizeForFileName(scanId);
    final imageFile = File(p.join(_scansDir.path, 'scan_$safeId.jpg'));
    final thumbFile = File(p.join(_scansDir.path, 'scan_${safeId}_thumb.jpg'));

    await sourceImage.copy(imageFile.path);

    final thumbReady = _queue.add(() async {
      await _generateJpegThumbnail(
        sourcePath: imageFile.path,
        destPath: thumbFile.path,
        maxEdgePx: thumbMaxEdgePx,
        jpegQuality: thumbJpegQuality,
        maxDecodePixels: maxDecodePixels,
      );
      return thumbFile.path;
    });

    return DeferredStoredScanImage(
      imagePath: imageFile.path,
      // Use the full image until thumb is ready.
      thumbPath: imageFile.path,
      thumbReady: thumbReady,
    );
  }

  Future<StoredScanImage> importImage({
    required String scanId,
    required File sourceImage,
  }) async {
    await _scansDir.create(recursive: true);

    final safeId = _sanitizeForFileName(scanId);
    final imageFile = File(p.join(_scansDir.path, 'scan_$safeId.jpg'));
    final thumbFile = File(p.join(_scansDir.path, 'scan_${safeId}_thumb.jpg'));

    await sourceImage.copy(imageFile.path);

    await _generateJpegThumbnail(
      sourcePath: imageFile.path,
      destPath: thumbFile.path,
      maxEdgePx: thumbMaxEdgePx,
      jpegQuality: thumbJpegQuality,
      maxDecodePixels: maxDecodePixels,
    );

    return StoredScanImage(
      imagePath: imageFile.path,
      thumbPath: thumbFile.path,
    );
  }
}

String _sanitizeForFileName(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final isAllowed = RegExp(r'[a-zA-Z0-9_-]').hasMatch(char);
    buffer.write(isAllowed ? char : '_');
  }
  final out = buffer.toString();
  return out.isEmpty ? 'scan' : out;
}

class _ThumbJob {
  const _ThumbJob({
    required this.sourcePath,
    required this.destPath,
    required this.maxEdgePx,
    required this.jpegQuality,
    required this.maxDecodePixels,
  });

  final String sourcePath;
  final String destPath;
  final int maxEdgePx;
  final int jpegQuality;
  final int maxDecodePixels;

  Map<String, Object> toMap() => {
    'sourcePath': sourcePath,
    'destPath': destPath,
    'maxEdgePx': maxEdgePx,
    'jpegQuality': jpegQuality,
    'maxDecodePixels': maxDecodePixels,
  };
}

Future<void> _generateJpegThumbnail({
  required String sourcePath,
  required String destPath,
  required int maxEdgePx,
  required int jpegQuality,
  required int maxDecodePixels,
}) async {
  final job = _ThumbJob(
    sourcePath: sourcePath,
    destPath: destPath,
    maxEdgePx: maxEdgePx,
    jpegQuality: jpegQuality,
    maxDecodePixels: maxDecodePixels,
  );

  await compute(_thumbnailWorker, job.toMap());
}

Future<void> _thumbnailWorker(Map<String, Object> args) async {
  final sourcePath = args['sourcePath']! as String;
  final destPath = args['destPath']! as String;
  final maxEdgePx = args['maxEdgePx']! as int;
  final jpegQuality = args['jpegQuality']! as int;
  final maxDecodePixels = args['maxDecodePixels']! as int;

  final bytes = await File(sourcePath).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Failed to decode image for thumbnail');
  }

  final pixelCount = decoded.width * decoded.height;
  if (pixelCount > maxDecodePixels) {
    throw StateError('Image too large to thumbnail safely ($pixelCount px)');
  }

  final resized = img.copyResize(
    decoded,
    width: decoded.width >= decoded.height ? maxEdgePx : null,
    height: decoded.height > decoded.width ? maxEdgePx : null,
    interpolation: img.Interpolation.cubic,
  );

  final encoded = img.encodeJpg(resized, quality: jpegQuality);
  await File(destPath).writeAsBytes(encoded, flush: true);
}
