import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tourism/services/fcm_service.dart';
import 'package:tourism/services/fcm_service_web.dart';

class FCMProvider extends ChangeNotifier {
  final FCMService _fcmService = FCMService();
  final FCMServiceWeb _fcmServiceWeb = FCMServiceWeb();

  Future<void> initialize() async {
    if (kIsWeb) {
      await _fcmServiceWeb.initialize();
    } else {
      await _fcmService.initialize();
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      await _fcmServiceWeb.subscribeToTopic(topic);
    } else {
      await _fcmService.subscribeToTopic(topic);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      await _fcmServiceWeb.unsubscribeFromTopic(topic);
    } else {
      await _fcmService.unsubscribeFromTopic(topic);
    }
  }

  Future<void> sendNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _fcmService.sendNotificationToTopic(
      topic: topic,
      title: title,
      body: body,
      data: data,
    );
  }
}
