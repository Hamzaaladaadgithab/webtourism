import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../auth/userLoginScreen.dart';
import '../services/favorite_service.dart';
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
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();
  bool _isFavorite = false;
  bool _isLoading = false;
  Trip? _trip;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadTripData();
  }

  Future<void> _loadFavorites() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _isFavorite = false;
        });
        return;
      }
      
      final isFavorite = await _favoriteService.isFavorite(widget.trip.id);
      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      setState(() {
        _isFavorite = false;
      });
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

    try {
      if (_isFavorite) {
        await _favoriteService.removeFromFavorites(tripId);
      } else {
        await _favoriteService.addToFavorites(tripId);
      }
      
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? 'Favorilere eklendi' : 'Favorilerden kaldırıldı'),
            backgroundColor: _isFavorite ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade900),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _loadTripData() async {
    setState(() => _isLoading = true);
    try {
      final tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.trip.id)
          .get();
      
      if (!mounted) return;

      if (tripDoc.exists) {
        setState(() {
          _trip = Trip.fromFirestore(tripDoc.id, tripDoc.data() as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _trip = widget.trip;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading trip data: $e');
      if (!mounted) return;
      setState(() {
        _trip = widget.trip;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip ?? widget.trip;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        title: Text(
          trip.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => _toggleFavorite(trip.id),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trip.imageUrl.isNotEmpty)
                    Image.network(
                      trip.imageUrl.startsWith('http') ? trip.imageUrl : 'https://images.unsplash.com/photo-1605540436563-5bca919ae766?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c2tpaW5nfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
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
                        Text(
                          'Fiyat: ${trip.price} TL',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
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
            ),
    );
  }
}
