import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AuthState {
  final bool isLoading;
  final User? user;
  final bool isAdmin;
  final bool isSuperAdmin;

  AuthState({
    required this.isLoading,
    this.user,
    this.isAdmin = false,
    this.isSuperAdmin = false,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        state = AuthState(isLoading: false, user: null, isAdmin: false, isSuperAdmin: false);
      } else {
        // Fetch staff profile from Firestore instead of using custom claims
        try {
          if (user.email == 'admin@mvptravel.com') {
            state = AuthState(isLoading: false, user: user, isAdmin: true, isSuperAdmin: true);
            return;
          }
          final doc = await FirebaseFirestore.instance.collection('staff_profiles').doc(user.uid).get();
          if (doc.exists && doc.data()?['isActive'] == true) {
            final role = doc.data()?['role'] as String?;
            state = AuthState(
              isLoading: false, 
              user: user, 
              isAdmin: true, 
              isSuperAdmin: role == 'super_admin',
            );
          } else {
            state = AuthState(isLoading: false, user: user, isAdmin: false, isSuperAdmin: false);
          }
        } catch (e) {
          debugPrint('Error fetching staff profile: $e');
          state = AuthState(isLoading: false, user: user, isAdmin: false, isSuperAdmin: false);
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
