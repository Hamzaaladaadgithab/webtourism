import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı getir
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Email/Password ile giriş
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Yeni kullanıcı kaydı
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profili oluştur
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': name,
          'phone': phone,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı rolünü kontrol et
  Future<bool> isAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists && doc.data()?['role'] == 'admin';
    } catch (e) {
      print('Admin kontrolü sırasında hata: $e');
      return false;
    }
  }

  // Şifre sıfırlama maili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Şifre güncelleme
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Mevcut şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi güncelle
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Profil güncellenirken hata oluştu: $e');
    }
  }

  // Hata mesajlarını düzenle
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı';
        case 'wrong-password':
          return 'Hatalı şifre';
        case 'email-already-in-use':
          return 'Bu email adresi zaten kullanımda';
        case 'invalid-email':
          return 'Geçersiz email adresi';
        case 'weak-password':
          return 'Şifre çok zayıf';
        case 'operation-not-allowed':
          return 'Bu işlem şu anda kullanılamıyor';
        case 'too-many-requests':
          return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin';
        default:
          return 'Bir hata oluştu: ${error.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu';
  }
}
