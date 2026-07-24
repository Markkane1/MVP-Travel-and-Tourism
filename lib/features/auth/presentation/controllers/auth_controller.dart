import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/user_entity.dart';

part 'auth_controller.g.dart';

/// Manages the authentication state of the current user session.
@riverpod
class AuthController extends _$AuthController {
  late final AuthService _authService;

  @override
  FutureOr<UserEntity?> build() {
    _authService = ref.watch(authServiceProvider);

    // Sync state changes from the stream to Riverpod provider state
    final subscription = _authService.authStateChanges.listen((user) {
      if (!ref.mounted) {
        return;
      }
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
    if (ref.mounted) {
      result.when(
        onSuccess: (_) {},
        onFailure: (exception) {
          state = AsyncValue.error(exception, StackTrace.current);
        },
      );
    }
    return result;
  }

  /// Registers a new user and creates their API-backed profile.
  Future<Result<UserEntity>> register(
    String name,
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    final result = await _authService.registerWithEmailAndProfile(
      name,
      email,
      password,
    );

    return result.when(
      onSuccess: (user) {
        return Result.success(user);
      },
      onFailure: (exception) {
        if (ref.mounted) {
          state = AsyncValue.error(exception, StackTrace.current);
        }
        return Result.failure(exception);
      },
    );
  }

  /// Authenticates using Google Sign-In, initializing user document if first-time.
  Future<Result<UserEntity>> loginWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _authService.signInWithGoogleAndProfile();

    return result.when(
      onSuccess: (user) {
        return Result.success(user);
      },
      onFailure: (exception) {
        if (ref.mounted) {
          state = AsyncValue.error(exception, StackTrace.current);
        }
        return Result.failure(exception);
      },
    );
  }

  /// Authenticates using Apple Sign-In, initializing user document if first-time.
  Future<Result<UserEntity>> loginWithApple() async {
    state = const AsyncValue.loading();
    final result = await _authService.signInWithAppleAndProfile();

    return result.when(
      onSuccess: (user) {
        return Result.success(user);
      },
      onFailure: (exception) {
        if (ref.mounted) {
          state = AsyncValue.error(exception, StackTrace.current);
        }
        return Result.failure(exception);
      },
    );
  }

  /// Signs the current user out.
  Future<Result<void>> logout() async {
    state = const AsyncValue.loading();
    final result = await _authService.signOut();
    if (ref.mounted) {
      result.when(
        onSuccess: (_) {},
        onFailure: (exception) {
          state = AsyncValue.error(exception, StackTrace.current);
        },
      );
    }
    return result;
  }

  /// Dispatches a password reset email.
  Future<Result<void>> sendPasswordReset(String email) async {
    return _authService.sendPasswordResetEmail(email);
  }
}
