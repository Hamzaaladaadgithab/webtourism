import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

class FCMServiceWeb {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!kIsWeb) return;
    
    try {
      // Web'de bildirim izinlerini kontrol et
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        try {
          // Web için FCM token al
          String? token = await _firebaseMessaging.getToken(
            // VAPID anahtarını Firebase Console'dan alabilirsiniz
            // Cloud Messaging > Web Push certificates > Generate key pair
            vapidKey: 'BIIlG3PYQMXah0tovROeN6bj6edUaBUp1ywZGoxCxQGFfRdIp7f-NgMT4Cd1cuHaDs4P3SHTaKD8tzSOmZgISlc'
          );
          print('Web FCM Token: $token');
        } catch (tokenError) {
          print('FCM token alma hatası: $tokenError');
          return;
        }

        // Web'de mesaj dinleme
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Web Message received: ${message.notification?.title}');
          // Web bildirimi göster
          if (message.notification != null) {
            _showWebNotification(message.notification!);
          }
        });
      }
    } catch (e) {
      print('Web FCM initialization error: $e');
    }
  }

  void _showWebNotification(RemoteNotification notification) {
    if (kIsWeb) {
      try {
        js.context.callMethod('Notification', [
          notification.title ?? 'Bildirim',
          js.JsObject.jsify({
            'body': notification.body,
            'icon': '/images/notification_icon.png'
          })
        ]);
      } catch (e) {
        print('Web notification error: $e');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      try {
        await _firebaseMessaging.subscribeToTopic(topic);
      } catch (e) {
        print('Web subscribe error: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      try {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
      } catch (e) {
        print('Web unsubscribe error: $e');
      }
    }
  }


}
