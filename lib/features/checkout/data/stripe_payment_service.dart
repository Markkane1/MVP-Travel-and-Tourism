import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';
import '../domain/payment_service.dart';

class StripePaymentService implements PaymentService {
  final FirebaseFunctions _functions;

  StripePaymentService(this._functions);

  @override
  Future<Result<PaymentOutcome>> pay({
    required String bookingId,
    required num amount,
    required String currency,
  }) async {
    try {
      // 1. Call Cloud Function to create PaymentIntent
      final response = await _functions.httpsCallable('createPaymentIntent').call({
        'bookingId': bookingId,
      });

      final data = response.data as Map?;
      if (data == null) {
        return const Result.failure(AppException.unknown('Invalid response from payment server'));
      }

      final clientSecret = data['paymentIntent'] as String?;
      final ephemeralKey = data['ephemeralKey'] as String?;
      final customer = data['customer'] as String?;

      if (clientSecret == null) {
        return const Result.failure(AppException.unknown('Missing client secret from server'));
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customer,
          merchantDisplayName: 'MVP Travel & Tourism',
          style: ThemeMode.system,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If presentPaymentSheet completes without throwing, payment was successful.
      // (If user cancels or card is declined, it throws a StripeException)
      
      // We don't have the exact transaction ID from the sheet response easily,
      // but we can return a success indicator. The webhook handles the actual confirmation.
      return const Result.success(
        PaymentOutcome(transactionId: 'completed_via_sheet'),
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const Result.failure(AppException.payment('Payment was canceled'));
      }
      return Result.failure(AppException.payment(e.error.localizedMessage ?? 'Payment failed'));
    } on FirebaseFunctionsException catch (e) {
      return Result.failure(AppException.unknown('Payment intent failed: ${e.message}'));
    } catch (e) {
      return Result.failure(AppException.unknown('An unexpected error occurred during payment: $e'));
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return StripePaymentService(FirebaseFunctions.instance);
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
