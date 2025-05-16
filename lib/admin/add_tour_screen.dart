import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../utils/responsive_helper.dart';

class AddTourScreen extends StatefulWidget {
  static const routeName = '/add-tour';

  @override
  State<AddTourScreen> createState() => _AddTourScreenState();
}

class _AddTourScreenState extends State<AddTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _durationController = TextEditingController(text: '1');
  final _capacityController = TextEditingController(text: '10');
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  List<String> _selectedCategories = [];
  
  // Sabit kategori listesi
  final List<String> _availableCategories = [
    'Doğa Turizmi',
    'Kültür Turizmi',
    'Macera Turizmi',
    'Eğitim Turizmi'
  ];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlangıç ve bitiş tarihlerini seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final trip = Trip(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        price: double.parse(_priceController.text),
        categories: _selectedCategories,
        imageUrl: _imageUrlController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        status: TripStatus.AVAILABLE,
        duration: int.parse(_durationController.text),
        capacity: int.parse(_capacityController.text),
      );

      await FirebaseFirestore.instance.collection('trips').doc(trip.id).set(trip.toFirestore());
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gezi başarıyla eklendi')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $error')),
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
          'Yeni Gezi Ekle',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 20)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Gezi Adı',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen gezi adını girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
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
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Konum',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen konum girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Süre ve Kapasite
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                decoration: const InputDecoration(
                                  labelText: 'Süre (Gün)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.timer),
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Süre gerekli';
                                  }
                                  if (int.tryParse(value) == null || int.parse(value) < 1) {
                                    return 'Geçerli bir süre girin';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _capacityController,
                                decoration: const InputDecoration(
                                  labelText: 'Kapasite',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.group),
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kapasite gerekli';
                                  }
                                  if (int.tryParse(value) == null || int.parse(value) < 1) {
                                    return 'Geçerli bir kapasite girin';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Fiyat (TL)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen fiyat girin';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Geçerli bir fiyat girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Resim URL',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.image),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitForm(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen resim URL girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Kategori seçimi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kategoriler', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: _availableCategories.map((category) {
                                  return CheckboxListTile(
                                    title: Text(category),
                                    value: _selectedCategories.contains(category),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedCategories.add(category);
                                        } else {
                                          _selectedCategories.remove(category);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        const SizedBox(height: 15),
                        // Kategoriler Seçimi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategoriler',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _availableCategories.map((category) {
                                return FilterChip(
                                  label: Text(category),
                                  selected: _selectedCategories.contains(category),
                                  selectedColor: Colors.blue.shade100,
                                  checkmarkColor: Colors.blue.shade900,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category);
                                      } else {
                                        _selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ListTile(
                          title: Text(
                            'Tarih Aralığı',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _startDate != null && _endDate != null
                                ? '${_startDate?.toString().split(' ')[0]} - ${_endDate?.toString().split(' ')[0]}'
                                : 'Tarih aralığı seçilmedi',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(Icons.date_range),
                          onTap: () async {
                            final DateTimeRange? dateRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: _startDate != null && _endDate != null
                                  ? DateTimeRange(start: _startDate!, end: _endDate!)
                                  : null,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.blue.shade900,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (dateRange != null) {
                              setState(() {
                                _startDate = dateRange.start;
                                _endDate = dateRange.end;
                              });
                            }
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 20)),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'GEZİ EKLE',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getFontSize(context, 16),
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _durationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
}
