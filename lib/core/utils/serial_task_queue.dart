typedef Task<T> = Future<T> Function();

class SerialTaskQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> add<T>(Task<T> task) {
    final next = _tail.then((_) => task());
    _tail = next.then((_) {}).catchError((_) {});
    return next;
  }
}
