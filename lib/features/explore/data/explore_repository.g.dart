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

String _$exploreRepositoryHash() => r'5dbdbdc88f7d7070776029c97caf33e4c6ea33b9';

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

String _$heroPromotionsHash() => r'05c463facdae992f538b0dd4191f6f637cded7dd';

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

String _$featuredToursHash() => r'cb7c6d8853249a5b375ed3ac5be2516a351a821b';

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
    r'bb73a1b6659593860b65809f3e34b2a0de7266c9';

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

String _$recentReviewsHash() => r'e46b71c05b4afad0217e6d338b5b2da8830d362c';
