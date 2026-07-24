// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingRepository)
final bookingRepositoryProvider = BookingRepositoryProvider._();

final class BookingRepositoryProvider
    extends
        $FunctionalProvider<
          BookingRepository,
          BookingRepository,
          BookingRepository
        >
    with $Provider<BookingRepository> {
  BookingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingRepository create(Ref ref) {
    return bookingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingRepository>(value),
    );
  }
}

String _$bookingRepositoryHash() => r'2604efcaad157b84eca3efc7e2341bb73284b0f1';

@ProviderFor(bookingDetails)
final bookingDetailsProvider = BookingDetailsFamily._();

final class BookingDetailsProvider
    extends
        $FunctionalProvider<AsyncValue<Booking?>, Booking?, Stream<Booking?>>
    with $FutureModifier<Booking?>, $StreamProvider<Booking?> {
  BookingDetailsProvider._({
    required BookingDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingDetailsHash();

  @override
  String toString() {
    return r'bookingDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Booking?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Booking?> create(Ref ref) {
    final argument = this.argument as String;
    return bookingDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingDetailsHash() => r'dcfb6fffbd760a78d4c853412bcc0abe559c0ff0';

final class BookingDetailsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Booking?>, String> {
  BookingDetailsFamily._()
    : super(
        retry: null,
        name: r'bookingDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookingDetailsProvider call(String bookingId) =>
      BookingDetailsProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingDetailsProvider';
}

@ProviderFor(userBookings)
final userBookingsProvider = UserBookingsFamily._();

final class UserBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Booking>>,
          List<Booking>,
          Stream<List<Booking>>
        >
    with $FutureModifier<List<Booking>>, $StreamProvider<List<Booking>> {
  UserBookingsProvider._({
    required UserBookingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userBookingsHash();

  @override
  String toString() {
    return r'userBookingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Booking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Booking>> create(Ref ref) {
    final argument = this.argument as String;
    return userBookings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userBookingsHash() => r'badaaf7c16c7db236a36300759a25430754f0dc1';

final class UserBookingsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Booking>>, String> {
  UserBookingsFamily._()
    : super(
        retry: null,
        name: r'userBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserBookingsProvider call(String userId) =>
      UserBookingsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userBookingsProvider';
}
