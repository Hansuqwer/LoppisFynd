import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/sync/cloud_photo_paths.dart';

void main() {
  test('CloudPhotoPaths builds stable object paths', () {
    expect(
      CloudPhotoPaths.imagePath(userId: 'user-1', scanItemId: 'scan-1'),
      'user-1/scan_items/scan-1/image.jpg',
    );
    expect(
      CloudPhotoPaths.thumbPath(userId: 'user-1', scanItemId: 'scan-1'),
      'user-1/scan_items/scan-1/thumb.jpg',
    );
  });
}
