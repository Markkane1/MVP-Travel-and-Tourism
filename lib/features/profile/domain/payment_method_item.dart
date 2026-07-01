import 'package:cloud_firestore/cloud_firestore.dart';

/// Representation model for a display-only payment method card item.
class PaymentMethodItem {
  final String id;
  final String cardBrand;
  final String last4;
  final bool isDefault;

  const PaymentMethodItem({
    required this.id,
    required this.cardBrand,
    required this.last4,
    required this.isDefault,
  });

  factory PaymentMethodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethodItem(
      id: doc.id,
      cardBrand: data['cardBrand'] ?? 'Visa',
      last4: data['last4'] ?? '0000',
      isDefault: data['isDefault'] ?? false,
    );
  }
}
