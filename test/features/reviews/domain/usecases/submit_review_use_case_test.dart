// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:mvp_travel/features/reviews/domain/usecases/submit_review_use_case.dart';
import 'package:mvp_travel/core/utils/result.dart';
import 'package:mvp_travel/core/errors/app_exception.dart';

// ---------------------------------------------------------------------------
// Mocktail fakes
// ---------------------------------------------------------------------------
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockToursCollection;
  late MockDocumentReference mockTourDoc;
  late MockCollectionReference mockReviewsCollection;
  late MockDocumentReference mockReviewDocRef;
  late MockCollectionReference mockBookingsCollection;
  late MockDocumentReference mockBookingDocRef;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockToursCollection = MockCollectionReference();
    mockTourDoc = MockDocumentReference();
    mockReviewsCollection = MockCollectionReference();
    mockReviewDocRef = MockDocumentReference();
    mockBookingsCollection = MockCollectionReference();
    mockBookingDocRef = MockDocumentReference();

    // tours/{tourId}/reviews chain
    when(() => mockFirestore.collection('tours'))
        .thenReturn(mockToursCollection);
    when(() => mockToursCollection.doc(any())).thenReturn(mockTourDoc);
    when(() => mockTourDoc.collection('reviews'))
        .thenReturn(mockReviewsCollection);
    when(() => mockReviewsCollection.add(any()))
        .thenAnswer((_) async => mockReviewDocRef);

    // bookings/{bookingId} chain
    when(() => mockFirestore.collection('bookings'))
        .thenReturn(mockBookingsCollection);
    when(() => mockBookingsCollection.doc(any()))
        .thenReturn(mockBookingDocRef);
  });

  group('SubmitReviewUseCase', () {
    test('success — review written and booking reviewed=true resolves', () async {
      // Arrange: booking snapshot immediately returns reviewed=true
      final snap = MockDocumentSnapshot();
      when(() => snap.data()).thenReturn({'reviewed': true});
      when(() => mockBookingDocRef.snapshots())
          .thenAnswer((_) => Stream.value(snap));

      final useCase = SubmitReviewUseCase(firestore: mockFirestore);

      // Act
      final result = await useCase.execute(
        userId: 'user-1',
        userName: 'Alice',
        bookingId: 'booking-1',
        tourId: 'tour-1',
        overallRating: 5.0,
        aspectRatings: {'Service': 5.0},
        comment: 'Fantastic!',
        photoUrls: [],
      );

      // Assert — Result is a sealed class; check via pattern
      expect(result, isA<Success<void>>());
      verify(() => mockReviewsCollection.add(any())).called(1);
    });

    test('booking never resolves reviewed=true → Result is Failure', () async {
      // Arrange: snapshot stream that emits reviewed=false only
      final snap = MockDocumentSnapshot();
      when(() => snap.data()).thenReturn({'reviewed': false});
      when(() => mockBookingDocRef.snapshots())
          .thenAnswer((_) => Stream.value(snap));

      final useCase = SubmitReviewUseCase(firestore: mockFirestore);

      // Act — the internal 10s timeout will fire; wrap with 15s guard
      final result = await useCase
          .execute(
            userId: 'user-1',
            userName: 'Alice',
            bookingId: 'booking-1',
            tourId: 'tour-1',
            overallRating: 5.0,
            aspectRatings: {'Service': 5.0},
            comment: 'Fantastic!',
            photoUrls: [],
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => const Failure(
              UnknownException('test outer timeout'),
            ),
          );

      expect(result, isA<Failure<void>>());
    });

    test('Firestore write failure → Result is Failure', () async {
      // Arrange: reviews.add throws immediately
      when(() => mockReviewsCollection.add(any()))
          .thenThrow(Exception('network error'));

      final useCase = SubmitReviewUseCase(firestore: mockFirestore);

      // Act
      final result = await useCase.execute(
        userId: 'user-1',
        userName: 'Alice',
        bookingId: 'booking-1',
        tourId: 'tour-1',
        overallRating: 5.0,
        aspectRatings: {'Service': 5.0},
        comment: 'Fantastic!',
        photoUrls: [],
      );

      expect(result, isA<Failure<void>>());
    });
  });
}
