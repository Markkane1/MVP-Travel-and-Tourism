import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/service.dart';

final servicesStreamProvider = StreamProvider.autoDispose<List<Service>>((ref) {
  final api = ref.watch(apiClientProvider);
  return Stream.fromFuture(api.getJson('/admin/services').then((data) {
    final services = (data as List)
        .map((json) => Service.fromJson(_serviceJson(json)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return services;
  }));
});

Map<String, dynamic> _serviceJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  final price = json['basePrice'] ?? 0;
  return {
    ...json,
    'name': json['name'] ?? json['title'] ?? '',
    'category': json['category'] ?? 'service',
    'currency': json['currency'] ?? 'USD',
    'unitType': json['unitType'] ?? 'service',
    'basePrice': price is num ? price.toDouble() : 0.0,
    'isActive': json['isActive'] ?? json['status'] == 'ACTIVE',
  };
}

class ServicesApi {
  final ApiClient _api;

  ServicesApi(this._api);

  Future<void> addService(Service newService) async {
    await _api.postJson('/admin/services', _servicePayload(newService));
  }

  Future<void> updateService(Service service) async {
    await _api.patchJson(
      '/admin/services/${Uri.encodeComponent(service.id)}',
      _servicePayload(service),
    );
  }

  Future<void> archiveService(String serviceId, String archivedBy) async {
    await _api.delete('/admin/services/${Uri.encodeComponent(serviceId)}');
  }

  Map<String, dynamic> _servicePayload(Service service) => {
        'title': service.name,
        'description': service.description,
        'basePrice': service.basePrice.round(),
        'status': service.isActive ? 'ACTIVE' : 'INACTIVE',
      };
}

final servicesApiProvider = Provider<ServicesApi>((ref) {
  return ServicesApi(ref.watch(apiClientProvider));
});
