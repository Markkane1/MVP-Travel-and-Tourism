import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/user.dart';

final usersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final api = ref.watch(apiClientProvider);
  return Stream.fromFuture(api.getJson('/admin/users').then((data) {
    return (data as List)
        .map((json) => UserModel.fromJson(_userJson(json)))
        .toList();
  }));
});

final userBookingsSummaryProvider = StreamProvider.autoDispose
    .family<(int total, int confirmed), String>((ref, userId) {
      final api = ref.watch(apiClientProvider);
      return Stream.fromFuture(api.getJson('/admin/bookings').then((data) {
        final bookings = (data as List)
            .where((booking) => (booking as Map)['userId'] == userId)
            .toList();
        final confirmed = bookings
            .where((booking) => (booking as Map)['status'] == 'CONFIRMED')
            .length;
        return (bookings.length, confirmed);
      }));
    });

Map<String, dynamic> _userJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  final firstName = json['firstName']?.toString() ?? '';
  final lastName = json['lastName']?.toString() ?? '';
  return {
    ...json,
    'displayName': json['displayName'] ?? '$firstName $lastName'.trim(),
    'tier': (json['tier'] ?? 'base').toString().toLowerCase(),
    'loyaltyPoints': json['loyaltyPoints'] ?? 0,
  };
}

class UsersApi {
  final ApiClient _api;

  UsersApi(this._api);

  Future<void> deleteUser(
    String targetUserId, {
    String reason = 'Admin request',
  }) async {
    await _api.delete('/admin/users/${Uri.encodeComponent(targetUserId)}');
  }

  Future<void> updateUser(
    String targetUserId, {
    String? displayName,
    String? tier,
    int? loyaltyPoints,
    String? conciergeId,
  }) async {
    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['displayName'] = displayName;
    if (tier != null) updates['tier'] = tier;
    if (loyaltyPoints != null) updates['loyaltyPoints'] = loyaltyPoints;
    if (conciergeId != null) {
      updates['conciergeId'] = conciergeId.isEmpty ? null : conciergeId;
    }
    await _api.patchJson('/admin/users/${Uri.encodeComponent(targetUserId)}', updates);
  }

  Future<void> addUser({
    required String email,
    required String password,
    required String displayName,
    required String tier,
  }) async {
    final nameParts = displayName.trim().split(RegExp(r'\s+'));
    await _api.postJson('/admin/users', {
      'email': email,
      'password': password,
      'firstName': nameParts.isEmpty ? displayName : nameParts.first,
      'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : 'User',
      'tier': tier.toUpperCase(),
    });
  }
}

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(apiClientProvider)),
);
