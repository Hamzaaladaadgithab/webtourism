import 'package:flutter/material.dart';
import '../services/fcm_service.dart';
import '../services/fcm_service_factory.dart';

class FCMProvider extends ChangeNotifier {
  final FCMService _fcmService = FCMServiceFactory.create();

  Future<void> initialize() async {
    await _fcmService.initialize();
  }

  Future<String?> getToken() async {
    return await _fcmService.getToken();
  }

  void showNotification(String title, String body) {
    _fcmService.showNotification(title, body);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcmService.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcmService.unsubscribeFromTopic(topic);
  }

  Future<void> sendNotification(String topic, String title, String body) async {
    await _fcmService.sendNotificationToTopic(topic, title, body);
  }
}
