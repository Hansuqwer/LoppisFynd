import 'tables/scan_items.dart';

class ScanItemStateMachine {
  static bool canTransition({
    required ScanItemStatus from,
    required ScanItemStatus to,
  }) {
    if (from == to) return true;
    return _allowed[from]!.contains(to);
  }

  static const Map<ScanItemStatus, Set<ScanItemStatus>> _allowed = {
    ScanItemStatus.pendingIdentify: {
      ScanItemStatus.pendingSync,
      ScanItemStatus.failed,
    },
    ScanItemStatus.pendingSync: {ScanItemStatus.syncing, ScanItemStatus.failed},
    ScanItemStatus.syncing: {
      ScanItemStatus.complete,
      ScanItemStatus.failed,
      ScanItemStatus.pendingSync,
    },
    ScanItemStatus.complete: {ScanItemStatus.pendingSync},
    ScanItemStatus.failed: {
      ScanItemStatus.pendingIdentify,
      ScanItemStatus.pendingSync,
    },
  };
}
