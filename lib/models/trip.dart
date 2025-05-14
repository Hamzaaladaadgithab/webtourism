import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum Season { SPRING, SUMMER, AUTUMN, WINTER }
enum TripType { CULTURAL, ADVENTURE, RELAXATION, EDUCATIONAL }
enum TripStatus { AVAILABLE, FULL, CANCELLED }

class Trip {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final int duration;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String season;
  final String type;
  final bool isFamilyFriendly;
  final List<String> categories;
  final List<String> activities;
  final String program;
  final int capacity;
  final TripStatus status;
  final DateTime? createdAt;
  final int groupSize;
  final String difficulty;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.duration,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.season,
    required this.type,
    required this.isFamilyFriendly,
    required this.createdAt,
    required this.groupSize,
    required this.difficulty,
    required this.categories,
    required this.activities,
    required this.program,
    required this.capacity,
    required this.status,
  });

  factory Trip.fromFirestore(String id, Map<String, dynamic> data) {
    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) return value.join(', ');
      return value.toString();
    }

    List<String> convertToStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) return [value];
      if (value is List) {
        return value.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
      }
      return [];
    }

    int parseGroupSize(dynamic value) {
      if (value == null) return 10;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 10;
      }
      return 10;
    }

    String parseDifficulty(dynamic value) {
      if (value == null) return 'Orta';
      if (value is String) return value;
      if (value is List) return value.isNotEmpty ? value.first.toString() : 'Orta';
      return 'Orta';
    }

    return Trip(
      id: id,
      title: parseString(data['title']),
      description: parseString(data['description']),
      imageUrl: parseString(data['imageUrl']),
      price: (data['price'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? 0,
      location: parseString(data['location']),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      season: parseString(data['season']),
      type: parseString(data['type']),
      isFamilyFriendly: data['isFamilyFriendly'] ?? false,
      categories: convertToStringList(data['categories']),
      activities: convertToStringList(data['activities']),
      program: parseString(data['program']),
      capacity: data['capacity'] ?? 0,
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == 'TripStatus.${parseString(data['status']).toUpperCase()}',
        orElse: () => TripStatus.AVAILABLE,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groupSize: parseGroupSize(data['groupSize']),
      difficulty: parseDifficulty(data['difficulty']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'duration': duration,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'season': season,
      'type': type,
      'isFamilyFriendly': isFamilyFriendly,
      'categories': categories,
      'activities': activities,
      'program': program,
      'capacity': capacity,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
    };
  }

  Trip copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? price,
    int? duration,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? season,
    String? type,
    bool? isFamilyFriendly,
    List<String>? categories,
    List<String>? activities,
    String? program,
    int? capacity,
    TripStatus? status,
    DateTime? createdAt,
    int? groupSize,
    String? difficulty,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      season: season ?? this.season,
      createdAt: createdAt ?? this.createdAt,
      groupSize: groupSize ?? this.groupSize,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      isFamilyFriendly: isFamilyFriendly ?? this.isFamilyFriendly,
      categories: categories ?? this.categories,
      activities: activities ?? this.activities,
      program: program ?? this.program,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
    );
  }

  String get seasonText {
    switch (season) {
      case 'SPRING':
        return 'BAHAR';
      case 'SUMMER':
        return 'YAZ';
      case 'AUTUMN':
        return 'SONBAHAR';
      case 'WINTER':
        return 'KIŞ';
      default:
        return 'BELİRSİZ';
    }
  }

  String get tripTypeText {
    switch (type) {
      case 'CULTURAL':
        return 'Kültürel';
      case 'ADVENTURE':
        return 'Macera';
      case 'RELAXATION':
        return 'Dinlenme';
      case 'EDUCATIONAL':
        return 'Eğitim';
      default:
        return 'Belirsiz';
    }
  }
}