import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final usersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
        .toList();
  });
});

class UsersApi {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> updateUser(
    String targetUserId, {
    String? tier,
    int? loyaltyPoints,
    String? conciergeId,
  }) async {
    final actor = _auth.currentUser;
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
      'summary': 'Admin updated user profile fields: ${updates.keys.where((k) => k != 'updatedAt').join(', ')}',
      'after': updates,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

final usersApiProvider = Provider<UsersApi>((ref) => UsersApi());
