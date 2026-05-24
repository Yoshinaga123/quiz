import 'package:quiz_mobile/layers/data/dto/push_feed_dto.dart';
import 'package:quiz_mobile/layers/data/service/local_notification_service.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushFeedPoller {
  const PushFeedPoller({
    required QuizApiClient apiClient,
    required LocalNotificationService notificationService,
    required SharedPreferences preferences,
  })  : _apiClient = apiClient,
        _notificationService = notificationService,
        _preferences = preferences;

  static const String _lastDeliveryIdKey = 'quzzes:lastMockPushDeliveryId';

  final QuizApiClient _apiClient;
  final LocalNotificationService _notificationService;
  final SharedPreferences _preferences;

  Future<PushFeedDto?> checkLatest() async {
    final feed = await _apiClient.fetchPushFeed();
    if (feed == null) return null;

    final lastDeliveryId = _preferences.getInt(_lastDeliveryIdKey);
    if (lastDeliveryId == feed.deliveryId) {
      return feed;
    }

    await _notificationService.showPushFeed(feed);
    await _preferences.setInt(_lastDeliveryIdKey, feed.deliveryId);
    return feed;
  }
}
