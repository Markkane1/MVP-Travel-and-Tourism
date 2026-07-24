import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/concierge_thread.dart';

final conciergeThreadsStreamProvider =
    StreamProvider.autoDispose<List<ConciergeThread>>((ref) {
      final api = ref.watch(apiClientProvider);
      return Stream.fromFuture(api.getJson('/admin/concierge/threads').then((
        data,
      ) {
        return (data as List)
            .map((json) => ConciergeThread.fromJson(_threadJson(json)))
            .toList();
      }));
    });

final conciergeMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ConciergeMessage>, String>((ref, userId) {
      final api = ref.watch(apiClientProvider);
      return Stream.fromFuture(
        api
            .getJson('/admin/concierge/${Uri.encodeComponent(userId)}/messages')
            .then((data) {
              final messages = (data as List)
                  .map((json) => ConciergeMessage.fromJson(_messageJson(json)))
                  .toList()
                ..sort((a, b) => (b.createdAt ?? DateTime(0))
                    .compareTo(a.createdAt ?? DateTime(0)));
              return messages;
            }),
      );
    });

Map<String, dynamic> _threadJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  return {
    ...json,
    'id': json['userId'] ?? json['id'] ?? '',
    'lastMessageAt': json['lastMessageAt'] ?? json['updatedAt'],
    'lastMessageText': json['lastMessageText'] ?? '',
  };
}

Map<String, dynamic> _messageJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  return {
    ...json,
    'senderType': (json['senderType'] ?? json['senderRole'] ?? 'user')
        .toString()
        .toLowerCase(),
    'text': json['text'] ?? json['content'] ?? '',
  };
}

class ConciergeApi {
  final ApiClient _api;

  ConciergeApi(this._api);

  Future<void> replyToThread(String targetUserId, String text) async {
    await _api.postJson(
      '/admin/concierge/${Uri.encodeComponent(targetUserId)}/reply',
      {'content': text},
    );
  }
}

final conciergeApiProvider = Provider<ConciergeApi>(
  (ref) => ConciergeApi(ref.watch(apiClientProvider)),
);
