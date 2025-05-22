import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Grafik periyodu seçenekleri
enum ChartPeriod { 
  all,
  last7days,
  last30days,
  thisMonth,
  lastMonth,
  thisYear,
  custom
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  static const routeName = '/statistics';

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Veri listeleri
  final List<Map<String, dynamic>> _trips = [];
  final List<Map<String, dynamic>> _reservations = [];
  
  // Yükleme durumu
  bool _isLoading = false;
  
  // Tarih aralığı seçimi
  ChartPeriod _selectedPeriod = ChartPeriod.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  // Tarih seçiciler için controller'lar
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrips(); // Başlangıçta verileri yükle
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // Firestore'dan turları ve rezervasyonları yükleme fonksiyonu
  Future<void> _loadTrips() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      DateTime endDate = DateTime.now();
      DateTime startDate;

      // Seçilen periyoda göre başlangıç tarihini belirle
      switch (_selectedPeriod) {
        case ChartPeriod.last7days:
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case ChartPeriod.last30days:
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case ChartPeriod.thisMonth:
          startDate = DateTime(endDate.year, endDate.month, 1);
          break;
        case ChartPeriod.lastMonth:
          final lastMonth = DateTime(endDate.year, endDate.month - 1);
          startDate = DateTime(lastMonth.year, lastMonth.month, 1);
          endDate = DateTime(endDate.year, endDate.month, 0);
          break;
        case ChartPeriod.thisYear:
          startDate = DateTime(endDate.year, 1, 1);
          break;
        case ChartPeriod.custom:
          if (_customStartDate == null || _customEndDate == null) {
            setState(() => _isLoading = false);
            return;
          }
          startDate = _customStartDate!;
          endDate = _customEndDate!;
          break;
        case ChartPeriod.all:
          startDate = DateTime(2020);
          break;
      }

      print('Tarih Aralığı: ${startDate.toString()} - ${endDate.toString()}');

      // Tüm turları al
      print('Tarih Aralığı: $startDate - $endDate');
      
      QuerySnapshot<Map<String, dynamic>> tripsSnapshot;
      try {
        // Firestore'da startDate ile filtreleme yap
        tripsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();

        print('\n=== TÜM TURLARIN DURUMU ===');
        print('Toplam tur sayısı: ${tripsSnapshot.docs.length}');
      } catch (e, stackTrace) {
        print('Turları getirirken hata oluştu: $e');
        print('Hata detayı: $stackTrace');
        rethrow; // Hatayı yukarı seviyeye ilet
      }

      // Bellek üzerinde filtreleme yap
      final filteredTrips = tripsSnapshot.docs.where((doc) {
        try {
          final data = doc.data();
          
          final tripStartDate = (data['startDate'] as Timestamp?)?.toDate();
          final tripEndDate = (data['endDate'] as Timestamp?)?.toDate();
          final isDeleted = data['isDeleted'] as bool? ?? false;
          final status = data['status'] as String? ?? 'AVAILABLE';
          final normalizedStatus = status.replaceAll('TripStatus.', '');
          
          // Debug bilgileri
          print('\nTur ID: ${doc.id}');
          print('- Başlangıç: $tripStartDate');
          print('- Bitiş: $tripEndDate');
          print('- Status: $status (normalized: $normalizedStatus)');
          print('- Silinmiş: $isDeleted');
          
          // Temel kontroller
          if (tripStartDate == null || tripEndDate == null) {
            print('${doc.id} - Tarih bilgisi eksik');
            return false;
          }

          if (isDeleted) {
            print('${doc.id} - Silinmiş tur');
            return false;
          }

          if (normalizedStatus != 'AVAILABLE') {
            print('❌ Geçersiz durum: $status');
            return false;
          }

          // Tarih kontrolleri
          final isStartDateInRange = tripStartDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                                    tripStartDate.isBefore(endDate.add(const Duration(days: 1)));
          
          final isEndDateInRange = tripEndDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                                  tripEndDate.isBefore(endDate.add(const Duration(days: 1)));
          
          final isSpanningRange = tripStartDate.isBefore(startDate) && tripEndDate.isAfter(endDate);
          
          final isInDateRange = isStartDateInRange || isEndDateInRange || isSpanningRange;
          
          if (!isInDateRange) {
            print('${doc.id} - Tarih aralığı dışında:');
            print('- Tur tarihleri: $tripStartDate - $tripEndDate');
            print('- Seçili aralık: $startDate - $endDate');
            return false;
          }
          
          print('${doc.id} - Tur kabul edildi');
          return true;
        } catch (e, stackTrace) {
          print('Tur verisi işlenirken hata: $e');
          print('Hata detayı: $stackTrace');
          return false;
        }
      }).toList();

      // Rezervasyonları al
      QuerySnapshot<Map<String, dynamic>> reservationsSnapshot;
      try {
        // Firestore'da status ve tripStartDate ile filtreleme yap
        reservationsSnapshot = await FirebaseFirestore.instance
            .collection('reservations')
            .where('status', isEqualTo: 'ReservationStatus.confirmed')
            .where('tripStartDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('tripStartDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();
      } catch (e, stackTrace) {
        print('Rezervasyonları getirirken hata oluştu: $e');
        print('Hata detayı: $stackTrace');
        rethrow; // Hatayı yukarı seviyeye ilet
      }

      // Rezervasyonları bellek üzerinde filtrele
      final filteredReservations = reservationsSnapshot.docs.where((doc) {
        try {
          final data = doc.data();
          final status = data['status'] as String?;
          final reservationStartDate = (data['tripStartDate'] as Timestamp?)?.toDate();
          final reservationEndDate = (data['tripEndDate'] as Timestamp?)?.toDate();
          
          // Debug bilgileri
          print('\nRezervasyon ID: ${doc.id}');
          print('- Status: $status');
          print('- Başlangıç: $reservationStartDate');
          print('- Bitiş: $reservationEndDate');
          
          // Önce status kontrolü
          if (status != 'ReservationStatus.confirmed') {
            print('${doc.id} - Geçersiz durum: $status');
            return false;
          }
          
          if (reservationStartDate == null || reservationEndDate == null) {
            print('${doc.id} - Tarih bilgisi eksik');
            return false;
          }

          // Tarih kontrolleri
          final isStartDateInRange = reservationStartDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                                    reservationStartDate.isBefore(endDate.add(const Duration(days: 1)));
          
          final isEndDateInRange = reservationEndDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                                  reservationEndDate.isBefore(endDate.add(const Duration(days: 1)));
          
          final isSpanningRange = reservationStartDate.isBefore(startDate) && reservationEndDate.isAfter(endDate);
          
          final isInDateRange = isStartDateInRange || isEndDateInRange || isSpanningRange;
          
          if (!isInDateRange) {
            print('${doc.id} - Tarih aralığı dışında:');
            print('- Rezervasyon tarihleri: $reservationStartDate - $reservationEndDate');
            print('- Seçili aralık: $startDate - $endDate');
            return false;
          }
          
          print('${doc.id} - Rezervasyon kabul edildi');
          return true;
        } catch (e, stackTrace) {
          print('Rezervasyon verisi işlenirken hata: $e');
          print('Hata detayı: $stackTrace');
          return false;
        }
        

      }).toList();

      if (!mounted) return;

      setState(() {
        _trips
          ..clear()
          ..addAll(filteredTrips.map((doc) => {...doc.data(), 'id': doc.id}));
        _reservations
          ..clear()
          ..addAll(filteredReservations.map((doc) => {...doc.data(), 'id': doc.id}));
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata oluştu: $error')),
        );
      }
    }
  }

  // Tarih seçme fonksiyonu
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        controller.text = formattedDate;
        
        if (controller == _startDateController) {
          _customStartDate = picked;
        } else {
          _customEndDate = picked;
        }
      });

      if (_customStartDate != null && _customEndDate != null) {
        _loadTrips();
      }
    }
  }

  // Tarih aralığı seçici widget'ı
  Widget _buildPeriodSelector() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tarih Aralığı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tümü'),
                  selected: _selectedPeriod == ChartPeriod.all,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = ChartPeriod.all;
                        _customStartDate = null;
                        _customEndDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });
                      _loadTrips();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Son 7 Gün'),
                  selected: _selectedPeriod == ChartPeriod.last7days,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = ChartPeriod.last7days;
                        _customStartDate = null;
                        _customEndDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });
                      _loadTrips();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Son 30 Gün'),
                  selected: _selectedPeriod == ChartPeriod.last30days,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = ChartPeriod.last30days;
                        _customStartDate = null;
                        _customEndDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });
                      _loadTrips();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Bu Ay'),
                  selected: _selectedPeriod == ChartPeriod.thisMonth,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = ChartPeriod.thisMonth;
                        _customStartDate = null;
                        _customEndDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });
                      _loadTrips();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Geçen Ay'),
                  selected: _selectedPeriod == ChartPeriod.lastMonth,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = ChartPeriod.lastMonth;
                        _customStartDate = null;
                        _customEndDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });
                      _loadTrips();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Bu Yıl'),
                  selected: _selectedPeriod == ChartPeriod.thisYear,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = ChartPeriod.thisYear;
                        _customStartDate = null;
                        _customEndDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });
                      _loadTrips();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Özel Tarih'),
                  selected: _selectedPeriod == ChartPeriod.custom,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = ChartPeriod.custom);
                    }
                  },
                ),
              ],
            ),
            if (_selectedPeriod == ChartPeriod.custom) ...[              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Başlangıç Tarihi',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_startDateController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: 'Bitiş Tarihi',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // İstatistik kartı widget'ı
  Widget _buildStatisticsCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Genel bakış bölümü widget'ı
  Widget _buildOverviewSection() {
    final totalTrips = _trips.length;
    final totalReservations = _reservations.length;
    final completedTrips = _trips.where((trip) => 
      trip['endDate'] != null && 
      (trip['endDate'] as Timestamp).toDate().isBefore(DateTime.now())
    ).length;

    return Wrap(
      children: [
        _buildStatisticsCard(
          'Toplam Tur',
          totalTrips.toString(),
          Icons.map,
        ),
        _buildStatisticsCard(
          'Toplam Rezervasyon',
          totalReservations.toString(),
          Icons.book_online,
        ),
        _buildStatisticsCard(
          'Tamamlanan Turlar',
          completedTrips.toString(),
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  // Kategori dağılımı pasta grafiği widget'ı
  Widget _buildCategoryPieChart() {
    if (_trips.isEmpty) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Kategori verisi bulunamadı')),
      ));
    }

    Map<String, int> categoryCounts = {};
    for (var trip in _trips) {
      List<String> categories = List<String>.from(trip['categories'] ?? []);
      int participantCount = (trip['participantCount'] as num?)?.toInt() ?? 0;
      for (var category in categories) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + participantCount;
      }
    }

    if (categoryCounts.isEmpty) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Kategori verisi bulunamadı')),
      ));
    }

    final List<Color> colors = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
    ];

    final total = categoryCounts.values.fold<int>(0, (sum, val) => sum + val);
    final List<PieChartSectionData> sections = [];

    int colorIndex = 0;
    categoryCounts.forEach((category, count) {
      final double percentage = (count / total) * 100;
      sections.add(PieChartSectionData(
        color: colors[colorIndex % colors.length],
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      colorIndex++;
    });

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Kategori Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < categoryCounts.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: colors[i % colors.length],
                      ),
                      const SizedBox(width: 4),
                      Text(categoryCounts.keys.elementAt(i)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Doluluk oranı widget'ı
  Widget _buildOccupancyCard() {
    if (_trips.isEmpty) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Doluluk verisi bulunamadı')),
        ),
      );
    }

    // Güvenli sayaçlar ve listeler
    int totalCapacity = 0;
    int totalParticipants = 0;
    List<Map<String, dynamic>> lowOccupancyTrips = [];
    List<double> occupancyRates = [];

    // Güvenli dönüşüm yardımcı fonksiyonları
    int safeToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double calculateOccupancyRate(int capacity, int participants) {
      if (capacity <= 0) return 0.0;
      return (participants / capacity * 100).clamp(0.0, 100.0);
    }

    for (var trip in _trips) {
      int capacity = safeToInt(trip['capacity']);
      int participants = safeToInt(trip['participantCount']);
      
      if (capacity > 0) {
        totalCapacity += capacity;
        totalParticipants += participants;
        
        double occupancyRate = calculateOccupancyRate(capacity, participants);
        occupancyRates.add(occupancyRate);
        
        if (occupancyRate < 50) {
          lowOccupancyTrips.add(trip);
        }
      }
    }

    double averageOccupancyRate = occupancyRates.isEmpty ? 0 : occupancyRates.reduce((a, b) => a + b) / occupancyRates.length;
    double totalOccupancyRate = calculateOccupancyRate(totalCapacity, totalParticipants);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doluluk Oranları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPercentageBar('Toplam Doluluk', totalOccupancyRate),
            const SizedBox(height: 8),
            _buildPercentageBar('Ortalama Doluluk', averageOccupancyRate),
            const SizedBox(height: 16),
            const Text(
              'Düşük Doluluk Oranına Sahip Turlar (<%50)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (lowOccupancyTrips.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Düşük doluluk oranına sahip tur bulunmamaktadır.'),
              )
            else
              Column(
                children: lowOccupancyTrips.map((trip) {
                  int capacity = safeToInt(trip['capacity']);
                  int participants = safeToInt(trip['participantCount']);
                  double occupancyRate = calculateOccupancyRate(capacity, participants);
                  
                  return ListTile(
                    title: Text(trip['title'] ?? 'İsimsiz Tur'),
                    subtitle: Text('Doluluk: ${occupancyRate.toStringAsFixed(1)}%'),
                    trailing: Text('$participants/$capacity'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Rezervasyon durumları widget'ı
  Widget _buildReservationStatusCard() {
    if (_reservations.isEmpty) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Rezervasyon verisi bulunamadı')),
        ),
      );
    }

    // Rezervasyon durumlarını hesapla
    Map<String, int> statusCounts = {
      'pending': 0,
      'confirmed': 0,
      'cancelled': 0,
      'completed': 0,
    };

    for (var reservation in _reservations) {
      String status = (reservation['status'] ?? '').toString().toLowerCase();
      if (status.contains('pending')) statusCounts['pending'] = (statusCounts['pending'] ?? 0) + 1;
      if (status.contains('confirmed')) statusCounts['confirmed'] = (statusCounts['confirmed'] ?? 0) + 1;
      if (status.contains('cancelled')) statusCounts['cancelled'] = (statusCounts['cancelled'] ?? 0) + 1;
      if (status.contains('completed')) statusCounts['completed'] = (statusCounts['completed'] ?? 0) + 1;
    }

    // Güvenli toplam hesaplama
    int total = statusCounts.values.fold(0, (sum, count) => sum + (count ?? 0));
    total = total > 0 ? total : 1; // Sıfıra bölmeyi önle

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rezervasyon Durumları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusBar('Onay Bekleyen', statusCounts['pending']!, total, Colors.orange),
            const SizedBox(height: 8),
            _buildStatusBar('Onaylanmış', statusCounts['confirmed']!, total, Colors.green),
            const SizedBox(height: 8),
            _buildStatusBar('İptal Edilmiş', statusCounts['cancelled']!, total, Colors.red),
            const SizedBox(height: 8),
            _buildStatusBar('Tamamlanmış', statusCounts['completed']!, total, Colors.blue),
          ],
        ),
      ),
    );
  }

  // Gelir analizi widget'ı
  Widget _buildRevenueAnalysisCard() {
    if (_trips.isEmpty) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Gelir verisi bulunamadı')),
        ),
      );
    }

    // Toplam ve ortalama gelirleri hesapla
    double totalRevenue = 0;
    Map<String, double> categoryRevenues = {};
    Map<String, int> categoryParticipants = {};

    for (var trip in _trips) {
      double price = (trip['price'] as num?)?.toDouble() ?? 0;
      int participants = (trip['participantCount'] as num?)?.toInt() ?? 0;
      double tripRevenue = price * participants;
      totalRevenue += tripRevenue;

      // Kategori bazında gelir analizi
      List<String> categories = List<String>.from(trip['categories'] ?? []);
      for (var category in categories) {
        categoryRevenues[category] = (categoryRevenues[category] ?? 0) + tripRevenue;
        categoryParticipants[category] = (categoryParticipants[category] ?? 0) + participants;
      }
    }

    // En yüksek gelirli kategorileri sırala
    var sortedCategories = categoryRevenues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gelir Analizi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toplam: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(totalRevenue)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Kategori Bazında Gelir Dağılımı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sortedCategories.take(5).map((entry) {
              double percentage = (entry.value / totalRevenue) * 100;
              int participants = categoryParticipants[entry.key] ?? 0;
              double avgRevenuePerParticipant = participants > 0 ? 
                  entry.value / participants : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(entry.value),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (percentage.isFinite && percentage >= 0) ? percentage / 100 : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Katılımcı: $participants',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          'Kişi Başı: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(avgRevenuePerParticipant)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Katılımcı istatistikleri widget'ı
  Widget _buildParticipantChart() {
    if (_trips.isEmpty) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Katılımcı verisi bulunamadı')),
        ),
      );
    }

    int totalParticipants = _trips.fold(
      0,
      (sum, trip) => sum + ((trip['participantCount'] as num?)?.toInt() ?? 0),
    );

    double averageParticipants = _trips.isEmpty
        ? 0
        : totalParticipants / _trips.length;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Katılımcı İstatistikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Toplam Tur: ${_trips.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Toplam Katılımcı: $totalParticipants',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Ortalama Katılımcı: ${averageParticipants.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Durum çubuğu widget'ı
  Widget _buildStatusBar(String label, int count, int total, Color color) {
    // Güvenli değer kontrolleri
    final safeCount = count.clamp(0, double.maxFinite.toInt());
    final safeTotal = total <= 0 ? 1 : total;
    
    // Güvenli yüzde hesaplama
    final percentage = (safeCount / safeTotal * 100).clamp(0.0, 100.0);
    final progressValue = (percentage / 100).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$label ($safeCount)',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  // Yüzde çubuğu widget'ı
  Widget _buildPercentageBar(String label, double value) {
    // Değeri 0-100 aralığına sınırla
    final clampedValue = value.clamp(0.0, 100.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '${clampedValue.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: clampedValue / 100,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
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
          'İstatistikler',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTrips,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('İstatistikler Hakkında'),
                  content: const Text(
                    'Bu ekran, turlarınızın performansını analiz etmenize yardımcı olur. '
                    'Katılımcı sayıları, kategoriler ve zaman bazlı analizler sunarak '
                    'işletmenizin gelişimini takip etmenizi sağlar.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTrips,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),
                    _buildOverviewSection(),
                    _buildRevenueAnalysisCard(),
                    _buildOccupancyCard(),
                    _buildReservationStatusCard(),
                    _buildCategoryPieChart(),
                    _buildParticipantChart(),
                  ],
                ),
              ),
            ),
    );
  }
}