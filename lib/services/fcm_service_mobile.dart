import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'fcm_service.dart';

class FCMServiceMobile implements FCMService {
  FCMServiceMobile._();
  static final FCMServiceMobile _instance = FCMServiceMobile._();
  static FCMServiceMobile get instance => _instance;

  late final FirebaseMessaging _messaging;

  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('Mobile notification permission status: ${settings.authorizationStatus}');

      String? token = await getToken();
      print('Mobile FCM Token: $token');

      _setupMessageHandlers();
    } catch (e) {
      print('Error initializing Mobile FCM: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Mobile foreground message received:');
    _printMessageDetails(message);
    showNotification(
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
    );
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      print('Mobile app opened from terminated state with message:');
      _printMessageDetails(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Mobile notification clicked:');
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
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting mobile FCM token: $e');
      return null;
    }
  }

  @override
  void showNotification(String title, String body) {
    try {
      print('Showing mobile notification:');
      print('Title: $title');
      print('Body: $body');
    } catch (e) {
      print('Mobile notification error: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Mobile: Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic on mobile: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Mobile: Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic on mobile: $e');
    }
  }

  @override
  Future<void> sendNotificationToTopic(String topic, String title, String body) async {
    throw UnimplementedError('Sending notifications should be handled by the server');
  }
}
