// Golden tests for each bottom-navigation tab's root screen.
// Screens are rendered with canned ProviderScope overrides so no Firebase
// calls are made.  Tests are written with golden_toolkit at a Pixel 4a
// logical viewport (411 × 892, dpr 2.625).
//
// To regenerate goldens: `flutter test --update-goldens test/golden/`
// To verify: `flutter test test/golden/`

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mvp_travel/core/theme/app_theme.dart';

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
  Stream<List<Tour>> searchTours(SearchFilters filters) => Stream.value(const []);
}

class _FakeSavedToursRepository implements SavedToursRepository {
  @override
  Stream<List<String>> watchSavedTourIds(String uid) => Stream.value(const []);

  @override
  Future<void> saveTour(String uid, String tourId) async {}

  @override
  Future<void> unsaveTour(String uid, String tourId) async {}
}

class _FakeBookingRepository implements BookingRepository {
  @override
  Future<void> createPendingBooking(Booking booking) async {}

  @override
  Stream<Booking?> watchBooking(String bookingId) => Stream.value(null);

  @override
  Stream<List<Booking>> watchUserBookings(String userId) => Stream.value(const []);
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
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String photoUrl,
  }) async {}

  @override
  Future<void> updateNotificationPreference({
    required String uid,
    required String key,
    required bool value,
  }) async {}

  @override
  Future<void> saveTravelPreferences({
    required String uid,
    required String dietary,
    required String seat,
    required String hotelClass,
  }) async {}

  @override
  Stream<List<PaymentMethodItem>> watchPaymentMethods(String uid) => Stream.value(const []);

  @override
  Future<void> deletePaymentMethod({
    required String uid,
    required String methodId,
  }) async {}

  @override
  Future<void> savePaymentMethod({
    required String uid,
    required String cardBrand,
    required String last4,
    required bool isDefault,
  }) async {}

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
  Future<void> sendMessage({
    required String uid,
    required String text,
    String? attachmentUrl,
  }) async {}

  @override
  Future<bool> checkAndSeedConcierges(String uid) async => false;
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
      savedToursRepositoryProvider.overrideWithValue(_FakeSavedToursRepository()),
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

  setUpAll(() async {
    previousOnError = FlutterError.onError;
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
      fileNameFactory: (name) => 'test/golden/goldens/$name.png',
    ),
  );
}
