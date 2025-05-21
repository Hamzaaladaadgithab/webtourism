import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/trip.dart';
import '../models/admin_user.dart';

class EditTourScreen extends StatefulWidget {
  final Trip trip;

  const EditTourScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<EditTourScreen> createState() => _EditTourScreenState();
}

class _EditTourScreenState extends State<EditTourScreen> {
  final AdminService _adminService = AdminService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  List<String> _selectedCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;

  // Her kategori için simge ve renk tanımları
  final Map<String, Map<String, dynamic>> categoryDetails = {
    'Doğa & Ekoturizm': {
      'icon': '🏞️',
      'color': Color(0xFF4CAF50),
      'description': 'Dağ, yayla, yürüyüş, doğal parklar, kamp',
    },
    'Kültür & Tarih': {
      'icon': '🏛️',
      'color': Color(0xFF9C27B0),
      'description': 'Müzeler, tarihi yapılar, şehir turları',
    },
    'Deniz & Tatil': {
      'icon': '🏖️',
      'color': Color(0xFF1976D2),
      'description': 'Plajlar, yaz tatili, resortlar, yüzme',
    },
    'Macera & Spor': {
      'icon': '🧗',
      'color': Color(0xFFF57C00),
      'description': 'Rafting, paraşüt, safari, bisiklet',
    },
    'Yeme & İçme': {
      'icon': '🍽️',
      'color': Color(0xFFE91E63),
      'description': 'Gurme turları, yöresel yemek deneyimi',
    },
    'Festival & Etkinlik': {
      'icon': '🎭',
      'color': Color(0xFF673AB7),
      'description': 'Konserler, yerel festivaller, gösteriler',
    },
    'Alışveriş Turları': {
      'icon': '🛍️',
      'color': Color(0xFF795548),
      'description': 'Outlet merkezleri, pazarlar, hediyelik eşyalar',
    },
    'İnanç Turizmi': {
      'icon': '🕌',
      'color': Color(0xFF607D8B),
      'description': 'Dini yapılar, hac turları, camiler',
    },
    'Sağlık & Termal Turizm': {
      'icon': '🏥',
      'color': Color(0xFF009688),
      'description': 'Spa, kaplıca, sağlık merkezleri',
    },
    'Eğitim & Dil Turları': {
      'icon': '🏫',
      'color': Color(0xFFFF5722),
      'description': 'Dil okulları, kültür değişim programları',
    },
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trip.title);
    _descriptionController = TextEditingController(text: widget.trip.description);
    _locationController = TextEditingController(text: widget.trip.location);
    _priceController = TextEditingController(text: widget.trip.price.toString());
    _imageUrlController = TextEditingController(text: widget.trip.imageUrl);

    _selectedCategories = List<String>.from(widget.trip.categories);
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateTour() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedTrip = Trip(
        createdAt: widget.trip.createdAt,
        id: widget.trip.id,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        categories: _selectedCategories,
        startDate: _startDate!,
        endDate: _endDate!,
        status: widget.trip.status,
      );

      await _adminService.updateTrip(updatedTrip);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gezi başarıyla güncellendi'),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce başlangıç tarihini seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turu Düzenle'),
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<AdminUser?>(
        future: _adminService.getCurrentAdmin(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bu sayfaya erişim için admin yetkisi gereklidir.'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Gezi Düzenle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Lütfen bir başlık girin' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Lütfen bir açıklama girin' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Konum',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Lütfen bir konum girin' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Lütfen bir fiyat girin';
                        if (double.tryParse(value) == null) return 'Geçerli bir sayı girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Resim URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Lütfen resim URL\'si girin' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Başlangıç Tarihi'),
                            subtitle: Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Seçilmedi',
                            ),
                            onTap: _selectStartDate,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Bitiş Tarihi'),
                            subtitle: Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Seçilmedi',
                            ),
                            onTap: _selectEndDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categoryDetails.entries.map((entry) {
                        final category = entry.key;
                        final details = entry.value;
                        final isSelected = _selectedCategories.contains(category);
                        return FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                details['icon'] as String,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          tooltip: details['description'] as String,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: (details['color'] as Color).withOpacity(0.2),
                          checkmarkColor: details['color'] as Color,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading ? null : _updateTour,
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Güncelle', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
    );
  }
}
