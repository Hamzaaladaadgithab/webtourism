import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class FiltersScreen extends StatefulWidget {
  static const screenRoute = '/filters';
  final Function(Map<String, bool>) saveFilters;
  final Map<String, bool> currentFilters;

  FiltersScreen(this.currentFilters, this.saveFilters);

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  var _Sommer = false;
  var _Winter = false;
  var _Family = false;

  @override
  void initState() {
    _Sommer = widget.currentFilters['summer'] ?? false;
    _Winter = widget.currentFilters['winter'] ?? false;
    _Family = widget.currentFilters['family'] ?? false;
    super.initState();
  }

  Widget buildSwitchListTile(
    String title,
    String subtitle,
    bool currentValue,
    Function(bool) updateValue,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        value: currentValue,
        activeColor: Colors.blue,
        onChanged: updateValue,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: const Text(
          'Filtrele',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: 'ElMessiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () {
              final selectedFilters = {
                'summer': _Sommer,
                'winter': _Winter,
                'family': _Family,
              };
              widget.saveFilters(selectedFilters);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Filtreler kaydedildi!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Gezi Filtreleri',
                style: TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  buildSwitchListTile(
                    'YAZ GEZİLERİ',
                    'Sadece Yaz Mevsiminde Geziler Göster!',
                    _Sommer,
                    (newValue) {
                      setState(() {
                        _Sommer = newValue;
                      });
                    },
                  ),
                  buildSwitchListTile(
                    'KIŞ GEZİLERİ',
                    'Sadece Kış Mevsiminde Geziler Göster!',
                    _Winter,
                    (newValue) {
                      setState(() {
                        _Winter = newValue;
                      });
                    },
                  ),
                  buildSwitchListTile(
                    'AİLE İÇİN',
                    'Sadece Aile İçin Uygun Gezileri Göster!',
                    _Family,
                    (newValue) {
                      setState(() {
                        _Family = newValue;
                      });
                    },
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
