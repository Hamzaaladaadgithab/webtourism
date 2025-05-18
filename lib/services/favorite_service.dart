import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';

class FavoriteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Favorilere ekle
  Future<void> addToFavorites(String tripId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı girişi yapılmamış');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(tripId)
        .set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Favorilerden kaldır
  Future<void> removeFromFavorites(String tripId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı girişi yapılmamış');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(tripId)
        .delete();
  }

  // Favori turları getir
  Future<void> initializeFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı girişi yapılmamış');
    }

    // Favori koleksiyonunu başlat
    final favoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    // Koleksiyonun varlığını kontrol et
    final snapshot = await favoritesRef.limit(1).get();
    if (!snapshot.docs.isNotEmpty) {
      // Koleksiyon boşsa, varsayılan bir döküman oluştur ve hemen sil
      // Bu, koleksiyonun stream'ini başlatır
      final tempDoc = await favoritesRef.add({'temp': true});
      await tempDoc.delete();
    }
  }

  Stream<List<Trip>> getFavoriteTrips() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı girişi yapılmamış');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      final tripIds = snapshot.docs.map((doc) => doc.id).toList();
      if (tripIds.isEmpty) {
        print('Favori turlar boş');
        return [];
      }

      // Turları getir ve önbelleğe al
      try {
        final tripsQuery = _firestore.collection('trips');
        List<Trip> trips = [];

        // Firebase whereIn sınırlaması nedeniyle grupla
        for (var i = 0; i < tripIds.length; i += 10) {
          final end = (i + 10 < tripIds.length) ? i + 10 : tripIds.length;
          final batchIds = tripIds.sublist(i, end);

          final batchSnapshot = await tripsQuery
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

          trips.addAll(
            batchSnapshot.docs
                .map((doc) => Trip.fromFirestore(doc.id, doc.data()))
                .toList(),
          );
        }

        trips.sort((a, b) => b.startDate.compareTo(a.startDate));
        print('Favori turlar getirildi: ${trips.length}');
        return trips;
      } catch (e) {
        print('Favori turlar getirilirken hata: $e');
        return [];
      }
    });
  }

  // Tur favori mi kontrol et
  Future<bool> isFavorite(String tripId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(tripId)
        .get();

    return doc.exists;
  }
} 