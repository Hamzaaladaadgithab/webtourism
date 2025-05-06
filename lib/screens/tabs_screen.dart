import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/categories_screen.dart';
import '../screens/favorites_screen.dart';
import '../models/trip.dart';
import '../widgets/app_drawer.dart';
import '../services/data_service.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';
  final List<Trip> favoriteTrips;

  const TabsScreen(this.favoriteTrips);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DataService _dataService = DataService();
  int _selectedScreenIndex = 0;
  late List<Map<String, dynamic>> _screens;
  late List<Trip> _favoriteTrips;
  List<Trip> _availableTrips = [];

  @override
  void initState() { 
    super.initState();
    _favoriteTrips = widget.favoriteTrips;
    _setupDataStream();
    _screens = [
      {
        'Screen': CategoriesScreen(showAppBar: false),
        'Title': 'GEZİ KATEGORİLERİ',
        'icon': Icons.dashboard,
      },
      {
        'Screen': FavoritesScreen(
          _favoriteTrips,
          onToggleFavorite: _toggleFavorite,
        ),
        'Title': 'GEZİ FAVORİLERİ',
        'icon': Icons.star,
      },
    ];
  }

  void _setupDataStream() {
    _dataService.getTripsStream().listen((trips) {
      setState(() {
        _availableTrips = trips;
      });
    });
  }

  void _toggleFavorite(String tripId) {
    final existingIndex = _favoriteTrips.indexWhere((trip) => trip.id == tripId);
    setState(() {
      if (existingIndex >= 0) {
        _favoriteTrips.removeAt(existingIndex);
      } else {
        final trip = _availableTrips.firstWhere((trip) => trip.id == tripId);
        _favoriteTrips.add(trip);
      }
      // Favoriler ekranını güncelle
      _screens[1] = {
        'Screen': FavoritesScreen(
          _favoriteTrips,
          onToggleFavorite: _toggleFavorite,
        ),
        'Title': 'GEZİ FAVORİLERİ',
        'icon': Icons.star,
      };
    });
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _screens[_selectedScreenIndex]['Title'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (_auth.currentUser != null)
            Padding(
              padding: EdgeInsets.only(right: 100),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      // Profil sayfasına yönlendirme
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_auth.currentUser!.email}'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed('/');
                      } catch (e) {
                        print('Logout error: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
      drawer: AppDrawer(),
      body: _screens[_selectedScreenIndex]['Screen'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        backgroundColor: Colors.blue,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.white,
        currentIndex: _selectedScreenIndex,
        items: _screens.map((screen) => BottomNavigationBarItem(
          backgroundColor: Colors.blue,
          icon: Icon(screen['icon'] as IconData),
          label: screen['Title'] as String,
        )).toList(),
      ),
    );
  }
}