import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';
import '../services/data_service.dart';
import 'WelcomeScreen.dart';

class TripDetailScreen extends StatefulWidget {
  static const routeName = '/trip-detail';
  final Function(String) toggleFavorite;
  final Function(String) isFavorite;

  const TripDetailScreen({required this.toggleFavorite, required this.isFavorite});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Trip? _selectedTrip;
  bool _isLoading = true;
  final DataService _dataService = DataService();
  String? _tripId;

  static const double desktopBreakpoint = 1024;

  Widget buildListTile(String title, IconData icon, Function() onTapLink) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'ElMessiri', fontSize: 24),
      ),
      onTap: onTapLink,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _tripId = ModalRoute.of(context)?.settings.arguments as String;
      _setupTripStream();
    }
  }

  void _setupTripStream() {
    _dataService.getTripsStream().listen((trips) {
      setState(() {
        _selectedTrip = trips.firstWhere((trip) => trip.id == _tripId);
        _isLoading = false;
      });
    }, onError: (e) {
      print('Tur detayı dinlenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= desktopBreakpoint;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _selectedTrip?.title ?? 'Gezi Detayı',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 50),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedTrip != null)
                  IconButton(
                    icon: Icon(
                      widget.isFavorite(_selectedTrip!.id)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      widget.toggleFavorite(_selectedTrip!.id);
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    // Profil sayfasına yönlendirme
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _selectedTrip == null
              ? Center(child: Text('Tur bulunamadı'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: isDesktop ? 400 : 300,
                            width: double.infinity,
                            child: Image.network(
                              _selectedTrip!.imageUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 10,
                            child: Container(
                              width: 300,
                              color: Colors.black54,
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 20,
                              ),
                              child: Text(
                                _selectedTrip!.title,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Text(
                              _selectedTrip!.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 32 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktiviteler',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: _selectedTrip!.activities.length,
                                itemBuilder: (ctx, index) => Card(
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Icon(Icons.star, color: Colors.blue),
                                    title: Text(
                                      _selectedTrip!.activities[index],
                                      style: TextStyle(
                                        fontSize: isDesktop ? 18 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Günlük Program',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: _selectedTrip!.program.length,
                                itemBuilder: (ctx, index) => Card(
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      _selectedTrip!.program[index],
                                      style: TextStyle(
                                        fontSize: isDesktop ? 18 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}