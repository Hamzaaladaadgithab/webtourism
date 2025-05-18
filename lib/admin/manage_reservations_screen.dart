import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/reservation_service.dart';
import '../models/reservation.dart';
import '../services/admin_service.dart';
import '../utils/responsive_helper.dart';

class ManageReservationsScreen extends StatefulWidget {
  static const routeName = '/manage-reservations';

  @override
  _ManageReservationsScreenState createState() => _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final AdminService _adminService = AdminService();
  ReservationStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isUpdating = false;

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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = isStartDate ? _startDate ?? now : _endDate ?? now;
    final firstDate = DateTime(2020);
    final lastDate = DateTime(now.year + 2, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _showStatusUpdateDialog(Reservation reservation) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    
    final currentAdmin = await _adminService.getCurrentAdmin();
    if (currentAdmin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin oturumu bulunamadı')),
      );
      setState(() => _isUpdating = false);
      return;
    }

      String? reason;
      final ReservationStatus? selectedStatus = await showDialog<ReservationStatus>(
        context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Rezervasyon Durumunu Güncelle',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<ReservationStatus>(
              value: reservation.status,
              items: ReservationStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == ReservationStatus.cancelled) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('İptal Nedeni'),
                      content: TextField(
                        onChanged: (value) => reason = value,
                        decoration: InputDecoration(
                          hintText: 'İptal nedenini giriniz',
                          hintStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14)
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getFontSize(context, 16),
                            vertical: ResponsiveHelper.getFontSize(context, 12)
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'İptal',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 14)
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: Text(
                            'Tamam',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 14)
                            ),
                          ),
                          onPressed: () {
                            setState(() => _isUpdating = true);
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop(value);
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  setState(() => _isUpdating = true);
                  Navigator.of(context).pop(value);
                }
              },
            ),
          ],
        ),
      ),
    );

    if (selectedStatus != null && selectedStatus != reservation.status) {
      try {
        await _reservationService.updateReservationStatus(
          reservationId: reservation.id,
          newStatus: selectedStatus,
          admin: currentAdmin.id,
          reason: reason,
        );

        // Stream'i yenilemek için setState kullanmaya gerek yok
        // StreamBuilder otomatik olarak yeni verileri alacak

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervasyon durumu güncellendi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Sayfayı yenile
        setState(() {
          _isLoading = false;
          _isUpdating = false;
        });
        
        // Kullanıcıya bildirim gönderildi
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _showDeleteConfirmationDialog(Reservation reservation) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyonu Sil'),
        content: Text('${reservation.tripTitle} rezervasyonunu silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('VAZGEÇ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isUpdating = true);
              try {
                await _reservationService.deleteReservation(reservation.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rezervasyon başarıyla silindi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isUpdating = false);
              }
            },
            child: const Text(
              'SİL',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      final admin = await _adminService.getCurrentAdmin();
      if (admin == null) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin yetkisi gerekli')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rezervasyonları Yönet',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: Column(
                children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<ReservationStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Durum Filtresi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem<ReservationStatus>(
                          value: null,
                          child: Text('Tüm Durumlar'),
                        ),
                        ...ReservationStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Başlangıç Tarihi',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _startDate == null
                                    ? 'Tarih Seçin'
                                    : DateFormat('dd/MM/yyyy').format(_startDate!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Bitiş Tarihi',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _endDate == null
                                    ? 'Tarih Seçin'
                                    : DateFormat('dd/MM/yyyy').format(_endDate!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Reservation>>(
                stream: _reservationService.getAllReservations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Hata: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  var reservations = snapshot.data ?? [];

                  // Durum filtreleme
                  if (_selectedStatus != null) {
                    reservations = reservations
                        .where((r) => r.status == _selectedStatus)
                        .toList();
                  }

                  // Tarih filtreleme
                  if (_startDate != null) {
                    reservations = reservations
                        .where((r) => r.startDate.isAfter(_startDate!))
                        .toList();
                  }

                  if (_endDate != null) {
                    reservations = reservations
                        .where((r) => r.endDate.isBefore(_endDate!))
                        .toList();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Hata: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  if (reservations.isEmpty) {
                    return Center(
                      child: Text(
                        'Rezervasyon bulunamadı.',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            reservation.tripTitle,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Müşteri: ${reservation.userName}'),
                              Text('Tarih: ${DateFormat('dd/MM/yyyy').format(reservation.startDate)} - ${DateFormat('dd/MM/yyyy').format(reservation.endDate)}'),
                              Text('Kişi Sayısı: ${reservation.numberOfPeople}'),
                              Text('Toplam: ${reservation.totalPrice.toStringAsFixed(2)} TL'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(reservation.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(reservation.status),
                                  style: TextStyle(
                                    color: _getStatusColor(reservation.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isUpdating)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else ...[  
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showStatusUpdateDialog(reservation),
                                  color: Colors.blue.shade900,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteConfirmationDialog(reservation),
                                  color: Colors.red,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
