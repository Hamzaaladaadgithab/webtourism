import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus {
  pending,    // Onay bekliyor
  confirmed,  // Onaylandı
  cancelled,  // İptal edildi
  completed   // Tamamlandı
}

extension ReservationStatusExtension on ReservationStatus {
  String get value {
    switch (this) {
      case ReservationStatus.pending:
        return 'ReservationStatus.pending';
      case ReservationStatus.confirmed:
        return 'ReservationStatus.confirmed';
      case ReservationStatus.cancelled:
        return 'ReservationStatus.cancelled';
      case ReservationStatus.completed:
        return 'ReservationStatus.completed';
    }
  }

  static ReservationStatus fromString(String status) {
    switch (status) {
      case 'ReservationStatus.pending':
        return ReservationStatus.pending;
      case 'ReservationStatus.confirmed':
        return ReservationStatus.confirmed;
      case 'ReservationStatus.cancelled':
        return ReservationStatus.cancelled;
      case 'ReservationStatus.completed':
        return ReservationStatus.completed;
      default:
        return ReservationStatus.pending;
    }
  }
}

class Reservation {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String userPhone;
  final String tripId;
  final String tripTitle;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfPeople;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final String? cancelReason;

  Reservation({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    required this.tripId,
    required this.tripTitle,
    required this.startDate,
    required this.endDate,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.cancelReason,
  });

  factory Reservation.fromFirestore(String id, Map<String, dynamic> data) {
    return Reservation(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      tripId: data['tripId'] ?? '',
      tripTitle: data['tripTitle'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      numberOfPeople: data['numberOfPeople'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: ReservationStatusExtension.fromString(data['status'] ?? 'ReservationStatus.pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      cancelReason: data['cancelReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      if (cancelReason != null) 'cancelReason': cancelReason,
    };
  }

  Reservation copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? userPhone,
    String? tripId,
    String? tripTitle,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfPeople,
    double? totalPrice,
    ReservationStatus? status,
    DateTime? createdAt,
    String? cancelReason,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
