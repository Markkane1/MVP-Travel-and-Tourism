import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import '../../firebase_options.dart';

/// Environment configuration manager reading compilation definitions.
class Env {
  Env._();

  /// The active environment flavor ('dev' or 'prod').
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  /// True if running in production flavor.
  static bool get isProd => flavor == 'prod';

  /// True if running in development flavor.
  static bool get isDev => flavor == 'dev';

  /// True when integration tests ask the app to skip nondeterministic setup.
  static const bool skipNotificationSetup = bool.fromEnvironment(
    'SKIP_NOTIFICATION_SETUP',
    defaultValue: false,
  );

  /// Firebase Options selection based on active flavor.
  static FirebaseOptions get firebaseOptions {
    return DefaultFirebaseOptions.currentPlatform;
  }

  /// Stripe Publishable Key mapped per environment.
  static String get stripePublishableKey {
    if (isProd) {
      return const String.fromEnvironment(
        'STRIPE_PUB_KEY_PROD',
        defaultValue: 'pk_live_placeholder',
      );
    }
    return const String.fromEnvironment(
      'STRIPE_PUB_KEY_DEV',
      defaultValue: 'pk_test_placeholder',
    );
  }

  /// Google Maps SDK key for native map widgets.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
