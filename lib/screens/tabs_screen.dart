import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';
import '../screens/favorites_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/filters_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';
  final List<Trip> favoriteTrips;
  
  const TabsScreen(this.favoriteTrips);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedScreenIndex = 0;
  late List<Map<String, dynamic>> _screens;

  // Ekran boyutları için sabitler
  static const double tabletBreakpoint = 768;
     
  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  void initState() { 
    super.initState();
    _screens = [
      {
        'Screen': CategoriesScreen(),
        'Title': 'GEZİ KATEGORİLERİ',
        'icon': Icons.dashboard,
      },
      {
        'Screen': FavoritesScreen(widget.favoriteTrips),
        'Title': 'GEZİ FAVORİLERİ',
        'icon': Icons.star,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < tabletBreakpoint;
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          _screens[_selectedScreenIndex]['Title'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 40),
            child: Row(
              children: [
                if (_auth.currentUser != null) ...[
                  if (!isMobile)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          _auth.currentUser!.email ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      _auth.currentUser!.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      _auth.signOut();
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              padding: EdgeInsets.only(top: 40),
              alignment: Alignment.center,
              color: Colors.blue,
              child: Text(
                'Gezi Rehberi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'ElMessiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.card_travel,
                size: 30,
                color: Colors.blue,
              ),
              title: Text(
                'Tüm Geziler',
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _selectScreen(0);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.filter_list,
                size: 30,
                color: Colors.blue,
              ),
              title: Text(
                'Filtreler',
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(FiltersScreen.screenRoute);
              },
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.zero,
        child: _screens[_selectedScreenIndex]['Screen'],
      ),
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