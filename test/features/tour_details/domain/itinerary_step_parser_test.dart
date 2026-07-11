import 'package:test/test.dart';
import 'package:mvp_travel/features/tour_details/domain/itinerary_step_parser.dart';

void main() {
  group('ItineraryStepParser', () {
    test('parses a valid itinerary step into a safe view model', () {
      final parsed = parseItineraryStep(
        {'day': 2, 'title': 'Lunch', 'description': 'Enjoy the view.'},
        1,
      );

      expect(parsed.day, 2);
      expect(parsed.title, 'Lunch');
      expect(parsed.description, 'Enjoy the view.');
    });

    test('falls back safely for malformed itinerary data', () {
      final parsed = parseItineraryStep('not-a-map', 7);

      expect(parsed.day, 7);
      expect(parsed.title, '');
      expect(parsed.description, '');
    });
  });
}
