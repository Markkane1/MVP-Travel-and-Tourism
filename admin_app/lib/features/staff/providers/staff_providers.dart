import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/staff_model.dart';

final staffStreamProvider = StreamProvider.autoDispose<List<StaffModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('staff_profiles')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => StaffModel.fromFirestore(doc.data(), doc.id))
        .toList();
  });
});

class StaffApi {
  final _functions = FirebaseFunctions.instance;

  Future<void> registerStaffProfile({
    required String email,
    required String password,
    required String role,
  }) async {
    final callable = _functions.httpsCallable('adminManageStaff');
    await callable.call({
      'action': 'create',
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<void> updateRole({required String uid, required String role}) async {
    final callable = _functions.httpsCallable('adminManageStaff');
    await callable.call({
      'action': 'updateRole',
      'uid': uid,
      'role': role,
    });
  }

  Future<void> deactivate({required String uid}) async {
    final callable = _functions.httpsCallable('adminManageStaff');
    await callable.call({
      'action': 'deactivate',
      'uid': uid,
    });
  }
}

final staffApiProvider = Provider<StaffApi>((ref) => StaffApi());
