import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rezervasyon oluştur
  Future<void> createReservation({
    required String tripId,
    required String tripTitle,
    required DateTime startDate,
    required DateTime endDate,
    required int numberOfPeople,
    required double totalPrice,
    required String userName,
    required String userPhone,
    required String userId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı girişi yapılmamış');
    }

    final reservation = Reservation(
      id: '', // Firestore otomatik ID oluşturacak
      userId: userId,
      userEmail: user.email!,
      userName: userName,
      userPhone: userPhone,
      tripId: tripId,
      tripTitle: tripTitle,
      startDate: startDate,
      endDate: endDate,
      numberOfPeople: numberOfPeople,
      totalPrice: totalPrice,
      status: ReservationStatus.pending,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('reservations')
        .add(reservation.toFirestore());
  }

  // Rezervasyon güncelle
  Future<void> updateReservation(Reservation reservation) async {
    await _firestore
        .collection('reservations')
        .doc(reservation.id)
        .update(reservation.toFirestore());
  }

  // Rezervasyon iptal et
  Future<void> cancelReservation(String reservationId) async {
    // Önce rezervasyonu iptal olarak işaretle
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({
          'status': ReservationStatus.cancelled.value,
          'cancelledAt': FieldValue.serverTimestamp(),
        });

    // 30 saniye sonra rezervasyonu sil
    await Future.delayed(const Duration(seconds: 30));
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .delete();
  }

  // Rezervasyon durumunu güncelle (admin için)
  Future<void> updateReservationStatus({
    required String reservationId,
    required ReservationStatus newStatus,
    required String admin,
    String? reason,
  }) async {
    try {
      final docRef = _firestore.collection('reservations').doc(reservationId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Rezervasyon bulunamadı');
      }

      final data = {
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastUpdatedBy': admin,
      };

      if (newStatus == ReservationStatus.cancelled) {
        data['cancellationReason'] = reason ?? 'Belirtilmedi';
        data['cancelledAt'] = FieldValue.serverTimestamp();
        data['cancelledBy'] = admin;
      } else if (newStatus == ReservationStatus.confirmed) {
        data['confirmedAt'] = FieldValue.serverTimestamp();
        data['confirmedBy'] = admin;
      } else if (newStatus == ReservationStatus.completed) {
        data['completedAt'] = FieldValue.serverTimestamp();
        data['completedBy'] = admin;
      }

      // Batch işlemi başlat
      final batch = _firestore.batch();

      // Rezervasyon güncelleme
      batch.update(docRef, data);
      
      // Bildirim oluştur
      final notification = {
        'userId': doc.data()?['userId'],
        'type': 'reservation_status_update',
        'status': newStatus.value,
        'tripTitle': doc.data()?['tripTitle'],
        'createdAt': FieldValue.serverTimestamp(),
        'message': _getStatusUpdateMessage(newStatus, doc.data()?['tripTitle']),
        'read': false
      };
      
      final notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, notification);
      
      // İşlemleri commit et
      await batch.commit();
    } catch (e) {
      print('Rezervasyon durumu güncellenirken hata: $e');
      throw Exception('Rezervasyon durumu güncellenirken hata oluştu: $e');
    }
  }

  String _getStatusUpdateMessage(ReservationStatus status, String? tripTitle) {
    switch (status) {
      case ReservationStatus.confirmed:
        return '$tripTitle rezervasyonunuz onaylandı!';
      case ReservationStatus.cancelled:
        return '$tripTitle rezervasyonunuz iptal edildi.';
      case ReservationStatus.completed:
        return '$tripTitle rezervasyonunuz tamamlandı.';
      case ReservationStatus.pending:
        return '$tripTitle rezervasyonunuz beklemeye alındı.';
    }
  }

  // Rezervasyon sil
  Future<void> deleteReservation(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).delete();
  }

  // Tek bir rezervasyonu getir
  Future<Reservation?> getReservation(String reservationId) async {
    final doc = await _firestore.collection('reservations').doc(reservationId).get();
    
    if (!doc.exists) {
      return null;
    }

    return Reservation.fromFirestore(doc.id, doc.data()!);
  }

  // Kullanıcının rezervasyonlarını getir
  Stream<List<Reservation>> getUserReservations() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı girişi yapılmamış');
    }

    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Tur için rezervasyonları getir
  Stream<List<Reservation>> getTripReservations(String tripId) {
    return _firestore
        .collection('reservations')
        .where('tripId', isEqualTo: tripId)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Tüm rezervasyonları getir (admin için)
  Stream<List<Reservation>> getAllReservations() {
    return _firestore
        .collection('reservations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => Reservation.fromFirestore(doc.id, doc.data()))
                .toList();
          } catch (e) {
            print('Rezervasyon dönüşüm hatası: $e');
            return <Reservation>[];
          }
        });
  }

  // Belirli bir tarih aralığında rezervasyon kontrolü
  Future<bool> isDateRangeAvailable(
    String tripId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final querySnapshot = await _firestore
        .collection('reservations')
        .where('tripId', isEqualTo: tripId)
        .where('status', isEqualTo: ReservationStatus.confirmed.value)
        .get();

    for (var doc in querySnapshot.docs) {
      final reservation = Reservation.fromFirestore(doc.id, doc.data());
      
      // Tarih çakışması kontrolü
      if (startDate.isBefore(reservation.endDate) &&
          endDate.isAfter(reservation.startDate)) {
        return false; // Tarih aralığı müsait değil
      }
    }

    return true; // Tarih aralığı müsait
  }
}
