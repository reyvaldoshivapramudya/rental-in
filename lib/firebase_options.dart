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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQ82jZHLksfJF4gZsK1JlQuD5dztHDv5w',
    appId: '1:944717689292:android:e69d5d9ddd7d78c75ded69',
    messagingSenderId: '944717689292',
    projectId: 'rental-in-4c0a1',
    storageBucket: 'rental-in-4c0a1.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7bw0JCD8X0Wq2qVaTA-2eNBJR3O7pPZE',
    appId: '1:944717689292:web:1f188860da834c375ded69',
    messagingSenderId: '944717689292',
    projectId: 'rental-in-4c0a1',
    authDomain: 'rental-in-4c0a1.firebaseapp.com',
    storageBucket: 'rental-in-4c0a1.firebasestorage.app',
    measurementId: 'G-G8TNYSRQ1J',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAaSRsb0O0rotcVSwA1pBRMUuIp98n8Cc',
    appId: '1:944717689292:ios:98a3d7581bbedd015ded69',
    messagingSenderId: '944717689292',
    projectId: 'rental-in-4c0a1',
    storageBucket: 'rental-in-4c0a1.firebasestorage.app',
    iosBundleId: 'com.example.rentalinApp',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAaSRsb0O0rotcVSwA1pBRMUuIp98n8Cc',
    appId: '1:944717689292:ios:98a3d7581bbedd015ded69',
    messagingSenderId: '944717689292',
    projectId: 'rental-in-4c0a1',
    storageBucket: 'rental-in-4c0a1.firebasestorage.app',
    iosBundleId: 'com.example.rentalinApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC7bw0JCD8X0Wq2qVaTA-2eNBJR3O7pPZE',
    appId: '1:944717689292:web:ce7a2416dc2183815ded69',
    messagingSenderId: '944717689292',
    projectId: 'rental-in-4c0a1',
    authDomain: 'rental-in-4c0a1.firebaseapp.com',
    storageBucket: 'rental-in-4c0a1.firebasestorage.app',
    measurementId: 'G-C85HCGE1S2',
  );

}