// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationsRepository,
          NotificationsRepository,
          NotificationsRepository
        >
    with $Provider<NotificationsRepository> {
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsRepository create(Ref ref) {
    return notificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRepository>(value),
    );
  }
}

String _$notificationsRepositoryHash() =>
    r'fc08c1d5f1874a343f45220c762068d5e6c68259';

@ProviderFor(notificationsStream)
final notificationsStreamProvider = NotificationsStreamFamily._();

final class NotificationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotificationItem>>,
          List<NotificationItem>,
          Stream<List<NotificationItem>>
        >
    with
        $FutureModifier<List<NotificationItem>>,
        $StreamProvider<List<NotificationItem>> {
  NotificationsStreamProvider._({
    required NotificationsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notificationsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsStreamHash();

  @override
  String toString() {
    return r'notificationsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NotificationItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NotificationItem>> create(Ref ref) {
    final argument = this.argument as String;
    return notificationsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsStreamHash() =>
    r'0a6c6434bd4bce4d0527d8a49dbfd73332ba578a';

final class NotificationsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NotificationItem>>, String> {
  NotificationsStreamFamily._()
    : super(
        retry: null,
        name: r'notificationsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationsStreamProvider call(String uid) =>
      NotificationsStreamProvider._(argument: uid, from: this);

  @override
  String toString() => r'notificationsStreamProvider';
}
