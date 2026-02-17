# Fix: Comment cleanup in Dashboard

Removed speculative comments/reasoning from `_ModelPreflightCard` in `dashboard_screen.dart` to keep the code clean.
Verified that `setState` in `finally` block is sufficient to trigger `FutureBuilder` re-evaluation of `modelManager.state()`.

# Fix: Remove Eco/Turbo placeholders

Removed remaining "Eco/Turbo" placeholder wording from roadmap docs; kept existing `ai_accuracy_mode_*` setting keys and the localized "Eco" option used by the AI mode selector.

# Execution Learnings

- `ModelManager.downloadFromUrl` now supports optional `onProgress(int received, int? total)` and `isCancelled()`; it streams to `.partial` and renames on success, with cleanup on error/cancel.
- Dashboard `_ModelPreflightCard` uses `ModelDownloadCard` and wires progress via `onProgress`; updates are throttled (~120ms / >=1% when total known).
- Settings sync controls are gated behind existing Dev Mode (7 taps on version in the LoppisFynd info card).

## Testing AppDatabase with Fakes
When testing widgets that depend on `AppDatabase`, using `AppDatabase.inMemory()` can cause issues with pending timers if streams (like `watchProblems`) are left open.
A better approach is to create `FakeAppDatabase`, `FakeAppSettingsDao`, etc., extending the real classes and overriding methods to return controlled Futures/Streams.
This avoids the overhead of a real in-memory SQLite database and gives fine-grained control over data.
Example:
```dart
class FakeAppSettingsDao extends AppSettingsDao {
  FakeAppSettingsDao(super.db);
  // ... override getInt/setInt
}
```

## Model download resume-safe partials
- Keep `${target.path}.partial` if the app crashes mid-download (no delete-at-start).
- On next `downloadFromUrl()`, if partial length > 0, try `Range: bytes=<existing>-` and append on `206` (total from `Content-Range` when available).
- If resume is unsupported/out-of-sync (`200` or `416`), delete partial and restart a full download; still rename to target only after the full payload is present.
