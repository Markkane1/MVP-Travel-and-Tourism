import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/reviews_repository.dart';

/// Sequenced multi-step use case to submit a tour review.
class SubmitReviewUseCase {
  final ReviewsRepository _repository;

  SubmitReviewUseCase(this._repository);

  /// Submits the review to Firestore and waits until the background Cloud Function
  /// sets `reviewed: true` on the booking document.
  Future<Result<void>> execute({
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
    final submitResult = await _repository.submitReview(
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      bookingId: bookingId,
      tourId: tourId,
      overallRating: overallRating,
      aspectRatings: aspectRatings,
      comment: comment,
      photoUrls: photoUrls,
    );

    return submitResult.when(
      onSuccess: (_) async {
        final waitResult = await _repository.waitForReviewProcessing(bookingId);
        return waitResult.when(
          onSuccess: (_) => const Result.success(null),
          onFailure: (exception) => Result.failure(
            AppException.unknown(
              'Failed to submit review and verify points credit: ${exception.message}',
            ),
          ),
        );
      },
      onFailure: (exception) => Result.failure(
        AppException.unknown(
          'Failed to submit review and verify points credit: ${exception.message}',
        ),
      ),
    );
  }
}
