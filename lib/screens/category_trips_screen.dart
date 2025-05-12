import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/data_service.dart';
import '../widgets/trip_card.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

// Web uyumluluğu için ekran boyutları sabitleri
class ScreenSize {
  // Tablet boyutu - 768px ve üzeri için grid görünümüne geçecek
  static const double tablet = 768;
  // Desktop boyutu - 1024px ve üzeri için daha geniş grid
  static const double desktop = 1024;
}

class CategoryTripsScreen extends StatefulWidget {
  static const routeName = '/category-trips';

  @override
  State<CategoryTripsScreen> createState() => _CategoryTripsScreenState();
}

class _CategoryTripsScreenState extends State<CategoryTripsScreen> {
  final DataService _dataService = DataService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final favorites = await _userService.getUserFavorites(user.uid).first;
        setState(() {
          _favorites = Set.from(favorites);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favoriler yüklenirken bir hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleFavorite(String tripId) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilere eklemek için giriş yapmalısınız'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _userService.toggleFavorite(user.uid, tripId);
      setState(() {
        if (_favorites.contains(tripId)) {
          _favorites.remove(tripId);
        } else {
          _favorites.add(tripId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_favorites.contains(tripId)
              ? 'Favorilere eklendi'
              : 'Favorilerden çıkarıldı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final categoryId = args['id'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          args['title'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Trip>>(
        stream: _dataService.getTripsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bu kategoride gezi bulunamadı',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final trips = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              final childAspectRatio = constraints.maxWidth > 600 ? 1.5 : 1.2;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return TripCard(
                    trip: trip,
                    isFavorite: _favorites.contains(trip.id),
                    onFavoriteToggle: () => _toggleFavorite(trip.id),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/trip-detail',
                        arguments: trip,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
