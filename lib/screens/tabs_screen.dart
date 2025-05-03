import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import './categories_screen.dart';
import './favorites_scrren.dart'; 
import '../models/trip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/WelcomeScreen.dart';

// bu artık giriş sonrası görünen sayfamız...

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';
  final List<Trip> favoriteTrips;
  
  const TabsScreen(this.favoriteTrips);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
 
    
  void _selectScreen(int index){
    setState(() {
      _selectedScreenIndex=index;
      
    });
  }


  int _selectedScreenIndex=0;


  late List<Map<String, dynamic>> _screens;
     
  
 

  @override
  void initState() { 
     _screens = [{
      'Screen':CategoriesScreen(),
      'Title':'GEZİ KATEGORİLERİ',

     },
      {
      'Screen': FavoritesScreen(widget.favoriteTrips),
      'Title':'GEZİ FAVORİLERİ',
      
     },
  ];

    super.initState();
  } 

  @override

  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
        backgroundColor: Colors.blue,
        title: Text(_screens[_selectedScreenIndex]['Title'] as String,
            style:TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              _auth.signOut();
              Navigator.pushNamed(context, WelcomeScreen.routeName);
            }, 
             icon: Icon(Icons.logout, color: Colors.white),

            )
        ],
    ),
    drawer: AppDrawer(),
    
    
     
    body:_screens[_selectedScreenIndex]['Screen'] as Widget,

    bottomNavigationBar:BottomNavigationBar(
     onTap: _selectScreen,
     backgroundColor: Colors.blue,
     selectedItemColor: Colors.yellowAccent, 
     unselectedItemColor: Colors.white,
     currentIndex: _selectedScreenIndex,

  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label:'GEZİ KATEGORİLERİ',
    ),
     BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label:'GEZİ FAVORİLERİ',

    ),

  ],
     ),
    );
  }
}