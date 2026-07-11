import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

final conciergeMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ConciergeMessage>, String>((ref, userId) {
      return FirebaseFirestore.instance
          .collection('concierge_threads')
          .doc(userId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map(
                  (doc) => ConciergeMessage.fromFirestore(doc.data(), doc.id),
                )
                .toList();
          });
    });

class ConciergeApi {
  Future<void> replyToThread(String targetUserId, String text) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'adminReplyToConciergeThread',
    );
    await callable.call({'targetUserId': targetUserId, 'text': text});
  }
}

final conciergeApiProvider = Provider<ConciergeApi>((ref) => ConciergeApi());
