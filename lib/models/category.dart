class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;
  final List<String> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
    required this.subCategories,
  });

  factory Category.fromFirestore(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
      isActive: data['isActive'] ?? false,
      subCategories: List<String>.from(data['subCategories'] ?? []),
    );
  }
}