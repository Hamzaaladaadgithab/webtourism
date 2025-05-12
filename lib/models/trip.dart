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
    required this.categories,
    required this.activities,
    required this.program,
    required this.capacity,
    required this.status,
  });

  factory Trip.fromFirestore(String id, Map<String, dynamic> data) {
    return Trip(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['duration'] ?? 0,
      location: data['location'] ?? '',
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 1)),
      season: data['season'] ?? 'summer',
      type: data['type'] ?? 'individual',
      isFamilyFriendly: data['isFamilyFriendly'] ?? false,
      categories: List<String>.from(data['categories'] ?? []),
      activities: List<String>.from(data['activities'] ?? []),
      program: data['program'] ?? '',
      capacity: data['capacity'] ?? 0,
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TripStatus.AVAILABLE,
      ),
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