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
  final String fullNameLabel = 'Full Name';
  final String forgotPasswordButton = 'Forgot Password?';
  final String sendResetLinkButton = 'Send Reset Link';
  final String orContinueWith = 'OR CONTINUE WITH';
  final String googleButton = 'Google';
  final String appleButton = 'Apple ID';
  final String agreeCheckbox = 'I agree to the Terms of Use and Privacy Policy';
  final String footnotePrefix = 'By continuing, you agree to MVP Travel\'s premium ';
  final String termsOfUseLink = 'terms of use';
  final String footnoteAnd = ' and ';
  final String privacyStandardsLink = 'global privacy standards';
  final String footnoteSuffix = '.';

  final String userNotFound = 'No user found with this email.';
  final String wrongPassword = 'Incorrect password. Please try again.';
  final String emailAlreadyInUse = 'This email is already registered.';
  final String weakPassword = 'The password is too weak (minimum 8 characters with at least one number).';
  final String networkRequestFailed = 'Network connection failed. Please check your internet.';
  final String invalidEmail = 'The email address is invalid.';
  final String operationNotAllowed = 'This authentication method is not enabled.';
  final String userDisabled = 'This user account has been disabled.';
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

  final String title = 'Configure Your Trip';
  final String premiumBadge = 'PREMIUM EXPERIENCE';
  final String dateSection = 'Select Tour Date';
  final String participantsSection = 'Participants';
  final String adultsLabel = 'Adults';
  final String adultsSubtitle = 'Ages 13 or above';
  final String childrenLabel = 'Children';
  final String childrenSubtitle = 'Ages 2-12';
  final String privateOptionsSection = 'Private Options';
  final String privateVehicleLabel = 'Private Vehicle / Exclusive SUV & Driver';
  final String groupSizeLimitLabel = 'Group Size Limit';
  final String logisticsSection = 'Logistics';
  final String pickupLocationLabel = 'Pickup Location';
  final String pickupLocationHint = 'Enter Hotel Name or Address';
  final String specialRequestsLabel = 'Special Requests';
  final String specialRequestsHint = 'Dietary requirements, accessibility needs, etc...';
  final String totalLabel = 'Total';
  final String proceedButton = 'Proceed to Payment →';
}

class _CheckoutStrings {
  const _CheckoutStrings();

  final String title = 'Checkout';
  final String orderSummary = 'Order Summary';
  final String cardholderNameLabel = 'Cardholder Name';
  final String cardholderNameHint = 'John Doe';
  final String cardNumberLabel = 'Card Number';
  final String cardNumberHint = '4111 2222 3333 4444';
  final String expiryLabel = 'Expiry';
  final String expiryHint = 'MM/YY';
  final String cvvLabel = 'CVV';
  final String cvvHint = '123';
  final String saveCardLabel = 'Save card details for future bookings';
  final String bankTransferRow = 'Bank Transfer';
  final String bankTransferTitle = 'Bank Details';
  final String bankTransferInstructions = 'Please transfer the total amount to the bank details below. Your booking will be processed once the transfer is cleared.';
  final String bankName = 'MVP International Bank';
  final String bankAccount = 'Account: 9876-5432-1098';
  final String bankRouting = 'Routing/IBAN: MVPTAEAAXXX';
  final String footnote = 'Secure Checkout — this is a demo payment flow. No real charge will be made.';
  final String applePayButton = 'Apple Pay';
  final String googlePayButton = 'Google Pay';
  final String demoBadge = 'DEMO';
  final String payWithCard = 'OR PAY WITH CARD';
  final String payButton = 'Pay';
  final String paymentFailed = 'Payment failed. Please try again.';
  
  // Success Screen
  final String successHeader = 'Payment Successful';
  final String successSub = 'Your expedition is now confirmed. A digital receipt has been sent to your email.';
  final String referenceLabel = 'BOOKING ID:';
  final String viewItineraryButton = 'View Your Itinerary →';
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
