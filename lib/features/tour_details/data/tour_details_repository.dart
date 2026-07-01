import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
      final data = doc.data()!;
      data['id'] = doc.id;
      return Tour.fromJson(_mapTourData(data));
    });
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
        final data = doc.data();
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return Review.fromJson(data);
      }).toList();
    });
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
  if (data['availableDates'] is List) {
    data['availableDates'] = (data['availableDates'] as List).map((timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate().toIso8601String();
      }
      return timestamp;
    }).toList();
  }
  if (data['pricePerPerson'] is int) {
    data['pricePerPerson'] = (data['pricePerPerson'] as int).toDouble();
  }
  if (data['privateVehicleSurcharge'] is int) {
    data['privateVehicleSurcharge'] = (data['privateVehicleSurcharge'] as int).toDouble();
  }
  if (data['groupSizeOptions'] is List) {
    data['groupSizeOptions'] = (data['groupSizeOptions'] as List).map((opt) {
      if (opt is Map) {
        final newOpt = Map<String, dynamic>.from(opt);
        if (newOpt['priceModifier'] is int) {
          newOpt['priceModifier'] = (newOpt['priceModifier'] as int).toDouble();
        }
        return newOpt;
      }
      return opt;
    }).toList();
  }
  return data;
}

