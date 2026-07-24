import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/api_client.dart';

import '../domain/tour.dart';
import '../domain/review.dart';

part 'explore_repository.g.dart';

/// Repository responsible for loading Explore dashboard sections from the API.
class ExploreRepository {
  final ApiClient _api;

  ExploreRepository(this._api);

  Stream<List<Tour>> watchHeroPromotions() {
    return Stream.fromFuture(_fetchTours());
  }

  Stream<List<Tour>> watchFeaturedTours() {
    return Stream.fromFuture(_fetchTours());
  }

  Stream<List<Tour>> watchPopularDestinations() {
    return Stream.fromFuture(_fetchTours());
  }

  Stream<List<Review>> watchRecentReviews() {
    return Stream.fromFuture(_fetchReviews('/reviews/recent'));
  }

  Future<List<Tour>> _fetchTours() async {
    final data = await _api.getJson('/tours');
    return (data as List)
        .whereType<Map>()
        .map(
          (tour) =>
              Tour.fromJson(_mapTourData(Map<String, dynamic>.from(tour))),
        )
        .toList();
  }

  Future<List<Review>> _fetchReviews(String path) async {
    final data = await _api.getJson(path);
    return (data as List)
        .whereType<Map>()
        .map(
          (review) => Review.fromJson(
            _mapReviewData(Map<String, dynamic>.from(review)),
          ),
        )
        .toList();
  }
}

@riverpod
ExploreRepository exploreRepository(Ref ref) {
  return ExploreRepository(ref.watch(apiClientProvider));
}

@riverpod
Stream<List<Tour>> heroPromotions(Ref ref) {
  return ref.watch(exploreRepositoryProvider).watchHeroPromotions();
}

@riverpod
Stream<List<Tour>> featuredTours(Ref ref) {
  return ref.watch(exploreRepositoryProvider).watchFeaturedTours();
}

@riverpod
Stream<List<Tour>> popularDestinations(Ref ref) {
  return ref.watch(exploreRepositoryProvider).watchPopularDestinations();
}

@riverpod
Stream<List<Review>> recentReviews(Ref ref) {
  return ref.watch(exploreRepositoryProvider).watchRecentReviews();
}

Map<String, dynamic> _mapTourData(Map<String, dynamic> data) {
  data['title'] = data['title'] as String? ?? '';
  data['destination'] = data['destination'] as String? ?? data['title'];
  data['category'] = data['category'] as String? ?? data['type'] ?? 'Tour';
  data['badges'] =
      (data['badges'] as List?)?.cast<String>() ?? const <String>[];
  data['heroImageUrl'] = data['heroImageUrl'] as String? ?? '';
  data['galleryImageUrls'] =
      (data['galleryImageUrls'] as List?)?.cast<String>() ?? const <String>[];
  data['currency'] = data['currency'] as String? ?? 'USD';
  data['ratingAverage'] = (data['ratingAverage'] as num?)?.toDouble() ?? 0.0;
  data['ratingCount'] = (data['ratingCount'] as num?)?.toInt() ?? 0;
  data['durationDays'] = (data['durationDays'] as num?)?.toInt() ?? 0;
  data['maxParticipants'] = (data['maxParticipants'] as num?)?.toInt() ?? 0;
  data['overview'] = data['overview'] as String? ?? data['description'] ?? '';
  data['itinerary'] =
      ((data['itinerary'] ?? data['itineraries']) as List?)
          ?.whereType<Map>()
          .map((step) => Map<String, dynamic>.from(step))
          .toList() ??
      const <Map<String, dynamic>>[];
  data['inclusions'] =
      (data['inclusions'] as List?)?.cast<String>() ?? const <String>[];
  data['latitude'] = (data['latitude'] as num?)?.toDouble() ?? 0.0;
  data['longitude'] = (data['longitude'] as num?)?.toDouble() ?? 0.0;
  final dates = data['availableDates'] ?? data['dates'];
  if (dates is List) {
    data['availableDates'] = dates.map((date) {
      if (date is Map && date['startDate'] != null) return date['startDate'];
      return date;
    }).toList();
  } else {
    data['availableDates'] = const <String>[];
  }
  data['pricePerPerson'] =
      (data['pricePerPerson'] as num?)?.toDouble() ??
      (data['basePrice'] as num?)?.toDouble() ??
      0.0;
  data['privateVehicleSurcharge'] =
      (data['privateVehicleSurcharge'] as num?)?.toDouble() ?? 0.0;
  if (data['groupSizeOptions'] is List) {
    data['groupSizeOptions'] = (data['groupSizeOptions'] as List).map((opt) {
      if (opt is Map) {
        final newOpt = Map<String, dynamic>.from(opt);
        newOpt['priceModifier'] =
            (newOpt['priceModifier'] as num?)?.toDouble() ?? 0.0;
        newOpt['maxSize'] = (newOpt['maxSize'] as num?)?.toInt() ?? 0;
        return newOpt;
      }
      return opt;
    }).toList();
  } else {
    data['groupSizeOptions'] = const <Map<String, dynamic>>[];
  }
  return data;
}

Map<String, dynamic> _mapReviewData(Map<String, dynamic> data) {
  data['id'] = data['id'] as String? ?? '';
  final user = data['user'] is Map
      ? Map<String, dynamic>.from(data['user'] as Map)
      : const <String, dynamic>{};
  data['userName'] =
      data['userName'] as String? ??
      [
        user['firstName'],
        user['lastName'],
      ].whereType<String>().join(' ').trim();
  if ((data['userName'] as String).isEmpty) data['userName'] = 'Anonymous';
  data['userPhotoUrl'] = data['userPhotoUrl'] as String? ?? '';
  data['overallRating'] =
      (data['overallRating'] as num?)?.toDouble() ??
      (data['rating'] as num?)?.toDouble() ??
      0.0;
  data['comment'] = data['comment'] as String? ?? '';
  if (data['createdAt'] is String) {
    data['createdAt'] = data['createdAt'] as String;
  } else {
    data['createdAt'] = DateTime.now().toIso8601String();
  }
  return data;
}
