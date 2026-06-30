import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'route_paths.dart';

/// Navigation redirect guard. Redirects unauthenticated users to `/auth`.
class AuthGuard {
  final AuthService _authService;

  AuthGuard(this._authService);

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final signedIn = _authService.isSignedIn;
    final isLoggingIn = state.matchedLocation == RoutePaths.auth;

    if (!signedIn) {
      // Allow legal terms and privacy access without sign-in
      if (state.matchedLocation == RoutePaths.legalTerms || state.matchedLocation == RoutePaths.legalPrivacy) {
        return null;
      }
      // Force sign in
      return isLoggingIn ? null : RoutePaths.auth;
    }

    // If user is already signed in, prevent them from landing on the auth screen
    if (isLoggingIn) {
      return RoutePaths.explore;
    }

    // No redirect needed
    return null;
  }
}
