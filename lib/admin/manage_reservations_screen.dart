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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
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
    final currentAdmin = await _adminService.getCurrentAdmin();
    if (currentAdmin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin oturumu bulunamadı')),
      );
      return;
    }

    String? reason;
    ReservationStatus? newStatus = await showDialog<ReservationStatus>(
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
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop(value);
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.of(context).pop(value);
                }
              },
            ),
          ],
        ),
      ),
    );

    if (newStatus != null && newStatus != reservation.status) {
      try {
        await _reservationService.updateReservationStatus(
          reservationId: reservation.id,
          newStatus: newStatus,
          admin: currentAdmin.id,
          reason: reason,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyon durumu güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
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
      body: Container(
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
                stream: _reservationService.getAllReservations(
                  status: _selectedStatus,
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final reservation = snapshot.data![index];
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
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showStatusUpdateDialog(reservation),
                            color: Colors.blue.shade900,
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
