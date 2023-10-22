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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC5Cv-h-06D4LJzoqRFGJM41TmnFoW-5yg',
    appId: '1:756969800896:web:2e57d3548aade83a789925',
    messagingSenderId: '756969800896',
    projectId: 'chatapp-4c31f',
    authDomain: 'chatapp-4c31f.firebaseapp.com',
    storageBucket: 'chatapp-4c31f.appspot.com',
    measurementId: 'G-PGYDH7RV8V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAHtHCY2X6IlxQ3kdj7T50OzeSCZns84mU',
    appId: '1:756969800896:android:6fe85642bf6ecc49789925',
    messagingSenderId: '756969800896',
    projectId: 'chatapp-4c31f',
    storageBucket: 'chatapp-4c31f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5SM-EX95bvCsQmECmzsSxrQod5koemWg',
    appId: '1:756969800896:ios:a2714c3723f6fb7f789925',
    messagingSenderId: '756969800896',
    projectId: 'chatapp-4c31f',
    storageBucket: 'chatapp-4c31f.appspot.com',
    iosClientId: '756969800896-j7otg666ern829resnkh78124hgml5dg.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5SM-EX95bvCsQmECmzsSxrQod5koemWg',
    appId: '1:756969800896:ios:cc16d81087bd9af1789925',
    messagingSenderId: '756969800896',
    projectId: 'chatapp-4c31f',
    storageBucket: 'chatapp-4c31f.appspot.com',
    iosClientId: '756969800896-8rpakmbbc3tate4jbo4bmi4eba3ftpsb.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatapp.RunnerTests',
  );
}
