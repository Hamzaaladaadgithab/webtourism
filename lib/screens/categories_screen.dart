import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/category_item.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DataService _dataService = DataService();
  bool _isLoading = true;

  // Ekran boyutları için sabitler
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  @override
  void initState() {
    super.initState();
    _setupCategoriesStream();
  }

  void _setupCategoriesStream() {
    _dataService.getCategoriesStream().listen((categories) {
      setState(() {
        _isLoading = false;
      });
    }, onError: (e) {
      print('Kategoriler dinlenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Ekran genişliğine göre grid kolonlarını hesapla
  int _calculateCrossAxisCount(double width) {
    if (width >= desktopBreakpoint) {
      return 3; // Desktop: 3 kolon
    } else if (width >= tabletBreakpoint) {
      return 2; // Tablet: 2 kolon
    }
    return 1; // Mobil: 1 kolon
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: _dataService.getCategoriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Kategori bulunamadı'));
        }

        final categories = snapshot.data!;
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = _calculateCrossAxisCount(screenWidth);
        
        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1600),
            padding: EdgeInsets.zero, // Dış padding'i kaldırdık
            child: GridView.builder(
              padding: EdgeInsets.all(40), // İç padding'i artırdık
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.3,
                crossAxisSpacing: 40,
                mainAxisSpacing: 40,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryItem(
                  category.id,
                  category.title,
                  category.imageUrl,
                );
              },
            ),
          ),
        );
      },
    );
  }
}