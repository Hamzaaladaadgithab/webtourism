import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'fcm_service.dart';

class FCMServiceWeb implements FCMService {
  FCMServiceWeb._();
  static final FCMServiceWeb _instance = FCMServiceWeb._();
  static FCMServiceWeb get instance => _instance;

  late final FirebaseMessaging _messaging;

  @override
  Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('Web notification permission status: ${settings.authorizationStatus}');

      String? token = await getToken();
      print('Web FCM Token: $token');

      _setupMessageHandlers();
    } catch (e) {
      print('Error initializing Web FCM: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Web foreground message received:');
    _printMessageDetails(message);
    showNotification(
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Web notification clicked:');
    _printMessageDetails(message);
  }

  void _printMessageDetails(RemoteMessage message) {
    if (message.notification != null) {
      print('Notification:');
      print('  Title: ${message.notification?.title}');
      print('  Body: ${message.notification?.body}');
    }
    
    if (message.data.isNotEmpty) {
      print('Data:');
      message.data.forEach((key, value) {
        print('  $key: $value');
      });
    }
  }

  @override
  Future<String?> getToken() async {
    if (!kIsWeb) return null;
    try {
      return await _messaging.getToken(
        vapidKey: 'YOUR-VAPID-KEY', // Replace with your VAPID key from Firebase Console
      );
    } catch (e) {
      print('Error getting web FCM token: $e');
      return null;
    }
  }

  @override
  void showNotification(String title, String body) {
    if (!kIsWeb) return;
    try {
      // Use the Web Notifications API
      print('Showing web notification:');
      print('Title: $title');
      print('Body: $body');
    } catch (e) {
      print('Web notification error: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    if (!kIsWeb) return;
    try {
      await _messaging.subscribeToTopic(topic);
      print('Web: Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic on web: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!kIsWeb) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Web: Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic on web: $e');
    }
  }

  @override
  Future<void> sendNotificationToTopic(String topic, String title, String body) async {
    throw UnimplementedError('Sending notifications should be handled by the server');
  }
}
