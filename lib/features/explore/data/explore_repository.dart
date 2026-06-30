import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
        return Tour.fromJson(data);
      }).toList();
    });
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
        return Tour.fromJson(data);
      }).toList();
    });
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
        return Tour.fromJson(data);
      }).toList();
    });
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
    });
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
