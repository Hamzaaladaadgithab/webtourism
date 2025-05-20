import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import 'category_trips_screen.dart';

class CategoriesScreen extends StatelessWidget {
  static const routeName = '/categories';

  final bool showAppBar;

  const CategoriesScreen({super.key, this.showAppBar = true});

  // Her kategori için simge ve renk tanımları
  final Map<String, Map<String, dynamic>> categoryDetails = const {
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
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final crossAxisCount = isDesktop ? 3 : 2;

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
          childAspectRatio: isDesktop ? 1.2 : 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categoryDetails.length,
        itemBuilder: (context, index) {
          final categoryName = categoryDetails.keys.elementAt(index);
          final details = categoryDetails[categoryName]!;
          final color = details['color'] as Color;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 8,
              shadowColor: color.withOpacity(0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    CategoryTripsScreen.routeName,
                    arguments: {
                      'category': categoryName,
                      'color': color,
                      'icon': details['icon'],
                      'description': details['description'],
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Büyük yarı saydam emoji arka planda
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Text(
                          details['icon'] as String,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 60),
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Ana içerik
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // İkon container'ı
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                details['icon'] as String,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Kategori adı
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Açıklama
                            Text(
                              details['description'] as String,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 14),
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}