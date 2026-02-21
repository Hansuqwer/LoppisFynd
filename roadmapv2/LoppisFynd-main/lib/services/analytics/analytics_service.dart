import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsEvent {
  const AnalyticsEvent({required this.name, required this.at, this.data});

  final String name;
  final DateTime at;
  final Map<String, Object?>? data;
}

abstract class AnalyticsService {
  void event(String name, {Map<String, Object?>? data});

  Future<T> measure<T>(
    String name,
    FutureOr<T> Function() fn, {
    Map<String, Object?>? data,
  });
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  void event(String name, {Map<String, Object?>? data}) {}

  @override
  Future<T> measure<T>(
    String name,
    FutureOr<T> Function() fn, {
    Map<String, Object?>? data,
  }) async {
    return fn();
  }
}

class SentryAnalyticsService implements AnalyticsService {
  const SentryAnalyticsService();

  @override
  void event(String name, {Map<String, Object?>? data}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: name,
        category: 'analytics',
        level: SentryLevel.info,
        timestamp: DateTime.now(),
        data: data,
      ),
    );
  }

  @override
  Future<T> measure<T>(
    String name,
    FutureOr<T> Function() fn, {
    Map<String, Object?>? data,
  }) async {
    final sw = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      sw.stop();
      event(name, data: {...?data, 'duration_ms': sw.elapsedMilliseconds});
    }
  }
}
