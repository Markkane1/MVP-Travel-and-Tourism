import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/user_entity.dart';

part 'auth_controller.g.dart';

/// Manages the authentication state of the current user session.
@riverpod
class AuthController extends _$AuthController {
  late final AuthService _authService;
  late final FirestoreService _firestoreService;

  @override
  FutureOr<UserEntity?> build() {
    _authService = ref.watch(authServiceProvider);
    _firestoreService = ref.watch(firestoreServiceProvider);

    // Sync state changes from the stream to Riverpod provider state
    final subscription = _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return _authService.currentUser;
  }

  /// Signs in a user using email and password.
  Future<Result<UserEntity>> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _authService.signInWithEmail(email, password);
    result.when(
      onSuccess: (user) {
        state = AsyncValue.data(user);
      },
      onFailure: (exception) {
        state = AsyncValue.error(exception, StackTrace.current);
      },
    );
    return result;
  }

  /// Registers a new user and creates their Firestore user profile document.
  Future<Result<UserEntity>> register(
    String name,
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    final result = await _authService.registerWithEmail(email, password);

    return result.when(
      onSuccess: (user) async {
        try {
          // Initialize user profile in Firestore
          await _firestoreService.set<Map<String, dynamic>>(
            path: 'users/${user.uid}',
            data: {
              'displayName': name,
              'email': email,
              'tier': 'Standard',
              'loyaltyPoints': 0,
            },
            toJson: (val) => {
              ...val,
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
          
          final updatedUser = user.copyWith(displayName: name);
          state = AsyncValue.data(updatedUser);
          return Result.success(updatedUser);
        } catch (e) {
          state = AsyncValue.error(e, StackTrace.current);
          return const Result.failure(
            AppException.unknown(
              'Account created, but failed to initialize user profile document.',
            ),
          );
        }
      },
      onFailure: (exception) {
        state = AsyncValue.error(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }

  /// Authenticates using Google Sign-In, initializing user document if first-time.
  Future<Result<UserEntity>> loginWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _authService.signInWithGoogle();

    return result.when(
      onSuccess: (user) async {
        try {
          final exists = await _firestoreService.get(
            path: 'users/${user.uid}',
            fromJson: (json) => json,
            toJson: (json) => json,
          );
          if (exists == null) {
            await _firestoreService.set<Map<String, dynamic>>(
              path: 'users/${user.uid}',
              data: {
                'displayName': user.displayName ?? 'Google User',
                'email': user.email,
                'tier': 'Standard',
                'loyaltyPoints': 0,
              },
              toJson: (val) => {
                ...val,
                'createdAt': FieldValue.serverTimestamp(),
              },
            );
          }
          state = AsyncValue.data(user);
          return Result.success(user);
        } catch (e) {
          state = AsyncValue.data(user);
          return Result.success(user);
        }
      },
      onFailure: (exception) {
        state = AsyncValue.error(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }

  /// Authenticates using Apple Sign-In, initializing user document if first-time.
  Future<Result<UserEntity>> loginWithApple() async {
    state = const AsyncValue.loading();
    final result = await _authService.signInWithApple();

    return result.when(
      onSuccess: (user) async {
        try {
          final exists = await _firestoreService.get(
            path: 'users/${user.uid}',
            fromJson: (json) => json,
            toJson: (json) => json,
          );
          if (exists == null) {
            await _firestoreService.set<Map<String, dynamic>>(
              path: 'users/${user.uid}',
              data: {
                'displayName': user.displayName ?? 'Apple User',
                'email': user.email,
                'tier': 'Standard',
                'loyaltyPoints': 0,
              },
              toJson: (val) => {
                ...val,
                'createdAt': FieldValue.serverTimestamp(),
              },
            );
          }
          state = AsyncValue.data(user);
          return Result.success(user);
        } catch (e) {
          state = AsyncValue.data(user);
          return Result.success(user);
        }
      },
      onFailure: (exception) {
        state = AsyncValue.error(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }

  /// Signs the current user out.
  Future<Result<void>> logout() async {
    state = const AsyncValue.loading();
    final result = await _authService.signOut();
    result.when(
      onSuccess: (_) {
        state = const AsyncValue.data(null);
      },
      onFailure: (exception) {
        state = AsyncValue.error(exception, StackTrace.current);
      },
    );
    return result;
  }

  /// Dispatches a password reset email.
  Future<Result<void>> sendPasswordReset(String email) async {
    return _authService.sendPasswordResetEmail(email);
  }
}
