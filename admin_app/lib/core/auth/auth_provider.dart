import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final bool isAdmin;

  AuthState({
    required this.isLoading,
    this.user,
    this.isAdmin = false,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        state = AuthState(isLoading: false, user: null, isAdmin: false);
      } else {
        // Fetch claims
        try {
          final idTokenResult = await user.getIdTokenResult(true);
          final isAdmin = idTokenResult.claims?['admin'] == true;
          state = AuthState(isLoading: false, user: user, isAdmin: isAdmin);
        } catch (e) {
          debugPrint('Error fetching claims: $e');
          state = AuthState(isLoading: false, user: user, isAdmin: false);
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
    await FirebaseAuth.instance.signOut();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
