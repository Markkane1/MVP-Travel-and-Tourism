import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/safe_stream.dart';

import '../domain/tour.dart';
import '../domain/review.dart';

part 'explore_repository.g.dart';

/// Repository responsible for streaming Explore dashboard sections from Firestore.
class ExploreRepository {
  final FirebaseFirestore _firestore;

  ExploreRepository(this._firestore);

  /// Streams tours with the "Exclusive" badge for the Hero Promo Carousel.
  Stream<List<Tour>> watchHeroPromotions() {
    return _firestore
        .collection('tours')
        .where('badges', arrayContains: 'Exclusive')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Tour.fromJson(_mapTourData(data));
      }).toList();
    }).mapAppException('Failed to load hero promotions');
  }

  /// Streams tours with the "Featured" badge.
  Stream<List<Tour>> watchFeaturedTours() {
    return _firestore
        .collection('tours')
        .where('badges', arrayContains: 'Featured')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Tour.fromJson(_mapTourData(data));
      }).toList();
    }).mapAppException('Failed to load featured tours');
  }

  /// Streams tours with the "Top Rated" badge.
  Stream<List<Tour>> watchPopularDestinations() {
    return _firestore
        .collection('tours')
        .where('badges', arrayContains: 'Top Rated')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Tour.fromJson(_mapTourData(data));
      }).toList();
    }).mapAppException('Failed to load popular destinations');
  }

  /// Streams the 5 most recent reviews using a collectionGroup query.
  Stream<List<Review>> watchRecentReviews() {
    return _firestore
        .collectionGroup('reviews')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Convert Firestore Timestamp to ISO-8601 String for json_serializable
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return Review.fromJson(data);
      }).toList();
    }).mapAppException('Failed to load recent reviews');
  }
}

@riverpod
ExploreRepository exploreRepository(Ref ref) {
  return ExploreRepository(FirebaseFirestore.instance);
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
  data['destination'] = data['destination'] as String? ?? '';
  data['category'] = data['category'] as String? ?? '';
  data['badges'] = (data['badges'] as List?)?.cast<String>() ?? const <String>[];
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
