/// Legacy saved payment metadata shown for account cleanup only.
class PaymentMethodItem {
  final String id;
  final String brand;
  final String last4;
  final bool isDefault;

  const PaymentMethodItem({
    required this.id,
    required this.brand,
    required this.last4,
    required this.isDefault,
  });
}
