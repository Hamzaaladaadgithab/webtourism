import 'package:flutter/material.dart';
import 'package:tourism/models/trip.dart';
import 'package:tourism/screens/category_trips_screen.dart';
import './screens/filters_screen.dart';
import './screens/tabs_screen.dart';
import 'package:tourism/screens/trip_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/data_service.dart';
import 'screens/WelcomeScreen.dart';
import 'auth/LoginScreen.dart';
import 'auth/SignUpScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase başarıyla başlatıldı!');

    final firebaseService = FirebaseService();
    final categories = await firebaseService.getCategoriesStream().first;
    final trips = await firebaseService.getTripsStream().first;

    if (categories.isEmpty || trips.isEmpty) {
      print('Veriler yükleniyor...');
      await firebaseService.uploadCategories();
      await firebaseService.uploadTrips();
      print('Veriler başarıyla yüklendi!');
    } else {
      print('Veriler zaten yüklenmiş.');
    }
  } catch (e) {
    print('Firebase başlatılırken hata oluştu: $e');
  }
  runApp(MyApp());
} 






class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DataService _dataService = DataService();
  List<Trip> _availableTrips = [];
  List<Trip> _favoriteTrips = [];
  Map<String, bool> _filters = {
    'summer': false,
    'winter': false,
    'family': false,
  };

  @override
  void initState() {
    super.initState();
    _setupDataStream();
  }

  void _setupDataStream() {
    _dataService.getTripsStream().listen((trips) {
      setState(() {
        _availableTrips = trips;
        _filterTrips();
      });
    });
  }

  void _filterTrips() {
    _availableTrips = _availableTrips.where((trip) {
      if (_filters['summer'] == true && !trip.isInSummer) return false;
      if (_filters['winter'] == true && !trip.isInWinter) return false;
      if (_filters['family'] == true && !trip.isForFamilies) return false;
      return true;
    }).toList();
  }

  void _changeFilters(Map<String, bool> filterData) {
    setState(() {
      _filters = filterData;
      _filterTrips();
    });
  }

  void _mangeFavorite(String tripId) {
    final existingIndex = _favoriteTrips.indexWhere((trip) => trip.id == tripId);
    if (existingIndex >= 0) {
      setState(() {
        _favoriteTrips.removeAt(existingIndex);
      });
    } else {
      setState(() {
        _favoriteTrips.add(
          _availableTrips.firstWhere((trip) => trip.id == tripId),
        );
      });
    }
  }

  bool _isFavorite(String id) {
    return _favoriteTrips.any((trip) => trip.id == id);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourism App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: WelcomeScreen.routeName, // Başlangıç sayfası
    routes: {
      WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
      LoginScreen.routeName: (ctx) => LoginScreen(),
      SignUpScreen.routeName: (ctx) => SignUpScreen(),
      '/tabs': (ctx) => TabsScreen(_favoriteTrips), // giriş sonrası buraya gider
      CategoryTripsScreen.routeName: (ctx) => CategoryTripsScreen(_availableTrips),
      TripDetailScreen.screenRoute: (ctx) => TripDetailScreen(_mangeFavorite, _isFavorite),
      FiltersScreen.screenRoute: (ctx) => FiltersScreen(_filters, _changeFilters),
    },
    );
  }
}
