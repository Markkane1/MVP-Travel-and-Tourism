import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsApi {
  Future<void> sendNotification({
    required String targetType,
    required String title,
    required String body,
    String? type,
    String? deepLink,
    String? targetUserId,
    String? cohortTier,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('adminSendNotification');
    final Map<String, dynamic> payload = {
      'targetType': targetType,
      'title': title,
      'body': body,
    };
    if (type != null && type.isNotEmpty) payload['type'] = type;
    if (deepLink != null && deepLink.isNotEmpty) payload['deepLink'] = deepLink;
    if (targetUserId != null && targetUserId.isNotEmpty) payload['targetUserId'] = targetUserId;
    if (cohortTier != null && cohortTier.isNotEmpty) payload['cohortTier'] = cohortTier;

    await callable.call(payload);
  }
}

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi();
});
