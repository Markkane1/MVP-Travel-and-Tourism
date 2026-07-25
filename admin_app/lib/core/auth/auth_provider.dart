import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../services/api_client.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final bool isAdmin;
  final bool isSuperAdmin;
  final String? accessToken;
  final String? authError;
  final String? apiEmail;
  final String? apiRole;

  AuthState({
    required this.isLoading,
    this.user,
    this.isAdmin = false,
    this.isSuperAdmin = false,
    this.accessToken,
    this.authError,
    this.apiEmail,
    this.apiRole,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        // Clear ApiClient token cache on sign-out
        ref.read(apiClientProvider).clearTokenCache();
        state = AuthState(
          isLoading: false,
          user: null,
          isAdmin: false,
          isSuperAdmin: false,
          accessToken: null,
          authError: null,
        );
      } else {
        try {
          final idToken = await user.getIdToken(true);
          final response = await http.post(
            Uri.parse('${Env.apiBaseUrl}/auth/firebase'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          );
          final decoded = response.body.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(response.body) as Map<String, dynamic>;
          if (response.statusCode >= 200 && response.statusCode < 300) {
            final data = decoded;
            final apiUser = data['user'] as Map<String, dynamic>? ?? {};
            final role = apiUser['role']?.toString();
            final email = apiUser['email']?.toString();
            final isAdmin = role == 'ADMIN' || role == 'SUPER_ADMIN';
            final accessToken = data['accessToken'] as String?;

            // Seed the token into ApiClient so subsequent API calls
            // don't need to hit /auth/firebase again.
            if (accessToken != null) {
              ref.read(apiClientProvider).seedToken(accessToken);
            }

            state = AuthState(
              isLoading: false,
              user: user,
              isAdmin: isAdmin,
              isSuperAdmin: role == 'SUPER_ADMIN',
              accessToken: accessToken,
              authError: isAdmin
                  ? null
                  : 'Backend returned role ${role ?? 'none'} for ${email ?? user.email ?? 'this account'}.',
              apiEmail: email,
              apiRole: role,
            );
          } else {
            final error = decoded['error']?.toString() ?? 'Auth request failed';
            state = AuthState(
              isLoading: false,
              user: user,
              isAdmin: false,
              isSuperAdmin: false,
              accessToken: null,
              authError: '${response.statusCode}: $error',
            );
          }
        } catch (e) {
          debugPrint('Error fetching admin role: $e');
          state = AuthState(
            isLoading: false,
            user: user,
            isAdmin: false,
            isSuperAdmin: false,
            accessToken: null,
            authError: e.toString(),
          );
        }
      }
    });

    return AuthState(isLoading: true);
  }

  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    ref.read(apiClientProvider).clearTokenCache();
    await FirebaseAuth.instance.signOut();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
