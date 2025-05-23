import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String phone;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String> favorites;
  final String? profileImage;
  final bool notificationsEnabled;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.createdAt,
    this.lastLogin,
    this.favorites = const [],
    this.profileImage,
    this.notificationsEnabled = true,
    this.isActive = true,
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
      lastLogin: data['lastLogin'] != null 
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      favorites: List<String>.from(data['favorites'] ?? []),
      profileImage: data['profileImage'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'favorites': favorites,
      'profileImage': profileImage,
      'notificationsEnabled': notificationsEnabled,
      'isActive': isActive,
    };
  }

  AppUser copyWith({
    String? email,
    String? name,
    String? role,
    String? phone,
    String? profileImage,
    bool? notificationsEnabled,
    bool? isActive,
    DateTime? lastLogin,
    List<String>? favorites,
  }) {
    return AppUser(
      id: this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      favorites: favorites ?? this.favorites,
      profileImage: profileImage ?? this.profileImage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
}
