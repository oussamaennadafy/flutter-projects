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
    apiKey: 'AIzaSyDpzjoCkkAAEvtnr1D3BXIPBFApAmdA3Lo',
    appId: '1:123386505184:web:55a66c0bc7581cb5b02d85',
    messagingSenderId: '123386505184',
    projectId: 'expense-tracker-9999',
    authDomain: 'expense-tracker-9999.firebaseapp.com',
    storageBucket: 'expense-tracker-9999.appspot.com',
    measurementId: 'G-CXLDLT3T41',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCu6Q_d0zNv7VmbqeO4QJ-QtIjpTkGmCzo',
    appId: '1:123386505184:android:45ea97afdafdb444b02d85',
    messagingSenderId: '123386505184',
    projectId: 'expense-tracker-9999',
    storageBucket: 'expense-tracker-9999.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB5RmLLBYCCQhkQwm-eijDcu94pNnVF7EA',
    appId: '1:123386505184:ios:580687de00601317b02d85',
    messagingSenderId: '123386505184',
    projectId: 'expense-tracker-9999',
    storageBucket: 'expense-tracker-9999.appspot.com',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB5RmLLBYCCQhkQwm-eijDcu94pNnVF7EA',
    appId: '1:123386505184:ios:580687de00601317b02d85',
    messagingSenderId: '123386505184',
    projectId: 'expense-tracker-9999',
    storageBucket: 'expense-tracker-9999.appspot.com',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDpzjoCkkAAEvtnr1D3BXIPBFApAmdA3Lo',
    appId: '1:123386505184:web:f2fd5aa98edf1e27b02d85',
    messagingSenderId: '123386505184',
    projectId: 'expense-tracker-9999',
    authDomain: 'expense-tracker-9999.firebaseapp.com',
    storageBucket: 'expense-tracker-9999.appspot.com',
    measurementId: 'G-TYRDYCP2GJ',
  );
}