import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/admin_service.dart';

class EditTourScreen extends StatefulWidget {
  final Trip trip;

  const EditTourScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<EditTourScreen> createState() => _EditTourScreenState();
}

class _EditTourScreenState extends State<EditTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _imageUrlController;

  String _selectedType = '';
  String _selectedSeason = '';
  List<String> _selectedCategories = [];
  List<String> _selectedActivities = [];
  bool _isFamilyFriendly = false;
  int _capacity = 0;
  String _program = '';

  @override
  void initState() {
    super.initState();
    // Mevcut verileri controller'lara yükle
    _titleController.text = widget.trip.title;
    _descriptionController.text = widget.trip.description;
    _locationController.text = widget.trip.location;
    _priceController.text = widget.trip.price.toString();
    _durationController.text = widget.trip.duration.toString();
    _imageUrlController.text = widget.trip.imageUrl;
    _selectedCategories = List<String>.from(widget.trip.categories);
    _selectedActivities = List<String>.from(widget.trip.activities);
    _selectedSeason = widget.trip.season;
    _selectedType = widget.trip.type;
    _isFamilyFriendly = widget.trip.isFamilyFriendly;
    _capacity = widget.trip.capacity;
    _program = widget.trip.program;
    _titleController = TextEditingController(text: widget.trip.title);
    _descriptionController = TextEditingController(text: widget.trip.description);
    _locationController = TextEditingController(text: widget.trip.location);
    _priceController = TextEditingController(text: widget.trip.price.toString());
    _durationController = TextEditingController(text: widget.trip.duration.toString());
    _imageUrlController = TextEditingController(text: widget.trip.imageUrl);

    _selectedType = widget.trip.type;
    _selectedSeason = widget.trip.season;
    _selectedCategories = List<String>.from(widget.trip.categories);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateTour() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedTrip = Trip(
        id: widget.trip.id,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        price: double.parse(_priceController.text),
        duration: int.parse(_durationController.text),
        type: _selectedType,
        season: _selectedSeason,
        categories: _selectedCategories,
        imageUrl: _imageUrlController.text,
        program: widget.trip.program,
        activities: widget.trip.activities,
        startDate: widget.trip.startDate,
        endDate: widget.trip.endDate,
        capacity: widget.trip.capacity,
        status: widget.trip.status,
        isFamilyFriendly: widget.trip.isFamilyFriendly,
      );

      await _adminService.updateTrip(updatedTrip);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tur başarıyla güncellendi'),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tur Düzenle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tur Adı',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen tur adını girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen açıklama girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Konum',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen konum girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (TL)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen fiyat girin';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Süre (Gün)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen süre girin';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _updateTour(),
                      decoration: const InputDecoration(
                        labelText: 'Resim URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tur Tipi',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'individual', child: Text('Bireysel')),
                        DropdownMenuItem(value: 'group', child: Text('Grup')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen tur tipi seçin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSeason,
                      decoration: const InputDecoration(
                        labelText: 'Sezon',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'summer', child: Text('Yaz')),
                        DropdownMenuItem(value: 'winter', child: Text('Kış')),
                        DropdownMenuItem(value: 'spring', child: Text('İlkbahar')),
                        DropdownMenuItem(value: 'autumn', child: Text('Sonbahar')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSeason = value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen sezon seçin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kategoriler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Doğa'),
                          selected: _selectedCategories.contains('nature'),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add('nature');
                              } else {
                                _selectedCategories.remove('nature');
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Tarih'),
                          selected: _selectedCategories.contains('history'),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add('history');
                              } else {
                                _selectedCategories.remove('history');
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Kültür'),
                          selected: _selectedCategories.contains('culture'),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add('culture');
                              } else {
                                _selectedCategories.remove('culture');
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Macera'),
                          selected: _selectedCategories.contains('adventure'),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add('adventure');
                              } else {
                                _selectedCategories.remove('adventure');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updateTour,
                      child: const Text('Güncelle'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
