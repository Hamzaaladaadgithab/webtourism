import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/data_service.dart';
import '../widgets/trip_card.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';

class CategoryTripsScreen extends StatefulWidget {
  static const routeName = '/category-trips';

  const CategoryTripsScreen({super.key});

  @override
  State<CategoryTripsScreen> createState() => _CategoryTripsScreenState();
}

class _CategoryTripsScreenState extends State<CategoryTripsScreen> {
  final DataService _dataService = DataService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  Set<String> _favorites = {};
  late String _category;
  late Color _categoryColor;
  late String _categoryIcon;
  late String _categoryDescription;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favoriler yüklenirken bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_favorites.contains(tripId)
                ? 'Favorilere eklendi'
                : 'Favorilerden çıkarıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: ResponsiveHelper.getFontSize(context, 64),
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Bu kategoride henüz gezi yok',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.blue.shade900,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveHelper.getFontSize(context, 64),
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _category = args['category'] as String;
    _categoryColor = args['color'] as Color;
    _categoryIcon = args['icon'] as String;
    _categoryDescription = args['description'] as String;
  }

  Future<List<Trip>> _getCategoryTrips() async {
    final trips = await _dataService.getTrips();
    return trips.where((trip) => 
      trip.categories.contains(_category)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_categoryIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_category),
                Text(
                  _categoryDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: _categoryColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<Trip>>(
        future: _getCategoryTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                childAspectRatio: isDesktop ? 1.2 : 1.5,
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
            ),
          );
        },
      ),
    );
  }
}
