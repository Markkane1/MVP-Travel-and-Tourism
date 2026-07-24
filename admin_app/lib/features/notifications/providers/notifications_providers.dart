import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';

final notificationHistoryProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final api = ref.watch(apiClientProvider);
      return Stream.fromFuture(
        api.getJson('/admin/audit?action=SEND_NOTIFICATION').then((data) {
          return (data as List)
              .map((json) => Map<String, dynamic>.from(json as Map))
              .take(20)
              .toList();
        }),
      );
    });

class NotificationsApi {
  final ApiClient _api;

  NotificationsApi(this._api);

  Future<int> sendNotification({
    required String targetType,
    required String title,
    required String body,
    String? type,
    String? deepLink,
    String? targetUserId,
    String? cohortTier,
  }) async {
    final response = await _api.postJson('/admin/notifications/send', {
      'targetType': targetType,
      'title': title,
      'message': body,
      'type': type,
      'deepLink': deepLink,
      'targetUserId': targetUserId,
      'cohortTier': cohortTier,
    });
    return (response['count'] as num?)?.toInt() ?? 0;
  }
}

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.watch(apiClientProvider)),
);
