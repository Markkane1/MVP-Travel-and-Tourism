import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/result.dart';

part 'checkout_repository.g.dart';

/// Checkout repository for API-backed manual payment intents.
class CheckoutRepository {
  final ApiClient _api;

  CheckoutRepository(this._api);

  /// Submits the selected manual payment method through the trusted backend.
  Future<Result<void>> submitPaymentIntent({
    required String bookingId,
    required String paymentMethod,
  }) async {
    try {
      await _api.postJson('/payments/manual-intent', {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
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
}

@riverpod
CheckoutRepository checkoutRepository(Ref ref) {
  return CheckoutRepository(ref.watch(apiClientProvider));
}
