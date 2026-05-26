# Dio Large File Download Best Practices Research

**Date**: 2026-02-16  
**Context**: Flutter app needs robust 1.5GB on-device model download with progress UI

## Required Dependencies

```yaml
dependencies:
  dio: ^5.7.0
  path_provider: ^2.1.5
  crypto: ^3.0.3
  
dev_dependencies:
  dio_smart_retry: ^7.0.1
  storage_space: ^1.2.0
```

---

## 1. STREAMING & PROGRESS TRACKING

```dart
await dio.download(
  url,
  savePath,
  onReceiveProgress: (received, total) {
    if (total != -1) {
      final progress = received / total;
      // Update UI
    }
  },
  options: Options(
    headers: {HttpHeaders.acceptEncodingHeader: '*'},
  ),
);
```

**Key**: Set `accept-encoding: '*'` to disable gzip for accurate progress.

**Ref**: https://pub.dev/documentation/dio/latest/dio/Dio/download.html

---

## 2. RESUME VIA RANGE REQUESTS

```dart
final file = File(savePath);
int startByte = await file.exists() ? await file.length() : 0;

await dio.download(
  url,
  savePath,
  options: Options(
    headers: startByte > 0 ? {'Range': 'bytes=$startByte-'} : null,
  ),
  deleteOnError: false,  // CRITICAL
);
```

**Ref**: MDN Range Requests - https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Range_requests

---

## 3. CANCELLATION

```dart
final cancelToken = CancelToken();
dio.download(url, savePath, cancelToken: cancelToken);
cancelToken.cancel('User cancelled');
```

---

## 4. RETRY / BACKOFF

Use `dio_smart_retry`:

```dart
dio.interceptors.add(RetryInterceptor(
  dio: dio,
  retries: 3,
  retryDelays: const [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ],
));
```

**Ref**: https://pub.dev/packages/dio_smart_retry

---

## 5. CHECKSUM VALIDATION

```dart
import 'package:crypto/crypto.dart';

Future<String?> calculateChecksum(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  final hash = await md5.bind(file.openRead()).first;
  return hex.encode(hash.bytes);
}
```

**Ref**: https://pub.dev/packages/crypto

---

## 6. DISK SPACE CHECKS

```dart
import 'package:storage_space/storage_space.dart';

Future<bool> hasSpace(int requiredBytes) async {
  final space = await getStorageSpace();
  return space.free! >= requiredBytes * 1.15; // 15% buffer
}
```

**Ref**: https://pub.dev/packages/storage_space

---

## 7. SAFE TARGET PATHS

```dart
final dir = await getApplicationSupportDirectory();
final path = join(dir.path, 'models', filename);
```

| Directory | Use Case |
|-----------|----------|
| `getApplicationSupportDirectory()` | App-private files (AI models) |
| `getApplicationDocumentsDirectory()` | User-generated content |
| `getTemporaryDirectory()` | Cache (may be cleared) |

**Ref**: https://pub.dev/packages/path_provider

---

## References

1. Dio: https://pub.dev/packages/dio
2. path_provider: https://pub.dev/packages/path_provider
3. dio_smart_retry: https://pub.dev/packages/dio_smart_retry
4. storage_space: https://pub.dev/packages/storage_space
5. crypto: https://pub.dev/packages/crypto
6. MDN Range Requests: https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Range_requests
