import 'package:cloud_firestore/cloud_firestore.dart';
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

final userBookingsSummaryProvider =
    StreamProvider.autoDispose.family<(int total, int confirmed), String>((
      ref,
      userId,
    ) {
      return FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            var confirmed = 0;
            for (final doc in snapshot.docs) {
              if (doc.data()['status'] == 'confirmed') {
                confirmed++;
              }
            }
            return (snapshot.size, confirmed);
          });
    });

class UsersApi {
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
    String? tier,
    int? loyaltyPoints,
    String? conciergeId,
  }) async {
    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['displayName'] = displayName;
    if (tier != null) updates['tier'] = tier;
    if (loyaltyPoints != null) updates['loyaltyPoints'] = loyaltyPoints;
    if (conciergeId != null) {
      updates['conciergeId'] = conciergeId.isEmpty ? null : conciergeId;
    }
    final callable = _functions.httpsCallable('adminUpdateUser');
    await callable.call({'targetUserId': targetUserId, 'updates': updates});
  }

  Future<void> addUser({
    required String email,
    required String password,
    required String displayName,
    required String tier,
  }) async {
    final callable = _functions.httpsCallable('adminCreateUser');
    await callable.call({
      'email': email,
      'password': password,
      'displayName': displayName,
      'tier': tier,
    });
  }
}

final usersApiProvider = Provider<UsersApi>((ref) => UsersApi());
