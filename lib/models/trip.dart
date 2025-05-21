import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> tripCategories = [
  'Kültür Turları',
  'Doğa Turları',
  'Yurt Dışı Turları',
  'Gemi Turları',
  'Termal Turları',
  'Kayak Turları',
  'Günlük Turlar',
  'Yurt İçi Turları',
  'Balayı Turları',
  'Safari Turları',
  'Mavi Turlar',
];

enum TripStatus { AVAILABLE, FULL, CANCELLED }

extension TripStatusExtension on TripStatus {
  String get value => 'TripStatus.$name';

  static TripStatus fromString(String status) {
    if (status.startsWith('TripStatus.')) {
      status = status.split('.').last;
    }
    return TripStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TripStatus.AVAILABLE,
    );
  }
}

enum NotificationStatus {
  NONE,
  SENT_3_DAYS,
  SENT_1_DAY,
  SENT_LOW_PARTICIPANTS,
  SENT_COMPLETED;

  String get value => toString().split('.').last;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NotificationStatus.NONE,
    );
  }
}

class Trip {
  static DateTime get defaultDate => DateTime(2024);

  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> categories;
  final TripStatus status;
  final DateTime? createdAt;
  final int duration;
  final int capacity;
  final String? season;
  final String? cancelReason;
  final List<String>? searchFields;
  final int participantCount;
  final NotificationStatus notificationStatus;
  final DateTime? lastNotificationDate;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.status,
    this.createdAt,
    this.duration = 1,
    this.capacity = 10,
    this.season,
    this.cancelReason,
    this.searchFields,
    this.participantCount = 0,
    this.notificationStatus = NotificationStatus.NONE,
    this.lastNotificationDate,
  });

  static DateTime? _parseTimestamp(dynamic value, {bool addOneDay = false}) {
    if (value == null) return null;
    if (value is Timestamp) {
      final date = value.toDate();
      return addOneDay ? date.add(const Duration(days: 1)) : date;
    }
    if (value is DateTime) return addOneDay ? value.add(const Duration(days: 1)) : value;
    final date = DateTime.tryParse(value.toString());
    return addOneDay && date != null ? date.add(const Duration(days: 1)) : date;
  }

  factory Trip.fromFirestore(String id, Map<String, dynamic> json) {
    json['id'] = id;
    return Trip.fromJson(json);
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      startDate: _parseTimestamp(json['startDate'])!,
      endDate: _parseTimestamp(json['endDate'])!,
      categories: List<String>.from(json['categories'] ?? []),
      status: TripStatusExtension.fromString(json['status'] ?? 'AVAILABLE'),
      notificationStatus: NotificationStatus.fromString(json['notificationStatus'] ?? ''),
      lastNotificationDate: _parseTimestamp(json['lastNotificationDate']),
      participantCount: json['participantCount'] as int? ?? 0,
      createdAt: _parseTimestamp(json['createdAt'])!,
      duration: json['duration'] as int? ?? 1,
      capacity: json['capacity'] as int? ?? 10,
      season: json['season'] as String?,
      cancelReason: json['cancelReason'] as String?,
      searchFields: json['searchFields'] != null ? List<String>.from(json['searchFields']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'endDate': endDate,
      'categories': categories,
      'status': status.value,
      'notificationStatus': notificationStatus.value,
      'lastNotificationDate': lastNotificationDate,
      'participantCount': participantCount,
      'createdAt': createdAt ?? DateTime.now(),
      'duration': duration,
      'capacity': capacity,
      'season': season,
      'cancelReason': cancelReason,
      'searchFields': searchFields ?? _generateSearchFields(),
    };
  }

  List<String> _generateSearchFields() {
    final fields = <String>[];
    
    // Türkçe karakterleri normalize et
    String normalizeText(String text) {
      return text.toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c');
    }
    
    final titleNormalized = normalizeText(title);
    final locationNormalized = normalizeText(location);
    final descriptionNormalized = normalizeText(description);
    
    // Başlık, lokasyon ve açıklama alanlarını ekle
    fields.addAll([titleNormalized, locationNormalized]);
    
    // Kelimeleri ayır ve ekle
    fields.addAll(titleNormalized.split(' ').where((word) => word.isNotEmpty));
    fields.addAll(locationNormalized.split(' ').where((word) => word.isNotEmpty));
    fields.addAll(descriptionNormalized.split(' ').where((word) => word.length > 2));
    
    // Kategorileri ekle
    categories.forEach((category) {
      fields.add(normalizeText(category));
    });
    
    // Tekrar eden kelimeleri kaldır ve boş stringleri filtrele
    return fields.where((field) => field.isNotEmpty).toSet().toList();
  }

  Trip copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    double? price,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    TripStatus? status,
    DateTime? createdAt,
    int? duration,
    int? capacity,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      capacity: capacity ?? this.capacity,
      participantCount: 0,
      notificationStatus: NotificationStatus.NONE,
      lastNotificationDate: null,
    );
  }
}