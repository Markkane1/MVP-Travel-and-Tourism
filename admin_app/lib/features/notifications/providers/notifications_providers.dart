import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsApi {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Sends a notification to one user, all users, or a tier cohort.
  /// Uses chunked Firestore batch writes (max 500 per batch).
  Future<int> sendNotification({
    required String targetType, // 'single' | 'all' | 'cohort'
    required String title,
    required String body,
    String? type,
    String? deepLink,
    String? targetUserId,
    String? cohortTier,
  }) async {
    final actor = _auth.currentUser;
    List<String> targetUids = [];

    // 1. Resolve target UIDs.
    if (targetType == 'single') {
      if (targetUserId == null || targetUserId.isEmpty) {
        throw Exception('targetUserId is required for single target.');
      }
      targetUids = [targetUserId];
    } else if (targetType == 'all') {
      final snap = await _db.collection('users').get();
      targetUids = snap.docs.map((d) => d.id).toList();
    } else if (targetType == 'cohort') {
      if (cohortTier == null || cohortTier.isEmpty) {
        throw Exception('cohortTier is required for cohort target.');
      }
      final snap = await _db
          .collection('users')
          .where('tier', isEqualTo: cohortTier)
          .get();
      targetUids = snap.docs.map((d) => d.id).toList();
    } else {
      throw Exception('Invalid targetType: $targetType');
    }

    if (targetUids.isEmpty) return 0;

    // 2. Chunked batch writes (Firestore max = 500 per batch).
    const chunkSize = 450;
    for (var i = 0; i < targetUids.length; i += chunkSize) {
      final chunk = targetUids.sublist(
        i,
        (i + chunkSize) > targetUids.length ? targetUids.length : i + chunkSize,
      );
      final batch = _db.batch();
      for (final uid in chunk) {
        final notifRef = _db
            .collection('notifications')
            .doc(uid)
            .collection('items')
            .doc();
        batch.set(notifRef, {
          'title': title,
          'body': body,
          'type': type ?? 'system',
          'deepLink': deepLink ?? '',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }

    // 3. Write audit log.
    await _db.collection('admin_audit_logs').add({
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminSendNotification',
      'targetType': targetType,
      'targetId': targetUserId ?? cohortTier ?? 'all',
      'summary': 'Sent notification to ${targetUids.length} users.',
      'payload': {'title': title, 'type': type ?? 'system'},
      'createdAt': FieldValue.serverTimestamp(),
    });

    return targetUids.length;
  }
}

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(),
);
