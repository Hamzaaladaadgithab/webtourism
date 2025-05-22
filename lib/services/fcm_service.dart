abstract class FCMService {
  /// Initialize the FCM service
  Future<void> initialize();

  /// Get the FCM token for this device
  Future<String?> getToken();

  /// Show a notification with the given title and body
  void showNotification(String title, String body);

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Send a notification to a topic
  Future<void> sendNotificationToTopic(String topic, String title, String body);

  /// Factory constructor to return the appropriate implementation
  factory FCMService() {
    if (identical(0, 0.0)) {
      throw UnsupportedError(
        'Cannot create a FCMService instance directly. Use FCMService.instance instead.',
      );
    }
    throw UnsupportedError(
      'Cannot create a FCMService instance directly. Use FCMService.instance instead.',
    );
  }
}
