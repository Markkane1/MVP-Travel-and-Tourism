import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final usersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc.data(), doc.id)).toList();
  });
});

class UsersApi {
  Future<void> updateUser(String targetUserId, {String? tier, int? loyaltyPoints, String? conciergeId}) async {
    final callable = FirebaseFunctions.instance.httpsCallable('adminUpdateUser');
    final Map<String, dynamic> updates = {};
    if (tier != null) updates['tier'] = tier;
    if (loyaltyPoints != null) updates['loyaltyPoints'] = loyaltyPoints;
    if (conciergeId != null) updates['conciergeId'] = conciergeId;

    await callable.call({
      'targetUserId': targetUserId,
      'updates': updates,
    });
  }
}

final usersApiProvider = Provider<UsersApi>((ref) {
  return UsersApi();
});
