import 'package:flutter/material.dart';
import '../screens/filters_screen.dart';
import '../screens/tabs_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});



  Widget buildListTile(String title, IconData icon, VoidCallback onTapLink){    
    return ListTile(
      leading: Icon(
        icon, 
      size:30, 
      color:Colors.blue),
      title: Text(
        title,
        style: TextStyle(
          fontFamily:'ElMessiri',
          fontSize:24,
          fontWeight: FontWeight.bold,
        ),
      ),
      
        onTap:onTapLink, //..
      
    );
   }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding:EdgeInsets.only(top:40),
            alignment: Alignment.center,
            color:Colors.blue,
            child: Text('TOURİSM REHBERİ',
             style:TextStyle(
            color:Colors.white,
             fontSize:26,
             fontFamily:'ElMessiri',
             fontWeight:FontWeight.bold,


             ),
          ),
          ),
          SizedBox(height:20),

          buildListTile('GEZİLER' ,
           Icons.card_travel,(){
             // Butona tıklanınca yapılacak işlem
           Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
           }
           ),
           
          buildListTile('FİLTERELEME',
           Icons.filter_list,(){
             // Butona tıklanınca yapılacak işlem
           Navigator.of(context).pushReplacementNamed(FiltersScreen.screenRoute);
           }
           ),
        ],
      ),
    );
  }
}