// Unit tests for BookingRepository's Timestamp → DateTime mapping logic.
// Tests the watchBooking stream by providing a mock DocumentSnapshot
// whose data contains Firestore Timestamps and verifying the resulting
// Booking domain model has properly converted DateTime fields.
// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:mvp_travel/core/errors/app_exception.dart';
import 'package:mvp_travel/features/booking/data/booking_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Map<String, dynamic> _rawBookingData({
  required DateTime tourDate,
  required DateTime createdAt,
}) {
  return {
    'userId': 'user-1',
    'tourId': 'tour-1',
    'tourSnapshot': {
      'title': 'Bora Bora Adventure',
      'heroImageUrl': 'https://example.com/hero.jpg',
      'destination': 'Bora Bora',
    },
    'tourDate': Timestamp.fromDate(tourDate),
    'adults': 2,
    'children': 0,
    'privateVehicle': false,
    'groupSizeOption': 'Shared',
    'pickupLocation': 'Airport',
    'specialRequests': null,
    'totalPrice': 2000.0,
    'currency': 'USD',
    'status': 'confirmed',
    'stripePaymentIntentId': null,
    'bookingReferenceCode': 'LT-12345-ADV',
    'reviewed': false,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;

  final tourDate = DateTime(2026, 8, 15, 10, 0);
  final createdAt = DateTime(2026, 7, 1, 9, 0);

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    when(() => mockFirestore.collection('bookings'))
        .thenReturn(mockCollection);
    when(() => mockCollection.doc('booking-1')).thenReturn(mockDocRef);

    when(() => mockSnapshot.exists).thenReturn(true);
    when(() => mockSnapshot.id).thenReturn('booking-1');
    when(() => mockSnapshot.data())
        .thenReturn(_rawBookingData(tourDate: tourDate, createdAt: createdAt));
    when(() => mockDocRef.snapshots())
        .thenAnswer((_) => Stream.value(mockSnapshot));
  });

  group('BookingRepository — Timestamp conversion', () {
    test('watchBooking converts Timestamp tourDate to DateTime correctly', () async {
      final repo = BookingRepository(mockFirestore);
      final booking = await repo.watchBooking('booking-1').first;

      expect(booking, isNotNull);
      expect(booking!.tourDate.year, equals(2026));
      expect(booking.tourDate.month, equals(8));
      expect(booking.tourDate.day, equals(15));
    });

    test('watchBooking converts Timestamp createdAt to DateTime correctly', () async {
      final repo = BookingRepository(mockFirestore);
      final booking = await repo.watchBooking('booking-1').first;

      expect(booking, isNotNull);
      expect(booking!.createdAt.year, equals(2026));
      expect(booking.createdAt.month, equals(7));
      expect(booking.createdAt.day, equals(1));
    });

    test('watchBooking maps status, totalPrice, adults correctly', () async {
      final repo = BookingRepository(mockFirestore);
      final booking = await repo.watchBooking('booking-1').first;

      expect(booking!.status, equals('confirmed'));
      expect(booking.totalPrice, equals(2000.0));
      expect(booking.adults, equals(2));
    });

    test('watchBooking returns null when document does not exist', () async {
      when(() => mockSnapshot.exists).thenReturn(false);
      final repo = BookingRepository(mockFirestore);
      final booking = await repo.watchBooking('booking-1').first;

      expect(booking, isNull);
    });

    test('watchBooking maps backend stream errors to AppException', () async {
      when(() => mockDocRef.snapshots())
          .thenAnswer((_) => Stream.error(Exception('boom')));

      final repo = BookingRepository(mockFirestore);

      expect(
        repo.watchBooking('booking-1'),
        emitsError(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            contains('Failed to load booking'),
          ),
        ),
      );
    });
  });
}
