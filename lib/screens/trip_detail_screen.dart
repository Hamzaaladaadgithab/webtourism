import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../auth/userLoginScreen.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class TripDetailScreen extends StatefulWidget {
  static const routeName = '/trip-detail';
  final Trip trip;

  const TripDetailScreen({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  Set<String> _favorites = {};
  late Future<Trip?> _tripFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _tripFuture = _loadTripData();
  }

  Future<void> _loadFavorites() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;
      
      final userDoc = await _userService.getUser(currentUser.uid);
      if (!mounted) return;
      
      final favorites = userDoc?.favorites ?? [];
      setState(() {
        _favorites = Set<String>.from(favorites);
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(String tripId) async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      if (mounted) {
        Navigator.of(context).pushNamed(UserLoginScreen.routeName);
      }
      return;
    }

    if (mounted) {
      setState(() {
        if (_favorites.contains(tripId)) {
          _favorites.remove(tripId);
          _userService.updateUser(currentUser.uid, {
            'favorites': FieldValue.arrayRemove([tripId])
          });
        } else {
          _favorites.add(tripId);
          _userService.updateUser(currentUser.uid, {
            'favorites': FieldValue.arrayUnion([tripId])
          });
        }
      });
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blue.shade900,
                size: isWideScreen ? 28 : 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isWideScreen ? 16 : 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isWideScreen ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Trip?> _loadTripData() async {
    try {
      final tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.trip.id)
          .get();
      
      if (!tripDoc.exists) {
        return null;
      }
      return Trip.fromFirestore(tripDoc.id, tripDoc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error loading trip data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.trip.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _favorites.contains(widget.trip.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () => _toggleFavorite(widget.trip.id),
          ),
        ],
      ),
      body: FutureBuilder<Trip?>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final trip = snapshot.data ?? widget.trip;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip.imageUrl.isNotEmpty)
                  Image.network(
                    trip.imageUrl.startsWith('http') ? trip.imageUrl : 'https://images.unsplash.com/photo-1605540436563-5bca919ae766?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c2tpaW5nfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error_outline, size: 40),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Konum', trip.location, Icons.location_on),
                      _buildDetailRow('Tarih', '${trip.startDate.day}/${trip.startDate.month} - ${trip.endDate.day}/${trip.endDate.month}', Icons.calendar_today),
                      const SizedBox(height: 20),
                      const Text(
                        'Açıklama',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(trip.description),
                      const SizedBox(height: 20),
                      const Text(
                        'Kategoriler',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: trip.categories.map((category) => Chip(
                          label: Text(category),
                          backgroundColor: Colors.blue.shade100,
                        )).toList(),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/make-reservation',
                              arguments: trip,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Rezervasyon Yap - ${trip.price.toStringAsFixed(2)} TL',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}