import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm kullanıcıları getir
  Future<List<AppUser>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => 
        AppUser.fromFirestore(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      print('Kullanıcılar getirilirken hata: $e');
      throw Exception('Kullanıcılar yüklenirken bir hata oluştu');
    }
  }

  // Kullanıcı bilgilerini getir
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return AppUser.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      print('Kullanıcı bilgisi getirilirken hata: $e');
      throw Exception('Kullanıcı bilgisi yüklenirken bir hata oluştu');
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Kullanıcı güncellenirken hata: $e');
      throw Exception('Kullanıcı güncellenirken bir hata oluştu');
    }
  }

  // Kullanıcı rolünü güncelle
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kullanıcı rolü güncellenirken hata: $e');
      throw Exception('Kullanıcı rolü güncellenirken bir hata oluştu');
    }
  }

  // Kullanıcı sil
  Future<void> deleteUser(String userId) async {
    try {
      // Önce kullanıcının rezervasyonlarını kontrol et
      final reservations = await _firestore
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .get();

      // Eğer aktif rezervasyonu varsa silme
      final hasActiveReservation = reservations.docs.any((doc) {
        final status = doc.data()['status'] as String;
        return status == 'pending' || status == 'confirmed';
      });

      if (hasActiveReservation) {
        throw Exception('Aktif rezervasyonu olan kullanıcı silinemez');
      }

      // Kullanıcıyı sil
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Kullanıcı silinirken hata: $e');
      throw Exception('Kullanıcı silinirken bir hata oluştu: ${e.toString()}');
    }
  }

  // Kullanıcı ara
  Future<List<AppUser>> searchUsers(String query) async {
    try {
      // Email ve isim üzerinden arama yap
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + 'z')
          .get();

      final nameSnapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      // Sonuçları birleştir ve tekrar edenleri kaldır
      final Set<String> userIds = {};
      final List<AppUser> users = [];

      for (var doc in [...querySnapshot.docs, ...nameSnapshot.docs]) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          users.add(AppUser.fromFirestore(doc.data(), doc.id));
        }
      }

      return users;
    } catch (e) {
      print('Kullanıcı aranırken hata: $e');
      throw Exception('Kullanıcı aranırken bir hata oluştu');
    }
  }

  // Kullanıcının favori gezilerini getir
  Stream<List<String>> getUserFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return [];
          final data = doc.data();
          if (data == null || !data.containsKey('favorites')) return [];
          return List<String>.from(data['favorites']);
        });
  }

  // Favorilere gezi ekle/çıkar
  Future<void> toggleFavorite(String userId, String tripId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final doc = await userDoc.get();
      
      if (!doc.exists) {
        throw Exception('Kullanıcı bulunamadı');
      }

      final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      
      if (favorites.contains(tripId)) {
        favorites.remove(tripId);
      } else {
        favorites.add(tripId);
      }

      await userDoc.update({'favorites': favorites});
    } catch (e) {
      print('Favori güncellenirken hata: $e');
      throw Exception('Favori güncellenirken bir hata oluştu');
    }
  }
}
