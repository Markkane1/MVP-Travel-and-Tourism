import '../../../../core/utils/result.dart';
import '../../data/reviews_repository.dart';

/// Use case to submit a tour review.
class SubmitReviewUseCase {
  final ReviewsRepository _repository;

  SubmitReviewUseCase(this._repository);

  /// Submits the review through the backend API.
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
      onSuccess: (_) async => const Result.success(null),
      onFailure: (exception) => Result.failure(exception),
    );
  }
}
