import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tourism/models/trip.dart';
import 'package:tourism/screens/category_trips_screen.dart';
import './screens/tabs_screen.dart';

import 'package:tourism/screens/trip_detail_screen.dart';
import 'package:tourism/screens/make_reservation_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/admin_service.dart';
import 'screens/WelcomeScreen.dart';
import 'auth/userLoginScreen.dart';
import 'auth/userSignUpScreen.dart';
import 'auth/AdminLoginScreen.dart';
import 'admin/admin_home_screen.dart';
import 'admin/add_tour_screen.dart';
import 'admin/manage_tours_screen.dart';
import 'admin/manage_reservations_screen.dart';
import 'admin/edit_tour_screen.dart';
import 'admin/manage_users_screen.dart';
import 'screens/categories_screen.dart';

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
  List<Trip> _favoriteTrips = [];

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
        '/user-login': (ctx) => UserLoginScreen(),
        '/user-signup': (ctx) => UserSignUpScreen(),
        '/admin-login': (ctx) => AdminLoginScreen(),
        '/tabs': (ctx) => TabsScreen(_favoriteTrips),
        '/category-trips': (ctx) => CategoryTripsScreen(),
        '/trip-detail': (context) {
          final route = ModalRoute.of(context);
          if (route == null) return const MaterialApp(home: Center(child: CircularProgressIndicator()));
          
          final args = route.settings.arguments;
          if (args == null || args is! Trip) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Tur bilgisi bulunamadı'),
                ),
              ),
            );
          }
          
          return TripDetailScreen(trip: args);
        },
        '/admin-home': (ctx) => AdminHomeScreen(),
        '/add-tour': (ctx) => AddTourScreen(),
        '/manage-tours': (ctx) => ManageToursScreen(),
        '/manage-reservations': (ctx) => ManageReservationsScreen(),
        '/manage-users': (ctx) => ManageUsersScreen(),

        CategoriesScreen.routeName: (ctx) => const CategoriesScreen(),
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
