import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';

part 'checkout_repository.g.dart';

class CheckoutRepository {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  CheckoutRepository(this._functions, this._firestore);

  /// Triggers the cloud function to confirm the booking in Firestore.
  Future<Result<Map<String, dynamic>?>> confirmBooking(String bookingId) async {
    try {
      final response = await _functions.httpsCallable('confirmBooking').call({'bookingId': bookingId});
      final data = response.data as Map?;
      return Result.success(data?.cast<String, dynamic>());
    } catch (e) {
      return Result.failure(AppException.unknown('Booking confirmation failed: ${e.toString()}'));
    }
  }

  /// Adds a display-only payment method card under users/{uid}/paymentMethods.
  Future<Result<void>> savePaymentMethod({
    required String uid,
    required String cardBrand,
    required String last4,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .add({
        'cardBrand': cardBrand,
        'last4': last4,
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.unknown('Failed to save payment method: ${e.toString()}'));
    }
  }
}

@riverpod
CheckoutRepository checkoutRepository(Ref ref) {
  return CheckoutRepository(
    FirebaseFunctions.instance,
    FirebaseFirestore.instance,
  );
}
