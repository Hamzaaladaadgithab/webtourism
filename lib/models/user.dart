import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String phone;
  final DateTime createdAt;
  final List<String> favorites;
  final String? profileImage;
  final bool notificationsEnabled;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.createdAt,
    this.favorites = const [],
    this.profileImage,
    this.notificationsEnabled = true,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      favorites: List<String>.from(data['favorites'] ?? []),
      profileImage: data['profileImage'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'createdAt': createdAt,
      'favorites': favorites,
      'profileImage': profileImage,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  AppUser copyWith({
    String? email,
    String? name,
    String? role,
    String? phone,
    String? profileImage,
    bool? notificationsEnabled,
    List<String>? favorites,
  }) {
    return AppUser(
      id: this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: this.createdAt,
      favorites: favorites ?? this.favorites,
    );
  }
}
