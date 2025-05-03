import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../widgets/trip_item.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Trip> favoriteTrips;

  const FavoritesScreen(this.favoriteTrips, {super.key});

  @override
  Widget build(BuildContext context) {
    if(favoriteTrips.isEmpty){
      return const Center(
        child: Text('Sende Favori Sayfasında Hiç Bir Gezi Yok...'),
      );
    }

    return ListView.builder(
      itemCount: favoriteTrips.length,
      itemBuilder: (context, index) {
        return TripItem(
          id: favoriteTrips[index].id,
          title: favoriteTrips[index].title,
          imageUrl: favoriteTrips[index].imageUrl,
          duration: favoriteTrips[index].duration,
          season: favoriteTrips[index].season,
          tripType: favoriteTrips[index].tripType,
         
        );
      },
    );
  }
}