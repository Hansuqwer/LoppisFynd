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

  Future<void> downloadFromUrl({required Uri url}) async {
    final target = await modelFile();
    final tmp = File('${target.path}.partial');

    if (await tmp.exists()) {
      await tmp.delete();
    }

    final client = http.Client();
    try {
      final resp = await client.send(http.Request('GET', url));
      if (resp.statusCode != 200) {
        throw HttpException('HTTP ${resp.statusCode} downloading model');
      }

      final sink = tmp.openWrite();
      try {
        await resp.stream.pipe(sink);
      } finally {
        await sink.close();
      }

      if (await target.exists()) {
        await target.delete();
      }
      await tmp.rename(target.path);
    } finally {
      client.close();
    }
  }

  Future<void> deleteInstalled() async {
    final target = await modelFile();
    if (await target.exists()) {
      await target.delete();
    }
  }
}
