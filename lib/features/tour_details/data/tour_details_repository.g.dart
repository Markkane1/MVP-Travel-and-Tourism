// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_details_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tourDetailsRepository)
final tourDetailsRepositoryProvider = TourDetailsRepositoryProvider._();

final class TourDetailsRepositoryProvider
    extends
        $FunctionalProvider<
          TourDetailsRepository,
          TourDetailsRepository,
          TourDetailsRepository
        >
    with $Provider<TourDetailsRepository> {
  TourDetailsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tourDetailsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tourDetailsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TourDetailsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TourDetailsRepository create(Ref ref) {
    return tourDetailsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TourDetailsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TourDetailsRepository>(value),
    );
  }
}

String _$tourDetailsRepositoryHash() =>
    r'82300688f5b38fad37ee884c7308ad969b655a42';

@ProviderFor(tourDetails)
final tourDetailsProvider = TourDetailsFamily._();

final class TourDetailsProvider
    extends $FunctionalProvider<AsyncValue<Tour?>, Tour?, Stream<Tour?>>
    with $FutureModifier<Tour?>, $StreamProvider<Tour?> {
  TourDetailsProvider._({
    required TourDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tourDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tourDetailsHash();

  @override
  String toString() {
    return r'tourDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Tour?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Tour?> create(Ref ref) {
    final argument = this.argument as String;
    return tourDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TourDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tourDetailsHash() => r'719db96958617cc37e0cd65c37ab40c692b2f916';

final class TourDetailsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Tour?>, String> {
  TourDetailsFamily._()
    : super(
        retry: null,
        name: r'tourDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TourDetailsProvider call(String tourId) =>
      TourDetailsProvider._(argument: tourId, from: this);

  @override
  String toString() => r'tourDetailsProvider';
}

@ProviderFor(tourReviews)
final tourReviewsProvider = TourReviewsFamily._();

final class TourReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  TourReviewsProvider._({
    required TourReviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tourReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tourReviewsHash();

  @override
  String toString() {
    return r'tourReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    final argument = this.argument as String;
    return tourReviews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TourReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tourReviewsHash() => r'3d3bb4aa129a4158f2de8d8f80c2a867b16e09a7';

final class TourReviewsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Review>>, String> {
  TourReviewsFamily._()
    : super(
        retry: null,
        name: r'tourReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TourReviewsProvider call(String tourId) =>
      TourReviewsProvider._(argument: tourId, from: this);

  @override
  String toString() => r'tourReviewsProvider';
}
