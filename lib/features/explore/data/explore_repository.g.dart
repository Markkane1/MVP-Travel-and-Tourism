// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreRepository)
final exploreRepositoryProvider = ExploreRepositoryProvider._();

final class ExploreRepositoryProvider
    extends
        $FunctionalProvider<
          ExploreRepository,
          ExploreRepository,
          ExploreRepository
        >
    with $Provider<ExploreRepository> {
  ExploreRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExploreRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExploreRepository create(Ref ref) {
    return exploreRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreRepository>(value),
    );
  }
}

String _$exploreRepositoryHash() => r'df1be5d9b0aa6d2dd56d6a9a905c999ac3145160';

@ProviderFor(heroPromotions)
final heroPromotionsProvider = HeroPromotionsProvider._();

final class HeroPromotionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tour>>,
          List<Tour>,
          Stream<List<Tour>>
        >
    with $FutureModifier<List<Tour>>, $StreamProvider<List<Tour>> {
  HeroPromotionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heroPromotionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heroPromotionsHash();

  @$internal
  @override
  $StreamProviderElement<List<Tour>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tour>> create(Ref ref) {
    return heroPromotions(ref);
  }
}

String _$heroPromotionsHash() => r'7cb51d4c829dc6ed5db3e9e893a9ec2cb79d01c6';

@ProviderFor(featuredTours)
final featuredToursProvider = FeaturedToursProvider._();

final class FeaturedToursProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tour>>,
          List<Tour>,
          Stream<List<Tour>>
        >
    with $FutureModifier<List<Tour>>, $StreamProvider<List<Tour>> {
  FeaturedToursProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredToursProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredToursHash();

  @$internal
  @override
  $StreamProviderElement<List<Tour>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tour>> create(Ref ref) {
    return featuredTours(ref);
  }
}

String _$featuredToursHash() => r'936187ae46af8e0248c1a712cc52e73da71795ea';

@ProviderFor(popularDestinations)
final popularDestinationsProvider = PopularDestinationsProvider._();

final class PopularDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tour>>,
          List<Tour>,
          Stream<List<Tour>>
        >
    with $FutureModifier<List<Tour>>, $StreamProvider<List<Tour>> {
  PopularDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularDestinationsHash();

  @$internal
  @override
  $StreamProviderElement<List<Tour>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tour>> create(Ref ref) {
    return popularDestinations(ref);
  }
}

String _$popularDestinationsHash() =>
    r'2dd1fcdf306ff6d7f097650a899a604c3a4ce090';

@ProviderFor(recentReviews)
final recentReviewsProvider = RecentReviewsProvider._();

final class RecentReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Review>>,
          List<Review>,
          Stream<List<Review>>
        >
    with $FutureModifier<List<Review>>, $StreamProvider<List<Review>> {
  RecentReviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentReviewsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentReviewsHash();

  @$internal
  @override
  $StreamProviderElement<List<Review>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Review>> create(Ref ref) {
    return recentReviews(ref);
  }
}

String _$recentReviewsHash() => r'25825e0f358419a1e62d7658e6a9f894ccf476d4';
