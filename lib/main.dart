import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tourism/models/trip.dart';
import 'package:tourism/screens/category_trips_screen.dart';
import './screens/tabs_screen.dart';
import 'package:tourism/screens/trip_detail_screen.dart';
import 'package:tourism/screens/make_reservation_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/data_service.dart';
import 'services/admin_service.dart';
import 'screens/WelcomeScreen.dart';
import 'auth/userLoginScreen.dart';
import 'auth/userSignUpScreen.dart';
import 'auth/AdminLoginScreen.dart';
import 'auth/adminSignUpScreen.dart';
import 'admin/admin_home_screen.dart';
import 'admin/add_tour_screen.dart';
import 'admin/manage_tours_screen.dart';
import 'admin/manage_reservations_screen.dart';
import 'admin/edit_tour_screen.dart';
import 'admin/manage_users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase başarıyla başlatıldı!');

    // İlk admin kullanıcısını oluştur
    final adminService = AdminService();
    await adminService.createInitialAdmin();
    print('İlk admin kullanıcısı oluşturuldu veya zaten mevcut.');
  } catch (e) {
    print('Firebase başlatma hatası: $e');
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

  @override
  void initState() {
    super.initState();
    _setupDataStream();
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
      debugShowCheckedModeBanner: false,
      title: 'TOURİSM REHBERİ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => WelcomeScreen(),
        UserLoginScreen.routeName: (ctx) => UserLoginScreen(),
        UserSignUpScreen.routeName: (ctx) => UserSignUpScreen(),
        AdminLoginScreen.routeName: (ctx) => AdminLoginScreen(),
        AdminSignUpScreen.routeName: (ctx) => AdminSignUpScreen(),
        TabsScreen.routeName: (ctx) => TabsScreen(_favoriteTrips),
        CategoryTripsScreen.routeName: (ctx) => CategoryTripsScreen(),
        TripDetailScreen.routeName: (context) {
          final trip = ModalRoute.of(context)!.settings.arguments as Trip;
          return TripDetailScreen(trip: trip);
        },
        AdminHomeScreen.routeName: (ctx) => AdminHomeScreen(),
        AddTourScreen.routeName: (ctx) => AddTourScreen(),
        ManageToursScreen.routeName: (ctx) => ManageToursScreen(),
        ManageReservationsScreen.routeName: (ctx) => ManageReservationsScreen(),
        ManageUsersScreen.routeName: (ctx) => ManageUsersScreen(),
        '/edit-tour': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Trip;
          return EditTourScreen(trip: args);
        },
        '/make-reservation': (context) {
          final trip = ModalRoute.of(context)!.settings.arguments as Trip;
          return MakeReservationScreen(trip: trip);
        },
      },
    );
  }
}
