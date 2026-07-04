import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for the development flavor.
/// This file acts as a placeholder and can be regenerated via `flutterfire configure`.
class DefaultFirebaseOptionsDev {
  DefaultFirebaseOptionsDev._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web target is not supported.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-dev-android-api-key',
    appId: '1:1234567890:android:dev1234567890',
    messagingSenderId: '1234567890',
    projectId: 'mvp-travel-dev',
    storageBucket: 'mvp-travel-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-dev-ios-api-key',
    appId: '1:1234567890:ios:dev1234567890',
    messagingSenderId: '1234567890',
    projectId: 'mvp-travel-dev',
    storageBucket: 'mvp-travel-dev.appspot.com',
    iosBundleId: 'com.mvptravelandtourism.app',
  );
}
