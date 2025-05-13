import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String phone;
  final DateTime createdAt;
  final List<String> favorites;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.createdAt,
    this.favorites = const [],
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
    };
  }

  AppUser copyWith({
    String? email,
    String? name,
    String? role,
    String? phone,
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
