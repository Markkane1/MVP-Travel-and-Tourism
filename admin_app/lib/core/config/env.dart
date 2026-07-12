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

  /// Firebase Options selection based on active flavor.
  static FirebaseOptions get firebaseOptions {
    return DefaultFirebaseOptions.currentPlatform;
  }

  static const String appCheckWebSiteKey = String.fromEnvironment(
    'FIREBASE_APP_CHECK_WEB_KEY',
    defaultValue: '',
  );
}
