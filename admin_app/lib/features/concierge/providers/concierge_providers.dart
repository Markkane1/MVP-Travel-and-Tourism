import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/concierge_thread.dart';

final conciergeThreadsStreamProvider =
    StreamProvider.autoDispose<List<ConciergeThread>>((ref) {
  return FirebaseFirestore.instance
      .collection('concierge_threads')
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ConciergeThread.fromFirestore(doc.data(), doc.id))
        .toList();
  });
});

final conciergeMessagesStreamProvider =
    StreamProvider.autoDispose.family<List<ConciergeMessage>, String>(
        (ref, userId) {
  return FirebaseFirestore.instance
      .collection('concierge_threads')
      .doc(userId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ConciergeMessage.fromFirestore(doc.data(), doc.id))
        .toList();
  });
});

class ConciergeApi {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> replyToThread(String targetUserId, String text) async {
    final actor = _auth.currentUser;
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    // 1. Write the message as 'staff'.
    final messageRef = _db
        .collection('concierge_threads')
        .doc(targetUserId)
        .collection('messages')
        .doc();
    batch.set(messageRef, {
      'senderUid': actor?.uid ?? 'unknown',
      'senderEmail': actor?.email ?? 'Admin',
      'senderType': 'staff',
      'text': text,
      'createdAt': now,
    });

    // 2. Update thread metadata.
    batch.update(
      _db.collection('concierge_threads').doc(targetUserId),
      {
        'lastMessageAt': now,
        'updatedAt': now,
      },
    );

    // 3. Write audit log.
    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminReplyToConciergeThread',
      'targetType': 'concierge_thread',
      'targetId': targetUserId,
      'summary': 'Admin replied to concierge thread',
      'createdAt': now,
    });

    await batch.commit();
  }
}

final conciergeApiProvider = Provider<ConciergeApi>((ref) => ConciergeApi());
