import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism/providers/fcm_provider.dart';
import 'package:tourism/models/trip.dart';



/// Bildirim tipleri
enum NotificationType {
  TOUR_START_3_DAYS,    // Tur başlangıcına 3 gün kaldı
  TOUR_START_1_DAY,     // Tur başlangıcına 1 gün kaldı
  TOUR_END_1_DAY,       // Tur bitişine 1 gün kaldı
  LOW_PARTICIPANTS,     // Düşük katılımcı sayısı
  RESERVATION_NEW,      // Yeni rezervasyon
  RESERVATION_CONFIRM,  // Rezervasyon onaylandı
  RESERVATION_CANCEL,   // Rezervasyon iptal edildi
  CAPACITY_FULL,        // Kapasite doldu
  SYSTEM,               // Sistem bildirimi
  INFO                  // Genel bilgi
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FCMProvider _fcmProvider = FCMProvider();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static void showNotification({required String title, required String body}) {
    final instance = NotificationService();
    instance.createNotification(title, body, 'info');
  }

  // Yaklaşan gezileri kontrol et ve bildirim gönder
  Future<void> checkUpcomingTours() async {
    try {
      final now = DateTime.now();
      print('Checking tours at: $now');
      
      // Tüm aktif turları al
      final toursSnapshot = await _firestore
          .collection('trips')
          .where('status', isEqualTo: TripStatus.AVAILABLE.value)
          .get();

      for (var doc in toursSnapshot.docs) {
        final tour = doc.data();
        final startDate = (tour['startDate'] as Timestamp).toDate();
        final endDate = (tour['endDate'] as Timestamp).toDate();
        final daysUntilStart = startDate.difference(now).inDays;
        final hoursUntilStart = startDate.difference(now).inHours;
        final daysUntilEnd = endDate.difference(now).inDays;
        final hoursUntilEnd = endDate.difference(now).inHours;
        final int capacity = (tour['capacity'] as num?)?.toInt() ?? 0;
        final int participantCount = (tour['participantCount'] as num?)?.toInt() ?? 0;

        // Tur başlamadan 3 gün veya 72 saat kala bildirim
        if ((daysUntilStart == 3 || hoursUntilStart <= 72) && tour['notificationStatus'] != 'SENT_3_DAYS') {
          await _sendTourNotification(
            doc.id,
            tour,
            'Yaklaşan Tur: ${tour['title']}',
            '${tour['title']} turuna 3 gün kaldı! Hazırlıklarınızı tamamladınız mı?',
            NotificationType.TOUR_START_3_DAYS,
            'SENT_3_DAYS'
          );
        }

        // Tur başlamadan 1 gün veya 24 saat kala bildirim
        else if ((daysUntilStart == 1 || hoursUntilStart <= 24) && tour['notificationStatus'] != 'SENT_1_DAY') {
          await _sendTourNotification(
            doc.id,
            tour,
            'Tur Yarın Başlıyor: ${tour['title']}',
            '${tour['title']} turu yarın başlıyor! Tüm hazırlıklarınızı kontrol edin.',
            NotificationType.TOUR_START_1_DAY,
            'SENT_1_DAY'
          );
        }

        // Tur bitmeden 1 gün veya 24 saat kala bildirim
        else if ((daysUntilEnd == 1 || hoursUntilEnd <= 24) && tour['notificationStatus'] != 'SENT_END') {
          await _sendTourNotification(
            doc.id,
            tour,
            'Tur Bitiyor: ${tour['title']}',
            '${tour['title']} turu yarın sona eriyor. Son hazırlıklarınızı kontrol edin.',
            NotificationType.TOUR_END_1_DAY,
            'SENT_END'
          );
        }

        // Düşük katılım bildirimi (kapasitenin %30'undan az)
        else if (capacity > 0 && 
                 participantCount < (capacity * 0.3) && 
                 daysUntilStart <= 7 && 
                 tour['notificationStatus'] != 'SENT_LOW_PARTICIPANTS') {
          await _sendTourNotification(
            doc.id,
            tour,
            'Düşük Katılım Uyarısı: ${tour['title']}',
            '${tour['title']} turunda katılım düşük (%${(participantCount / capacity * 100).toStringAsFixed(0)}). '
            'Tur başlangıcına $daysUntilStart gün kaldı.',
            NotificationType.LOW_PARTICIPANTS,
            'SENT_LOW_PARTICIPANTS'
          );
        }

        // Kapasite dolduğunda bildirim
        else if (participantCount >= capacity && tour['notificationStatus'] != 'SENT_CAPACITY_FULL') {
          await _sendTourNotification(
            doc.id,
            tour,
            'Kapasite Doldu: ${tour['title']}',
            '${tour['title']} turunun kontenjanı dolmuştur.',
            NotificationType.CAPACITY_FULL,
            'SENT_CAPACITY_FULL'
          );
        }
      }
    } catch (e) {
      print('Error checking upcoming tours: $e');
    }
  }

  Future<void> _sendTourNotification(
    String tourId,
    Map<String, dynamic> tour,
    String title,
    String message,
    NotificationType type,
    String status
  ) async {
    await createNotification(
      title,
      message,
      type.toString(),
      tourId: tourId,
      tourStartDate: (tour['startDate'] as Timestamp).toDate(),
    );

    await _firestore.collection('trips').doc(tourId).update({
      'lastNotificationDate': Timestamp.now(),
      'notificationStatus': status
    });
  }


  // Bildirimleri getir
  Stream<List<Map<String, dynamic>>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                  'createdAt': (doc.data()['createdAt'] as Timestamp).toDate(),
                })
            .toList());
  }

  // Okunmamış bildirimleri getir
  Stream<int> getUnreadNotificationsCount() {
    return _firestore
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Bildirimi oluştur
  Future<void> createNotification(String title, String message, String type, {String? tourId, DateTime? tourStartDate}) async {
    print('Creating notification: $title - $message - $type');
    try {
      // FCM bildirimi gönder
      await _fcmProvider.sendNotification(
        topic: 'admin_notifications',
        title: title,
        body: message,
      );

      print('FCM notification sent successfully');

      // Firestore'a kaydet
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'tourId': tourId,
        'tourStartDate': tourStartDate != null ? Timestamp.fromDate(tourStartDate) : null,
        'priority': _getNotificationPriority(type),
      });

      print('Notification saved to Firestore successfully');
    } catch (e) {
      print('Error in createNotification: $e');
      rethrow;
    }
  }

  int _getNotificationPriority(String type) {
    switch (type) {
      case 'NotificationType.TOUR_START_1_DAY':
      case 'NotificationType.LOW_PARTICIPANTS':
        return 3;
      case 'NotificationType.TOUR_START_3_DAYS':
      case 'NotificationType.CAPACITY_FULL':
      case 'NotificationType.RESERVATION_NEW':
      case 'NotificationType.RESERVATION_CONFIRM':
      case 'NotificationType.RESERVATION_CANCEL':
        return 2;
      default:
        return 1;
    }
  }
}
