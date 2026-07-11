import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for the production flavor.
/// This file acts as a placeholder and can be regenerated via `flutterfire configure`.
class DefaultFirebaseOptionsProd {
  DefaultFirebaseOptionsProd._();

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
          'DefaultFirebaseOptionsProd are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-prod-android-api-key',
    appId: '1:1234567890:android:prod1234567890',
    messagingSenderId: '1234567890',
    projectId: 'mvp-travel-prod',
    storageBucket: 'mvp-travel-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-prod-ios-api-key',
    appId: '1:1234567890:ios:prod1234567890',
    messagingSenderId: '1234567890',
    projectId: 'mvp-travel-prod',
    storageBucket: 'mvp-travel-prod.appspot.com',
    iosBundleId: 'com.mvptravelandtourism.app',
  );
}
