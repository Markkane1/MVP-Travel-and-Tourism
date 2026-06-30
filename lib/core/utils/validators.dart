/// Static input form validation helpers.
class Validators {
  Validators._();

  /// Validates that the input is a correctly formatted email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Validates that a password satisfies strength policy: 8+ characters, 1+ number.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final numberRegex = RegExp(r'[0-9]');
    if (!numberRegex.hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  /// Validates that the confirmation password matches the primary password exactly.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Validates that a field is not empty.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates that the input is a valid full name.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }
    final trimmed = value.trim();
    if (trimmed.split(' ').length < 2) {
      return 'Please enter your first and last name.';
    }
    return null;
  }
}
