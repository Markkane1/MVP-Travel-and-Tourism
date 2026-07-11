import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import 'auth_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService();

  /// Requests permissions and sets up FCM token updates for the user.
  Future<void> setupNotifications(String uid) async {
    if (Env.skipNotificationSetup) {
      return;
    }

    try {
      // 1. Request notification permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permissions.');
        }

        // 2. Fetch and save FCM token
        final token = await _fcm.getToken();
        if (token != null) {
          await _saveToken(uid, token);
        }

        // 3. Monitor token refresh events
        _fcm.onTokenRefresh.listen((newToken) {
          _saveToken(uid, newToken);
        });

        // 4. Handle foreground notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _handleForegroundMessage(uid, message);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up notification services: $e');
      }
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({'fcmToken': token});
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token to user profile: $e');
      }
    }
  }

  /// Writes foreground messaging payloads into the in-app notifications subcollection.
  Future<void> _handleForegroundMessage(
    String uid,
    RemoteMessage message,
  ) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      await _firestore
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .add({
            'title': notification.title ?? '',
            'body': notification.body ?? '',
            'type': message.data['type'] ?? 'system',
            'deepLink': message.data['deepLink'] ?? '',
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (kDebugMode) {
        print('Error handling foreground notification write: $e');
      }
    }
  }

  /// Watch stream of unread notification counts.
  Stream<int> watchUnreadCount(String uid) {
    return _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Marks all unread user notifications as read.
  Future<void> markAllAsRead(String uid) async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications read: $e');
      }
    }
  }

  /// Marks a specific notification item as read.
  Future<void> markAsRead(String uid, String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification item read: $e');
      }
    }
  }
}

/// Provider for the NotificationService instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Riverpod stream provider for unread count.
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final authUser = ref.watch(authServiceProvider).currentUser;
  if (authUser == null) return Stream.value(0);

  return ref.watch(notificationServiceProvider).watchUnreadCount(authUser.uid);
});
