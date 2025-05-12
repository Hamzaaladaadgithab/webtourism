import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';
import '../models/trip.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Favori gezileri getir
  Stream<List<Trip>> getFavoriteTrips() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
          final tripIds = snapshot.docs.map((doc) => doc.id).toList();
          if (tripIds.isEmpty) return [];

          final tripsSnapshot = await _firestore
              .collection('trips')
              .where(FieldPath.documentId, whereIn: tripIds)
              .get();

          return tripsSnapshot.docs
              .map((doc) => Trip.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  // Gezi favori durumunu kontrol et
  Future<bool> isTripFavorite(String tripId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final docSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(tripId)
        .get();

    return docSnapshot.exists;
  }

  // Favori durumunu değiştir
  Future<void> toggleFavorite(String tripId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(tripId);

    final docSnapshot = await favoriteRef.get();

    if (docSnapshot.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _parseProgram(dynamic value) {
    if (value == null) return '';
    
    try {
      if (value is String) return value;
      if (value is List) {
        // Listeyi birleştirip string yap
        return value.join('\n');
      }
    } catch (e) {
      print('Program dönüşümünde hata: $e');
    }
    
    return ''; // Varsayılan değer
  }

  int _parseDuration(dynamic value) {
    if (value == null) return 1;
    
    try {
      if (value is int) return value;
      if (value is String) {
        // "5 gün" gibi bir string'den sayıyı çıkar
        return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      }
      if (value is List) {
        // Liste içindeki ilk elemanı kullan
        if (value.isNotEmpty) {
          var firstValue = value[0];
          if (firstValue is int) return firstValue;
          if (firstValue is String) {
            return int.tryParse(firstValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          }
        }
      }
    } catch (e) {
      print('Süre dönüşümünde hata: $e');
    }
    
    return 1; // Varsayılan değer
  }

  DateTime _parseTimestamp(dynamic value, {bool addOneDay = false}) {
    if (value == null) {
      return addOneDay 
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.now();
    }

    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.parse(value);
      }
    } catch (e) {
      print('Tarih dönüşüm hatası: $e');
    }

    return addOneDay 
        ? DateTime.now().add(const Duration(days: 1))
        : DateTime.now();
  }

  // Kategorileri gerçek zamanlı dinle
  Stream<List<Category>> getCategoriesStream() {
    try {
      return _firestore.collection('categories').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          print('Category data: $data');
          return Category(
            id: doc.id, // Belge ID'sini kullan
            title: data['title'] ?? 'Isimsiz Kategori',
            imageUrl: data['imageUrl'] ?? '',
          );
        }).toList();
      });
    } catch (e) {
      print('Kategoriler dinlenirken hata: $e');
      return Stream.value([]);
    }
  }

  // Turları gerçek zamanlı dinle
  Stream<List<Trip>> getTripsStream() {
    try {
      return _firestore.collection('trips').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          print('Trip data: $data');
          
          // Kategorileri kontrol et ve null kontrolü yap
          List<String> categories = [];
          try {
            categories = (data['categories'] as List?)?.map((e) => e.toString()).toList() ?? [];
          } catch (e) {
            print('Kategori dönüşümünde hata: $e');
          }
          print('Trip categories: $categories');
          
          // TripType'ı kontrol et
          final tripTypeStr = data['type'] ?? 'CULTURAL';
          final tripType = TripType.values.firstWhere(
            (e) => e.toString().split('.').last == tripTypeStr,
            orElse: () => TripType.CULTURAL,
          );
          
          // Season'ı kontrol et
          final seasonStr = data['season'] ?? 'SUMMER';
          final season = Season.values.firstWhere(
            (e) => e.toString().split('.').last == seasonStr,
            orElse: () => Season.SUMMER,
          );
          
          // Duration'ı kontrol et
          final durationStr = data['duration'] is List ? data['duration'][0] : data['duration'];
          final duration = int.tryParse(durationStr.toString().replaceAll(' gün', '')) ?? 1;
          
          // Fiyatı kontrol et
          final price = (data['price'] as num?)?.toDouble() ?? 0.0;
          
          return Trip(
            id: doc.id,
            title: data['title'] ?? 'Isimsiz Tur',
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            price: price,
            duration: duration,
            location: data['location'] ?? 'Konum belirtilmedi',
            startDate: _parseTimestamp(data['startDate']),
            endDate: _parseTimestamp(data['endDate'], addOneDay: true),
            season: season.toString().split('.').last,
            type: tripType.toString().split('.').last,
            isFamilyFriendly: data['isFamilyFriendly'] ?? false,
            categories: (data['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
            activities: (data['activities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
            program: _parseProgram(data['program']),
            capacity: data['capacity'] ?? 10,
            status: TripStatus.values.firstWhere(
              (e) => e.toString().split('.').last == data['status'],
              orElse: () => TripStatus.AVAILABLE,
            ),
          );
        }).toList();
      });
    } catch (e) {
      print('Turlar dinlenirken hata: $e');
      return Stream.value([]);
    }
  }

  // Kategorileri çek
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          id: doc.id, // Belge ID'sini kullan
          title: data['title'] ?? 'Isimsiz Kategori',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Kategoriler çekilirken hata: $e');
      return [];
    }
  }

  // Turları çek
  Future<List<Trip>> getTrips() async {
    try {
      final snapshot = await _firestore.collection('trips').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // TripType'ı kontrol et
        final tripTypeStr = data['type'] ?? 'CULTURAL';
        final tripType = TripType.values.firstWhere(
          (e) => e.toString().split('.').last == tripTypeStr,
          orElse: () => TripType.CULTURAL,
        );
        
        // Season'ı kontrol et
        final seasonStr = data['season'] ?? 'SUMMER';
        final season = Season.values.firstWhere(
          (e) => e.toString().split('.').last == seasonStr,
          orElse: () => Season.SUMMER,
        );
        
        // Duration'ı kontrol et
        final durationStr = data['duration'] is List ? data['duration'][0] : data['duration'];
        final duration = int.tryParse(durationStr.toString().replaceAll(' gün', '')) ?? 1;
        
        // Fiyatı kontrol et
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        
        return Trip(
          id: doc.id,
          title: data['title'] ?? 'Isimsiz Tur',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: price,
          duration: duration,
          location: data['location'] ?? 'Konum belirtilmedi',
          startDate: _parseTimestamp(data['startDate']),
          endDate: _parseTimestamp(data['endDate'], addOneDay: true),
          season: season.toString().split('.').last,
          type: tripType.toString().split('.').last,
          isFamilyFriendly: data['isFamilyFriendly'] ?? false,
          categories: (data['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          activities: (data['activities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          program: _parseProgram(data['program']),
          capacity: data['capacity'] ?? 10,
          status: TripStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
            orElse: () => TripStatus.AVAILABLE,
          ),
        );
      }).toList();
    } catch (e) {
      print('Turlar çekilirken hata: $e');
      return [];
    }
  }

  // Tur programını güncelle
  Future<void> updateTripProgram(String tripId, String newProgram) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'program': newProgram,
      });
      print('Program başarıyla güncellendi!');
    } catch (e) {
      print('Program güncellenirken hata: $e');
      rethrow;
    }
  }

  // Tur aktivitelerini güncelle
  Future<void> updateTripActivities(String tripId, List<String> newActivities) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'activities': newActivities,
      });
      print('Aktiviteler başarıyla güncellendi!');
    } catch (e) {
      print('Aktiviteler güncellenirken hata: $e');
      rethrow;
    }
  }

  // Kategoriye göre gezileri getir
  Stream<List<Trip>> getTripsByCategory(String categoryId) {
    return _firestore
        .collection('trips')
        .where('categories', arrayContainsAny: [categoryId])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Trip(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          duration: _parseDuration(data['duration']),
          location: data['location'] ?? '',
          startDate: _parseTimestamp(data['startDate']),
          endDate: _parseTimestamp(data['endDate'], addOneDay: true),
          season: data['season'] ?? 'SUMMER',
          type: data['type'] ?? 'CULTURAL',
          isFamilyFriendly: data['isFamilyFriendly'] ?? false,
          categories: List<String>.from(data['categories'] ?? []),
          activities: List<String>.from(data['activities'] ?? []),
          program: _parseProgram(data['program']),
          capacity: data['capacity'] ?? 0,
          status: TripStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
            orElse: () => TripStatus.AVAILABLE,
          ),
        );
      }).toList();
    });
  }

  // Tüm gezileri getir
  Stream<List<Trip>> getAllTrips() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Trip(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          duration: _parseDuration(data['duration']),
          location: data['location'] ?? '',
          startDate: _parseTimestamp(data['startDate']),
          endDate: _parseTimestamp(data['endDate'], addOneDay: true),
          season: data['season'] ?? 'SUMMER',
          type: data['type'] ?? 'CULTURAL',
          isFamilyFriendly: data['isFamilyFriendly'] ?? false,
          categories: List<String>.from(data['categories'] ?? []),
          activities: List<String>.from(data['activities'] ?? []),
          program: _parseProgram(data['program']),
          capacity: data['capacity'] ?? 0,
          status: TripStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
            orElse: () => TripStatus.AVAILABLE,
          ),
        );
      }).toList();
    });
  }

  // Gezi detaylarını getir
  Future<Trip?> getTripById(String tripId) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Trip(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        duration: data['duration'] ?? 1,
        location: data['location'] ?? '',
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        season: data['season'] ?? 'SUMMER',
        type: data['type'] ?? 'CULTURAL',
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
    } catch (e) {
      print('Error getting trip: $e');
      return null;
    }
  }

  // Yeni gezi ekle
  Future<void> addTrip(Trip trip) async {
    try {
      await _firestore.collection('trips').add(trip.toFirestore());
    } catch (e) {
      print('Error adding trip: $e');
      rethrow;
    }
  }

  // Gezi güncelle
  Future<void> updateTrip(String tripId, Trip trip) async {
    try {
      await _firestore.collection('trips').doc(tripId).update(trip.toFirestore());
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }

  // Gezi sil
  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }
} 