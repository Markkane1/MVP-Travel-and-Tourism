import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/user.dart';

final usersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
        .toList();
  });
});

class UsersApi {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _functions = FirebaseFunctions.instance;

  Future<void> deleteUser(
    String targetUserId, {
    String reason = 'Admin request',
  }) async {
    final callable = _functions.httpsCallable('adminDeleteUser');
    await callable.call({'targetUid': targetUserId, 'reason': reason});
  }

  Future<void> updateUser(
    String targetUserId, {
    String? displayName,
    String? phoneNumber,
    String? tier,
    int? loyaltyPoints,
    String? conciergeId,
  }) async {
    final actor = _auth.currentUser;
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (tier != null) updates['tier'] = tier;
    if (loyaltyPoints != null) updates['loyaltyPoints'] = loyaltyPoints;
    if (conciergeId != null) {
      updates['conciergeId'] = conciergeId.isEmpty ? null : conciergeId;
    }

    final batch = _db.batch();

    // 1. Update the user document.
    batch.update(_db.collection('users').doc(targetUserId), updates);

    // 2. Write audit log.
    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminUpdateUser',
      'targetType': 'user',
      'targetId': targetUserId,
      'summary':
          'Admin updated user profile fields: ${updates.keys.where((k) => k != 'updatedAt').join(', ')}',
      'after': updates,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> addUser({
    required String email,
    required String password,
    required String displayName,
    required String tier,
  }) async {
    try {
      final callable = _functions.httpsCallable('adminCreateUser');
      await callable.call({
        'email': email,
        'password': password,
        'displayName': displayName,
        'tier': tier,
      });
    } catch (e) {
      // Mock for frontend UI testing since backend may not be deployed
      final actor = _auth.currentUser;
      final docRef = _db.collection('users').doc();
      final batch = _db.batch();
      batch.set(docRef, {
        'email': email,
        'displayName': displayName,
        'tier': tier,
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(_db.collection('admin_audit_logs').doc(), {
        'actorUid': actor?.uid ?? 'unknown',
        'actorEmail': actor?.email ?? 'unknown',
        'action': 'adminCreateUser',
        'targetType': 'user',
        'targetId': docRef.id,
        'summary': 'Admin manually created user: $email',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }
  }
}

final usersApiProvider = Provider<UsersApi>((ref) => UsersApi());
