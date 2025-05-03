import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions, ${defaultTargetPlatform.name} platformu için yapılandırılmamış.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaRmsG0pkuv7vOa0DZKVXPIdTF1ayl4dQ',
    appId: '1:441311683716:android:88d60cd791d4cae5408ed1',
    messagingSenderId: '441311683716',
    projectId: 'fluttermobil-2b782',
    storageBucket: 'fluttermobil-2b782.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy...',
    appId: '1:123456789:ios:abcdef...',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBgY39iehOcust1qRJkaCBY-TOf5vNQBgQ',
    appId: '1:441311683716:web:22ba2d7461bc63db408ed1',
    messagingSenderId: '441311683716',
    projectId: 'fluttermobil-2b782',
    authDomain: 'fluttermobil-2b782.firebaseapp.com',
    storageBucket: 'fluttermobil-2b782.firebasestorage.app',
    databaseURL: 'https://fluttermobil-2b782-default-rtdb.europe-west1.firebasedatabase.app',
  );
} 