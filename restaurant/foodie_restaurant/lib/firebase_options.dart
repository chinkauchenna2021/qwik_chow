// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGmEJ36dfiUHTVwhDS2ICM8iUFoCxBt04',
    appId: '1:996880334783:android:afd888e157020fedb72b0a',
    messagingSenderId: '996880334783',
    projectId: 'foodiesrestaurantlogis',
    storageBucket: 'foodiesrestaurantlogis.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBY_9XvYVF3I0Dbbkc0kZcRk89vxFg6hgw',
    appId: '1:996880334783:ios:226f842db5315a02b72b0a',
    messagingSenderId: '996880334783',
    projectId: 'foodiesrestaurantlogis',
    storageBucket: 'foodiesrestaurantlogis.appspot.com',
    iosBundleId: 'com.foodies.restaurant.ios',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdxJNNKYEymF05X17Fys9Tu0yNDS-ewpk',
    appId: '1:996880334783:web:4f0acfa41844073bb72b0a',
    messagingSenderId: '996880334783',
    projectId: 'foodiesrestaurantlogis',
    authDomain: 'foodiesrestaurantlogis.firebaseapp.com',
    storageBucket: 'foodiesrestaurantlogis.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBY_9XvYVF3I0Dbbkc0kZcRk89vxFg6hgw',
    appId: '1:996880334783:ios:3e2d898fbb095e03b72b0a',
    messagingSenderId: '996880334783',
    projectId: 'foodiesrestaurantlogis',
    storageBucket: 'foodiesrestaurantlogis.appspot.com',
    iosBundleId: 'com.foodies.restaurant.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAdxJNNKYEymF05X17Fys9Tu0yNDS-ewpk',
    appId: '1:996880334783:web:463c5195d21553afb72b0a',
    messagingSenderId: '996880334783',
    projectId: 'foodiesrestaurantlogis',
    authDomain: 'foodiesrestaurantlogis.firebaseapp.com',
    storageBucket: 'foodiesrestaurantlogis.appspot.com',
  );

}