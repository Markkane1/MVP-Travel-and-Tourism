// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'a89dee20163feb56ab0747b1feb60c3b53ae5b11';

/// Provider that reactively streams the current user's profile from the API.

@ProviderFor(userProfileData)
final userProfileDataProvider = UserProfileDataProvider._();

/// Provider that reactively streams the current user's profile from the API.

final class UserProfileDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          Stream<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $StreamProvider<Map<String, dynamic>?> {
  /// Provider that reactively streams the current user's profile from the API.
  UserProfileDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileDataHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>?> create(Ref ref) {
    return userProfileData(ref);
  }
}

String _$userProfileDataHash() => r'99845fc5dfd0250f2b479a552d9c4d7333ec3a60';

@ProviderFor(paymentMethodsStream)
final paymentMethodsStreamProvider = PaymentMethodsStreamFamily._();

final class PaymentMethodsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentMethodItem>>,
          List<PaymentMethodItem>,
          Stream<List<PaymentMethodItem>>
        >
    with
        $FutureModifier<List<PaymentMethodItem>>,
        $StreamProvider<List<PaymentMethodItem>> {
  PaymentMethodsStreamProvider._({
    required PaymentMethodsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paymentMethodsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentMethodsStreamHash();

  @override
  String toString() {
    return r'paymentMethodsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PaymentMethodItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PaymentMethodItem>> create(Ref ref) {
    final argument = this.argument as String;
    return paymentMethodsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentMethodsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentMethodsStreamHash() =>
    r'00aae75182b5ca49c6bf8b712d35926f64fc468a';

final class PaymentMethodsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PaymentMethodItem>>, String> {
  PaymentMethodsStreamFamily._()
    : super(
        retry: null,
        name: r'paymentMethodsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaymentMethodsStreamProvider call(String uid) =>
      PaymentMethodsStreamProvider._(argument: uid, from: this);

  @override
  String toString() => r'paymentMethodsStreamProvider';
}
