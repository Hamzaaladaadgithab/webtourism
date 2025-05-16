class Category {
  final String id;
  final String title;
  final String imageUrl;
  
  Category({
    required this.id, 
    required this.title,
    required this.imageUrl
  });

  factory Category.fromFirestore(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? ''
    );
  }
}