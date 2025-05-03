import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/trip.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kategorileri gerçek zamanlı dinle
  Stream<List<Category>> getCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('Category data: $data');
        return Category(
          id: data['id'],
          title: data['title'],
          imageUrl: data['imageUrl'],
        );
      }).toList();
    });
  }

  // Turları gerçek zamanlı dinle
  Stream<List<Trip>> getTripsStream() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('Trip data: $data');
        
        // Kategorileri kontrol et
        final categories = List<String>.from(data['categories'] ?? []);
        print('Trip categories: $categories');
        
        // TripType'ı kontrol et
        final tripTypeStr = data['tripType'] ?? 'Exploration';
        final tripType = TripType.values.firstWhere(
          (e) => e.toString() == 'TripType.$tripTypeStr',
          orElse: () => TripType.Exploration,
        );
        
        // Season'ı kontrol et
        final seasonStr = data['season'] ?? 'summer';
        final season = Season.values.firstWhere(
          (e) => e.toString() == 'Season.$seasonStr',
          orElse: () => Season.summer,
        );
        
        // Duration'ı kontrol et
        final durationStr = data['duration'] is List ? data['duration'][0] : data['duration'];
        final duration = int.tryParse(durationStr.toString().replaceAll(' gün', '')) ?? 1;
        
        return Trip(
          id: data['id'],
          categories: categories,
          title: data['title'],
          tripType: tripType,
          season: season,
          imageUrl: data['imageUrl'],
          duration: duration,
          activities: List<String>.from(data['activities'] ?? []),
          program: List<String>.from(data['program'] ?? []),
          isInSummer: data['isInSummer'] ?? false,
          isInWinter: data['isInWinter'] ?? false,
          isForFamilies: data['isForFamilies'] ?? false,
          numberOfTrips: 1,
        );
      }).toList();
    });
  }

  // Kategorileri çek
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          id: data['id'],
          title: data['title'],
          imageUrl: data['imageUrl'],
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
        
        // Kategorileri kontrol et
        final categories = List<String>.from(data['categories'] ?? []);
        
        // TripType'ı kontrol et
        final tripTypeStr = data['tripType'] ?? 'Exploration';
        final tripType = TripType.values.firstWhere(
          (e) => e.toString() == 'TripType.$tripTypeStr',
          orElse: () => TripType.Exploration,
        );
        
        // Season'ı kontrol et
        final seasonStr = data['season'] ?? 'summer';
        final season = Season.values.firstWhere(
          (e) => e.toString() == 'Season.$seasonStr',
          orElse: () => Season.summer,
        );
        
        // Duration'ı kontrol et
        final durationStr = data['duration'] is List ? data['duration'][0] : data['duration'];
        final duration = int.tryParse(durationStr.toString().replaceAll(' gün', '')) ?? 1;
        
        return Trip(
          id: data['id'],
          categories: categories,
          title: data['title'],
          tripType: tripType,
          season: season,
          imageUrl: data['imageUrl'],
          duration: duration,
          activities: List<String>.from(data['activities'] ?? []),
          program: List<String>.from(data['program'] ?? []),
          isInSummer: data['isInSummer'] ?? false,
          isInWinter: data['isInWinter'] ?? false,
          isForFamilies: data['isForFamilies'] ?? false,
          numberOfTrips: 1,
        );
      }).toList();
    } catch (e) {
      print('Turlar çekilirken hata: $e');
      return [];
    }
  }

  // Tur programını güncelle
  Future<void> updateTripProgram(String tripId, List<String> newProgram) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'program': newProgram,
      });
      print('Program başarıyla güncellendi!');
    } catch (e) {
      print('Program güncellenirken hata: $e');
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
    }
  }
} 