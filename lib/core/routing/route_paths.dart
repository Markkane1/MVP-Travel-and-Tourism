/// Constant path definitions for the GoRouter navigation system.
class RoutePaths {
  RoutePaths._();

  static const String auth = '/auth';
  static const String forgotPassword = '/auth/forgot-password';
  
  // Bottom Navigation Shell Tabs
  static const String explore = '/explore';
  static const String search = '/search';
  static const String trips = '/trips';
  static const String concierge = '/concierge';
  static const String profile = '/profile';

  // Sub-routes or standalone screens
  static const String searchResults = '/search/results';
  static const String tourDetails = '/tour/:tourId';
  static const String bookingConfig = '/tour/:tourId/book';
  static const String checkout = '/booking/:bookingId/checkout';
  static const String paymentSuccess = '/booking/:bookingId/success';
  static const String bookingConfirmation = '/trips/:bookingId';
  static const String reviewTrip = '/trips/:bookingId/review';
  static const String reviewSuccess = '/trips/:bookingId/review/success';
  static const String editProfile = '/profile/edit';
  static const String paymentMethods = '/profile/payments';
  static const String notifications = '/notifications';
  static const String legalTerms = '/legal/terms';
  static const String legalPrivacy = '/legal/privacy';

  // Helper getters to generate parameterized paths
  static String tourDetailsPath(String tourId) => '/tour/$tourId';
  static String bookingConfigPath(String tourId) => '/tour/$tourId/book';
  static String checkoutPath(String bookingId) => '/booking/$bookingId/checkout';
  static String paymentSuccessPath(String bookingId) => '/booking/$bookingId/success';
  static String bookingConfirmationPath(String bookingId) => '/trips/$bookingId';
  static String reviewTripPath(String bookingId) => '/trips/$bookingId/review';
  static String reviewSuccessPath(String bookingId) => '/trips/$bookingId/review/success';
}
