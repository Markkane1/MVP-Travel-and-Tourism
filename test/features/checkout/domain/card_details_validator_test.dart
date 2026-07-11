import 'package:test/test.dart';
import 'package:mvp_travel/features/checkout/domain/card_details_validator.dart';

void main() {
  group('validateCardDetails', () {
    test('accepts valid card details', () {
      final result = validateCardDetails(
        name: 'Jane Doe',
        cardNumber: '4111 1111 1111 1111',
        expiry: '12/30',
        cvv: '123',
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('rejects a missing cardholder name', () {
      final result = validateCardDetails(
        name: '   ',
        cardNumber: '4111111111111111',
        expiry: '12/30',
        cvv: '123',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Please enter the cardholder name.');
    });

    test('rejects an invalid card number', () {
      final result = validateCardDetails(
        name: 'Jane Doe',
        cardNumber: '4111',
        expiry: '12/30',
        cvv: '123',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Please enter a valid card number.');
    });
  });
}
