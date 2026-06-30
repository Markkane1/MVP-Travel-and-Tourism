import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/user_entity.dart';
import '../utils/result.dart';
import '../errors/app_exception.dart';
import '../constants/app_strings.dart';

/// A service that handles all Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService();

  /// Stream of user sign-in status changes, mapped to UserEntity.
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUser(user) : null;
    });
  }

  /// Synchronous check for current sign-in status.
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Returns the current signed in UserEntity or null if unauthenticated.
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? _mapFirebaseUser(user) : null;
  }

  /// Signs in a user using email and password.
  Future<Result<UserEntity>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Result.failure(AppException.auth(AppStrings.common.genericError));
      }
      return Result.success(_mapFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthException(e));
    } catch (e, s) {
      return _handleGeneralError(e, s);
    }
  }

  /// Registers a new user using email and password.
  Future<Result<UserEntity>> registerWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Result.failure(AppException.auth(AppStrings.common.genericError));
      }
      return Result.success(_mapFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthException(e));
    } catch (e, s) {
      return _handleGeneralError(e, s);
    }
  }

  /// Authenticates using Google Sign-In.
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return Result.failure(AppException.auth(AppStrings.common.genericError));
      }
      return Result.success(_mapFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthException(e));
    } catch (e, s) {
      return _handleGeneralError(e, s);
    }
  }

  /// Authenticates using Apple Sign-In.
  Future<Result<UserEntity>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return Result.failure(AppException.auth(AppStrings.common.genericError));
      }
      return Result.success(_mapFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthException(e));
    } catch (e, s) {
      return _handleGeneralError(e, s);
    }
  }

  /// Triggers reset password link delivery.
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthException(e));
    } catch (e, s) {
      return _handleGeneralError(e, s);
    }
  }

  /// Signs the current user out of Firebase.
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn.instance.signOut();
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthException(e));
    } catch (e, s) {
      return _handleGeneralError(e, s);
    }
  }

  // Maps standard Firebase User object onto the domain UserEntity model.
  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // Converts Firebase Authentication specific errors to User-facing messages.
  AppException _handleAuthException(FirebaseAuthException e) {
    final String message;
    switch (e.code) {
      case 'user-not-found':
        message = AppStrings.auth.userNotFound;
        break;
      case 'wrong-password':
      case 'invalid-credential':
        message = AppStrings.auth.wrongPassword;
        break;
      case 'email-already-in-use':
        message = AppStrings.auth.emailAlreadyInUse;
        break;
      case 'weak-password':
        message = AppStrings.auth.weakPassword;
        break;
      case 'invalid-email':
        message = AppStrings.auth.invalidEmail;
        break;
      case 'operation-not-allowed':
        message = AppStrings.auth.operationNotAllowed;
        break;
      case 'user-disabled':
        message = AppStrings.auth.userDisabled;
        break;
      case 'network-request-failed':
        message = AppStrings.auth.networkRequestFailed;
        break;
      default:
        message = e.message ?? AppStrings.common.genericError;
    }
    return AppException.auth(message);
  }

  // Captures and returns unhandled system error blocks inside AppException.
  Result<T> _handleGeneralError<T>(Object e, StackTrace s) {
    if (e is FirebaseAuthException) {
      return Result.failure(_handleAuthException(e));
    }
    return Result.failure(AppException.unknown(AppStrings.common.genericError));
  }
}

/// Provider for the AuthService instance.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
