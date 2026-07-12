import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listens for real-world events in Firestore and writes in-app notification
/// documents when they occur — without requiring any Cloud Functions or
/// server-side code (fully compatible with the free Firebase Spark plan).
///
/// Events handled:
///   1. Booking status changes → notify customer when their booking is confirmed,
///      cancelled, or refunded.
///   2. New concierge staff messages → notify customer when staff replies.
class ClientNotificationTriggerService {
  final FirebaseFirestore _firestore;

  ClientNotificationTriggerService(this._firestore);

  final List<StreamSubscription> _subscriptions = [];

  /// Start listening for events for the given [uid].
  /// Call this once after login.
  void startListening(String uid) {
    _stopAll();

    _watchBookingStatusChanges(uid);
    _watchConciergeStaffMessages(uid);
  }

  void _stopAll() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void dispose() => _stopAll();

  // ── 1. Booking status changes ─────────────────────────────────────────────

  void _watchBookingStatusChanges(String uid) {
    // Track the statuses we have already seen so we only fire on real changes.
    final Map<String, String> seenStatuses = {};
    bool firstLoad = true;

    final sub = _firestore
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snap) async {
            // Skip the very first emission — those are existing docs, not new changes.
            if (firstLoad) {
              for (final doc in snap.docs) {
                seenStatuses[doc.id] = doc.data()['status'] ?? '';
              }
              firstLoad = false;
              return;
            }

            for (final change in snap.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                final data = change.doc.data();
                if (data == null) continue;

                final newStatus = data['status'] as String? ?? '';
                final previousStatus = seenStatuses[change.doc.id] ?? '';

                if (newStatus == previousStatus) continue;
                seenStatuses[change.doc.id] = newStatus;

                final tourTitle =
                    (data['tourSnapshot'] as Map?)?['title'] as String? ??
                    'your booking';
                final bookingId = change.doc.id;

                switch (newStatus) {
                  case 'confirmed':
                    await _writeNotification(
                      uid: uid,
                      title: 'Booking Confirmed! 🎉',
                      body:
                          'Your expedition to $tourTitle is confirmed and ready.',
                      type: 'booking',
                      deepLink: '/trips/$bookingId',
                    );
                    break;
                  case 'cancelled':
                    await _writeNotification(
                      uid: uid,
                      title: 'Booking Cancelled',
                      body: 'Your booking for $tourTitle has been cancelled.',
                      type: 'booking',
                      deepLink: '/trips/$bookingId',
                    );
                    break;
                  case 'refunded':
                    await _writeNotification(
                      uid: uid,
                      title: 'Refund Processed',
                      body: 'Your refund for $tourTitle has been processed.',
                      type: 'booking_refund',
                      deepLink: '/trips/$bookingId',
                    );
                    break;
                }
              }
            }
          },
          onError: (e) {
            if (kDebugMode)
              print('ClientNotificationTrigger: booking watch error: $e');
          },
        );

    _subscriptions.add(sub);
  }

  // ── 2. Concierge staff messages ───────────────────────────────────────────

  void _watchConciergeStaffMessages(String uid) {
    bool firstLoad = true;

    final sub = _firestore
        .collection('concierge_threads')
        .doc(uid)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen(
          (snap) async {
            // Skip initial load — only react to new additions.
            if (firstLoad) {
              firstLoad = false;
              return;
            }

            for (final change in snap.docChanges) {
              if (change.type != DocumentChangeType.added) continue;

              final data = change.doc.data();
              if (data == null) continue;

              final senderType = data['senderType'] as String? ?? '';

              // Only notify the customer when STAFF/CONCIERGE sends a message.
              if (senderType == 'staff' || senderType == 'concierge') {
                final text = data['text'] as String? ?? '';
                await _writeNotification(
                  uid: uid,
                  title: 'New message from your concierge',
                  body: text.length > 100 ? '${text.substring(0, 100)}…' : text,
                  type: 'concierge',
                  deepLink: '/concierge',
                );
              }
            }
          },
          onError: (e) {
            if (kDebugMode) {
              print('ClientNotificationTrigger: concierge watch error: $e');
            }
          },
        );

    _subscriptions.add(sub);
  }

  // ── Shared helper ─────────────────────────────────────────────────────────

  Future<void> _writeNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
    required String deepLink,
  }) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .add({
            'title': title,
            'body': body,
            'type': type,
            'deepLink': deepLink,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (kDebugMode) {
        print('ClientNotificationTrigger: failed to write notification: $e');
      }
    }
  }
}

/// Provider for the client notification trigger service.
final clientNotificationTriggerProvider =
    Provider<ClientNotificationTriggerService>((ref) {
      final service = ClientNotificationTriggerService(
        FirebaseFirestore.instance,
      );
      ref.onDispose(service.dispose);
      return service;
    });
