import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';

import '../../../../core/services/auth_service.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository {
  final ApiClient _api;

  ReviewsRepository(this._api);

  /// Streams a boolean indicating whether the given user has reviewed the given tour.
  Stream<bool> watchIsTourReviewed(String tourId, String uid) {
    return Stream.fromFuture(_isTourReviewed(tourId, uid));
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
    if (userId.isEmpty || bookingId.isEmpty || tourId.isEmpty) {
      return const Result.failure(
        AppException.unknown(
          'Review submission is missing required information.',
        ),
      );
    }

    if (overallRating <= 0.0) {
      return const Result.failure(
        AppException.unknown('Please select a valid rating before submitting.'),
      );
    }

    try {
      await _api.postJson('/reviews', {
        'bookingId': bookingId,
        'rating': overallRating.round(),
        'comment': comment,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to submit review: ${e.toString()}'),
      );
    }
  }

  Future<bool> _isTourReviewed(String tourId, String uid) async {
    final data = await _api.getJson(
      '/reviews/tour/${Uri.encodeComponent(tourId)}',
    );
    return (data as List).whereType<Map>().any((review) {
      return review['userId'] == uid;
    });
  }
}

@riverpod
ReviewsRepository reviewsRepository(Ref ref) {
  return ReviewsRepository(ref.watch(apiClientProvider));
}

@riverpod
Stream<bool> tourReviewed(Ref ref, String tourId) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return Stream.value(false);
  return ref
      .watch(reviewsRepositoryProvider)
      .watchIsTourReviewed(tourId, user.uid);
}
