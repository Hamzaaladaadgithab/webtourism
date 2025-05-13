import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/categories_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/user_reservations_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../models/trip.dart';
import '../services/data_service.dart';

const double kMinPrice = 0;
const double kMaxPrice = 10000;
const int kMinDuration = 0;
const int kMaxDuration = 30;

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
  double _maxPrice = kMaxPrice;
  DateTime? _selectedDate;

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtreler',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Maksimum fiyat
          const Text('Maksimum Fiyat'),
          Slider(
            value: _maxPrice,
            min: kMinPrice,
            max: kMaxPrice,
            divisions: 100,
            label: '₺${_maxPrice.toStringAsFixed(0)}',
            onChanged: (value) {
              setState(() {
                _maxPrice = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Tarih seçici
          const Text('Tarih'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _selectedDate == null
                  ? 'Tarih seçin'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Filtreleri uygula butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Filtreleri Uygula'),
            ),
          ),
        ],
      ),
    );
  }

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
        'Screen': const SearchScreen(),
        'Title': 'Ara',
        'icon': Icons.search,
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
          if (_selectedScreenIndex == 1) // Ara ekranında ise
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildFilterSheet(),
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                );
              },
            ),
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