import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onCancel;

  const ReservationCard({
    Key? key,
    required this.reservation,
    required this.onCancel,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (reservation.status) {
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

  String _getStatusText() {
    switch (reservation.status) {
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM y');
    final startDateStr = dateFormat.format(reservation.startDate);
    final endDateStr = dateFormat.format(reservation.endDate);
    final duration = reservation.endDate.difference(reservation.startDate).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum Göstergesi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tur Başlığı
            Text(
              reservation.tripTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // Tarih Aralığı
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Gidiş: $startDateStr',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Dönüş: $endDateStr',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Süre: $duration gün',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Kişi Sayısı
            Row(
              children: [
                Icon(Icons.people, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${reservation.numberOfPeople} Kişi',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // İletişim Bilgileri
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  reservation.userPhone,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            // İptal Butonu
            if (reservation.status == ReservationStatus.pending ||
                reservation.status == ReservationStatus.confirmed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Rezervasyon İptali'),
                        content: const Text(
                          'Bu rezervasyonu iptal etmek istediğinizden emin misiniz?'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('VAZGEÇ'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              onCancel();
                            },
                            child: const Text(
                              'İPTAL ET',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text(
                    'REZERVASYONU İPTAL ET',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
