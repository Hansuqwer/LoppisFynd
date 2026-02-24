import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelSpec {
  const ModelSpec({required this.id, required this.fileName});

  final String id;
  final String fileName;
}

class ModelInstallState {
  const ModelInstallState({required this.installed, this.file, this.bytes});

  final bool installed;
  final File? file;
  final int? bytes;
}

class ModelManager {
  ModelManager({
    required this.spec,
    Future<Directory> Function()? baseDirProvider,
  }) : _baseDirProvider = baseDirProvider;

  final ModelSpec spec;

  final Future<Directory> Function()? _baseDirProvider;

  Future<Directory> _modelsDir() async {
    final dir = _baseDirProvider == null
        ? await getApplicationSupportDirectory()
        : await _baseDirProvider();
    final models = Directory(p.join(dir.path, 'models'));
    await models.create(recursive: true);
    return models;
  }

  Future<File> modelFile() async {
    final dir = await _modelsDir();
    return File(p.join(dir.path, spec.fileName));
  }

  Future<ModelInstallState> state() async {
    final file = await modelFile();
    final exists = await file.exists();
    if (!exists) return const ModelInstallState(installed: false);

    final bytes = await file.length();
    return ModelInstallState(installed: true, file: file, bytes: bytes);
  }

  Future<void> installFromFile({required File source}) async {
    final target = await modelFile();
    final tmp = File('${target.path}.partial');

    if (await tmp.exists()) {
      await tmp.delete();
    }

    await source.copy(tmp.path);
    if (await target.exists()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }

  Future<void> downloadFromUrl({
    required Uri url,
    void Function(int received, int? total)? onProgress,
    bool Function()? isCancelled,
    bool Function()? isPaused,
  }) async {
    final target = await modelFile();
    final tmp = File('${target.path}.partial');

    final client = http.Client();
    try {
      if (isCancelled?.call() == true) {
        throw const _ModelDownloadCancelledException();
      }

      if (isPaused?.call() == true) {
        throw const _ModelDownloadPausedException();
      }

      var existingBytes = 0;
      if (await tmp.exists()) {
        existingBytes = await tmp.length();
      }

      http.StreamedResponse resp;
      FileMode sinkMode;
      var received = 0;
      int? total;

      if (existingBytes > 0) {
        final resumeReq = http.Request('GET', url);
        resumeReq.headers['Range'] = 'bytes=$existingBytes-';
        resp = await client.send(resumeReq);

        if (resp.statusCode == 206) {
          sinkMode = FileMode.append;
          received = existingBytes;

          final parsedTotal = _parseTotalFromContentRange(
            _getHeader(resp.headers, 'content-range'),
          );
          final respLen = resp.contentLength;
          total =
              parsedTotal ??
              ((respLen != null && respLen >= 0)
                  ? (existingBytes + respLen)
                  : null);
        } else if (resp.statusCode == 200) {
          // Server ignored Range; restart safely from scratch.
          if (await tmp.exists()) {
            await tmp.delete();
          }
          existingBytes = 0;
          sinkMode = FileMode.write;
          received = 0;

          final respLen = resp.contentLength;
          total = (respLen != null && respLen >= 0) ? respLen : null;
        } else if (resp.statusCode == 416) {
          // Partial is out of sync with remote; restart safely.
          if (await tmp.exists()) {
            await tmp.delete();
          }
          existingBytes = 0;

          if (isCancelled?.call() == true) {
            throw const _ModelDownloadCancelledException();
          }

          resp = await client.send(http.Request('GET', url));
          if (resp.statusCode != 200) {
            throw HttpException('HTTP ${resp.statusCode} downloading model');
          }

          sinkMode = FileMode.write;
          received = 0;
          final respLen = resp.contentLength;
          total = (respLen != null && respLen >= 0) ? respLen : null;
        } else {
          throw HttpException(
            'HTTP ${resp.statusCode} downloading model (resume attempt)',
          );
        }
      } else {
        resp = await client.send(http.Request('GET', url));
        if (resp.statusCode != 200) {
          throw HttpException('HTTP ${resp.statusCode} downloading model');
        }

        sinkMode = FileMode.write;
        received = 0;
        final respLen = resp.contentLength;
        total = (respLen != null && respLen >= 0) ? respLen : null;
      }

      onProgress?.call(received, total);

      final sink = tmp.openWrite(mode: sinkMode);
      try {
        await sink.addStream(
          resp.stream.map((chunk) {
            if (isCancelled?.call() == true) {
              throw const _ModelDownloadCancelledException();
            }

            if (isPaused?.call() == true) {
              throw const _ModelDownloadPausedException();
            }
            received += chunk.length;
            onProgress?.call(received, total);
            return chunk;
          }),
        );
      } finally {
        await sink.close();
      }

      if (isCancelled?.call() == true) {
        throw const _ModelDownloadCancelledException();
      }

      final shouldPause =
          isPaused?.call() == true && (total == null || received < total);
      if (shouldPause) {
        throw const _ModelDownloadPausedException();
      }

      if (await target.exists()) {
        await target.delete();
      }
      await tmp.rename(target.path);
    } catch (e) {
      final paused = isPaused?.call() == true;
      if (e is _ModelDownloadPausedException || paused) {
        rethrow;
      }

      try {
        if (await tmp.exists()) {
          await tmp.delete();
        }
      } catch (_) {
        // Best-effort cleanup; keep original error.
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  static String? _getHeader(Map<String, String> headers, String name) {
    final target = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == target) return entry.value;
    }
    return null;
  }

  static int? _parseTotalFromContentRange(String? value) {
    if (value == null) return null;
    final match = RegExp(r'\/(\d+|\*)\s*$').firstMatch(value.trim());
    if (match == null) return null;
    final raw = match.group(1);
    if (raw == null || raw == '*') return null;
    return int.tryParse(raw);
  }

  Future<void> deleteInstalled() async {
    final target = await modelFile();
    if (await target.exists()) {
      await target.delete();
    }
  }
}

class _ModelDownloadCancelledException implements Exception {
  const _ModelDownloadCancelledException();

  @override
  String toString() => 'Model download cancelled';
}

class _ModelDownloadPausedException implements Exception {
  const _ModelDownloadPausedException();

  @override
  String toString() => 'Model download paused';
}
