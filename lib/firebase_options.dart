// Archivo generado por FlutterFire CLI.
// ...
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDxKtQ6gtmpMfeYQunXlqa9E8NiLMT3dmY',
    appId: '1:139849852555:web:3b343c5cfede9e57e7d68e',
    messagingSenderId: '139849852555',
    projectId: 'bookapps-bb7fe',
    authDomain: 'bookapps-bb7fe.firebaseapp.com',
    storageBucket: 'bookapps-bb7fe.firebasestorage.app',
    measurementId: 'G-31EKZ3Y5LJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_QG18P9-2SeEhn6mXBJLY04iPUEYp2zc',
    appId: '1:139849852555:android:de4b814a7faccdbde7d68e',
    messagingSenderId: '139849852555',
    projectId: 'bookapps-bb7fe',
    storageBucket: 'bookapps-bb7fe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvQT-hRDBipmWUUaQo4YwIw-vZxpoob1k',
    appId: '1:139849852555:ios:517d12396d831fdae7d68e',
    messagingSenderId: '139849852555',
    projectId: 'bookapps-bb7fe',
    storageBucket: 'bookapps-bb7fe.firebasestorage.app',
    iosBundleId: 'com.example.bookapps',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvQT-hRDBipmWUUaQo4YwIw-vZxpoob1k',
    appId: '1:139849852555:ios:517d12396d831fdae7d68e',
    messagingSenderId: '139849852555',
    projectId: 'bookapps-bb7fe',
    storageBucket: 'bookapps-bb7fe.firebasestorage.app',
    iosBundleId: 'com.example.bookapps',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDxKtQ6gtmpMfeYQunXlqa9E8NiLMT3dmY',
    appId: '1:139849852555:web:34d3ad6d86ecd783e7d68e',
    messagingSenderId: '139849852555',
    projectId: 'bookapps-bb7fe',
    authDomain: 'bookapps-bb7fe.firebaseapp.com',
    storageBucket: 'bookapps-bb7fe.firebasestorage.app',
    measurementId: 'G-7MGG3SBBM3',
  );

}

//Firebase configuration file lib\firebase_options.dart generated successfully with the following Firebase apps:

//Platform  Firebase App Id
//web       1:139849852555:web:3b343c5cfede9e57e7d68e
//android   1:139849852555:android:de4b814a7faccdbde7d68e
//ios       1:139849852555:ios:517d12396d831fdae7d68e
//macos     1:139849852555:ios:517d12396d831fdae7d68e
//windows   1:139849852555:web:34d3ad6d86ecd783e7d68e
