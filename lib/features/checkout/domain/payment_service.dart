import '../../../../core/utils/result.dart';

/// Structured outcome of a successful payment gateway transaction.
class PaymentOutcome {
  final String transactionId;

  const PaymentOutcome({required this.transactionId});
}

/// Interface defining the contract for payment provider transactions.
abstract class PaymentService {
  /// Invokes a payment charge transaction.
  Future<Result<PaymentOutcome>> pay({
    required String bookingId,
    required num amount,
    required String currency,
  });
}
