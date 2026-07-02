// ignore_for_file: subtype_of_sealed_class

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:mvp_travel/core/errors/app_exception.dart';
import 'package:mvp_travel/core/utils/result.dart';
import 'package:mvp_travel/features/reviews/data/reviews_repository.dart';
import 'package:mvp_travel/features/reviews/domain/usecases/submit_review_use_case.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
  });

  group('SubmitReviewUseCase', () {
    test(
      'success - review written and booking reviewed=true resolves',
      () async {
        when(
          () => mockRepository.submitReview(
            userId: any(named: 'userId'),
            userName: any(named: 'userName'),
            userPhotoUrl: any(named: 'userPhotoUrl'),
            bookingId: any(named: 'bookingId'),
            tourId: any(named: 'tourId'),
            overallRating: any(named: 'overallRating'),
            aspectRatings: any(named: 'aspectRatings'),
            comment: any(named: 'comment'),
            photoUrls: any(named: 'photoUrls'),
          ),
        ).thenAnswer((_) async => const Result.success(null));
        when(
          () => mockRepository.waitForReviewProcessing(any()),
        ).thenAnswer((_) async => const Result.success(null));

        final useCase = SubmitReviewUseCase(mockRepository);

        final result = await useCase.execute(
          userId: 'user-1',
          userName: 'Alice',
          userPhotoUrl: 'https://example.com/alice.png',
          bookingId: 'booking-1',
          tourId: 'tour-1',
          overallRating: 5.0,
          aspectRatings: {'Service': 5.0},
          comment: 'Fantastic!',
          photoUrls: const [],
        );

        expect(result, isA<Success<void>>());
        verify(
          () => mockRepository.submitReview(
            userId: 'user-1',
            userName: 'Alice',
            userPhotoUrl: 'https://example.com/alice.png',
            bookingId: 'booking-1',
            tourId: 'tour-1',
            overallRating: 5.0,
            aspectRatings: {'Service': 5.0},
            comment: 'Fantastic!',
            photoUrls: const [],
          ),
        ).called(1);
        verify(
          () => mockRepository.waitForReviewProcessing('booking-1'),
        ).called(1);
      },
    );

    test('processing timeout/failure -> Result is Failure', () async {
      when(
        () => mockRepository.submitReview(
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          userPhotoUrl: any(named: 'userPhotoUrl'),
          bookingId: any(named: 'bookingId'),
          tourId: any(named: 'tourId'),
          overallRating: any(named: 'overallRating'),
          aspectRatings: any(named: 'aspectRatings'),
          comment: any(named: 'comment'),
          photoUrls: any(named: 'photoUrls'),
        ),
      ).thenAnswer((_) async => const Result.success(null));
      when(() => mockRepository.waitForReviewProcessing(any())).thenAnswer(
        (_) async => const Result.failure(AppException.unknown('timeout')),
      );

      final useCase = SubmitReviewUseCase(mockRepository);

      final result = await useCase.execute(
        userId: 'user-1',
        userName: 'Alice',
        userPhotoUrl: 'https://example.com/alice.png',
        bookingId: 'booking-1',
        tourId: 'tour-1',
        overallRating: 5.0,
        aspectRatings: {'Service': 5.0},
        comment: 'Fantastic!',
        photoUrls: const [],
      );

      expect(result, isA<Failure<void>>());
    });

    test('submit failure -> Result is Failure', () async {
      when(
        () => mockRepository.submitReview(
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          userPhotoUrl: any(named: 'userPhotoUrl'),
          bookingId: any(named: 'bookingId'),
          tourId: any(named: 'tourId'),
          overallRating: any(named: 'overallRating'),
          aspectRatings: any(named: 'aspectRatings'),
          comment: any(named: 'comment'),
          photoUrls: any(named: 'photoUrls'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(AppException.unknown('write failed')),
      );

      final useCase = SubmitReviewUseCase(mockRepository);

      final result = await useCase.execute(
        userId: 'user-1',
        userName: 'Alice',
        userPhotoUrl: 'https://example.com/alice.png',
        bookingId: 'booking-1',
        tourId: 'tour-1',
        overallRating: 5.0,
        aspectRatings: {'Service': 5.0},
        comment: 'Fantastic!',
        photoUrls: const [],
      );

      expect(result, isA<Failure<void>>());
      verifyNever(() => mockRepository.waitForReviewProcessing(any()));
    });
  });
}
