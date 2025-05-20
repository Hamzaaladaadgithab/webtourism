import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gelişmiş arama sistemi
  Future<List<Trip>> searchTrips({
    String? searchQuery,
    String? category,
    double? maxPrice,
    DateTime? selectedDate,
  }) async {
    try {
      // Ana sorgu
      Query<Map<String, dynamic>> query = _firestore.collection('trips');

      // Önce sadece aktif turları filtrele
      query = query.where('status', isEqualTo: TripStatus.AVAILABLE.toString());

      // Fiyat filtresi
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Kategori filtresi - yeni kategori sistemine göre
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }

      // Sorguyu çalıştır
      final querySnapshot = await query.orderBy('price').get();

      // Sonuçları al
      var results = querySnapshot.docs.map((doc) => Trip.fromFirestore(doc.id, doc.data())).toList();

      // Metin araması için manuel filtreleme
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Küçük harfe çevir ve Türkçe karakterleri normalize et
        String normalizedQuery = searchQuery.toLowerCase()
            .replaceAll('ı', 'i')
            .replaceAll('ğ', 'g')
            .replaceAll('ü', 'u')
            .replaceAll('ş', 's')
            .replaceAll('ö', 'o')
            .replaceAll('ç', 'c');

        // Manuel arama yap
        results = results.where((trip) {
          // Başlık ve açıklamada arama
          String normalizedTitle = trip.title.toLowerCase()
              .replaceAll('ı', 'i')
              .replaceAll('ğ', 'g')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ö', 'o')
              .replaceAll('ç', 'c');
          
          String normalizedDesc = trip.description.toLowerCase()
              .replaceAll('ı', 'i')
              .replaceAll('ğ', 'g')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ö', 'o')
              .replaceAll('ç', 'c');

          return normalizedTitle.contains(normalizedQuery) || 
                 normalizedDesc.contains(normalizedQuery);
        }).toList();
      }
      
      // Tarih filtresi uygula
      if (selectedDate != null) {
        results = results.where((trip) {
          return trip.startDate.isAfter(selectedDate) || 
                 trip.startDate.isAtSameMomentAs(selectedDate);
        }).toList();
      }

      // Eğer metin araması varsa, alakalılık skoruna göre sırala
      if (searchQuery != null && searchQuery.isNotEmpty) {
        results.sort((a, b) {
          int scoreA = _calculateRelevanceScore(a, searchQuery);
          int scoreB = _calculateRelevanceScore(b, searchQuery);
          return scoreB.compareTo(scoreA);
        });
      }

      return results;

    } catch (e) {
      print('Tur arama hatası: $e');
      return [];
    }
  }

  // Alakalılık skorunu hesapla
  int _calculateRelevanceScore(Trip trip, String query) {
    int score = 0;
    String normalizedQuery = query.toLowerCase();

    // Başlıkta eşleşme
    if (trip.title.toLowerCase().contains(normalizedQuery)) {
      score += 3;
    }

    // Açıklamada eşleşme
    if (trip.description.toLowerCase().contains(normalizedQuery)) {
      score += 2;
    }

    // Lokasyonda eşleşme
    if (trip.location.toLowerCase().contains(normalizedQuery)) {
      score += 1;
    }

    return score;
  }

  // Popüler gezileri getir
  Future<List<Trip>> getPopularTrips() async {
    try {
      final querySnapshot = await _firestore
          .collection('trips')
          .where('status', isEqualTo: TripStatus.AVAILABLE.toString())
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => Trip.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Popüler geziler getirilirken hata: $e');
      return [];
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
