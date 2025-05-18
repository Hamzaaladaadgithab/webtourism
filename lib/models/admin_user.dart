import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' veya 'superadmin'
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
  });

  factory AdminUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AdminUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] is Timestamp 
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.parse(data['createdAt']))
        : DateTime.now(),
      lastLogin: data['lastLogin'] != null 
        ? (data['lastLogin'] is Timestamp 
            ? (data['lastLogin'] as Timestamp).toDate()
            : DateTime.parse(data['lastLogin']))
        : DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'permissions': permissions,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isActive': isActive,
    };
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'superadmin';
  }
}
