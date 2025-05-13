import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/search_service.dart';
import '../widgets/trip_card.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

const double kMaxPrice = 10000.0;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Kültür Turu',
    'Doğa Turu',
    'Yemek Turu',
    'Şehir Turu',
    'Gemi Turu',
    'Kayak Turu',
  ];

  String _selectedCategory = '';
  List<Trip> _searchResults = [];
  String? _error;
  double _maxPrice = kMaxPrice;
  DateTime? _selectedDate;
  bool _isLoading = false;
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _performSearch();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _searchService.searchTrips(
        searchQuery: _searchController.text,
        category: _selectedCategory,
        maxPrice: _maxPrice,
        selectedDate: _selectedDate,
      );

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Arama sırasında bir hata oluştu';
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final userDoc = await _userService.getUser(user.uid);
        if (userDoc != null && mounted) {
          setState(() {
            _favorites = Set<String>.from(userDoc.favorites);
          });
        }
      }
    } catch (e) {
      // Favorileri yüklerken hata oluşursa sessizce devam et
    }
  }

  Future<void> _toggleFavorite(String tripId) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          if (_favorites.contains(tripId)) {
            _favorites.remove(tripId);
          } else {
            _favorites.add(tripId);
          }
        });

        if (!mounted) return;

        if (_favorites.contains(tripId)) {
          await _userService.addToFavorites(user.uid, tripId);
        } else {
          await _userService.removeFromFavorites(user.uid, tripId);
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilere eklemek için giriş yapmalısınız'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklerken/çıkarırken bir hata oluştu'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tur ara...',
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            onChanged: (value) => _performSearch(),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: _selectedCategory.isEmpty,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = '';
                  });
                  _performSearch();
                },
                label: const Text('Tümü'),
                backgroundColor: Colors.white,
                selectedColor: const Color(0x332196F3),
                checkmarkColor: Colors.blue,
              ),
              const SizedBox(width: 8),
              ..._categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : '';
                      });
                      _performSearch();
                    },
                    label: Text(category),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0x332196F3),
                    checkmarkColor: Colors.blue,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Arama sonucu bulunamadı',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final trip = _searchResults[index];
                      return TripCard(
                        trip: trip,
                        isFavorite: _favorites.contains(trip.id),
                        onFavoriteToggle: () => _toggleFavorite(trip.id),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/trip-detail',
                            arguments: trip,
                          );
                        },
                      );
                    }
                  ),
          ),
      ],
    );
  }
}