import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/scan_item_state_machine.dart';
import 'package:fynd_loppis/core/database/tables/scan_items.dart';

void main() {
  test('ScanItemStateMachine allows expected transitions', () {
    expect(
      ScanItemStateMachine.canTransition(
        from: ScanItemStatus.pendingIdentify,
        to: ScanItemStatus.pendingSync,
      ),
      isTrue,
    );
    expect(
      ScanItemStateMachine.canTransition(
        from: ScanItemStatus.pendingSync,
        to: ScanItemStatus.syncing,
      ),
      isTrue,
    );
    expect(
      ScanItemStateMachine.canTransition(
        from: ScanItemStatus.syncing,
        to: ScanItemStatus.complete,
      ),
      isTrue,
    );
    expect(
      ScanItemStateMachine.canTransition(
        from: ScanItemStatus.syncing,
        to: ScanItemStatus.failed,
      ),
      isTrue,
    );
  });

  test('ScanItemStateMachine rejects invalid transitions', () {
    expect(
      ScanItemStateMachine.canTransition(
        from: ScanItemStatus.complete,
        to: ScanItemStatus.pendingIdentify,
      ),
      isFalse,
    );
    expect(
      ScanItemStateMachine.canTransition(
        from: ScanItemStatus.pendingIdentify,
        to: ScanItemStatus.complete,
      ),
      isFalse,
    );
  });
}
