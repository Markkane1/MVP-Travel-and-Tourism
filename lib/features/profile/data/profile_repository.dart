import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/controllers/auth_controller.dart';

part 'profile_repository.g.dart';

/// Provider that reactively streams the current user's profile document from Firestore.
@riverpod
Stream<Map<String, dynamic>?> userFirestoreData(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
}
