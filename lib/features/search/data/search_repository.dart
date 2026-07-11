import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/safe_stream.dart';
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
  final FirebaseFirestore _firestore;

  SearchRepository(this._firestore);

  /// Performs compound tour lookups.
  /// Note on Firestore Limitations:
  /// Firestore does not support native full-text searches or multi-field inequalities.
  /// We fetch by category (to limit database load) and filter by price/search keywords client-side.
  Stream<List<Tour>> searchTours(SearchFilters filters) {
    Query firestoreQuery = _firestore.collection('tours');

    if (filters.category != null && filters.category != 'All') {
      firestoreQuery = firestoreQuery.where(
        'category',
        isEqualTo: filters.category,
      );
    }

    return firestoreQuery
        .snapshots()
        .map((snapshot) {
          final tours = snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
            data['id'] = doc.id;
            return Tour.fromJson(_mapTourData(data));
          }).toList();

          return tours.where((tour) {
            // Destination check
            if (filters.destination != null &&
                filters.destination != 'All Destinations' &&
                filters.destination != 'All') {
              final dest = filters.destination!.toLowerCase();
              if (!tour.destination.toLowerCase().contains(dest)) {
                return false;
              }
            }

            // Min price check
            if (filters.minPrice != null &&
                tour.pricePerPerson < filters.minPrice!) {
              return false;
            }

            // Max price check
            if (filters.maxPrice != null &&
                tour.pricePerPerson > filters.maxPrice!) {
              return false;
            }

            // Duration check
            if (filters.durationDays != null &&
                tour.durationDays != filters.durationDays) {
              return false;
            }

            // Substring keywords text check
            if (filters.query != null && filters.query!.isNotEmpty) {
              final q = filters.query!.toLowerCase();
              final titleMatch = tour.title.toLowerCase().contains(q);
              final descMatch = tour.destination.toLowerCase().contains(q);
              final overviewMatch = tour.overview.toLowerCase().contains(q);
              if (!titleMatch && !descMatch && !overviewMatch) {
                return false;
              }
            }

            return true;
          }).toList();
        })
        .mapAppException('Failed to search tours');
  }
}

@riverpod
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Tour>> searchResults(Ref ref, SearchFilters filters) {
  return ref.watch(searchRepositoryProvider).searchTours(filters);
}

Map<String, dynamic> _mapTourData(Map<String, dynamic> data) {
  data['title'] = data['title'] as String? ?? '';
  data['destination'] = data['destination'] as String? ?? '';
  data['category'] = data['category'] as String? ?? '';
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
  data['overview'] = data['overview'] as String? ?? '';
  data['itinerary'] =
      (data['itinerary'] as List?)
          ?.whereType<Map>()
          .map((step) => Map<String, dynamic>.from(step))
          .toList() ??
      const <Map<String, dynamic>>[];
  data['inclusions'] =
      (data['inclusions'] as List?)?.cast<String>() ?? const <String>[];
  data['latitude'] = (data['latitude'] as num?)?.toDouble() ?? 0.0;
  data['longitude'] = (data['longitude'] as num?)?.toDouble() ?? 0.0;
  if (data['availableDates'] is List) {
    data['availableDates'] = (data['availableDates'] as List).map((timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate().toIso8601String();
      }
      return timestamp;
    }).toList();
  } else {
    data['availableDates'] = const <String>[];
  }
  data['pricePerPerson'] = (data['pricePerPerson'] as num?)?.toDouble() ?? 0.0;
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
