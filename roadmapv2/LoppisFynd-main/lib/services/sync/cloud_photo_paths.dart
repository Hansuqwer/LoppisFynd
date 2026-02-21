class CloudPhotoPaths {
  static const bucketId = 'scan-photos';

  static String imagePath({
    required String userId,
    required String scanItemId,
  }) {
    return '$userId/scan_items/$scanItemId/image.jpg';
  }

  static String thumbPath({
    required String userId,
    required String scanItemId,
  }) {
    return '$userId/scan_items/$scanItemId/thumb.jpg';
  }
}
