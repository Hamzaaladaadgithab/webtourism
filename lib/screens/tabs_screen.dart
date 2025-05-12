import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/categories_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/user_reservations_screen.dart';
import '../screens/profile_screen.dart';
import '../models/trip.dart';
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
        'Title': 'Kategoriler',
        'icon': Icons.dashboard,
      },
      {
        'Screen': const FavoritesScreen(),
        'Title': 'Favoriler',
        'icon': Icons.star,
      },
      {
        'Screen': const UserReservationsScreen(),
        'Title': 'Rezervasyonlar',
        'icon': Icons.calendar_today,
      },
      {
        'Screen': const ProfileScreen(),
        'Title': 'Profil',
        'icon': Icons.person,
      },
    ];
  }

  void _setupDataStream() {
    _dataService.getTripsStream().listen((trips) {
      if (mounted) {
        setState(() {
          _availableTrips = trips;
        });
      }
    });
  }

  void _selectScreen(int index) {
    if (mounted) {
      setState(() {
        _selectedScreenIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        title: Text(
          _screens[_selectedScreenIndex]['Title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Çıkış yapılırken hata oluştu: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: _screens[_selectedScreenIndex]['Screen'],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            onTap: _selectScreen,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.blue.shade900,
            currentIndex: _selectedScreenIndex,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            items: _screens.map((screen) => BottomNavigationBarItem(
              icon: Icon(screen['icon'] as IconData),
              label: screen['Title'] as String,
            )).toList(),
          ),
        ),
      ),
    );
  }
}