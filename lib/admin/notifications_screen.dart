import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/responsive_helper.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/services.dart';
import '../models/trip.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String? tourId;
  final DateTime? tourStartDate;
  final int priority;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.tourId,
    this.tourStartDate,
    this.priority = 1,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? 'info',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      tourId: data['tourId']?.toString(),
      tourStartDate: (data['tourStartDate'] as Timestamp?)?.toDate(),
      priority: (data['priority'] as num?)?.toInt() ?? 1,
    );
  }

  // Bildirimin türüne göre renk döndürür
  Color getTypeColor() {
    switch (type.toUpperCase()) {
      case 'NOTIFICATIONTYPE.TOUR_START_1_DAY':
      case 'NOTIFICATIONTYPE.LOW_PARTICIPANTS':
        return Colors.red;
      case 'NOTIFICATIONTYPE.TOUR_START_3_DAYS':
      case 'NOTIFICATIONTYPE.CAPACITY_FULL':
        return Colors.orange;
      case 'NOTIFICATIONTYPE.RESERVATION_NEW':
      case 'NOTIFICATIONTYPE.RESERVATION_CONFIRM':
        return Colors.green;
      case 'NOTIFICATIONTYPE.RESERVATION_CANCEL':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Bildirimin türüne göre icon döndürür
  IconData getTypeIcon() {
    switch (type.toUpperCase()) {
      case 'NOTIFICATIONTYPE.TOUR_START_1_DAY':
      case 'NOTIFICATIONTYPE.TOUR_START_3_DAYS':
        return Icons.event_available;
      case 'NOTIFICATIONTYPE.LOW_PARTICIPANTS':
        return Icons.warning;
      case 'NOTIFICATIONTYPE.CAPACITY_FULL':
        return Icons.group;
      case 'NOTIFICATIONTYPE.RESERVATION_NEW':
      case 'NOTIFICATIONTYPE.RESERVATION_CONFIRM':
      case 'NOTIFICATIONTYPE.RESERVATION_CANCEL':
        return Icons.confirmation_number;
      default:
        return Icons.info_outline;
    }
  }
}

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
    BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _getNotificationIcon(NotificationModel notification) {
    return Icon(
      notification.getTypeIcon(),
      color: notification.getTypeColor(),
      size: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tüm bildirimleri okundu olarak işaretle
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            onPressed: () async {
              try {
                final batch = _firestore.batch();
                final snapshot = await _firestore.collection('notifications').get();
                for (var doc in snapshot.docs) {
                  batch.update(doc.reference, {'isRead': true});
                }
                await batch.commit();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tüm bildirimler okundu olarak işaretlendi')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            },
          ),
          // Test bildirimi oluşturma butonu
          IconButton(
            icon: const Icon(Icons.add_alert),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('notifications').add({
                  'title': 'Test Bildirimi',
                  'message': 'Bu bir test bildirimidir',
                  'type': 'info',
                  'createdAt': FieldValue.serverTimestamp(),
                  'isRead': false,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test bildirimi oluşturuldu')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('permission-denied')) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bildirimleri görmek için lütfen giriş yapın.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList() ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text('Henüz bildirim bulunmamaktadır'));
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: notifications.length,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getFontSize(context, 16),
              vertical: ResponsiveHelper.getFontSize(context, 8),
            ),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Bildirimi Sil'),
                      content: const Text('Bu bildirimi silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  _firestore.collection('notifications').doc(notification.id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bildirim silindi')),
                  );
                },
                child: ListTile(
                  leading: _getNotificationIcon(notification),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(notification.createdAt, locale: 'tr'),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 12),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Bildirimi Sil'),
                          content: const Text('Bu bildirimi silmek istediğinize emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );
                      if (confirm) {
                        await _firestore.collection('notifications').doc(notification.id).delete();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bildirim silindi')),
                          );
                        }
                      }
                    },
                  ),
                  tileColor: notification.isRead ? null : Colors.blue.shade50,
                  onTap: () async {
                    // Bildirimi okundu olarak işaretle
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notification.id)
                        .update({'isRead': true});

                    // Eğer bildirim bir tura aitse ve context hala geçerliyse
                    if (notification.tourId != null && mounted) {
                      try {
                        // Önce tur bilgilerini al
                        final tourDoc = await FirebaseFirestore.instance
                            .collection('trips')
                            .doc(notification.tourId)
                            .get();

                        if (tourDoc.exists) {
                          // Trip modelini oluştur
                          final data = tourDoc.data() as Map<String, dynamic>;
                          final trip = Trip.fromFirestore(tourDoc.id, data);
                          
                          // Tur detay sayfasına yönlendir
                          Navigator.of(context).pushNamed(
                            '/trip-detail',
                            arguments: trip,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tur bulunamadı')),
                          );
                        }
                      } catch (e) {
                        print('Tur detay yönlendirme hatası: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tur detayları yüklenirken hata oluştu')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}
