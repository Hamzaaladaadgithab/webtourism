import 'package:flutter/material.dart';
import '../models/admin_user.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';
import '../widgets/reservation_card.dart';

class UserReservationsScreen extends StatefulWidget {
  const UserReservationsScreen({Key? key}) : super(key: key);

  @override
  State<UserReservationsScreen> createState() => _UserReservationsScreenState();
}

class _UserReservationsScreenState extends State<UserReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final AuthService _authService = AuthService();
  String? _userId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _error = 'Kullanıcı girişi yapılmamış';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _userId = user.uid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      final admin = AdminUser(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        name: currentUser.displayName ?? 'User',
        role: 'user',
        permissions: ['cancel_own_reservations'],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // İlk önce durumu iptal edildi olarak güncelle
      await _reservationService.updateReservationStatus(
        reservationId: reservationId,
        newStatus: ReservationStatus.cancelled,
        reason: 'Kullanıcı tarafından iptal edildi',
        admin: admin.id,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon iptal edildi. 5 saniye sonra silinecek...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );

      // 5 saniye bekle ve sonra rezervasyonu sil
      await Future.delayed(const Duration(seconds: 5));
      await _reservationService.deleteReservation(reservationId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervasyon başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildReservationsList() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserId,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_userId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Lütfen giriş yapın',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<Reservation>>(
      stream: _reservationService.getUserReservations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reservations = snapshot.data!;

        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Henüz rezervasyonunuz bulunmuyor',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReservationCard(
                  reservation: reservation,
                  onCancel: () => _cancelReservation(reservation.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildReservationsList(),
      ),
    );
  }
}
