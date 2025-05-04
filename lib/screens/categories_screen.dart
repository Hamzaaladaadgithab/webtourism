import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/category_item.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';

class CategoriesScreen extends StatefulWidget {
  final bool showAppBar;

  const CategoriesScreen({this.showAppBar = true});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DataService _dataService = DataService();


  // Ekran boyutları için sabitler
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  @override
  void initState() {
    super.initState();
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          'GEZİ KATEGORİLERİ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

      ) : null,
      drawer: AppDrawer(),
      body: StreamBuilder<List<Category>>(
        stream: _dataService.getCategoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Kategori bulunamadı'));
          }

          final categories = snapshot.data!;
          final crossAxisCount = _calculateCrossAxisCount(screenWidth);
          
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1600),
              padding: EdgeInsets.zero,
              child: GridView.builder(
                padding: EdgeInsets.all(40),
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
      ),
    );
    
  }
}