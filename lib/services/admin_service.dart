import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_user.dart';
import '../models/trip.dart';
import '../models/reservation.dart';
import '../models/user.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin girişi
  Future<AdminUser?> signInAdmin(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Admin koleksiyonunda kullanıcıyı ara
        final adminDoc = await _firestore
            .collection('admins')
            .doc(userCredential.user!.uid)
            .get();

        if (adminDoc.exists) {
          // Son giriş zamanını güncelle
          await adminDoc.reference.update({
            'lastLogin': DateTime.now().toIso8601String(),
          });

          return AdminUser.fromFirestore(
            adminDoc.data() as Map<String, dynamic>,
            adminDoc.id,
          );
        } else {
          // Kullanıcı admin değilse çıkış yap
          await _auth.signOut();
          throw Exception('Bu kullanıcı admin yetkisine sahip değil.');
        }
      }
      return null;
    } catch (e) {
      throw Exception('Giriş başarısız: ${e.toString()}');
    }
  }

  // Admin çıkışı
  Future<void> signOutAdmin() async {
    await _auth.signOut();
  }

  // İlk admin kullanıcısını oluştur
  Future<void> createInitialAdmin() async {
    try {
      // Önce admin koleksiyonunu kontrol et
      final adminSnapshot = await _firestore.collection('admins').get();
      
      if (adminSnapshot.docs.isEmpty) {
        // İlk admin kullanıcısını oluştur
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@tourism.com',
          password: 'admin123',
        );

        // Admin bilgilerini Firestore'a kaydet
        await _firestore.collection('admins').doc(userCredential.user!.uid).set({
          'email': 'admin@tourism.com',
          'name': 'Super Admin',
          'role': 'superadmin',
          'permissions': ['all'],
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        });

        print('İlk admin kullanıcısı oluşturuldu!');
      }
    } catch (e) {
      print('İlk admin oluşturma hatası: $e');
      throw e;
    }
  }

  // Mevcut admin kullanıcısını getir
  Future<AdminUser?> getCurrentAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Oturum açmış kullanıcı bulunamadı');
        return null;
      }

      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) {
        print('Kullanıcı admin değil: ${user.uid}');
        return null;
      }

      final data = adminDoc.data();
      if (data == null) {
        print('Admin verisi boş: ${user.uid}');
        return null;
      }

      return AdminUser.fromFirestore(data, adminDoc.id);
    } catch (e) {
      print('Admin bilgileri alınırken hata: $e');
      return null;
    }
  }

  // Yeni admin oluştur (sadece superadmin yapabilir)
  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
    required List<String> permissions,
  }) async {
    try {
      // Önce mevcut kullanıcının superadmin olduğunu kontrol et
      final currentAdmin = await getCurrentAdmin();
      if (currentAdmin == null || currentAdmin.role != 'superadmin') {
        throw Exception('Bu işlem için superadmin yetkisi gerekiyor.');
      }

      // Email formatını kontrol et
      if (!email.contains('@')) {
        throw Exception('Geçersiz email formatı');
      }

      // Şifre güvenliğini kontrol et
      if (password.length < 6) {
        throw Exception('Şifre en az 6 karakter olmalıdır');
      }

      // Firebase Auth'da kullanıcı oluştur
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      // Admin koleksiyonuna ekle
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'admin',
        'permissions': permissions,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'status': 'active',
      });
    } catch (e) {
      throw Exception('Admin oluşturma başarısız: ${e.toString()}');
    }
  }

  // Admin bilgilerini güncelle
  Future<void> updateAdmin({
    required String adminId,
    String? name,
    List<String>? permissions,
  }) async {
    // Mevcut kullanıcının yetkisini kontrol et
    final currentAdmin = await getCurrentAdmin();
    if (currentAdmin == null || 
        (currentAdmin.role != 'superadmin' && currentAdmin.id != adminId)) {
      throw Exception('Bu işlem için yetkiniz yok.');
    }

    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (permissions != null) updateData['permissions'] = permissions;

    await _firestore.collection('admins').doc(adminId).update(updateData);
  }

  // Admin sil (sadece superadmin yapabilir)
  Future<void> deleteAdmin(String adminId) async {
    final currentAdmin = await getCurrentAdmin();
    if (currentAdmin == null || currentAdmin.role != 'superadmin') {
      throw Exception('Bu işlem için superadmin yetkisi gerekiyor.');
    }

    // Admin'i Firebase Auth ve Firestore'dan sil
    final adminDoc = await _firestore.collection('admins').doc(adminId).get();
    if (adminDoc.exists) {
      final adminData = AdminUser.fromFirestore(
        adminDoc.data() as Map<String, dynamic>,
        adminDoc.id,
      );

      // Superadmin'i silmeye çalışıyorsa engelle
      if (adminData.role == 'superadmin') {
        throw Exception('Superadmin silinemez.');
      }

      await _firestore.collection('admins').doc(adminId).delete();
      
      // Firebase Auth'dan kullanıcıyı sil
      try {
        final userRecord = await _auth.fetchSignInMethodsForEmail(adminData.email);
        if (userRecord.isNotEmpty) {
          // Kullanıcı var, silme işlemini gerçekleştir
          final currentUser = _auth.currentUser;
          if (currentUser != null) {
            await currentUser.delete();
          }
        }
      } catch (e) {
        print('Kullanıcı silme hatası: $e');
      }
    }
  }

  // Tüm adminleri getir (sadece superadmin görebilir)
  Future<List<AdminUser>> getAllAdmins() async {
    final currentAdmin = await getCurrentAdmin();
    if (currentAdmin == null || currentAdmin.role != 'superadmin') {
      throw Exception('Bu işlem için superadmin yetkisi gerekiyor.');
    }

    final querySnapshot = await _firestore.collection('admins').get();
    return querySnapshot.docs
        .map((doc) => AdminUser.fromFirestore(
              doc.data(),
              doc.id,
            ))
        .toList();
  }

  // Admin yetkisi kontrolü
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists && userDoc.data()?['role'] == 'admin';
  }

  // Tüm turları getir
  Stream<List<Trip>> getAllTrips() {
    return _firestore
        .collection('trips')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Tur sil
  Future<void> deleteTrip(String tripId) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Bu işlem için admin yetkisi gerekiyor');
    }
    await _firestore.collection('trips').doc(tripId).delete();
  }

  // Tüm rezervasyonları getir
  Stream<List<Reservation>> getAllReservations() {
    return _firestore
        .collection('reservations')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Rezervasyon durumunu güncelle
  Future<void> updateReservationStatus(String reservationId, String status) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Bu işlem için admin yetkisi gerekiyor');
    }
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({'status': status});
  }

  // Tüm kullanıcıları getir
  Stream<List<AppUser>> getAllUsers() {
    return _firestore
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Kullanıcı sil
  Future<void> deleteUser(String userId) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Bu işlem için admin yetkisi gerekiyor');
    }
    await _firestore.collection('users').doc(userId).delete();
  }

  // İstatistikleri getir
  Stream<Map<String, dynamic>> getStatistics() {
    return _firestore.collection('statistics').doc('admin').snapshots().map((doc) {
      if (!doc.exists) {
        return {
          'totalTrips': 0,
          'totalReservations': 0,
          'totalUsers': 0,
          'totalRevenue': 0.0,
        };
      }
      return doc.data() ?? {};
    });
  }

  // İstatistikleri güncelle
  Future<void> updateStatistics() async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Bu işlem için admin yetkisi gerekiyor');
    }

    final tripsSnapshot = await _firestore.collection('trips').get();
    final reservationsSnapshot = await _firestore.collection('reservations').get();
    final usersSnapshot = await _firestore.collection('users').get();

    double totalRevenue = 0;
    for (var doc in reservationsSnapshot.docs) {
      final reservation = Reservation.fromFirestore(doc.id, doc.data());
      if (reservation.status == 'confirmed') {
        totalRevenue += reservation.totalPrice;
      }
    }

    await _firestore.collection('statistics').doc('admin').set({
      'totalTrips': tripsSnapshot.size,
      'totalReservations': reservationsSnapshot.size,
      'totalUsers': usersSnapshot.size,
      'totalRevenue': totalRevenue,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Yeni tur ekle
  Future<void> addTrip(Trip trip) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Bu işlem için admin yetkisi gerekiyor');
    }

    await _firestore.collection('trips').add(trip.toFirestore());
  }

  // Tur güncelle
  Future<void> updateTrip(Trip trip) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Bu işlem için admin yetkisi gerekiyor');
    }

    await _firestore
        .collection('trips')
        .doc(trip.id)
        .update(trip.toFirestore());
  }
}
