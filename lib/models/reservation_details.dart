import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus {
  pending,    // Onay bekliyor
  confirmed,  // Onaylandı
  cancelled,  // İptal edildi
  completed   // Tamamlandı
}

class ReservationDetails {
  final String id;
  final String tripId;
  final String userId;
  final String userEmail;
  final String userName;
  final String userPhone;
  final int numberOfPeople;
  final DateTime reservationDate;
  final double totalPrice;
  final ReservationStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? confirmedBy;
  final DateTime? cancelledAt;
  final String? cancelReason;

  ReservationDetails({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    required this.numberOfPeople,
    required this.reservationDate,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
    this.confirmedAt,
    this.confirmedBy,
    this.cancelledAt,
    this.cancelReason,
  });

  factory ReservationDetails.fromFirestore(Map<String, dynamic> data, String id) {
    return ReservationDetails(
      id: id,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      numberOfPeople: data['numberOfPeople'] ?? 1,
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString() == 'ReservationStatus.${data['status']}',
        orElse: () => ReservationStatus.pending,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      confirmedAt: data['confirmedAt'] != null 
          ? (data['confirmedAt'] as Timestamp).toDate() 
          : null,
      confirmedBy: data['confirmedBy'],
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      cancelReason: data['cancelReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'numberOfPeople': numberOfPeople,
      'reservationDate': Timestamp.fromDate(reservationDate),
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'confirmedBy': confirmedBy,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancelReason': cancelReason,
    };
  }
}
