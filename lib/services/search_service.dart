import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gezileri arama ve filtreleme
  Future<List<Trip>> searchTrips({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    int? minDuration,
    int? maxDuration,
  }) async {
    try {
      Query query = _firestore.collection('trips');

      // Kategori filtresi
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }

      // Fiyat filtresi
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Tarih filtresi
      if (startDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('endDate', isLessThanOrEqualTo: endDate);
      }

      // Süre filtresi
      if (minDuration != null) {
        query = query.where('duration', isGreaterThanOrEqualTo: minDuration);
      }
      if (maxDuration != null) {
        query = query.where('duration', isLessThanOrEqualTo: maxDuration);
      }

      final querySnapshot = await query.get();
      final trips = querySnapshot.docs.map((doc) => 
        Trip.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();

      // Metin araması (Firestore'da tam metin araması olmadığı için client-side yapıyoruz)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return trips.where((trip) {
          return trip.title.toLowerCase().contains(searchLower) ||
                 trip.description.toLowerCase().contains(searchLower) ||
                 trip.location.toLowerCase().contains(searchLower);
        }).toList();
      }

      return trips;
    } catch (e) {
      print('Arama yapılırken hata: $e');
      throw Exception('Arama yapılırken bir hata oluştu');
    }
  }

  // Popüler gezileri getir
  Future<List<Trip>> getPopularTrips() async {
    try {
      final querySnapshot = await _firestore
          .collection('trips')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) =>
        Trip.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Popüler geziler getirilirken hata: $e');
      throw Exception('Popüler geziler yüklenirken bir hata oluştu');
    }
  }

  // Önerilen gezileri getir
  Future<List<Trip>> getRecommendedTrips(String userId) async {
    try {
      // Kullanıcının önceki rezervasyonlarına göre öneriler
      final userReservations = await _firestore
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .get();

      // Kullanıcının tercih ettiği kategorileri bul
      final preferredCategories = <String>{};
      for (var doc in userReservations.docs) {
        final tripId = doc.data()['tripId'];
        final tripDoc = await _firestore.collection('trips').doc(tripId).get();
        if (tripDoc.exists) {
          final categories = List<String>.from(tripDoc.data()?['categories'] ?? []);
          preferredCategories.addAll(categories);
        }
      }

      if (preferredCategories.isEmpty) {
        // Kullanıcının rezervasyonu yoksa popüler gezileri öner
        return getPopularTrips();
      }

      // Tercih edilen kategorilerdeki gezileri getir
      final querySnapshot = await _firestore
          .collection('trips')
          .where('categories', arrayContainsAny: preferredCategories.toList())
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) =>
        Trip.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Önerilen geziler getirilirken hata: $e');
      throw Exception('Önerilen geziler yüklenirken bir hata oluştu');
    }
  }
}
