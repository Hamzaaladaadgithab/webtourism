import 'package:cloud_firestore/cloud_firestore.dart';


class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ödeme işlemini başlat
  Future<Map<String, dynamic>> initiatePayment({
    required String reservationId,
    required double amount,
    required String userId,
    required String userEmail,
    required String userName,
  }) async {
    try {
      // Burada gerçek ödeme entegrasyonu yapılacak
      // Şimdilik sadece ödeme kaydı oluşturuyoruz
      final paymentDoc = await _firestore.collection('payments').add({
        'reservationId': reservationId,
        'amount': amount,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'paymentId': paymentDoc.id,
        'message': 'Ödeme işlemi başlatıldı',
      };
    } catch (e) {
      print('Ödeme başlatılırken hata: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Ödeme durumunu kontrol et
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      
      if (!doc.exists) {
        return {
          'success': false,
          'error': 'Ödeme kaydı bulunamadı',
        };
      }

      return {
        'success': true,
        'status': doc.data()?['status'],
        'updatedAt': doc.data()?['updatedAt'],
      };
    } catch (e) {
      print('Ödeme durumu kontrol edilirken hata: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Ödeme iptali
  Future<Map<String, dynamic>> cancelPayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Ödeme başarıyla iptal edildi',
      };
    } catch (e) {
      print('Ödeme iptal edilirken hata: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Ödeme geçmişini getir
  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Ödeme geçmişi getirilirken hata: $e');
      return [];
    }
  }
}
