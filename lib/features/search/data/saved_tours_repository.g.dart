// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_tours_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedToursRepository)
final savedToursRepositoryProvider = SavedToursRepositoryProvider._();

final class SavedToursRepositoryProvider
    extends
        $FunctionalProvider<
          SavedToursRepository,
          SavedToursRepository,
          SavedToursRepository
        >
    with $Provider<SavedToursRepository> {
  SavedToursRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedToursRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedToursRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedToursRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedToursRepository create(Ref ref) {
    return savedToursRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedToursRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedToursRepository>(value),
    );
  }
}

String _$savedToursRepositoryHash() =>
    r'2cbcf28082285258c9207612edba08c299851d11';

@ProviderFor(savedTourIds)
final savedTourIdsProvider = SavedTourIdsProvider._();

final class SavedTourIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  SavedTourIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedTourIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedTourIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return savedTourIds(ref);
  }
}

String _$savedTourIdsHash() => r'b3e55f93292f3689a65b592725dc9cc52cfb39d0';

@ProviderFor(OptimisticSavedTours)
final optimisticSavedToursProvider = OptimisticSavedToursProvider._();

final class OptimisticSavedToursProvider
    extends $AsyncNotifierProvider<OptimisticSavedTours, Set<String>> {
  OptimisticSavedToursProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'optimisticSavedToursProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$optimisticSavedToursHash();

  @$internal
  @override
  OptimisticSavedTours create() => OptimisticSavedTours();
}

String _$optimisticSavedToursHash() =>
    r'd91c0db206184784d11350886d3c63e7a3d4e228';

abstract class _$OptimisticSavedTours extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(savedToursList)
final savedToursListProvider = SavedToursListProvider._();

final class SavedToursListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tour>>,
          AsyncValue<List<Tour>>,
          AsyncValue<List<Tour>>
        >
    with $Provider<AsyncValue<List<Tour>>> {
  SavedToursListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedToursListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedToursListHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Tour>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Tour>> create(Ref ref) {
    return savedToursList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Tour>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Tour>>>(value),
    );
  }
}

String _$savedToursListHash() => r'acb61810c5e4f192ed430750ef5826af7872e8c1';
