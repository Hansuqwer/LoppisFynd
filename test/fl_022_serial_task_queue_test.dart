import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/utils/serial_task_queue.dart';

void main() {
  test('SerialTaskQueue runs tasks sequentially', () async {
    final queue = SerialTaskQueue();
    final events = <String>[];

    final gate1 = Completer<void>();
    final gate2 = Completer<void>();

    final f1 = queue.add(() async {
      events.add('start1');
      await gate1.future;
      events.add('end1');
    });

    final f2 = queue.add(() async {
      events.add('start2');
      await gate2.future;
      events.add('end2');
    });

    final f3 = queue.add(() async {
      events.add('start3');
      events.add('end3');
    });

    await Future<void>.delayed(Duration.zero);
    expect(events, ['start1']);

    gate2.complete();
    await Future<void>.delayed(Duration.zero);
    expect(events, ['start1']);

    gate1.complete();

    await f1;
    await Future<void>.delayed(Duration.zero);
    expect(events.contains('start2'), isTrue);

    await Future.wait([f2, f3]);
    expect(events, ['start1', 'end1', 'start2', 'end2', 'start3', 'end3']);
  });

  test('SerialTaskQueue continues after task errors', () async {
    final queue = SerialTaskQueue();
    final events = <String>[];

    final f1 = queue.add(() async {
      events.add('t1');
      throw StateError('boom');
    });

    final f2 = queue.add(() async {
      events.add('t2');
    });

    await expectLater(f1, throwsStateError);
    await f2;
    expect(events, ['t1', 't2']);
  });
}
