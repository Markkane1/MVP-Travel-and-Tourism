import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/safe_stream.dart';

import '../../../../core/config/env.dart';
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

  Future<Result<void>> submitReview({
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String bookingId,
    required String tourId,
    required double overallRating,
    required Map<String, double> aspectRatings,
    required String comment,
    required List<String> photoUrls,
  }) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('reviews')
          .add({
            'userId': userId,
            'userName': userName,
            'userPhotoUrl': userPhotoUrl,
            'bookingId': bookingId,
            'overallRating': overallRating,
            'aspectRatings': {
              'service': aspectRatings['Service'] ?? 0.0,
              'accommodation': aspectRatings['Accommodation'] ?? 0.0,
              'activities': aspectRatings['Activities'] ?? 0.0,
              'value': aspectRatings['Value'] ?? 0.0,
            },
            'comment': comment,
            'photoUrls': photoUrls,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to submit review: ${e.toString()}'),
      );
    }
  }

  Future<Result<void>> waitForReviewProcessing(String bookingId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .snapshots()
          .firstWhere((snap) {
            final data = snap.data();
            return data != null && (data['reviewed'] ?? false) == true;
          })
          .timeout(const Duration(seconds: 10));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to verify review processing: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<void>> finalizeReviewFallback({
    required String userId,
    required String bookingId,
  }) async {
    if (!Env.isDev) {
      return const Result.failure(
        AppException.unknown('Review processing is still pending.'),
      );
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final bookingRef = _firestore.collection('bookings').doc(bookingId);

        final userSnap = await transaction.get(userRef);
        final currentPoints =
            (userSnap.data()?['loyaltyPoints'] as num?)?.toInt() ?? 0;

        transaction.set(userRef, {
          'loyaltyPoints': currentPoints + 250,
        }, SetOptions(merge: true));
        transaction.set(bookingRef, {
          'reviewed': true,
        }, SetOptions(merge: true));
      });

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to finalize review in dev fallback: ${e.toString()}',
        ),
      );
    }
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
  return ref
      .watch(reviewsRepositoryProvider)
      .watchIsTourReviewed(tourId, user.uid);
}
