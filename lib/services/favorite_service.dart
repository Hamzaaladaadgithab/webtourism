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