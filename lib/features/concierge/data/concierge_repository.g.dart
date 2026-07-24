// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concierge_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conciergeRepository)
final conciergeRepositoryProvider = ConciergeRepositoryProvider._();

final class ConciergeRepositoryProvider
    extends
        $FunctionalProvider<
          ConciergeRepository,
          ConciergeRepository,
          ConciergeRepository
        >
    with $Provider<ConciergeRepository> {
  ConciergeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conciergeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conciergeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConciergeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConciergeRepository create(Ref ref) {
    return conciergeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConciergeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConciergeRepository>(value),
    );
  }
}

String _$conciergeRepositoryHash() =>
    r'262de6c5f1b048c1502f584957a7aaba9e57ac53';

@ProviderFor(conciergeProfile)
final conciergeProfileProvider = ConciergeProfileFamily._();

final class ConciergeProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConciergeProfile>,
          ConciergeProfile,
          Stream<ConciergeProfile>
        >
    with $FutureModifier<ConciergeProfile>, $StreamProvider<ConciergeProfile> {
  ConciergeProfileProvider._({
    required ConciergeProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conciergeProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conciergeProfileHash();

  @override
  String toString() {
    return r'conciergeProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ConciergeProfile> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ConciergeProfile> create(Ref ref) {
    final argument = this.argument as String;
    return conciergeProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConciergeProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conciergeProfileHash() => r'6a392f4982a0d46efce871768ce48f36026a4325';

final class ConciergeProfileFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ConciergeProfile>, String> {
  ConciergeProfileFamily._()
    : super(
        retry: null,
        name: r'conciergeProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConciergeProfileProvider call(String conciergeId) =>
      ConciergeProfileProvider._(argument: conciergeId, from: this);

  @override
  String toString() => r'conciergeProfileProvider';
}

@ProviderFor(conciergeMessages)
final conciergeMessagesProvider = ConciergeMessagesFamily._();

final class ConciergeMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConciergeMessage>>,
          List<ConciergeMessage>,
          Stream<List<ConciergeMessage>>
        >
    with
        $FutureModifier<List<ConciergeMessage>>,
        $StreamProvider<List<ConciergeMessage>> {
  ConciergeMessagesProvider._({
    required ConciergeMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conciergeMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conciergeMessagesHash();

  @override
  String toString() {
    return r'conciergeMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ConciergeMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConciergeMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return conciergeMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConciergeMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conciergeMessagesHash() => r'23e10f31b27379be9dd3b7b63a0518760f8d4015';

final class ConciergeMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ConciergeMessage>>, String> {
  ConciergeMessagesFamily._()
    : super(
        retry: null,
        name: r'conciergeMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConciergeMessagesProvider call(String uid) =>
      ConciergeMessagesProvider._(argument: uid, from: this);

  @override
  String toString() => r'conciergeMessagesProvider';
}

@ProviderFor(conciergeThreadMetadata)
final conciergeThreadMetadataProvider = ConciergeThreadMetadataFamily._();

final class ConciergeThreadMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          Stream<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $StreamProvider<Map<String, dynamic>> {
  ConciergeThreadMetadataProvider._({
    required ConciergeThreadMetadataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conciergeThreadMetadataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conciergeThreadMetadataHash();

  @override
  String toString() {
    return r'conciergeThreadMetadataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return conciergeThreadMetadata(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConciergeThreadMetadataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conciergeThreadMetadataHash() =>
    r'05cf037e9b85ba6fb4294f1aea468cc92a550fd4';

final class ConciergeThreadMetadataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, dynamic>>, String> {
  ConciergeThreadMetadataFamily._()
    : super(
        retry: null,
        name: r'conciergeThreadMetadataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConciergeThreadMetadataProvider call(String uid) =>
      ConciergeThreadMetadataProvider._(argument: uid, from: this);

  @override
  String toString() => r'conciergeThreadMetadataProvider';
}
