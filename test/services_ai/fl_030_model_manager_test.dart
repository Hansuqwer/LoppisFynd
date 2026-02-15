import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/ai/model_manager.dart';

void main() {
  test('ModelManager installs and reports state', () async {
    final temp = await Directory.systemTemp.createTemp('fynd_model_test_');
    addTearDown(() async => temp.delete(recursive: true));

    final source = File('${temp.path}/model.bin');
    await source.writeAsBytes(List<int>.filled(1024, 7), flush: true);

    final manager = ModelManager(
      spec: const ModelSpec(id: 'test', fileName: 'test.bin'),
      baseDirProvider: () async => temp,
    );

    await manager.deleteInstalled();
    final before = await manager.state();
    expect(before.installed, isFalse);

    await manager.installFromFile(source: source);
    final after = await manager.state();
    expect(after.installed, isTrue);
    expect(after.bytes, 1024);
    expect(after.file, isNotNull);
    expect(await after.file!.exists(), isTrue);
  });
}
