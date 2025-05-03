import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../widgets/trip_item.dart';


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
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
        title: Text(
            categoryTitle,
            style: TextStyle(color: Colors.white), // ← Başlık metni beyaz yapıldı
                  ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: displayTrips.isEmpty
          ? Center(child: Text('Bu kategoride gezi bulunamadı.'))
          : ListView.builder(
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
    );
  }
}
