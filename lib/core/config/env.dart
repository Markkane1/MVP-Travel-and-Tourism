import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import '../../firebase_options.dart';

/// Environment configuration manager reading compilation definitions.
class Env {
  Env._();

  /// The active environment flavor ('dev' or 'prod').
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'prod',
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

  /// Google Maps SDK key for native map widgets.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String appCheckWebSiteKey = String.fromEnvironment(
    'FIREBASE_APP_CHECK_WEB_KEY',
    defaultValue: '6LfBW2MtAAAAAGw29B4LzyvWEjaHV0BqVXCsw1mZ',
  );

  static bool get hasProductionAppCheckWebSiteKey =>
      appCheckWebSiteKey.isNotEmpty &&
      !appCheckWebSiteKey.toLowerCase().contains('placeholder') &&
      !appCheckWebSiteKey.toLowerCase().contains('test');

  static const String firebaseMessagingVapidKey = String.fromEnvironment(
    'FIREBASE_MESSAGING_VAPID_KEY',
    defaultValue: '',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://flutterapi.duckdns.org',
  );

  static const String bankName = String.fromEnvironment('BANK_NAME');
  static const String bankAccountTitle = String.fromEnvironment(
    'BANK_ACCOUNT_TITLE',
  );
  static const String bankAccountNumber = String.fromEnvironment(
    'BANK_ACCOUNT_NUMBER',
  );
  static const String bankIban = String.fromEnvironment('BANK_IBAN');

  static bool get hasBankTransferDetails =>
      bankName.isNotEmpty &&
      bankAccountTitle.isNotEmpty &&
      bankAccountNumber.isNotEmpty &&
      bankIban.isNotEmpty;
}
