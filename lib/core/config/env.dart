import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'firebase_options_dev.dart';
import 'firebase_options_prod.dart';

/// Environment configuration manager reading compilation definitions.
class Env {
  Env._();

  /// The active environment flavor ('dev' or 'prod').
  static const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// True if running in production flavor.
  static bool get isProd => flavor == 'prod';

  /// True if running in development flavor.
  static bool get isDev => flavor == 'dev';

  /// Firebase Options selection based on active flavor.
  static FirebaseOptions get firebaseOptions {
    if (isProd) {
      return DefaultFirebaseOptionsProd.currentPlatform;
    }
    return DefaultFirebaseOptionsDev.currentPlatform;
  }

  /// Stripe Publishable Key mapped per environment.
  static String get stripePublishableKey {
    if (isProd) {
      return const String.fromEnvironment('STRIPE_PUB_KEY_PROD', defaultValue: 'pk_live_placeholder');
    }
    return const String.fromEnvironment('STRIPE_PUB_KEY_DEV', defaultValue: 'pk_test_placeholder');
  }
}
