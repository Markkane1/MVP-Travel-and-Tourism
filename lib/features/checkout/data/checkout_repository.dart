import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';

part 'checkout_repository.g.dart';

/// Checkout repository — no Cloud Functions dependency.
///
/// Payments are handled via bank transfer or pay-on-arrival.
/// Bookings remain in 'pending' status until an admin manually confirms them
/// in the admin app. This works entirely on the Firebase Spark (free) plan.
class CheckoutRepository {
  final FirebaseFirestore _firestore;

  CheckoutRepository(this._firestore);

  /// Marks a pending booking with the chosen payment method so admin
  /// knows how the customer intends to pay. The booking status stays 'pending'.
  Future<Result<void>> submitPaymentIntent({
    required String bookingId,
    required String paymentMethod, // 'bank_transfer' | 'pay_on_arrival'
    String? transferNote,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'paymentMethod': paymentMethod,
        'paymentSubmittedAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to record payment intent: ${e.toString()}',
        ),
      );
    }
  }

  /// Adds a display-only payment method card under users/{uid}/paymentMethods.
  Future<Result<void>> savePaymentMethod({
    required String uid,
    required String brand,
    required String last4,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .add({'brand': brand, 'last4': last4, 'isDefault': false});
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to save payment method: ${e.toString()}'),
      );
    }
  }
}

@riverpod
CheckoutRepository checkoutRepository(Ref ref) {
  return CheckoutRepository(FirebaseFirestore.instance);
}
