import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationHistoryProvider =
    StreamProvider.autoDispose<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
    >((ref) {
      return FirebaseFirestore.instance
          .collection('admin_audit_logs')
          .where('action', isEqualTo: 'adminSendNotification')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });

class NotificationsApi {
  final _functions = FirebaseFunctions.instance;

  Future<int> sendNotification({
    required String targetType,
    required String title,
    required String body,
    String? type,
    String? deepLink,
    String? targetUserId,
    String? cohortTier,
  }) async {
    final callable = _functions.httpsCallable('adminSendNotification');
    final response = await callable.call({
      'targetType': targetType,
      'title': title,
      'body': body,
      'type': type,
      'deepLink': deepLink,
      'targetUserId': targetUserId,
      'cohortTier': cohortTier,
    });
    return (response.data['count'] as num?)?.toInt() ?? 0;
  }
}

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(),
);
