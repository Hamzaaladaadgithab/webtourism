import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';
import '../models/trip.dart';
import '../app_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kategorileri Firestore'a yükleme
  Future<void> uploadCategories() async {
    try {
      for (var category in Categories_data) {
        await _firestore.collection('categories').doc(category.id).set({
          'id': category.id,
          'title': category.title,
          'imageUrl': category.imageUrl,
        });
      }
      print('Kategoriler başariyla yüklendi!');
    } catch (e) {
      print('Kategoriler yüklenirken hata oluştu: $e');
    }
  }

  // Turları Firestore'a yükleme
  Future<void> uploadTrips() async {
    try {
      for (var trip in Trips_data) {
        await _firestore.collection('trips').doc(trip.id).set({
          'id': trip.id,
          'categories': trip.categories,
          'title': trip.title,
          'tripType': trip.tripType.toString(),
          'season': trip.season.toString(),
          'imageUrl': trip.imageUrl,
          'duration': trip.duration,
          'activities': trip.activities,
          'program': trip.program,
          'isInSummer': trip.isInSummer,
          'isInWinter': trip.isInWinter,
          'isForFamilies': trip.isForFamilies,
          'numberOfTrips': trip.numberOfTrips,
        });
      }
      print('Turlar başariyla yüklendi!');
    } catch (e) {
      print('Turlar yüklenirken hata oluştu: $e');
    }
  }

  // Kategorileri Firestore'dan gerçek zamanlı çekme
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

  // Turları Firestore'dan gerçek zamanlı çekme
  Stream<List<Trip>> getTripsStream() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Trip(
          id: data['id'],
          categories: List<String>.from(data['categories']),
          title: data['title'],
          tripType: TripType.values.firstWhere(
            (e) => e.toString() == data['tripType'],
          ),
          season: Season.values.firstWhere(
            (e) => e.toString() == data['season'],
          ),
          imageUrl: data['imageUrl'],
          duration: int.parse(data['duration'][0].replaceAll(' gün', '')),
          activities: List<String>.from(data['activities']),
          program: List<String>.from(data['program']),
          isInSummer: data['isInSummer'],
          isInWinter: data['isInWinter'],
          isForFamilies: data['isForFamilies'],
          numberOfTrips: 1,
        );
      }).toList();
    });
  }
} 