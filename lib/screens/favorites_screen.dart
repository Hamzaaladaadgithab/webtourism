import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../widgets/trip_item.dart';
import '../screens/trip_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Trip> favoriteTrips;
  final Function(String) onToggleFavorite;

  const FavoritesScreen(this.favoriteTrips, {required this.onToggleFavorite, super.key});

  @override
  Widget build(BuildContext context) {
    if(favoriteTrips.isEmpty){
      return const Center(
        child: Text('Sende Favori Sayfasında Hiç Bir Gezi Yok...'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: favoriteTrips.length,
        itemBuilder: (context, index) {
          return TripItem(
            id: favoriteTrips[index].id,
            title: favoriteTrips[index].title,
            imageUrl: favoriteTrips[index].imageUrl,
            duration: favoriteTrips[index].duration,
            season: favoriteTrips[index].season,
            tripType: favoriteTrips[index].tripType,
            onTap: () {
              Navigator.of(context).pushNamed(
                TripDetailScreen.routeName,
                arguments: favoriteTrips[index].id,
              );
            },
          );
        },
      ),
    );
  }
}