import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quiz_mobile/layers/data/dto/push_feed_dto.dart';

typedef NotificationTapHandler = void Function(int quizId);

class LocalNotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize({
    required NotificationTapHandler onTap,
  }) async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        final quizId = int.tryParse(payload);
        if (quizId == null) return;
        onTap(quizId);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showPushFeed(PushFeedDto feed) {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mock_push',
        'Mock Push',
        channelDescription: 'Development mock push notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    return _plugin.show(
      feed.deliveryId,
      feed.title,
      feed.body,
      details,
      payload: feed.quizId.toString(),
    );
  }
}
