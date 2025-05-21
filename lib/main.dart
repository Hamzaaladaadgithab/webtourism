import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tourism/providers/fcm_provider.dart';
import 'package:tourism/services/notification_scheduler.dart';
import 'package:tourism/admin/manage_reservations_screen.dart';
import 'package:tourism/screens/tabs_screen.dart';
import 'package:tourism/screens/category_trips_screen.dart';
import 'package:tourism/screens/trip_detail_screen.dart';
import 'package:tourism/screens/make_reservation_screen.dart';
import 'package:tourism/models/trip.dart' as models;
import 'package:tourism/admin/statistics_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'screens/WelcomeScreen.dart';
import 'auth/userLoginScreen.dart';
import 'auth/userSignUpScreen.dart';
import 'auth/adminLoginScreen.dart';
import 'admin/admin_home_screen.dart';
import 'admin/add_tour_screen.dart';
import 'admin/manage_tours_screen.dart';
import 'admin/edit_tour_screen.dart';
import 'admin/manage_users_screen.dart';
import 'admin/notifications_screen.dart';
import 'screens/categories_screen.dart';
import 'utils/timeago_tr.dart';

// Debug flag for development
const bool debug = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Önce Firebase'i başlat
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Sonra bildirimleri kontrol et
    await NotificationScheduler().checkNotifications();
    initTimeAgoTr();
    await initializeDateFormatting('tr_TR', null);
    
    print('Firebase başarıyla başlatıldı!');
    
    // FCM provider'ı başlat
    final fcmProvider = FCMProvider();
    await fcmProvider.initialize();

    // Firebase Auth'u dinle
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('Kullanıcı oturumu kapalı');
      } else {
        try {
          await user.getIdToken(true);
          print('Kullanıcı oturum açtı: ${user.email}');
        } catch (e) {
          print('Token yenileme hatası: $e');
        }
      }
    });
    // Bildirim servisini başlat
    final notificationService = NotificationService();
    // Her 15 dakikada bir yaklaşan gezileri kontrol et
    Timer.periodic(Duration(minutes: 15), (timer) {
      notificationService.checkUpcomingTours();
    });

    // İlk kontrol
    notificationService.checkUpcomingTours();
  } catch (e) {
    print('Firebase başlatma hatası: $e');
    // Hata durumunda uygulama çökmemeli
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Bağlantı hatası: Lütfen internet bağlantınızı kontrol edin'),
        ),
      ),
    ));
    return;
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<models.Trip> _favoriteTrips = [];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FCMProvider(),
        ),
      ],
      child: MaterialApp(
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
          if (args == null || args is! models.Trip) {
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
        '/manage-reservations': (ctx) => const ManageReservationsScreen(),
        '/make-reservation': (context) {
          final route = ModalRoute.of(context);
          if (route == null) return Center(child: CircularProgressIndicator());

          final args = route.settings.arguments;
          if (args == null || args is! models.Trip) {
            return Scaffold(
              body: Center(
                child: Text('Tur bilgisi bulunamadı'),
              ),
            );
          }

          return MakeReservationScreen(trip: args);
        },
        '/statistics': (ctx) => StatisticsScreen(),
        '/manage-users': (ctx) => ManageUsersScreen(),
        '/notifications': (ctx) => NotificationsScreen(),
        '/edit-tour': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as models.Trip;
          return EditTourScreen(trip: args);
        },
        CategoriesScreen.routeName: (ctx) => CategoriesScreen(),
      },
    ),
    );
  }
}
