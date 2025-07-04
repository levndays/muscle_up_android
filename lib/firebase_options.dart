// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDXdgCNhubTMaavu2na3KA3CAvPlriiPOI',
    appId: '1:1012783717502:web:89f5605ac9ecd155938c2f',
    messagingSenderId: '1012783717502',
    projectId: 'muscle-up-8c275',
    authDomain: 'muscle-up-8c275.firebaseapp.com',
    storageBucket: 'muscle-up-8c275.firebasestorage.app',
    measurementId: 'G-GV825LKZPE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnwYrzMP3nVK_bpX86pgItzDt-FK77NX8',
    appId: '1:1012783717502:android:2f7ce9326b23c730938c2f',
    messagingSenderId: '1012783717502',
    projectId: 'muscle-up-8c275',
    storageBucket: 'muscle-up-8c275.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCH_-IcY1EU-mHG5E8-Gj9W2iCjcmisBfk',
    appId: '1:1012783717502:ios:debb2939085adc3f938c2f',
    messagingSenderId: '1012783717502',
    projectId: 'muscle-up-8c275',
    storageBucket: 'muscle-up-8c275.firebasestorage.app',
    iosBundleId: 'com.example.muscleUp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCH_-IcY1EU-mHG5E8-Gj9W2iCjcmisBfk',
    appId: '1:1012783717502:ios:debb2939085adc3f938c2f',
    messagingSenderId: '1012783717502',
    projectId: 'muscle-up-8c275',
    storageBucket: 'muscle-up-8c275.firebasestorage.app',
    iosBundleId: 'com.example.muscleUp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDXdgCNhubTMaavu2na3KA3CAvPlriiPOI',
    appId: '1:1012783717502:web:a6ef83f4982ba06e938c2f',
    messagingSenderId: '1012783717502',
    projectId: 'muscle-up-8c275',
    authDomain: 'muscle-up-8c275.firebaseapp.com',
    storageBucket: 'muscle-up-8c275.firebasestorage.app',
    measurementId: 'G-8LRCSHJ4VK',
  );
}
