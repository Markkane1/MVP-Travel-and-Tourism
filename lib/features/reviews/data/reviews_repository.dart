import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/safe_stream.dart';

import '../../../../core/services/auth_service.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository {
  final FirebaseFirestore _firestore;

  ReviewsRepository(this._firestore);

  /// Streams a boolean indicating whether the given user has reviewed the given tour.
  Stream<bool> watchIsTourReviewed(String tourId, String uid) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('reviews')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty)
        .mapAppException('Failed to load review status');
  }
}

@riverpod
ReviewsRepository reviewsRepository(Ref ref) {
  return ReviewsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<bool> tourReviewed(Ref ref, String tourId) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return Stream.value(false);
  return ref.watch(reviewsRepositoryProvider).watchIsTourReviewed(tourId, user.uid);
}
