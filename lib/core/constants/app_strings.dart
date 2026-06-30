/// Central repository for all user-facing copy strings in the application.
class AppStrings {
  AppStrings._();

  static const common = _CommonStrings();
  static const auth = _AuthStrings();
  static const explore = _ExploreStrings();
  static const search = _SearchStrings();
  static const tourDetails = _TourDetailsStrings();
  static const booking = _BookingStrings();
  static const checkout = _CheckoutStrings();
  static const trips = _TripsStrings();
  static const profile = _ProfileStrings();
  static const concierge = _ConciergeStrings();
  static const reviews = _ReviewsStrings();
}

class _CommonStrings {
  const _CommonStrings();

  final String appDisplayName = 'MVP Travel';
  final String appLegalName = 'MVP Travel and Tourism LLC';
  final String retryButton = 'Retry';
  final String genericError = 'Something went wrong. Please try again.';
  final String noInternet = 'No internet connection.';
}

class _AuthStrings {
  const _AuthStrings();

  final String signInButton = 'Sign In';
  final String createAccountButton = 'Create Account';
  final String emailLabel = 'Email Address';
  final String passwordLabel = 'Password';
  final String confirmPasswordLabel = 'Confirm Password';
  final String forgotPasswordButton = 'Forgot Password?';
}

class _ExploreStrings {
  const _ExploreStrings();
}

class _SearchStrings {
  const _SearchStrings();
}

class _TourDetailsStrings {
  const _TourDetailsStrings();
}

class _BookingStrings {
  const _BookingStrings();
}

class _CheckoutStrings {
  const _CheckoutStrings();
}

class _TripsStrings {
  const _TripsStrings();
}

class _ProfileStrings {
  const _ProfileStrings();
}

class _ConciergeStrings {
  const _ConciergeStrings();
}

class _ReviewsStrings {
  const _ReviewsStrings();
}
