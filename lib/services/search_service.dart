import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Modern ve basit arama sistemi
  Future<List<Trip>> searchTrips({
    String? searchQuery,
    String? category,
    double? maxPrice,
    DateTime? selectedDate,
  }) async {
    try {
      // Ana sorgu
      Query query = _firestore.collection('trips');

      // 1. Metin araması
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        // Başlık veya konum içinde arama yap
        query = query.where('searchFields', arrayContainsAny: [
          'title_$searchLower',
          'location_$searchLower',
        ]);
      }

      // 2. Kategori filtresi
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }

      // 3. Fiyat filtresi
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // 4. Tarih filtresi
      if (selectedDate != null) {
        // Seçilen tarihte başlayan turları getir
        query = query.where('startDate', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDate));
      }

      // Sorguyu çalıştır
      final querySnapshot = await query.get();
      
      // Sonuçları Trip modellerine dönüştür
      return querySnapshot.docs.map((doc) {
        final tripData = doc.data() as Map<String, dynamic>;
        return Trip.fromFirestore(doc.id, tripData);
      }).toList();
    } catch (e) {
      print('Tur arama hatası: $e');
      return [];
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
        Trip.fromFirestore(doc.id, doc.data())
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
        if (tripDoc.exists && tripDoc.data() != null) {
          final data = tripDoc.data()!;
          if (data.containsKey('categories')) {
            final categoriesData = data['categories'] as List<dynamic>?;
          final categories = categoriesData?.map((e) => e.toString()).toList() ?? <String>[];
            preferredCategories.addAll(categories);
          }
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
        Trip.fromFirestore(doc.id, doc.data())
      ).toList();
    } catch (e) {
      print('Önerilen geziler getirilirken hata: $e');
      throw Exception('Önerilen geziler yüklenirken bir hata oluştu');
    }
  }
}
