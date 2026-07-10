import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Creates a staff_profiles document for a user that already exists in
  /// Firebase Auth. Firebase Auth account creation requires the Admin SDK
  /// (a backend) — instruct the super_admin to create the account manually
  /// in the Firebase Console first, then register their UID here.
  Future<void> registerStaffProfile({
    required String uid,
    required String email,
    required String role,
  }) async {
    final actor = _auth.currentUser;
    final batch = _db.batch();

    batch.set(_db.collection('staff_profiles').doc(uid), {
      'uid': uid,
      'email': email,
      'role': role,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminRegisterStaffProfile',
      'targetType': 'staff',
      'targetId': uid,
      'summary': 'Registered staff profile for $email with role $role',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> updateRole({required String uid, required String role}) async {
    final actor = _auth.currentUser;
    final batch = _db.batch();

    batch.update(_db.collection('staff_profiles').doc(uid), {
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminUpdateStaffRole',
      'targetType': 'staff',
      'targetId': uid,
      'summary': 'Updated staff role to $role',
      'after': {'role': role},
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> deactivate({required String uid}) async {
    final actor = _auth.currentUser;
    final batch = _db.batch();

    batch.update(_db.collection('staff_profiles').doc(uid), {
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminDeactivateStaff',
      'targetType': 'staff',
      'targetId': uid,
      'summary': 'Deactivated staff profile',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

final staffApiProvider = Provider<StaffApi>((ref) => StaffApi());
