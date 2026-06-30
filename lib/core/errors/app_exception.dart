/// Base class for all application-specific exceptions.
sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when a network-related error occurs (e.g. no internet connectivity, timeout).
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Thrown when authentication or registration fails.
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Thrown when form validation or input validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Thrown when a payment operation fails (e.g. Stripe checkout fails).
class PaymentException extends AppException {
  const PaymentException(super.message, [super.code]);
}

/// Thrown when an unknown error occurs.
class UnknownException extends AppException {
  const UnknownException(super.message, [super.code]);
}
