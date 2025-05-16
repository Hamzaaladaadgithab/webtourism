import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/admin_service.dart';
import '../utils/responsive_helper.dart';

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
  late TextEditingController _imageUrlController;

  List<String> _selectedCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;

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
        id: widget.trip.id,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        price: double.parse(_priceController.text),

        categories: _selectedCategories,
        imageUrl: _imageUrlController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        status: widget.trip.status,
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
        title: Text(
          'Gezi Düzenle',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: ResponsiveHelper.getPadding(context),
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
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getFontSize(context, 16),
                          vertical: ResponsiveHelper.getFontSize(context, 12),
                        ),
                        border: const OutlineInputBorder(),
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
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Başlangıç Tarihi'),
                            subtitle: Text(_startDate == null
                                ? 'Seçilmedi'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2025),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Bitiş Tarihi'),
                            subtitle: Text(_endDate == null
                                ? 'Seçilmedi'
                                : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? (_startDate?.add(const Duration(days: 1)) ?? DateTime.now()),
                                firstDate: _startDate ?? DateTime.now(),
                                lastDate: DateTime(2025),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
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
                    Text(
                      'Kategoriler',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
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
