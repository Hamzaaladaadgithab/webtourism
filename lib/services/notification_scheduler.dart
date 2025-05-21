import 'dart:async';
import 'package:tourism/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  final NotificationService _notificationService = NotificationService();
  static const String LAST_CHECK_KEY = 'last_notification_check';

  factory NotificationScheduler() {
    return _instance;
  }

  NotificationScheduler._internal();

  // Bildirimleri kontrol et ve son kontrol zamanını güncelle
  Future<void> checkNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastCheck = prefs.getString(LAST_CHECK_KEY);
    
    // Son kontrolden bu yana en az 1 saat geçtiyse veya hiç kontrol yapılmamışsa
    if (lastCheck == null || 
        now.difference(DateTime.parse(lastCheck)).inHours >= 1) {
      await _notificationService.checkUpcomingTours();
      await prefs.setString(LAST_CHECK_KEY, now.toIso8601String());
    }
  }

  // Son kontrol zamanını sıfırla
  Future<void> resetLastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LAST_CHECK_KEY);
  }
}
