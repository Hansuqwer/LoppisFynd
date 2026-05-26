import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';

class CloudDeleteOutcome {
  const CloudDeleteOutcome({
    required this.deletedScanItems,
    required this.deletedHauls,
    required this.deletedStorageObjects,
    this.errors = const [],
  });

  final int deletedScanItems;
  final int deletedHauls;
  final int deletedStorageObjects;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
}

class CloudDataDeletionService {
  CloudDataDeletionService({required AppConfig config}) : _config = config;

  final AppConfig _config;

  Future<CloudDeleteOutcome> deleteAllCloudData() async {
    if (!_config.hasSupabase) {
      throw const _CloudDeleteNotConfigured();
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw const _CloudDeleteNotSignedIn();
    }

    final scanResp = await client
        .from('scan_items')
        .select('id')
        .eq('user_id', user.id);
    final scanRows = scanResp as List;
    final scanIds = <String>[];
    final errors = <String>[];
    for (final rowAny in scanRows) {
      if (rowAny is Map) {
        final id = rowAny['id'];
        if (id is String && id.isNotEmpty) scanIds.add(id);
      }
    }

    var deletedObjects = 0;
    if (scanIds.isNotEmpty) {
      final storage = client.storage.from('scan-photos');
      final paths = <String>[];
      for (final id in scanIds) {
        paths.add('${user.id}/scan_items/$id/image.jpg');
        paths.add('${user.id}/scan_items/$id/thumb.jpg');
      }

      const batchSize = 50;
      for (var i = 0; i < paths.length; i += batchSize) {
        final batch = paths.sublist(i, (i + batchSize).clamp(0, paths.length));
        try {
          await storage.remove(batch);
          deletedObjects += batch.length;
        } catch (e) {
          // Best-effort: RLS/storage policies might reject removes.
          errors.add('Storage cleanup failed: $e');
        }
      }
    }

    int deletedScanItems = 0;
    int deletedHauls = 0;
    try {
      final resp = await client
          .from('scan_items')
          .delete()
          .eq('user_id', user.id);
      deletedScanItems = (resp is List) ? resp.length : 0;
    } catch (e) {
      deletedScanItems = 0;
      errors.add('Failed to delete scan items: $e');
    }
    try {
      final resp = await client.from('hauls').delete().eq('user_id', user.id);
      deletedHauls = (resp is List) ? resp.length : 0;
    } catch (e) {
      deletedHauls = 0;
      errors.add('Failed to delete hauls: $e');
    }

    return CloudDeleteOutcome(
      deletedScanItems: deletedScanItems,
      deletedHauls: deletedHauls,
      deletedStorageObjects: deletedObjects,
      errors: errors,
    );
  }
}

class _CloudDeleteNotConfigured implements Exception {
  const _CloudDeleteNotConfigured();
  @override
  String toString() => 'Cloud delete not configured';
}

class _CloudDeleteNotSignedIn implements Exception {
  const _CloudDeleteNotSignedIn();
  @override
  String toString() => 'Not signed in';
}
