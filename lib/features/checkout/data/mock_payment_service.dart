import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/result.dart';
import '../domain/payment_service.dart';

part 'mock_payment_service.g.dart';

/// Simulated payment gateway for Prompt 9.
/// Exposes a static trigger `shouldFail` to toggle simulation failures in debug environments.
class MockPaymentService implements PaymentService {
  /// Toggle to simulate transaction errors.
  static bool shouldFail = false;

  @override
  Future<Result<PaymentOutcome>> pay({
    required String bookingId,
    required num amount,
    required String currency,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (shouldFail) {
      return const Result.failure(
        AppException.payment('Card was declined. Please use a different card.'),
      );
    }

    return const Result.success(
      PaymentOutcome(transactionId: 'TXN-MOCK-123456'),
    );
  }
}

@riverpod
PaymentService paymentService(Ref ref) {
  return MockPaymentService();
}
