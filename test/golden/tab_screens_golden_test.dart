// Golden tests for each bottom-navigation tab's root screen.
// Screens are rendered with canned ProviderScope overrides so no Firebase
// calls are made.  Tests are written with golden_toolkit at a Pixel 4a
// logical viewport (411 × 892, dpr 2.625).
//
// To regenerate goldens: `flutter test --update-goldens test/golden/`
// To verify: `flutter test test/golden/`

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mvp_travel/core/theme/app_theme.dart';
import 'package:mvp_travel/core/utils/result.dart';

// Screen imports
import 'package:mvp_travel/features/explore/presentation/screens/explore_screen.dart';
import 'package:mvp_travel/features/search/presentation/screens/search_screen.dart';
import 'package:mvp_travel/features/trips/presentation/screens/trips_screen.dart';
import 'package:mvp_travel/features/concierge/presentation/screens/concierge_screen.dart';
import 'package:mvp_travel/features/profile/presentation/screens/profile_screen.dart';

// Provider imports for overrides
import 'package:mvp_travel/core/services/auth_service.dart';
import 'package:mvp_travel/features/auth/domain/user_entity.dart';
import 'package:mvp_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mvp_travel/features/booking/data/booking_repository.dart';
import 'package:mvp_travel/features/booking/domain/booking.dart';
import 'package:mvp_travel/features/concierge/data/concierge_repository.dart';
import 'package:mvp_travel/features/concierge/domain/concierge_message.dart';
import 'package:mvp_travel/features/concierge/domain/concierge_profile.dart';
import 'package:mvp_travel/features/explore/data/explore_repository.dart';
import 'package:mvp_travel/features/explore/domain/review.dart';
import 'package:mvp_travel/features/explore/domain/tour.dart';
import 'package:mvp_travel/features/profile/data/profile_repository.dart';
import 'package:mvp_travel/features/profile/domain/payment_method_item.dart';
import 'package:mvp_travel/features/search/data/saved_tours_repository.dart';
import 'package:mvp_travel/features/search/data/search_repository.dart';

const _transparentPng = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class _GoldenHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _GoldenHttpClient();
}

class _GoldenHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _GoldenHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _GoldenHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GoldenHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _GoldenHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GoldenHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Pixel 4a logical size
// ---------------------------------------------------------------------------
const _pixel4aSize = Size(411, 892);

// ---------------------------------------------------------------------------
// Fake auth implementations
// ---------------------------------------------------------------------------

class _FakeAuthService extends Fake implements AuthService {
  @override
  bool get isSignedIn => true;

  @override
  UserEntity? get currentUser => const UserEntity(
    uid: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
  );

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(currentUser);
}

/// Override AuthController so it returns a pre-seeded user without hitting Firebase.
class _FakeAuthController extends AuthController {
  @override
  FutureOr<UserEntity?> build() {
    return const UserEntity(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: null,
    );
  }
}

class _FakeExploreRepository implements ExploreRepository {
  @override
  Stream<List<Tour>> watchHeroPromotions() => Stream.value(const []);

  @override
  Stream<List<Tour>> watchFeaturedTours() => Stream.value(const []);

  @override
  Stream<List<Tour>> watchPopularDestinations() => Stream.value(const []);

  @override
  Stream<List<Review>> watchRecentReviews() => Stream.value(const []);
}

class _FakeSearchRepository implements SearchRepository {
  @override
  Stream<List<Tour>> searchTours(SearchFilters filters) =>
      Stream.value(const []);
}

class _FakeSavedToursRepository implements SavedToursRepository {
  @override
  Stream<List<String>> watchSavedTourIds(String uid) => Stream.value(const []);

  @override
  Future<Result<void>> saveTour(String uid, String tourId) async =>
      const Result.success(null);

  @override
  Future<Result<void>> unsaveTour(String uid, String tourId) async =>
      const Result.success(null);
}

class _FakeBookingRepository implements BookingRepository {
  @override
  String generateNewBookingId() => 'fake-booking-id';

  @override
  Future<Result<String>> createPendingBooking(Booking booking) async =>
      const Result.success('fake-booking-id');

  @override
  Stream<Booking?> watchBooking(String bookingId) => Stream.value(null);

  @override
  Stream<List<Booking>> watchUserBookings(String userId) =>
      Stream.value(const []);
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Stream<Map<String, dynamic>?> watchUserProfile(String uid) => Stream.value({
    'displayName': 'Test User',
    'email': 'test@example.com',
    'tier': 'Standard',
    'loyaltyPoints': 0,
    'conciergeId': 'concierge-elena',
  });

  @override
  Future<Result<void>> updateProfile({
    required String uid,
    required String name,
    required String photoUrl,
  }) async => const Result.success(null);

  @override
  Future<Result<void>> updateNotificationPreference({
    required String uid,
    required String key,
    required bool value,
  }) async => const Result.success(null);

  @override
  Future<Result<void>> saveTravelPreferences({
    required String uid,
    required String dietary,
    required String seat,
    required String hotelClass,
  }) async => const Result.success(null);

  @override
  Stream<List<PaymentMethodItem>> watchPaymentMethods(String uid) =>
      Stream.value(const []);

  @override
  Future<Result<void>> deletePaymentMethod({
    required String uid,
    required String methodId,
  }) async => const Result.success(null);

  @override
  Future<Result<void>> cleanupUserData() async => const Result.success(null);
}

class _FakeConciergeRepository implements ConciergeRepository {
  static const _profile = ConciergeProfile(
    id: 'concierge-elena',
    name: 'Elena',
    role: 'Senior Travel Specialist',
    specialty: 'Luxury Safaris & Lodges',
    languages: 'English, Spanish, French',
    photoUrl: '',
    isOnline: true,
  );

  @override
  Stream<ConciergeProfile> watchConciergeProfile(String conciergeId) =>
      Stream.value(_profile);

  @override
  Stream<List<ConciergeMessage>> watchMessages(String uid) =>
      Stream.value(const []);

  @override
  Stream<Map<String, dynamic>> watchThreadMetadata(String uid) =>
      Stream.value(const {'isTyping': false});

  @override
  Future<Result<void>> sendMessage({
    required String uid,
    required String text,
    String? attachmentUrl,
  }) async => const Result.success(null);

  @override
  Future<Result<bool>> checkAndSeedConcierges(String uid) async =>
      const Result.success(false);
}

// ---------------------------------------------------------------------------
// Helper: wrap screen with auth overrides (no extra overrides needed)
// ---------------------------------------------------------------------------
Widget _wrap(Widget screen) {
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(_FakeAuthService()),
      authControllerProvider.overrideWith(() => _FakeAuthController()),
      exploreRepositoryProvider.overrideWithValue(_FakeExploreRepository()),
      searchRepositoryProvider.overrideWithValue(_FakeSearchRepository()),
      savedToursRepositoryProvider.overrideWithValue(
        _FakeSavedToursRepository(),
      ),
      bookingRepositoryProvider.overrideWithValue(_FakeBookingRepository()),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      conciergeRepositoryProvider.overrideWithValue(_FakeConciergeRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: screen,
      debugShowCheckedModeBanner: false,
    ),
  );
}

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------
void main() {
  late void Function(FlutterErrorDetails details)? previousOnError;
  late HttpOverrides? previousHttpOverrides;

  setUpAll(() async {
    previousOnError = FlutterError.onError;
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _GoldenHttpOverrides();
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('NetworkImageLoadException')) return;
      previousOnError?.call(details);
    };
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadAppFonts();
  });

  tearDownAll(() {
    FlutterError.onError = previousOnError;
    HttpOverrides.global = previousHttpOverrides;
  });

  GoldenToolkit.runWithConfiguration(
    () {
      group('Golden — Tab root screens', () {
        testGoldens('Explore screen', (tester) async {
          await tester.pumpWidgetBuilder(
            _wrap(const ExploreScreen()),
            surfaceSize: _pixel4aSize,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await screenMatchesGolden(tester, 'explore_screen');
        });

        testGoldens('Search screen', (tester) async {
          await tester.pumpWidgetBuilder(
            _wrap(const SearchScreen()),
            surfaceSize: _pixel4aSize,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await screenMatchesGolden(tester, 'search_screen');
        });

        testGoldens('Trips screen', (tester) async {
          await tester.pumpWidgetBuilder(
            _wrap(const TripsScreen()),
            surfaceSize: _pixel4aSize,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await screenMatchesGolden(tester, 'trips_screen');
        });

        testGoldens('Concierge screen', (tester) async {
          await tester.pumpWidgetBuilder(
            _wrap(const ConciergeScreen()),
            surfaceSize: _pixel4aSize,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await screenMatchesGolden(tester, 'concierge_screen');
        });

        testGoldens('Profile screen', (tester) async {
          await tester.pumpWidgetBuilder(
            _wrap(const ProfileScreen()),
            surfaceSize: _pixel4aSize,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await screenMatchesGolden(tester, 'profile_screen');
        });
      });
    },
    config: GoldenToolkitConfiguration(
      enableRealShadows: false,
      fileNameFactory: (name) => 'goldens/$name.png',
    ),
  );
}
