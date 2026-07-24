import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/staff_model.dart';

final staffStreamProvider = StreamProvider.autoDispose<List<StaffModel>>((ref) {
  final api = ref.watch(apiClientProvider);
  return Stream.fromFuture(api.getJson('/admin/staff').then((data) {
    return (data as List)
        .map((json) => StaffModel.fromJson(_staffJson(json)))
        .toList();
  }));
});

Map<String, dynamic> _staffJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  return {
    ...json,
    'role': (json['role'] ?? 'admin').toString().toLowerCase(),
  };
}

class StaffApi {
  final ApiClient _api;

  StaffApi(this._api);

  Future<void> registerStaffProfile({
    required String email,
    required String password,
    required String role,
  }) async {
    final name = email.split('@').first;
    final user = await _api.postJson('/admin/users', {
      'email': email,
      'password': password,
      'firstName': name,
      'lastName': 'Staff',
      'role': _apiRole(role),
    });
    await _api.postJson('/admin/staff', {
      'userId': (user['id'] ?? user['user']?['id']).toString(),
      'role': _apiRole(role),
    });
  }

  Future<void> updateRole({required String uid, required String role}) async {
    await _api.patchJson('/admin/staff/${Uri.encodeComponent(uid)}', {
      'role': _apiRole(role),
    });
  }

  Future<void> deactivate({required String uid}) async {
    await _api.postJson('/admin/staff/${Uri.encodeComponent(uid)}/deactivate', {});
  }

  String _apiRole(String role) => role.toUpperCase();
}

final staffApiProvider = Provider<StaffApi>(
  (ref) => StaffApi(ref.watch(apiClientProvider)),
);
