import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/audit_model.dart';

final auditLogsProvider = StreamProvider.autoDispose<List<AuditModel>>((ref) {
  return Stream.fromFuture(_fetchAuditLogs(ref.watch(apiClientProvider)));
});

Future<List<AuditModel>> _fetchAuditLogs(ApiClient api) async {
  final data = await api.getJson('/admin/audit');
  return (data as List).whereType<Map>().map((log) {
    final json = Map<String, dynamic>.from(log);
    json['actorUid'] = json['actorUid'] ?? json['actorId'] ?? '';
    return AuditModel.fromJson(json);
  }).toList();
}
