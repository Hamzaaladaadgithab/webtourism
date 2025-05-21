import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // FCM izinleri al
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications için initialize
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // FCM token al
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Ön planda bildirim gösterme
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Arka planda bildirim tıklama
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Bildirim tıklandı: ${message.data}');
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'tourism_channel',
      'Tourism Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Yeni Bildirim',
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Bu kısım için Firebase Cloud Functions kullanılacak
    // Şimdilik boş bırakıyoruz
  }
}
