abstract class FCMService {
  Future<void> initialize();
  Future<String?> getToken();
  void showNotification(String title, String body);
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> sendNotificationToTopic(String topic, String title, String body);
}
