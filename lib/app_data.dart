import 'package:tourism/models/category.dart';
import './models/trip.dart';

// Kategoriler listesi
final List<Category> Categories_data = [
  Category(
    id: 'c1',
    title: 'DAĞLAR',
    imageUrl:
        'https://images.unsplash.com/photo-1575728252059-db43d03fc2de?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NTh8fG1vdW5hdGluc3xlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=',
  ),
  
  Category(
    id: 'c2',
    title: 'GÖLLER',
    imageUrl:
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8bGFrZXxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60', 
  ),
  Category(
    id: 'c3',
    title: 'SAHİLLER',
    imageUrl:
        'https://images.unsplash.com/photo-1493558103817-58b2924bce98?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTAxfHxiZWFjaHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60',
  ),
  Category(
    id: 'c4',
    title: 'ÇÖLLER',
    imageUrl:
        'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8ZGVzZXJ0fGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60', 
  ),
  Category(
    id: 'c5',
    title: 'ŞEHİRLER',
    imageUrl:
        'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NjR8fHRyYXZlbHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60', 
  ),
  Category(
    id: 'c6',
    title: 'DİĞER',
    imageUrl:
        'https://images.unsplash.com/photo-1605540436563-5bca919ae766?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c2tpaW5nfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60',
  ),
];

// Turlar listesi
final List<Trip> Trips_data = [
  Trip(
    id: 'm1',
    categories: ['c1'],
    title: 'Alpler Dağı',
    tripType: TripType.Exploration,
    season: Season.winter,
    imageUrl:
        'https://images.unsplash.com/photo-1611523658822-385aa008324c?ixid=MXwxMjA3fDB8MHxzZWFyY2h8N3x8bW91bmF0aW5zfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    duration: 20,
    activities: [
      'Tarihi yerleri Ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Geliş ve tanıtım.',
      'Tarihi bölge ziyareti.',
      'Serbest zaman ve alışveriş.',
      'Doğa yürüyüşü.',
      'Fotoğraf molası ve dinlenme.',
      'Dönüş hazırlığı.'
    ],
    isInSummer: false,
    isInWinter: true,
    isForFamilies: true,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm2',
    categories: ['c1'],
    title: 'Güney Dağları',
    tripType: TripType.Exploration,
    season: Season.winter,
    imageUrl:
        'https://images.unsplash.com/photo-1612456225451-bb8d10d0131d?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MjZ8fG1vdW5hdGluc3xlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    duration: 10,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Karşılama ve bilgilendirme.',
      'Doğa gezisi ve çevre tanıtımı.',
      'Serbest zaman ve alışveriş.',
      'Toplanma ve dönüş.'
    ],
    isInSummer: false,
    isInWinter: false,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm3',
    categories: ['c1'],
    title: 'Yüksek Dağlar',
    tripType: TripType.Recovery,
    season: Season.winter,
    imageUrl:
        'https://images.unsplash.com/photo-1592221912790-2b4df8882ea9?ixid=MXwxMjA3fDB8MHxzZWFyY2h8Mzd8fG1vdW5hdGluc3xlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    duration: 35,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Karşılama ve kamp tanıtımı.',
      'Yürüyüş ve dinlenme noktaları.',
      'Serbest keşif.',
      'Dönüşe hazırlık.'
    ],
    isInSummer: true,
    isInWinter: true,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm4',
    categories: ['c2', 'c1'],
    title: 'Büyük Göl',
    tripType: TripType.Activities,
    season: Season.spring,
    imageUrl:
        'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixid=MXwxMjA3fDB8MHxzZWFyY2h8OXx8bGFrZXxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    duration: 25,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Göle varış ve manzara.',
      'Yüzme veya tekne turu.',
      'Alışveriş ve serbest zaman.',
      'Dönüş.'
    ],
    isInSummer: false,
    isInWinter: false,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm5',
    categories: ['c2', 'c1'],
    title: 'Küçük Göller',
    tripType: TripType.Activities,
    season: Season.winter,
    imageUrl:
        'https://images.unsplash.com/photo-1580100586938-02822d99c4a8?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MjF8fGxha2V8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    duration: 15,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Göl gezisi ve tanıtım.',
      'Kamp ateşi etkinliği.',
      'Serbest zaman.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: true,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm6',
    categories: ['c2'],
    title: 'Zümrüt Gölü',
    tripType: TripType.Exploration,
    season: Season.summer,
    imageUrl:
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8bGFrZXxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    duration: 24,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Uzun yürüyüş ve kamp.',
      'Yüzme ve doğa fotoğrafçılığı.',
      'Alışveriş ve dinlenme.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: false,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm7',
    categories: ['c3'],
    title: 'Birinci Sahil',
    tripType: TripType.Exploration,
    season: Season.summer,
    imageUrl:
        'https://images.unsplash.com/photo-1493558103817-58b2924bce98?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTAxfHxiZWFjaHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    duration: 20,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Sahile varış ve yüzme.',
      'Fotoğraf çekimi ve piknik.',
      'Serbest zaman.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: false,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm8',
    categories: ['c3'],
    title: 'Büyük Sahil',
    tripType: TripType.Recovery,
    season: Season.spring,
    imageUrl:
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?ixid=MXwxMjA3fDB8MHxzZWFyY2h8Mnx8YmVhY2h8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    duration: 35,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Kamp ve eğlence.',
      'Yüzme ve sahil gezisi.',
      'Yemek ve dinlenme.',
      'Dönüş.'
    ],
    isInSummer: false,
    isInWinter: true,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm9',
    categories: ['c3'],
    title: 'Kayalık Sahili',
    tripType: TripType.Exploration,
    season: Season.summer,
    imageUrl:
        'https://images.unsplash.com/photo-1519602035691-16ac091344ef?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MjE1fHxiZWFjaHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    duration: 45,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Kayalık bölgede keşif.',
      'Yüzme ve piknik.',
      'Serbest zaman.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: false,
    isForFamilies: false,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm10',
    categories: ['c4'],
    title: 'Büyük Çöl',
    tripType: TripType.Activities,
    season: Season.spring,
    imageUrl:
        'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8ZGVzZXJ0fGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    duration: 30,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Çöl kampı kurulumu.',
      'Yürüyüş ve gece ateşi.',
      'Gündüz etkinlikleri.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: true,
    isForFamilies: true,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm11',
    categories: ['c4', 'c1'],
    title: 'Batı Çölü',
    tripType: TripType.Activities,
    season: Season.summer,
    imageUrl:
        'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTB8fHRyYXZlbHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    duration: 30,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Kamp kurulumu.',
      'Çöl yürüyüşü.',
      'Dinlenme ve alışveriş.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: true,
    isForFamilies: true,
    numberOfTrips: 1,
  ),
  Trip(
    id: 'm12',
    categories: ['c4'],
    title: 'Kumlu Çöl',
    tripType: TripType.Activities,
    season: Season.summer,
    imageUrl:
        'https://images.unsplash.com/photo-1452022582947-b521d8779ab6?ixid=MXwxMjA3fDB8MHxzZWFyY2h8ODN8fGRlc2VydHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    duration: 30,
    activities: [
      'Tarihi yerleri ziyaret',
      'Yürüyüş turu',
      'Alışveriş merkezlerini ziyaret',
      'Öğle yemeği',
      'Manzaranın tadını çıkarma'
    ],
    program: [
      'Kamp açılışı.',
      'Yürüyüş ve etkinlik.',
      'Alışveriş ve dinlenme.',
      'Dönüş.'
    ],
    isInSummer: true,
    isInWinter: true,
    isForFamilies: false,
    numberOfTrips: 1,
  ),

  Trip( 
  id: 'm13',
  categories: ['c5'],
  title: 'Birinci Şehir',
  tripType: TripType.Activities,
  season: Season.summer,
  imageUrl:
      'https://images.unsplash.com/photo-1498307833015-e7b400441eb8?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NDJ8fHRyYXZlbHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
  duration: 30,
  activities: [
    'Tarihi yerleri ziyaret',
    'Yürüyüş turu',
    'Alışveriş merkezi gezisi',
    'Öğle yemeği',
    'Manzara keyfi'
  ],
  program: [
    'Tarihi ve kültürel yerler gezisi.',
    'Şehir içi tur ve alışveriş.',
    'Yemek ve dinlenme.',
    'Manzara ve fotoğraf molaları.',
  ],
  isInSummer: true,
  isInWinter: false,
  isForFamilies: true,
  numberOfTrips: 1,
),
Trip(
  id: 'm14',
  categories: ['c5'],
  title: 'İkinci Şehir',
  tripType: TripType.Activities,
  season: Season.spring,
  imageUrl:
      'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NjR8fHRyYXZlbHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
  duration: 30,
  activities: [
    'Tarihi yerleri ziyaret',
    'Yürüyüş turu',
    'Alışveriş merkezi gezisi',
    'Öğle yemeği',
    'Manzara keyfi'
  ],
  program: [
    'Tarihi ve kültürel yerler gezisi.',
    'Şehir içi tur ve alışveriş.',
    'Yemek ve dinlenme.',
    'Manzara ve fotoğraf molaları.',
  ],
  isInSummer: true,
  isInWinter: true,
  isForFamilies:false,
  numberOfTrips: 1,
),
Trip(
  id: 'm15',
  categories: ['c5'],
  title: 'Eski Şehir',
  tripType: TripType.Activities,
  season: Season.winter,
  imageUrl:
      'https://images.unsplash.com/photo-1519923041107-e4dc8d9193da?ixid=MXwxMjA3fDB8MHxzZWFyY2h8Njd8fG9sZCUyMGNpdHl8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
  duration: 30,
  activities: [
    'Tarihi yerleri ziyaret',
    'Yürüyüş turu',
    'Alışveriş merkezi gezisi',
    'Öğle yemeği',
    'Manzara keyfi'
  ],
  program: [
    'Tarihi ve kültürel yerler gezisi.',
    'Şehir içi tur ve alışveriş.',
    'Yemek ve dinlenme.',
    'Manzara ve fotoğraf molaları.',
  ],
  isInSummer: true,
  isInWinter: true,
  isForFamilies: true,
  numberOfTrips: 1,
),
Trip(
  id: 'm16',
  categories: ['c6'],
  title: 'Kayak Sporu',
  tripType: TripType.Activities,
  season: Season.winter,
  imageUrl:
      'https://images.unsplash.com/photo-1605540436563-5bca919ae766?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c2tpaW5nfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
  duration: 30,
  activities: [
    'Tarihi yerleri ziyaret',
    'Yürüyüş turu',
    'Alışveriş merkezi gezisi',
    'Öğle yemeği',
    'Manzara keyfi'
  ],
  program: [
    'Tarihi ve kültürel yerler gezisi.',
    'Şehir içi tur ve alışveriş.',
    'Yemek ve dinlenme.',
    'Manzara ve fotoğraf molaları.',
  ],
  isInSummer: true,
  isInWinter: false,
  isForFamilies: true,
  numberOfTrips: 1,
),
Trip(
  id: 'm17',
  categories: ['c6', 'c2'],
  title: 'Yamaç Paraşütü',
  tripType: TripType.Activities,
  season: Season.winter,
  imageUrl:
      'https://images.unsplash.com/photo-1601024445121-e5b82f020549?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTJ8fHBhcmFjaHV0ZSUyMGp1bXBpbmd8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
  duration: 30,
  activities: [
    'Tarihi yerleri ziyaret',
    'Yürüyüş turu',
    'Alışveriş merkezi gezisi',
    'Öğle yemeği',
    'Manzara keyfi'
  ],
  program: [
    'Tarihi ve kültürel yerler gezisi.',
    'Şehir içi tur ve alışveriş.',
    'Yemek ve dinlenme.',
    'Manzara ve fotoğraf molaları.',
  ],
  isInSummer:false,
  isInWinter: true,
  isForFamilies: true,
  numberOfTrips: 1,
),

];
