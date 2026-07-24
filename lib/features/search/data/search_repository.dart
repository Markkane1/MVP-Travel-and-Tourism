import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/api_client.dart';
import '../../explore/domain/tour.dart';

part 'search_repository.g.dart';

/// Represents search queries filters.
class SearchFilters {
  final String? category;
  final String? destination;
  final double? minPrice;
  final double? maxPrice;
  final int? durationDays;
  final String? query;

  const SearchFilters({
    this.category,
    this.destination,
    this.minPrice,
    this.maxPrice,
    this.durationDays,
    this.query,
  });

  SearchFilters copyWith({
    String? category,
    String? destination,
    double? minPrice,
    double? maxPrice,
    int? durationDays,
    String? query,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      destination: destination ?? this.destination,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      durationDays: durationDays ?? this.durationDays,
      query: query ?? this.query,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          destination == other.destination &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          durationDays == other.durationDays &&
          query == other.query;

  @override
  int get hashCode =>
      category.hashCode ^
      destination.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      durationDays.hashCode ^
      query.hashCode;
}

class SearchRepository {
  final ApiClient _api;

  SearchRepository(this._api);

  Stream<List<Tour>> searchTours(SearchFilters filters) {
    return Stream.fromFuture(_fetchTours(filters));
  }

  Future<List<Tour>> _fetchTours(SearchFilters filters) async {
    final data = await _api.getJson('/tours');
    final tours = (data as List)
        .whereType<Map>()
        .map(
          (tour) =>
              Tour.fromJson(_mapTourData(Map<String, dynamic>.from(tour))),
        )
        .toList();

    return tours.where((tour) {
      if (filters.category != null && filters.category != 'All') {
        if (tour.category != filters.category) return false;
      }

      if (filters.destination != null &&
          filters.destination != 'All Destinations' &&
          filters.destination != 'All') {
        final dest = filters.destination!.toLowerCase();
        if (!tour.destination.toLowerCase().contains(dest)) return false;
      }

      if (filters.minPrice != null && tour.pricePerPerson < filters.minPrice!) {
        return false;
      }

      if (filters.maxPrice != null && tour.pricePerPerson > filters.maxPrice!) {
        return false;
      }

      if (filters.durationDays != null &&
          tour.durationDays != filters.durationDays) {
        return false;
      }

      if (filters.query != null && filters.query!.isNotEmpty) {
        final q = filters.query!.toLowerCase();
        final titleMatch = tour.title.toLowerCase().contains(q);
        final descMatch = tour.destination.toLowerCase().contains(q);
        final overviewMatch = tour.overview.toLowerCase().contains(q);
        if (!titleMatch && !descMatch && !overviewMatch) return false;
      }

      return true;
    }).toList();
  }
}

@riverpod
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(ref.watch(apiClientProvider));
}

@riverpod
Stream<List<Tour>> searchResults(Ref ref, SearchFilters filters) {
  return ref.watch(searchRepositoryProvider).searchTours(filters);
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
