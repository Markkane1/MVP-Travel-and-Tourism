import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A stub implementation of the AuthService for the bootstrap/core setup.
/// This will be fully implemented with Firebase Auth in subsequent steps.
class AuthService {
  AuthService();

  // A controller that emits auth status changes.
  static final _authStateController = StreamController<bool>.broadcast()..add(true); // Default to signed-in for development

  /// Stream of user sign-in status changes.
  Stream<bool> get authStateChanges => _authStateController.stream;

  /// Sync check for current sign-in status.
  bool get isSignedIn => _signedInValue;
  static bool _signedInValue = true;

  /// Helper to toggle sign-in state for manual verification/guards.
  void setSignedIn(bool signedIn) {
    _signedInValue = signedIn;
    _authStateController.add(signedIn);
  }
}

/// Provider for the AuthService stub.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
