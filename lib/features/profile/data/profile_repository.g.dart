// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that reactively streams the current user's profile document from Firestore.

@ProviderFor(userFirestoreData)
final userFirestoreDataProvider = UserFirestoreDataProvider._();

/// Provider that reactively streams the current user's profile document from Firestore.

final class UserFirestoreDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          Stream<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $StreamProvider<Map<String, dynamic>?> {
  /// Provider that reactively streams the current user's profile document from Firestore.
  UserFirestoreDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userFirestoreDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFirestoreDataHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>?> create(Ref ref) {
    return userFirestoreData(ref);
  }
}

String _$userFirestoreDataHash() => r'89e87eb4dbf958417f1be41c439d03572c41f2ea';
