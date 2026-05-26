import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotifications {
  AppNotifications(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<AppNotifications> initialize({
    bool requestPermissions = false,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();

    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: initAndroid,
      iOS: initDarwin,
    );

    await plugin.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      'sync',
      'Sync',
      description: 'Background sync status',
      importance: Importance.defaultImportance,
    );
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    if (requestPermissions) {
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    return AppNotifications(plugin);
  }

  Future<void> showSyncDone({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'sync',
        'Sync',
        channelDescription: 'Background sync status',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 1001,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
