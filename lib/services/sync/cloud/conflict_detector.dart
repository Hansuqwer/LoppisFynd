bool isLwwConflict({
  required DateTime localUpdatedAt,
  required DateTime cloudUpdatedAt,
  required DateTime lastSyncAt,
}) {
  return localUpdatedAt.isAfter(lastSyncAt) &&
      cloudUpdatedAt.isAfter(localUpdatedAt);
}
