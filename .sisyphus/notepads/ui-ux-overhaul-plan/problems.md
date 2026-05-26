## Problems

- Long-running background download progress notifications are OS-constrained (Android foreground service types; iOS limits). Treat as best-effort.

- Task 5 (ModelManager progress/cancel) is currently blocked by repeated subagent timeouts (no code changes landed after 3 attempts). Next attempt should be scoped to ONLY `lib/services/ai/model_manager.dart` + one test file, with minimal progress callback first, then cancellation.
