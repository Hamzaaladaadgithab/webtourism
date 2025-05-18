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
      // E-posta ve şifre kontrolü
      if (email.isEmpty || !email.contains('@')) {
        throw FirebaseAuthException(code: 'invalid-email');
      }
      if (password.isEmpty || password.length < 6) {
        throw FirebaseAuthException(code: 'weak-password');
      }

      // Giriş denemesi
      print('Giriş denemesi: $email'); // Debug için
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Kullanıcı token'ını yenile
      if (userCredential.user != null) {
        await userCredential.user!.reload();
      }
      
      print('Giriş başarılı: ${userCredential.user?.email}'); // Debug için
      return userCredential;
    } catch (e) {
      print('Giriş hatası: $e'); // Debug için
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
      if (userId.isEmpty) {
        print('Kullanıcı ID boş');
        return false;
      }

      // Önce admins koleksiyonunda kontrol et
      final adminDoc = await _firestore.collection('admins').doc(userId).get();
      
      if (adminDoc.exists) {
        print('Admin bulundu: $userId');
        // Son giriş zamanını güncelle
        await _firestore.collection('admins').doc(userId).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        return true;
      }
      
      print('Admin bulunamadı: $userId');
      return false;
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

  // Kullanıcının kimliğini yeniden doğrula
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Kullanıcı hesabını sil
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Firestore'dan kullanıcı verilerini sil
      await _firestore.collection('users').doc(user.uid).delete();

      // Firebase Auth'dan kullanıcıyı sil
      await user.delete();
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
    print('Auth Error: $error'); // Debug için
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı';
        case 'wrong-password':
          return 'Hatalı şifre';
        case 'invalid-credential':
          return 'Giriş bilgileri hatalı! Lütfen email ve şifrenizi kontrol edin.';
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
        case 'network-request-failed':
          return 'İnternet bağlantısı hatası! Lütfen bağlantınızı kontrol edin.';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış.';
        default:
          return 'Bir hata oluştu: ${error.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu: $error';
  }
}
