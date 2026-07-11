import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/safe_stream.dart';
import '../../explore/domain/tour.dart';
import '../../explore/domain/review.dart';

part 'tour_details_repository.g.dart';

/// Repository responsible for loading a single tour and its reviews subcollection.
class TourDetailsRepository {
  final FirebaseFirestore _firestore;

  TourDetailsRepository(this._firestore);

  /// Streams a single tour.
  Stream<Tour?> watchTour(String tourId) {
    return _firestore.collection('tours').doc(tourId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
      data['id'] = doc.id;
      return Tour.fromJson(_mapTourData(data));
    }).mapAppException('Failed to load tour details');
  }

  /// Streams the 5 most recent reviews for a tour.
  Stream<List<Review>> watchReviews(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return Review.fromJson(data);
      }).toList();
    }).mapAppException('Failed to load tour reviews');
  }
}

@riverpod
TourDetailsRepository tourDetailsRepository(Ref ref) {
  return TourDetailsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<Tour?> tourDetails(Ref ref, String tourId) {
  return ref.watch(tourDetailsRepositoryProvider).watchTour(tourId);
}

@riverpod
Stream<List<Review>> tourReviews(Ref ref, String tourId) {
  return ref.watch(tourDetailsRepositoryProvider).watchReviews(tourId);
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
