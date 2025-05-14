import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/category_item.dart';
import '../models/category.dart';
import '../utils/responsive_helper.dart';

class CategoriesScreen extends StatefulWidget {
  final bool showAppBar;

  const CategoriesScreen({this.showAppBar = true});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DataService _dataService = DataService();


  @override   
  void initState() {
    super.initState();
  }

  // Ekran genişliğine göre grid kolonlarını hesapla
  int _calculateCrossAxisCount(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return 4; // Desktop: 4 kolon
    } else if (ResponsiveHelper.isTablet(context)) {
      return 3; // Tablet: 3 kolon
    }
    return 2; // Mobil: 2 kolon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'Kategoriler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.blue.shade900,
              elevation: 0,
              centerTitle: true,
            )
          : null,
      body: StreamBuilder<List<Category>>(
        stream: _dataService.getCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, 
                       size: ResponsiveHelper.getFontSize(context, 48), 
                       color: Colors.red),
                  SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                  Text(
                    'Veriler yüklenirken bir hata oluştu',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16)
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, 
                       size: ResponsiveHelper.getFontSize(context, 48), 
                       color: Colors.grey),
                  SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                  Text(
                    'Henüz kategori eklenmemiş',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16)
                    ),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data!;
          final crossAxisCount = _calculateCrossAxisCount(context);
          
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