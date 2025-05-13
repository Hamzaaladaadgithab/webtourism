import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation.dart';
import '../models/admin_user.dart';
import '../models/trip.dart';

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
          'status': ReservationStatus.cancelled.toString(),
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
    final docRef = _firestore.collection('reservations').doc(reservationId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('Rezervasyon bulunamadı');
    }

    final data = {
      'status': newStatus.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (newStatus == ReservationStatus.cancelled && reason != null) {
      data['cancelReason'] = reason;
      data['cancelledAt'] = FieldValue.serverTimestamp();
    } else if (newStatus == ReservationStatus.confirmed) {
      data['confirmedAt'] = FieldValue.serverTimestamp();
      data['confirmedBy'] = admin;
    }

    await docRef.update(data);
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
  Stream<List<Reservation>> getAllReservations({
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('reservations');

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }

    if (startDate != null) {
      query = query.where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
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
        .where('status', isEqualTo: ReservationStatus.confirmed.toString().split('.').last)
        .get();

    for (var doc in querySnapshot.docs) {
      final reservation = Reservation.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      
      // Tarih çakışması kontrolü
      if (!(endDate.isBefore(reservation.startDate) || 
            startDate.isAfter(reservation.endDate))) {
        return false;
      }
    }

    return true;
  }
}
