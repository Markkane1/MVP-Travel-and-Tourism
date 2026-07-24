import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

import '../domain/notification_item.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  final ApiClient _api;

  NotificationsRepository(this._api);

  /// Streams the user's notification list.
  Stream<List<NotificationItem>> watchNotifications(String uid) {
    return Stream.fromFuture(_fetchNotifications());
  }

  /// Marks a specific notification item as read.
  Future<Result<void>> markAsRead(String uid, String notificationId) async {
    try {
      await _api.postJson('/notifications/$notificationId/read', {});
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to mark notification as read: ${e.toString()}',
        ),
      );
    }
  }

  /// Marks all unread user notifications as read.
  Future<Result<void>> markAllAsRead(String uid) async {
    try {
      await _api.postJson('/notifications/read-all', {});
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to mark notifications as read: ${e.toString()}',
        ),
      );
    }
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    final data = await _api.getJson('/notifications/me', authenticated: true);
    return (data as List)
        .whereType<Map>()
        .map(
          (item) => NotificationItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
}

@riverpod
Stream<List<NotificationItem>> notificationsStream(Ref ref, String uid) {
  return ref.watch(notificationsRepositoryProvider).watchNotifications(uid);
}
