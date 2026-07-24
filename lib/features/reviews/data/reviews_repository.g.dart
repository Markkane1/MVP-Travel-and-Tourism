// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewsRepository)
final reviewsRepositoryProvider = ReviewsRepositoryProvider._();

final class ReviewsRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewsRepository,
          ReviewsRepository,
          ReviewsRepository
        >
    with $Provider<ReviewsRepository> {
  ReviewsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewsRepository create(Ref ref) {
    return reviewsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewsRepository>(value),
    );
  }
}

String _$reviewsRepositoryHash() => r'cc8c7c4dc5cb1ec73541d3e4d9ff2794c36910df';

@ProviderFor(tourReviewed)
final tourReviewedProvider = TourReviewedFamily._();

final class TourReviewedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  TourReviewedProvider._({
    required TourReviewedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tourReviewedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tourReviewedHash();

  @override
  String toString() {
    return r'tourReviewedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return tourReviewed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TourReviewedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tourReviewedHash() => r'12ea963bec3675340bfc9dafe372ff22f080cb8c';

final class TourReviewedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  TourReviewedFamily._()
    : super(
        retry: null,
        name: r'tourReviewedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TourReviewedProvider call(String tourId) =>
      TourReviewedProvider._(argument: tourId, from: this);

  @override
  String toString() => r'tourReviewedProvider';
}
