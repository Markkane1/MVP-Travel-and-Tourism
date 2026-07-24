import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/tour.dart';

final toursStreamProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  final api = ref.watch(apiClientProvider);
  return Stream.fromFuture(api.getJson('/admin/tours').then((data) {
    return (data as List).map((json) => Tour.fromJson(_tourJson(json))).toList();
  }));
});

Map<String, dynamic> _tourJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  final price = json['basePrice'] ?? json['pricePerPerson'] ?? 0;
  return {
    ...json,
    'overview': json['overview'] ?? json['description'] ?? '',
    'pricePerPerson': price is num ? price.toDouble() : 0.0,
    'category': json['category'] ?? json['type'] ?? '',
    'isActive': json['isActive'] ?? json['status'] != 'ARCHIVED',
    'availableDates': json['availableDates'] ?? json['dates'] ?? const [],
  };
}

class ToursApi {
  final ApiClient _api;

  ToursApi(this._api);

  Future<void> addTour(Tour newTour) async {
    await _api.postJson('/admin/tours', _tourPayload(newTour));
  }

  Future<void> updateTour(Tour updatedTour) async {
    await _api.patchJson(
      '/admin/tours/${Uri.encodeComponent(updatedTour.id)}',
      _tourPayload(updatedTour),
    );
  }

  Future<void> deleteTour(String tourId) async {
    await _api.delete('/admin/tours/${Uri.encodeComponent(tourId)}');
  }

  Map<String, dynamic> _tourPayload(Tour tour) => {
        'title': tour.title,
        'description': tour.overview,
        'durationDays': tour.durationDays,
        'basePrice': tour.pricePerPerson.round(),
        'status': tour.isActive ? 'PUBLISHED' : 'ARCHIVED',
      };
}

final toursApiProvider = Provider<ToursApi>((ref) {
  return ToursApi(ref.watch(apiClientProvider));
});
