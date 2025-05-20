import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/search_service.dart';
import '../widgets/trip_card.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/responsive_helper.dart';

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
  // Her kategori için simge ve renk tanımları
  final Map<String, Map<String, dynamic>> categoryDetails = {
    'Doğa & Ekoturizm': {
      'icon': '🏞️',
      'color': Color(0xFF4CAF50),
      'description': 'Dağ, yayla, yürüyüş, doğal parklar, kamp',
    },
    'Kültür & Tarih': {
      'icon': '🏛️',
      'color': Color(0xFF9C27B0),
      'description': 'Müzeler, tarihi yapılar, şehir turları',
    },
    'Deniz & Tatil': {
      'icon': '🏖️',
      'color': Color(0xFF1976D2),
      'description': 'Plajlar, yaz tatili, resortlar, yüzme',
    },
    'Macera & Spor': {
      'icon': '🧗',
      'color': Color(0xFFF57C00),
      'description': 'Rafting, paraşüt, safari, bisiklet',
    },
    'Yeme & İçme': {
      'icon': '🍽️',
      'color': Color(0xFFE91E63),
      'description': 'Gurme turları, yöresel yemek deneyimi',
    },
    'Festival & Etkinlik': {
      'icon': '🎭',
      'color': Color(0xFF673AB7),
      'description': 'Konserler, yerel festivaller, gösteriler',
    },
    'Alışveriş Turları': {
      'icon': '🛍️',
      'color': Color(0xFF795548),
      'description': 'Outlet merkezleri, pazarlar, hediyelik eşyalar',
    },
    'İnanç Turizmi': {
      'icon': '🕌',
      'color': Color(0xFF607D8B),
      'description': 'Dini yapılar, hac turları, camiler',
    },
    'Sağlık & Termal Turizm': {
      'icon': '🏥',
      'color': Color(0xFF009688),
      'description': 'Spa, kaplıca, sağlık merkezleri',
    },
    'Eğitim & Dil Turları': {
      'icon': '🏫',
      'color': Color(0xFFFF5722),
      'description': 'Dil okulları, kültür değişim programları',
    },
  };

  String? _selectedCategory;
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
              hintStyle: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14)
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.blue,
                size: ResponsiveHelper.getFontSize(context, 24)
              ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              FilterChip(
                selected: _selectedCategory == null,
                label: const Text(
                  'Tümü',
                  style: TextStyle(fontSize: 12),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = null;
                  });
                  _performSearch();
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
              ...categoryDetails.entries.map((entry) {
                final category = entry.key;
                final details = entry.value;
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        details['icon'] as String,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  tooltip: details['description'] as String,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                    _performSearch();
                  },
                  backgroundColor: Colors.white,
                  selectedColor: (details['color'] as Color).withOpacity(0.2),
                  checkmarkColor: details['color'] as Color,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
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