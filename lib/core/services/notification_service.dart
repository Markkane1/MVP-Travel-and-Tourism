import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiClient _api;

  NotificationService(this._api);

  /// Requests permissions and sets up FCM token updates for the user.
  Future<void> setupNotifications(String uid) async {
    if (Env.skipNotificationSetup) {
      return;
    }
    if (kIsWeb && Env.firebaseMessagingVapidKey.isEmpty) {
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
          debugPrint('User granted notification permissions.');
        }

        // 2. Fetch and save FCM token
        final token = await _fcm.getToken(
          vapidKey: kIsWeb ? Env.firebaseMessagingVapidKey : null,
        );
        if (token != null) {
          await _saveToken(uid, token);
        }

        // 3. Monitor token refresh events
        _fcm.onTokenRefresh.listen((newToken) {
          _saveToken(uid, newToken);
        });

        // 4. Handle foreground notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            debugPrint('Foreground push received: ${message.messageId}');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting up notification services: $e');
      }
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    // ponytail: token persistence needs a UserDeviceToken table; add it when API sends FCM.
    if (kDebugMode) {
      final preview = token.length < 8 ? token : token.substring(0, 8);
      debugPrint('FCM token received for $uid: $preview...');
    }
  }

  /// Watch stream of unread notification counts.
  Stream<int> watchUnreadCount(String uid) {
    return Stream.fromFuture(_unreadCount());
  }

  /// Marks all unread user notifications as read.
  Future<void> markAllAsRead(String uid) async {
    try {
      await _api.postJson('/notifications/read-all', {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking all notifications read: $e');
      }
    }
  }

  /// Marks a specific notification item as read.
  Future<void> markAsRead(String uid, String notificationId) async {
    try {
      await _api.postJson('/notifications/$notificationId/read', {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking notification item read: $e');
      }
    }
  }

  Future<int> _unreadCount() async {
    final data = await _api.getJson('/notifications/me', authenticated: true);
    return (data as List).where((item) {
      if (item is! Map) return false;
      return item['isRead'] == false || item['read'] == false;
    }).length;
  }
}

/// Provider for the NotificationService instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(apiClientProvider));
});

/// Riverpod stream provider for unread count.
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final authUser = ref.watch(authServiceProvider).currentUser;
  if (authUser == null) return Stream.value(0);

  return ref.watch(notificationServiceProvider).watchUnreadCount(authUser.uid);
});
