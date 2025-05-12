import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Firebase Auth instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads initial categories to Firestore if they don't exist.
  Future<void> uploadCategories() async {
    try {
      final initialCategories = [
        Category(
          id: 'c1',
          title: 'Mountains',
          imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
        ),
        Category(
          id: 'c2',
          title: 'Lakes',
          imageUrl: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000',
        ),
        Category(
          id: 'c3',
          title: 'Beaches',
          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        ),
        Category(
          id: 'c4',
          title: 'Deserts',
          imageUrl: 'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0',
        ),
        Category(
          id: 'c5',
          title: 'Historic Sites',
          imageUrl: 'https://images.unsplash.com/photo-1606918801925-e2c914c4b503',
        ),
        Category(
          id: 'c6',
          title: 'Cities',
          imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df',
        ),
      ];

      for (final category in initialCategories) {
        await _firestore.collection('categories').doc(category.id).set({
          'id': category.id,
          'title': category.title,
          'imageUrl': category.imageUrl,
        });
      }
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
        'tripType': trip.type,
        'season': trip.season.toString(),
        'duration': trip.duration.toString(),
        'imageUrl': trip.imageUrl,
        'activities': trip.activities,
        'program': trip.program,
        'description': trip.description,
        'location': trip.location,
        'price': trip.price,
        'startDate': trip.startDate.toIso8601String(),
        'endDate': trip.endDate.toIso8601String(),
        'capacity': trip.capacity,
        'status': trip.status,
        'isFamilyFriendly': trip.isFamilyFriendly,
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
          id: data['id'],
          title: data['title'],
          imageUrl: data['imageUrl'],
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
          type: data['tripType'],
          season: data['season'],
          imageUrl: data['imageUrl'],
          duration: int.parse(data['duration'].toString()),
          activities: List<String>.from(data['activities']),
          program: data['program'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? 'Location not specified',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          startDate: data['startDate'] != null ? DateTime.parse(data['startDate'] as String) : DateTime.now(),
          endDate: data['endDate'] != null ? DateTime.parse(data['endDate'] as String) : DateTime.now().add(const Duration(days: 1)),
          capacity: data['capacity'] ?? 10,
          status: data['status'] ?? 'active',
          isFamilyFriendly: data['isFamilyFriendly'] ?? false,
        );
      }).toList();
    });
  }

  /// Updates a trip in Firestore.
  Future<void> updateTrip(Trip trip) async {
    try {
      await _firestore.collection('trips').doc(trip.id).update({
        'title': trip.title,
        'tripType': trip.type,
        'season': trip.season.toString(),
        'duration': trip.duration.toString(),
        'activities': trip.activities,
        'program': trip.program,
        'imageUrl': trip.imageUrl,
        'description': trip.description,
        'location': trip.location,
        'price': trip.price,
        'startDate': trip.startDate.toIso8601String(),
        'endDate': trip.endDate.toIso8601String(),
        'capacity': trip.capacity,
        'status': trip.status,
        'isFamilyFriendly': trip.isFamilyFriendly,
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