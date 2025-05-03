import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/trip.dart';

class TripDetailScreen extends StatefulWidget {
  static const screenRoute = '/trip-detail';

  final Function(String) mangeFavorite;
  final Function(String) isFavorite;

  TripDetailScreen(this.mangeFavorite, this.isFavorite);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final DataService _dataService = DataService();
  Trip? _selectedTrip;
  bool _isLoading = true;
  String? _tripId;

  @override
  void didChangeDependencies() {
    if (_isLoading) {
      _tripId = ModalRoute.of(context)?.settings.arguments as String;
      _setupTripStream();
    }
    super.didChangeDependencies();
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

  Widget buidlSectionTitle(String titleText) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      alignment: Alignment.topLeft,
      child: Text(
        titleText,
        style: TextStyle(
          color: Colors.blue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildListViewContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
          title: Text('Yükleniyor...'),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_selectedTrip == null) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
          title: Text('Hata'),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: Center(
          child: Text('Tur bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
        title: Text(
          _selectedTrip!.title,
          style: TextStyle(color: Colors.white), // ← başlık metni beyaz
            ),
        backgroundColor: Colors.blue,
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                _selectedTrip!.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            buidlSectionTitle('Aktiviteler:'),
            buildListViewContainer(
              ListView.builder(
                itemCount: _selectedTrip!.activities.length,
                itemBuilder: (context, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(_selectedTrip!.activities[index]),
                  ),
                ),
              ),
            ),
            buidlSectionTitle('Günlük Program:'),
            buildListViewContainer(
              ListView.builder(
                itemCount: _selectedTrip!.program.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text('Gün${index + 1}'),
                      ),
                      title: Text(_selectedTrip!.program[index]),
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          widget.isFavorite(_selectedTrip!.id) ? Icons.star : Icons.star_border,
        ),
        onPressed: () => widget.mangeFavorite(_selectedTrip!.id),
      ),
    );
  }
}