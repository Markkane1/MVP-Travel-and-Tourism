import 'package:mvp_travel/features/profile/data/profile_repository.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeProfileData', () {
    test('normalizes malformed profile values to safe defaults', () {
      final normalized = normalizeProfileData(<String, dynamic>{
        'displayName': 123,
        'email': null,
        'loyaltyPoints': '10',
        'milesTraveled': '5',
        'tier': null,
        'photoUrl': '',
        'notificationPrefs': <String, dynamic>{
          'bookingUpdates': 'false',
          'promotions': null,
          'conciergeMessages': true,
        },
        'preferences': <String, dynamic>{
          'dietary': true,
          'seat': 0,
          'hotelClass': null,
        },
      });

      final notificationPrefs = normalized['notificationPrefs'] as Map<String, dynamic>;
      final preferences = normalized['preferences'] as Map<String, dynamic>;

      expect(normalized['displayName'], 'Guest');
      expect(normalized['email'], '');
      expect(normalized['loyaltyPoints'], 10);
      expect(normalized['milesTraveled'], 5);
      expect(normalized['tier'], 'Standard');
      expect(normalized['photoUrl'], '');
      expect(notificationPrefs['bookingUpdates'], false);
      expect(notificationPrefs['promotions'], true);
      expect(preferences['dietary'], '');
      expect(preferences['seat'], '');
      expect(preferences['hotelClass'], '');
    });
  });
}
