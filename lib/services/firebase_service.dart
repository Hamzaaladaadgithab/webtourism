import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/trip.dart';

/// Firebase service class for interacting with Firestore and Firebase Auth.
class FirebaseService {
  /// Private constructor to prevent instantiation.
  FirebaseService._();

  /// Singleton instance of the FirebaseService class.
  static final FirebaseService instance = FirebaseService._();

  /// Factory constructor to return the singleton instance.
  factory FirebaseService() => instance;

  /// Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// Uploads initial categories to Firestore if they don't exist.
  Future<void> uploadCategories() async {
    try {
      final batch = _firestore.batch();
      final categoriesRef = _firestore.collection('categories');

      // Yeni kategori yapısı
      final categories = [
        {
          'id': 'c1',
          'name': 'Doğa & Ekoturizm',
          'description': 'Dağ, yayla, yürüyüş, doğal parklar, kamp',
          'icon': '🏞️',
          'isActive': true,
          'subCategories': ['mountain', 'nature', 'camping', 'lake', 'trekking'],
        },
        {
          'id': 'c2',
          'name': 'Kültür & Tarih',
          'description': 'Müzeler, tarihi yapılar, şehir turları',
          'icon': '🏛️',
          'isActive': true,
          'subCategories': ['museum', 'historical', 'ancient', 'culture'],
        },
        {
          'id': 'c3',
          'name': 'Deniz & Tatil',
          'description': 'Plajlar, yaz tatili, resortlar, yüzme',
          'icon': '🏖️',
          'isActive': true,
          'subCategories': ['beach'],
        },
        {
          'id': 'c4',
          'name': 'Macera & Spor',
          'description': 'Rafting, paraşüt, safari, bisiklet',
          'icon': '🧗',
          'isActive': true,
          'subCategories': ['adventure', 'trekking', 'safari'],
        },
        {
          'id': 'c5',
          'name': 'Yeme & İçme',
          'description': 'Gurme turları, yöresel yemek deneyimi',
          'icon': '🍽️',
          'isActive': true,
          'subCategories': [],
        },
        {
          'id': 'c6',
          'name': 'Festival & Etkinlik',
          'description': 'Konserler, yerel festivaller, gösteriler',
          'icon': '🎭',
          'isActive': true,
          'subCategories': [],
        },
        {
          'id': 'c7',
          'name': 'Alışveriş Turları',
          'description': 'Outlet merkezleri, pazarlar, hediyelik eşyalar',
          'icon': '🛍️',
          'isActive': true,
          'subCategories': [],
        },
        {
          'id': 'c8',
          'name': 'İnanç Turizmi',
          'description': 'Dini yapılar, hac turları, camiler',
          'icon': '🕌',
          'isActive': true,
          'subCategories': [],
        },
        {
          'id': 'c9',
          'name': 'Sağlık & Termal Turizm',
          'description': 'Spa, kaplıca, sağlık merkezleri',
          'icon': '🏥',
          'isActive': true,
          'subCategories': [],
        },
        {
          'id': 'c10',
          'name': 'Eğitim & Dil Turları',
          'description': 'Dil okulları, kültür değişim programları',
          'icon': '🏫',
          'isActive': true,
          'subCategories': [],
        },
      ];

      // Önce tüm kategorileri silelim
      final existingCategories = await categoriesRef.get();
      for (var doc in existingCategories.docs) {
        batch.delete(doc.reference);
      }

      // Yeni kategorileri ekleyelim
      for (var category in categories) {
        final docRef = categoriesRef.doc(category['id'] as String);
        batch.set(docRef, category);
      }

      // Batch işlemini uygula
      await batch.commit();
      print('Initial categories uploaded successfully!');
    } catch (e) {
      print('Error uploading categories: $e');
      throw e;
    }
  }

  /// Adds a new trip to Firestore.
  Future<void> addTrip(Trip trip) async {
    try {
      await _firestore.collection('trips').doc(trip.id).set({
        'id': trip.id,
        'categories': trip.categories,
        'title': trip.title,

        'imageUrl': trip.imageUrl,
        'description': trip.description,
        'location': trip.location,
        'price': trip.price,
        'startDate': trip.startDate.toIso8601String(),
        'endDate': trip.endDate.toIso8601String(),
        'status': trip.status,
      });
      print('Trip added successfully!');
    } catch (e) {
      print('Error adding trip: $e');
      throw e;
    }
  }

  /// Gets a stream of categories from Firestore.
  Stream<List<Category>> getCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          icon: data['icon'] ?? '',
          isActive: data['isActive'] ?? false,
          subCategories: List<String>.from(data['subCategories'] ?? []),
        );
      }).toList();
    });
  }

  /// Gets a stream of trips from Firestore.
  Stream<List<Trip>> getTripsStream() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Trip(
          id: data['id'],
          categories: List<String>.from(data['categories']),
          title: data['title'],
          imageUrl: data['imageUrl'],
          description: data['description'] ?? '',
          location: data['location'] ?? 'Location not specified',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          startDate: data['startDate'] != null ? DateTime.parse(data['startDate'] as String) : DateTime.now(),
          endDate: data['endDate'] != null ? DateTime.parse(data['endDate'] as String) : DateTime.now().add(const Duration(days: 1)),
          status: data['status'] ?? 'active',
        );
      }).toList();
    });
  }

  /// Updates a trip in Firestore.
  Future<void> updateTrip(Trip trip) async {
    try {
      await _firestore.collection('trips').doc(trip.id).update({
        'title': trip.title,

        'imageUrl': trip.imageUrl,
        'description': trip.description,
        'location': trip.location,
        'price': trip.price,
        'startDate': trip.startDate.toIso8601String(),
        'endDate': trip.endDate.toIso8601String(),
        'status': trip.status,
      });
      print('Trip updated successfully!');
    } catch (e) {
      print('Error updating trip: $e');
      throw e;
    }
  }

  /// Deletes a trip from Firestore.
  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
      print('Trip deleted successfully!');
    } catch (e) {
      print('Error deleting trip: $e');
      throw e;
    }
  }
}