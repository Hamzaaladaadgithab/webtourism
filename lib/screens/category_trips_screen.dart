import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../widgets/trip_item.dart';
import '../screens/trip_detail_screen.dart';

// Web uyumluluğu için ekran boyutları sabitleri
class ScreenSize {
  // Tablet boyutu - 768px ve üzeri için grid görünümüne geçecek
  static const double tablet = 768;
  // Desktop boyutu - 1024px ve üzeri için daha geniş grid
  static const double desktop = 1024;
}

class CategoryTripsScreen extends StatefulWidget {
  static const routeName = '/category-trips';
 
  final List<Trip> availableTrips; 

  CategoryTripsScreen(this.availableTrips);

  @override
  _CategoryTripsScreenState createState() => _CategoryTripsScreenState();
}

class _CategoryTripsScreenState extends State<CategoryTripsScreen> {
  late String categoryTitle;
  late List<Trip> displayTrips;
  bool _loadedInitData = false;

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      final routeArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      
      if (routeArgs == null) {
        print('Route arguments are null');
        return;
      }

      final categoryId = routeArgs['id'];
      
      if (categoryId == null) {
        print('Category ID is null');
        return;
      }

      categoryTitle = routeArgs['title'] ?? 'Kategori Gezileri';
      print('Category ID: $categoryId');
      print('Available trips count: ${widget.availableTrips.length}');

      displayTrips = widget.availableTrips.where((trip) {
        print('Checking trip: ${trip.title}');
        print('Trip categories: ${trip.categories}');
        final contains = trip.categories.contains(categoryId);
        print('Contains category: $contains');
        return contains;
      }).toList();

      print('Display trips count: ${displayTrips.length}');
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          categoryTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      // LayoutBuilder ekleyerek ekran boyutuna göre farklı görünümler sağlıyoruz
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ekran genişliğine göre içerik düzeni
          if (constraints.maxWidth < ScreenSize.tablet) {
            // MOBİL GÖRÜNÜM: Dikey liste görünümü
            return displayTrips.isEmpty
              ? Center(child: Text('Bu kategoride gezi bulunamadı.'))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  itemCount: displayTrips.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: TripItem(
                        id: displayTrips[index].id,
                        title: displayTrips[index].title,
                        imageUrl: displayTrips[index].imageUrl,
                        duration: displayTrips[index].duration,
                        season: displayTrips[index].season,
                        tripType: displayTrips[index].tripType,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            TripDetailScreen.routeName,
                            arguments: displayTrips[index].id,
                          );
                        },
                      ),
                    );
                  },
                );
          } else {
            // WEB GÖRÜNÜMÜ: Merkezi grid layout
            final crossAxisCount = constraints.maxWidth < ScreenSize.desktop ? 2 : 3;
            
            return displayTrips.isEmpty
              ? Center(child: Text('Bu kategoride gezi bulunamadı.'))
              : Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 1600), 
                    padding: EdgeInsets.zero, 
                    child: GridView.builder(
                      padding: EdgeInsets.all(40), 
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.9, 
                        crossAxisSpacing: 40, 
                        mainAxisSpacing: 40, 
                      ),
                      itemCount: displayTrips.length,
                      itemBuilder: (context, index) {
                        return TripItem(
                          id: displayTrips[index].id,
                          title: displayTrips[index].title,
                          imageUrl: displayTrips[index].imageUrl,
                          duration: displayTrips[index].duration,
                          season: displayTrips[index].season,
                          tripType: displayTrips[index].tripType,
                        );
                      },
                    ),
                  ),
                );
          }
        },
      ),
    );
  }
}
