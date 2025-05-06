import 'package:flutter/material.dart';
import '../screens/trip_detail_screen.dart';
import '../models/trip.dart';

class TripItem extends StatelessWidget { 
  final String id;
  final String title;
  final String imageUrl;
  final int duration;
  final TripType tripType;
  final Season season;
  final VoidCallback? onTap;

  const TripItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.season,
    required this.tripType,
    this.onTap,
  });

  String get seasonText {
    switch (season) {
      case Season.winter:
        return 'KIŞ';
      case Season.spring:
        return 'BAHAR';
      case Season.summer:
        return 'YAZ';
      case Season.autumn:
        return 'SONBAHAR';
    }
  }    

  String get tripTypeText {
    switch (tripType) {
      case TripType.Exploration:
        return 'Keşifetme';
      case TripType.Recovery:
        return 'İyileşmek'; 
      case TripType.Activities:
        return 'Aktiviteler'; 
      case TripType.Therapy:
        return 'iyileştirme';
    }
  } 

  void selectTrip(BuildContext context) {
    Navigator.of(context).pushNamed(
      TripDetailScreen.routeName,
      arguments: id,
    );
  }
   
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap ?? () => selectTrip(context),
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(Icons.today, '$duration gün'),
                  _buildInfoItem(Icons.wb_sunny, seasonText),
                  _buildInfoItem(Icons.family_restroom, tripTypeText),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}