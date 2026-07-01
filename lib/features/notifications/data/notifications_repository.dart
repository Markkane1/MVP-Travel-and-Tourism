import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/notification_item.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore;

  NotificationsRepository(this._firestore);

  /// Streams the user's notification list.
  Stream<List<NotificationItem>> watchNotifications(String uid) {
    return _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => NotificationItem.fromFirestore(doc)).toList());
  }

  /// Marks a specific notification item as read.
  Future<void> markAsRead(String uid, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc(notificationId)
        .update({'read': true});
  }

  /// Marks all unread user notifications as read.
  Future<void> markAllAsRead(String uid) async {
    final snap = await _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<NotificationItem>> notificationsStream(Ref ref, String uid) {
  return ref.watch(notificationsRepositoryProvider).watchNotifications(uid);
}
