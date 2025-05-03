import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class FiltersScreen extends StatefulWidget {
 

  static const screenRoute = '/filters';

  final Function(Map<String, bool>) saveFilters;

  final Map<String, bool> currentFilters;

  FiltersScreen(this.currentFilters , this.saveFilters);

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
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
            icon:Icon(Icons.save),
            onPressed: () {
                final selectedFilters = {
               'summer':_Sommer,
               'winter':_Winter,
               'family':_Family,
                       };
              widget.saveFilters(selectedFilters);
            }
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'YAZ GEZİLERİ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Sadece Yaz Mevsiminde Geziler Göster!'),
                    value: _Sommer,
                    activeColor: Colors.blue,
                    onChanged: (newValue) {
                      setState(() {
                        _Sommer = newValue;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'KIŞ GEZİLERİ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Sadece Kış Mevsiminde Geziler Göster!'),
                    value: _Winter,
                    activeColor: Colors.blue,
                    onChanged: (newValue) {
                      setState(() {
                        _Winter = newValue;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'AİLE İÇİN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Sadece Aileye Uygun Geziler Göster!'),
                    value: _Family,
                    activeColor: Colors.blue,
                    onChanged: (newValue) {
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
