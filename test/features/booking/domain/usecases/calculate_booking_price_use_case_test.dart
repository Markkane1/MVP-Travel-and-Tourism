import 'package:test/test.dart';
import 'package:mvp_travel/features/explore/domain/tour.dart';
import 'package:mvp_travel/features/booking/domain/usecases/calculate_booking_price_use_case.dart';

void main() {
  late CalculateBookingPriceUseCase useCase;
  late Tour testTour;

  setUp(() {
    useCase = CalculateBookingPriceUseCase();
    testTour = Tour(
      id: 'test-tour',
      title: 'Test Premium Expedition',
      destination: 'Bora Bora',
      category: 'Beach',
      badges: ['Premium'],
      heroImageUrl: 'https://example.com/hero.jpg',
      galleryImageUrls: ['https://example.com/gallery.jpg'],
      pricePerPerson: 1000.0,
      currency: 'USD',
      durationDays: 5,
      maxParticipants: 16,
      ratingAverage: 4.9,
      ratingCount: 128,
      overview: 'Test overview description.',
      itinerary: const [
        {'day': 1, 'title': 'Arrival', 'description': 'Welcome.'},
      ],
      inclusions: const ['Hotel', 'Transport'],
      latitude: -16.5004,
      longitude: -151.7415,
      availableDates: [DateTime(2026, 7, 5), DateTime(2026, 7, 10)],
      privateVehicleSurcharge: 250.0,
      groupSizeOptions: const [
        {'label': 'Shared', 'maxSize': 16, 'priceModifier': 0.0},
        {'label': 'Max 6', 'maxSize': 6, 'priceModifier': 500.0},
        {'label': 'Max 12', 'maxSize': 12, 'priceModifier': 300.0},
      ],
    );
  });

  group('CalculateBookingPriceUseCase Tests', () {
    test('Case 1: Shared tour, 2 adults, 0 children, no private vehicle', () {
      final total = useCase(
        tour: testTour,
        adults: 2,
        children: 0,
        privateVehicle: false,
        groupSizeOptionLabel: 'Shared',
      );
      // 1000.0 * 2 = 2000.0
      expect(total, 2000.0);
    });

    test(
      'Case 2: Shared tour, 1 adult, 0 children, with private vehicle surcharge',
      () {
        final total = useCase(
          tour: testTour,
          adults: 1,
          children: 0,
          privateVehicle: true,
          groupSizeOptionLabel: 'Shared',
        );
        // 1000.0 * 1 + 250.0 = 1250.0
        expect(total, 1250.0);
      },
    );

    test('Case 3: Max 6 group option (with private vehicle enabled)', () {
      final total = useCase(
        tour: testTour,
        adults: 2,
        children: 0,
        privateVehicle: true,
        groupSizeOptionLabel: 'Max 6',
      );
      // base: 1000.0 * 2 = 2000.0
      // group size modifier: 500.0
      // private vehicle surcharge: 250.0
      // total = 2000.0 + 500.0 + 250.0 = 2750.0
      expect(total, 2750.0);
    });

    test('Case 4: Max 12 group option (with private vehicle enabled)', () {
      final total = useCase(
        tour: testTour,
        adults: 4,
        children: 0,
        privateVehicle: true,
        groupSizeOptionLabel: 'Max 12',
      );
      // base: 1000.0 * 4 = 4000.0
      // group size modifier: 300.0
      // private vehicle surcharge: 250.0
      // total = 4000.0 + 300.0 + 250.0 = 4550.0
      expect(total, 4550.0);
    });

    test(
      'Case 5: Shared tour, 2 adults, 2 children (children at 50% price)',
      () {
        final total = useCase(
          tour: testTour,
          adults: 2,
          children: 2,
          privateVehicle: false,
          groupSizeOptionLabel: 'Shared',
        );
        // base: 1000.0 * (2 + 2 * 0.5) = 1000.0 * 3 = 3000.0
        expect(total, 3000.0);
      },
    );

    test(
      'Case 6: Invalid participant counts are treated as zero instead of producing a negative total',
      () {
        final total = useCase(
          tour: testTour,
          adults: -2,
          children: -2,
          privateVehicle: false,
          groupSizeOptionLabel: 'Shared',
        );

        expect(total, 0.0);
      },
    );
  });
}
