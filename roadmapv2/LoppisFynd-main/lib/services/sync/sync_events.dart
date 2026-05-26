sealed class SyncEvent {
  const SyncEvent();
}

class SyncRunStarted extends SyncEvent {
  const SyncRunStarted();
}

class SyncRunFinished extends SyncEvent {
  const SyncRunFinished();
}

class ScanItemSynced extends SyncEvent {
  const ScanItemSynced({required this.scanItemId});
  final String scanItemId;
}

class ScanItemSyncDeferred extends SyncEvent {
  const ScanItemSyncDeferred({required this.scanItemId});
  final String scanItemId;
}

class ScanItemSyncFailed extends SyncEvent {
  const ScanItemSyncFailed({required this.scanItemId, required this.error});
  final String scanItemId;
  final String error;
}
