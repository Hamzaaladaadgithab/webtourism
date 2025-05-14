import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';

class MakeReservationScreen extends StatefulWidget {
  final Trip trip;
  
  const MakeReservationScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<MakeReservationScreen> createState() => _MakeReservationScreenState();
}

class _MakeReservationScreenState extends State<MakeReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  int _numberOfPeople = 1;
  bool _isLoading = false;
  
  final ReservationService _reservationService = ReservationService();
  final AuthService _authService = AuthService();

  double get _totalPrice => widget.trip.price * _numberOfPeople;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userData.exists) {
          setState(() {
            _nameController.text = userData.data()?['name'] ?? '';
            _phoneController.text = userData.data()?['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _makeReservation() async {
    if (!_formKey.currentState!.validate()) return;

    // Ödeme formunu göster
    final paymentResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ödeme Bilgileri',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 20),
              fontWeight: FontWeight.bold
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Kart Numarası',
                    hintText: '1234 5678 9012 3456',
                    labelStyle: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16)
                    ),
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14)
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Son Kullanma',
                          hintText: 'AA/YY',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 16)
                          ),
                          hintStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14)
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 16)
                          ),
                          hintStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14)
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'İptal',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16)
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Ödemeyi Tamamla',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16)
                ),
              ),
            ),
          ],
        );
      },
    );

    if (paymentResult != true) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('Kullanıcı girişi yapılmamış');

      await _reservationService.createReservation(
        tripId: widget.trip.id,
        tripTitle: widget.trip.title,
        startDate: _startDate,
        endDate: _endDate,
        numberOfPeople: _numberOfPeople,
        totalPrice: _totalPrice,
        userName: _nameController.text,
        userPhone: _phoneController.text,
        userId: currentUser.uid,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon başarıyla oluşturuldu!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.trip.title} - Rezervasyon',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getPadding(context),
                child: Container(
                  width: ResponsiveHelper.getMaxWidth(context) * 0.7,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tur Bilgileri
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.trip.title,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 24),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.getFontSize(context, 8)),
                                Text(
                                  'Fiyat: ₺${widget.trip.price}',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),

                        // Kişisel Bilgiler
                        Text(
                          'Kişisel Bilgiler',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Ad Soyad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 16),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ad Soyad gerekli';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Telefon',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 16),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Telefon numarası gerekli';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),

                        // Tarih Seçimi
                        Text(
                          'Tarih Seçimi',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _selectDateRange(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.blue),
                                  SizedBox(width: ResponsiveHelper.getFontSize(context, 12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Başlangıç',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getFontSize(context, 4)),
                                        Text(
                                          DateFormat('d MMMM y', 'tr_TR').format(_startDate),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, color: Colors.grey),
                                  SizedBox(width: ResponsiveHelper.getFontSize(context, 12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Bitiş',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getFontSize(context, 4)),
                                        Text(
                                          DateFormat('d MMMM y', 'tr_TR').format(_endDate),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),

                        // Kişi Sayısı
                        Text(
                          'Kişi Sayısı',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Kişi Sayısı',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: _numberOfPeople > 1
                                          ? () => setState(() => _numberOfPeople--)
                                          : null,
                                      color: _numberOfPeople > 1 ? Colors.blue : Colors.grey,
                                    ),
                                    Text(
                                      '$_numberOfPeople',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => setState(() => _numberOfPeople++),
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),

                        // Notlar
                        Text(
                          'Notlar',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Eklemek istediğiniz notlar',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 16),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 32)),

                        // Toplam Fiyat
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Toplam Tutar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${_totalPrice.toStringAsFixed(2)} TL',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),

                        // Rezervasyon Butonu
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _makeReservation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Rezervasyonu Onayla - ${_totalPrice.toStringAsFixed(2)} TL',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        );
      } 
    }
  
