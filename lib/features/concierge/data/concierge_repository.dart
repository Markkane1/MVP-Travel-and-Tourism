import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

import '../domain/concierge_message.dart';
import '../domain/concierge_profile.dart';

part 'concierge_repository.g.dart';

class ConciergeRepository {
  final ApiClient _api;

  ConciergeRepository(this._api);

  /// Streams a single concierge profile.
  Stream<ConciergeProfile> watchConciergeProfile(String conciergeId) {
    return Stream.value(ConciergeProfile.fallback(conciergeId));
  }

  /// Streams the chat messages for a user's thread.
  Stream<List<ConciergeMessage>> watchMessages(String uid) {
    return Stream.fromFuture(_fetchMessages());
  }

  /// Streams the thread typing and metadata state.
  Stream<Map<String, dynamic>> watchThreadMetadata(String uid) {
    return Stream.fromFuture(_fetchThreadMetadata());
  }

  /// Sends a chat message.
  Future<Result<void>> sendMessage({
    required String uid,
    required String text,
    String? attachmentUrl,
  }) async {
    try {
      final content = attachmentUrl == null
          ? text
          : [text, attachmentUrl].where((part) => part.isNotEmpty).join('\n');
      await _api.postJson('/concierge/threads/me/messages', {
        'content': content,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to send message: ${e.toString()}'),
      );
    }
  }

  /// Automatic concierge seeding and user profile matching logic.
  Future<Result<bool>> checkAndSeedConcierges(String uid) async {
    return const Result.success(false);
  }

  Future<List<ConciergeMessage>> _fetchMessages() async {
    final data = await _api.getJson(
      '/concierge/threads/me/messages',
      authenticated: true,
    );
    return (data as List)
        .whereType<Map>()
        .map(
          (message) =>
              ConciergeMessage.fromJson(Map<String, dynamic>.from(message)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _fetchThreadMetadata() async {
    final data = await _api.getJson(
      '/concierge/threads/me',
      authenticated: true,
    );
    return Map<String, dynamic>.from(data as Map);
  }
}

@riverpod
ConciergeRepository conciergeRepository(Ref ref) {
  return ConciergeRepository(ref.watch(apiClientProvider));
}

@riverpod
Stream<ConciergeProfile> conciergeProfile(Ref ref, String conciergeId) {
  return ref
      .watch(conciergeRepositoryProvider)
      .watchConciergeProfile(conciergeId);
}

@riverpod
Stream<List<ConciergeMessage>> conciergeMessages(Ref ref, String uid) {
  return ref.watch(conciergeRepositoryProvider).watchMessages(uid);
}

@riverpod
Stream<Map<String, dynamic>> conciergeThreadMetadata(Ref ref, String uid) {
  return ref.watch(conciergeRepositoryProvider).watchThreadMetadata(uid);
}
