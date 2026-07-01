import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

/// Sequenced multi-step use case to submit a tour review.
class SubmitReviewUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SubmitReviewUseCase();

  /// Submits the review to Firestore and waits until the background Cloud Function
  /// sets `reviewed: true` on the booking document.
  Future<Result<void>> execute({
    required String userId,
    required String userName,
    required String bookingId,
    required String tourId,
    required double rating,
    required Map<String, double> aspects,
    required String comment,
    required List<String> images,
  }) async {
    try {
      // 1. Submit the review document to tours/{tourId}/reviews
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('reviews')
          .add({
        'userId': userId,
        'userName': userName,
        'bookingId': bookingId,
        'rating': rating,
        'aspects': aspects,
        'comment': comment,
        'images': images,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Wait until the background Cloud Function updates `bookings/{bookingId}` with `reviewed: true`.
      // We timeout after 10 seconds.
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
          'Failed to submit review and verify points credit: ${e.toString()}',
        ),
      );
    }
  }
}
