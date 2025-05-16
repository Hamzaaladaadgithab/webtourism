import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import 'category_trips_screen.dart';

class CategoriesScreen extends StatelessWidget {
  static const routeName = '/categories';

  final bool showAppBar;

  const CategoriesScreen({super.key, this.showAppBar = true});

  // Her kategori için simge ve renk tanımları
  final Map<String, Map<String, dynamic>> categoryDetails = const {
    'Doğa Turizmi': {
      'icon': Icons.landscape,
      'color': Color(0xFF4CAF50),
      'description': 'Doğanın güzelliğini keşfedin',
    },
    'Kültür Turizmi': {
      'icon': Icons.museum,
      'color': Color(0xFF9C27B0),
      'description': 'Tarihi ve kültürel deneyimler',
    },
    'Macera Turizmi': {
      'icon': Icons.terrain,
      'color': Color(0xFFF57C00),
      'description': 'Heyecan dolu aktiviteler',
    },
    'Eğitim Turizmi': {
      'icon': Icons.school,
      'color': Color(0xFF1976D2),
      'description': 'Öğrenerek seyahat edin',
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final crossAxisCount = isDesktop ? 2 : 1;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Kategoriler'),
              backgroundColor: Colors.blue.shade900,
              elevation: 0,
            )
          : null,
      body: GridView.builder(
        padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isDesktop ? 2 : 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categoryDetails.length,
        itemBuilder: (context, index) {
          final categoryName = categoryDetails.keys.elementAt(index);
          final details = categoryDetails[categoryName]!;

          return Card(
            elevation: 4,
            margin: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  CategoryTripsScreen.routeName,
                  arguments: {
                    'category': categoryName,
                    'color': categoryDetails[categoryName]!['color'],
                    'icon': categoryDetails[categoryName]!['icon'],
                    'description': categoryDetails[categoryName]!['description'],
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      details['icon'] as IconData,
                      size: ResponsiveHelper.getFontSize(context, 48),
                      color: details['color'] as Color,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details['description'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 14),
                      ),
                    ),
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