

enum Season {
  winter,
  spring,
  summer,
  autumn,
}

enum TripType{
  Exploration,
  Recovery,
  Activities,
  Therapy,

}
class Trip {
  final String id;
  final List<String> categories;
  final String title;
  final String imageUrl;
  final List<String> activities;
  final List<String> program;
  final int duration;
  final Season season;
  final TripType  tripType;
  final bool isInSummer;
  final bool isInWinter;
  final bool isForFamilies;
  final int numberOfTrips;


  Trip({
    required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.activities,
    required this.program,
    required this.duration,
    required this.season,
    required this.tripType,
    required this.isInSummer,
    required this.isInWinter,
    required this.isForFamilies,
    required this.numberOfTrips,
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
}