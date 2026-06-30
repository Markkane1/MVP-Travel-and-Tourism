/// Environment configuration manager reading compilation definitions.
class Env {
  Env._();

  /// The active environment flavor ('dev' or 'prod').
  static const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// True if running in production flavor.
  static bool get isProd => flavor == 'prod';

  /// True if running in development flavor.
  static bool get isDev => flavor == 'dev';

  /// Stripe Publishable Key mapped per environment.
  static String get stripePublishableKey {
    if (isProd) {
      return const String.fromEnvironment('STRIPE_PUB_KEY_PROD', defaultValue: 'pk_live_placeholder');
    }
    return const String.fromEnvironment('STRIPE_PUB_KEY_DEV', defaultValue: 'pk_test_placeholder');
  }
}
