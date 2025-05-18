import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, String filePath) async {
    final file = File(filePath);
    final ext = path.extension(filePath);
    final ref = _storage.ref().child('profile_images/$userId$ext');
    
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId');
      await ref.delete();
    } catch (e) {
      // Dosya zaten silinmiş olabilir
      print('Profil resmi silinirken hata: $e');
    }
  }
}
