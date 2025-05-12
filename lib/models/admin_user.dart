class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' veya 'superadmin'
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    required this.lastLogin,
  });

  factory AdminUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AdminUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
      createdAt: data['createdAt'] != null 
        ? DateTime.parse(data['createdAt']) 
        : DateTime.now(),
      lastLogin: data['lastLogin'] != null 
        ? DateTime.parse(data['lastLogin']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'superadmin';
  }
}
