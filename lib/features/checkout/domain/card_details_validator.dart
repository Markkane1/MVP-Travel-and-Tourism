/// Validation helpers for checkout card input.
class CardValidationResult {
  final bool isValid;
  final String? errorMessage;

  const CardValidationResult({required this.isValid, this.errorMessage});
}

/// Validates the card details required before processing a checkout payment.
CardValidationResult validateCardDetails({
  required String name,
  required String cardNumber,
  required String expiry,
  required String cvv,
}) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    return const CardValidationResult(
      isValid: false,
      errorMessage: 'Please enter the cardholder name.',
    );
  }

  final normalizedCardNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
  if (!RegExp(r'^\d{12,19}$').hasMatch(normalizedCardNumber)) {
    return const CardValidationResult(
      isValid: false,
      errorMessage: 'Please enter a valid card number.',
    );
  }

  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry.trim())) {
    return const CardValidationResult(
      isValid: false,
      errorMessage: 'Please enter the expiry date in MM/YY format.',
    );
  }

  if (!RegExp(r'^\d{3,4}$').hasMatch(cvv.trim())) {
    return const CardValidationResult(
      isValid: false,
      errorMessage: 'Please enter a valid CVV.',
    );
  }

  return const CardValidationResult(isValid: true);
}
