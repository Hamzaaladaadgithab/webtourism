import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/trip.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DataService();

  // Favori gezileri getir
  Stream<List<Trip>> getFavoriteTrips() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
          final tripIds = snapshot.docs.map((doc) => doc.id).toList();
          if (tripIds.isEmpty) return [];

          final tripsSnapshot = await _db
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

    final docSnapshot = await _db
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

    final favoriteRef = _db
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

  // Convert program data to string format
  String convertProgramToString(List<String> value) {
    try {
      return value.join('\n');
    } catch (e) {
      print('Program dönüşümünde hata: $e');
    }

    return '';
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
    return _db.collection('categories').snapshots().map((snapshot) {
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

  // Turları gerçek zamanlı dinle
  Stream<List<Trip>> getTripsStream() {
    try {
      return _db.collection('trips').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return Trip(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            location: data['location'] ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            startDate: _parseTimestamp(data['startDate']),
            endDate: _parseTimestamp(data['endDate'], addOneDay: true),
            categories: (data['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
            status: TripStatus.values.firstWhere(
              (e) => e.toString().split('.').last == (data['status'] ?? 'AVAILABLE'),
              orElse: () => TripStatus.AVAILABLE,
            ),
            createdAt: _parseTimestamp(data['createdAt']),
            duration: (data['duration'] as num?)?.toInt() ?? 1,
            capacity: (data['capacity'] as num?)?.toInt() ?? 10,
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
      final snapshot = await _db.collection('categories').get();
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
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Turları çek
  Future<List<Trip>> getTrips() async {
    try {
      final QuerySnapshot tripsSnapshot = await _db.collection('trips').get();
      return tripsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Trip(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          location: data['location'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          startDate: _parseTimestamp(data['startDate']),
          endDate: _parseTimestamp(data['endDate'], addOneDay: true),
          categories: (data['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
          status: TripStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (data['status'] ?? 'AVAILABLE'),
            orElse: () => TripStatus.AVAILABLE,
          ),
          createdAt: _parseTimestamp(data['createdAt']),
          duration: (data['duration'] as num?)?.toInt() ?? 1,
          capacity: (data['capacity'] as num?)?.toInt() ?? 10,
        );
      }).toList();
    } catch (e) {
      print('Error getting trips: $e');
      return [];
    }
  }

  Future<Trip?> getTripById(String tripId) async {
    try {
      final DocumentSnapshot tripDoc = await _db.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) return null;

      final data = tripDoc.data() as Map<String, dynamic>;
      return Trip(
        id: tripDoc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        location: data['location'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        startDate: _parseTimestamp(data['startDate']),
        endDate: _parseTimestamp(data['endDate'], addOneDay: true),
        categories: (data['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
        status: TripStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (data['status'] ?? 'AVAILABLE'),
          orElse: () => TripStatus.AVAILABLE,
        ),
        createdAt: _parseTimestamp(data['createdAt']),
        duration: (data['duration'] as num?)?.toInt() ?? 1,
        capacity: (data['capacity'] as num?)?.toInt() ?? 10,
      );
    } catch (e) {
      print('Error getting trip by id: $e');
      return null;
    }
  }

  Future<List<Trip>> getTripsByCategoryId(String categoryId) async {
    try {
      final QuerySnapshot tripsSnapshot = await _db
          .collection('trips')
          .where('categories', arrayContains: categoryId)
          .get();

      return tripsSnapshot.docs
          .map((doc) => Trip.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting trips by category: $e');
      return [];
    }
  }

  Future<List<Trip>> searchTrips(String query) async {
    try {
      final QuerySnapshot tripsSnapshot = await _db
          .collection('trips')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();

      return tripsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Trip(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          location: data['location'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          startDate: _parseTimestamp(data['startDate']),
          endDate: _parseTimestamp(data['endDate'], addOneDay: true),
          categories: (data['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
          status: TripStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (data['status'] ?? 'AVAILABLE'),
            orElse: () => TripStatus.AVAILABLE,
          ),
          createdAt: _parseTimestamp(data['createdAt']),
          duration: (data['duration'] as num?)?.toInt() ?? 1,
          capacity: (data['capacity'] as num?)?.toInt() ?? 10,
        );
      }).toList();
    } catch (e) {
      print('Error searching trips: $e');
      return [];
    }
  }

  Future<List<Trip>> filterTrips({
    String? category,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _db.collection('trips');

      if (category != null) {
        query = query.where('categories', arrayContains: category);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (startDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final QuerySnapshot tripsSnapshot = await query.get();

      return tripsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Trip.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error getting filtered trips: $e');
      return [];
    }
  }

  // Tur programını güncelle
  Future<void> updateTripProgram(String tripId, String newProgram) async {
    try {
      await _db.collection('trips').doc(tripId).update({
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
      await _db.collection('trips').doc(tripId).update({
        'activities': newActivities,
      });
      print('Aktiviteler başarıyla güncellendi!');
    } catch (e) {
      print('Aktiviteler güncellenirken hata: $e');
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      await _db.collection('trips').doc(trip.id).update(trip.toJson());
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _db.collection('trips').doc(tripId).delete();
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }

  Stream<List<Trip>> getTripsByCategory(String categoryId) {
    return _db
        .collection('trips')
        .where('categories', arrayContains: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return Trip(
                id: doc.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                price: (data['price'] as num?)?.toDouble() ?? 0.0,
                location: data['location'] ?? '',
                startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
                endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 1)),
                categories: List<String>.from(data['categories'] ?? []),
                status: TripStatus.values.firstWhere(
                  (e) => e.toString().split('.').last == (data['status'] ?? 'AVAILABLE'),
                  orElse: () => TripStatus.AVAILABLE,
                ),
                createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
                duration: (data['duration'] as num?)?.toInt() ?? 1,
                capacity: (data['capacity'] as num?)?.toInt() ?? 10,
              );
            })
            .toList());
  }

  Future<Trip> getTrip(String id) async {
    try {
      final doc = await _db.collection('trips').doc(id).get();
      if (!doc.exists) {
        throw Exception('Trip not found');
      }
      final data = doc.data()!;
      return Trip(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        location: data['location'] ?? '',
        startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 1)),
        categories: List<String>.from(data['categories'] ?? []),
        status: TripStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (data['status'] ?? 'AVAILABLE'),
          orElse: () => TripStatus.AVAILABLE,
        ),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        duration: (data['duration'] as num?)?.toInt() ?? 1,
        capacity: (data['capacity'] as num?)?.toInt() ?? 10,
      );
    } catch (e) {
      print('Error getting trip: $e');
      rethrow;
    }
  }

  Future<void> addTrip(Trip trip) async {
    try {
      await _db.collection('trips').doc(trip.id).set(trip.toJson());
    } catch (e) {
      print('Error adding trip: $e');
      rethrow;
    }
  }
}