// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'01ef552c5328762f0b0b115f4e631c862f2e1a44';

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsFamily._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tour>>,
          List<Tour>,
          Stream<List<Tour>>
        >
    with $FutureModifier<List<Tour>>, $StreamProvider<List<Tour>> {
  SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required SearchFilters super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Tour>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tour>> create(Ref ref) {
    final argument = this.argument as SearchFilters;
    return searchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'5935d951a6ca6d9f612a435cdd73d29128205692';

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Tour>>, SearchFilters> {
  SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchResultsProvider call(SearchFilters filters) =>
      SearchResultsProvider._(argument: filters, from: this);

  @override
  String toString() => r'searchResultsProvider';
}
