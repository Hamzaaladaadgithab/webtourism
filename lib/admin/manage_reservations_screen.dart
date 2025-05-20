import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../services/admin_service.dart';

class ManageReservationsScreen extends StatefulWidget {
  static const routeName = '/manage-reservations';
  const ManageReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ManageReservationsScreen> createState() => _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  bool _isUpdating = false;
  Stream<List<Reservation>>? _reservationsStream;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'Onay Bekliyor';
      case ReservationStatus.confirmed:
        return 'Onaylandı';
      case ReservationStatus.cancelled:
        return 'İptal Edildi';
      case ReservationStatus.completed:
        return 'Tamamlandı';
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      if (!isAdmin) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu sayfaya erişim için admin yetkisi gerekiyor')),
        );
        Navigator.of(context).pop();
        return;
      }
      _reservationsStream = _adminService.getAllReservations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  Future<void> _showStatusUpdateDialog(Reservation reservation) async {
    if (_isUpdating) return;
    
    try {
      setState(() => _isUpdating = true);
      final ReservationStatus? newStatus = await showDialog<ReservationStatus>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rezervasyon Durumunu Güncelle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ReservationStatus.values.map((status) => ListTile(
              title: Text(_getStatusText(status)),
              tileColor: _getStatusColor(status).withOpacity(0.1),
              onTap: () => Navigator.of(context).pop(status),
            )).toList(),
          ),
        ),
      );

      if (newStatus == null) return;

      String? cancelReason;
      if (newStatus == ReservationStatus.cancelled) {
        cancelReason = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('İptal Sebebi'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'İptal sebebini giriniz',
              ),
              onChanged: (value) => cancelReason = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(cancelReason),
                child: const Text('TAMAM'),
              ),
            ],
          ),
        );

        if (cancelReason == null) return;
      }

      await _adminService.updateReservation(
        reservation.id,
        status: newStatus.toString(),
        cancelReason: cancelReason,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervasyon durumu güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(Reservation reservation) async {
    if (_isUpdating) return;
    
    try {
      setState(() => _isUpdating = true);
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rezervasyonu Sil'),
          content: const Text('Bu rezervasyonu silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await _adminService.deleteReservation(
        reservation.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervasyon silindi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyonları Yönet' , style: TextStyle(color: Colors.white,)),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Reservation>>(
              stream: _reservationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final reservations = snapshot.data!;
                if (reservations.isEmpty) {
                  return const Center(
                    child: Text('Rezervasyon bulunamadı'),
                  );
                }

                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          'Müşteri: ${reservation.userName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tarih: ${DateFormat('dd/MM/yyyy').format(reservation.startDate)} - ${DateFormat('dd/MM/yyyy').format(reservation.endDate)}',
                            ),
                            Text(
                              'Durum: ${_getStatusText(reservation.status)}',
                              style: TextStyle(
                                color: _getStatusColor(reservation.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (reservation.status == ReservationStatus.cancelled)
                              Text(
                                'İptal Nedeni: ${reservation.cancellationReason ?? 'Belirtilmemiş'}',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showStatusUpdateDialog(reservation),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmationDialog(reservation),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
