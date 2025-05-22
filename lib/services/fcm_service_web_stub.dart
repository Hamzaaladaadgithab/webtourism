import 'fcm_service_interface.dart';

class FCMServiceWeb implements FCMService {
  @override
  Future<void> initialize() async {
    // Stub implementation for non-web platforms
  }

  @override
  Future<String?> getToken() async {
    return null;
  }

  @override
  void showNotification(String title, String body) {
    // Stub implementation for non-web platforms
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    // Stub implementation for non-web platforms
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // Stub implementation for non-web platforms
  }

  @override
  Future<void> sendNotificationToTopic(String topic, String title, String body) async {
    // Stub implementation for non-web platforms
  }
}
