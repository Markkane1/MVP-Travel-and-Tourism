import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'app_shell.dart';
import '../../features/auth/presentation/screens/login_register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/legal_placeholder_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/tour_details/presentation/screens/tour_details_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/bank_transfer_screen.dart';
import '../../features/checkout/presentation/screens/payment_success_screen.dart';
import '../../features/trips/presentation/screens/booking_confirmation_screen.dart';
import '../../features/trips/presentation/screens/trips_screen.dart';
import '../../features/reviews/presentation/screens/review_trip_screen.dart';
import '../../features/reviews/presentation/screens/review_success_screen.dart';
import '../../features/concierge/presentation/screens/concierge_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/travel_preferences_screen.dart';
import '../../features/profile/presentation/screens/tier_benefits_screen.dart';
import '../../features/profile/presentation/screens/travel_map_screen.dart';
import '../../features/profile/presentation/screens/security_privacy_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import 'auth_guard.dart';
import 'route_paths.dart';

// Global key for the root navigator
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Shell navigator keys for the 5 persistent tabs
final exploreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'exploreTab');
final searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'searchTab');
final tripsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tripsTab');
final conciergeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'conciergeTab');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileTab');

/// Provider for the declarative GoRouter instance.
final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final authGuard = AuthGuard(authService);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.explore,
    refreshListenable: _GoRouterRefreshStream(authService.authStateChanges),
    redirect: authGuard.redirect,
    routes: [
      // Authentication screen
      GoRoute(
        path: RoutePaths.auth,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginRegisterScreen(),
      ),

      // Forgot Password screen
      GoRoute(
        path: RoutePaths.forgotPassword,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Persistent Bottom-Nav Shell
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) => ShellScaffold(navigationShell: navigationShell),
        branches: [
          // Explore Tab (Branch 1)
          StatefulShellBranch(
            navigatorKey: exploreNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),

          // Search Tab (Branch 2)
          StatefulShellBranch(
            navigatorKey: searchNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.search,
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'results',
                    builder: (context, state) => SearchResultsScreen(
                      queryParameters: state.uri.queryParameters,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Trips Tab (Branch 3)
          StatefulShellBranch(
            navigatorKey: tripsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.trips,
                builder: (context, state) {
                  final segment = state.uri.queryParameters['segment'];
                  return TripsScreen(initialSegment: segment);
                },
              ),
            ],
          ),

          // Concierge Tab (Branch 4)
          StatefulShellBranch(
            navigatorKey: conciergeNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.concierge,
                builder: (context, state) => const ConciergeScreen(),
              ),
            ],
          ),

          // Profile Tab (Branch 5)
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Pushed / Non-Tab Routes (Stacked on top of everything)
      GoRoute(
        path: RoutePaths.searchResults,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => SearchResultsScreen(
          queryParameters: state.uri.queryParameters,
        ),
      ),
      GoRoute(
        path: RoutePaths.tourDetails,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final tourId = state.pathParameters['tourId'] ?? 'unknown';
          return TourDetailsScreen(tourId: tourId);
        },
      ),
      GoRoute(
        path: RoutePaths.bookingConfig,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final tourId = state.pathParameters['tourId'] ?? 'unknown';
          return BookingScreen(tourId: tourId);
        },
      ),
      GoRoute(
        path: RoutePaths.checkout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return CheckoutScreen(bookingId: bookingId);
        },
        routes: [
          GoRoute(
            path: 'bank',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final amount = state.extra as double? ?? 0.0;
              return BankTransferScreen(amount: amount);
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.paymentSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          final Map<String, dynamic> data = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
          final refCode = data['bookingReferenceCode'] as String? ?? 'LT-XXXXX';
          return PaymentSuccessScreen(
            bookingId: bookingId,
            bookingReferenceCode: refCode,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.bookingConfirmation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RoutePaths.reviewTrip,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return ReviewTripScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RoutePaths.reviewSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extraMap = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
          return ReviewSuccessScreen(extraData: extraMap);
        },
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.paymentMethods,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/profile/preferences',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TravelPreferencesScreen(),
      ),
      GoRoute(
        path: '/profile/tier-benefits',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TierBenefitsScreen(),
      ),
      GoRoute(
        path: '/profile/travel-map',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TravelMapScreen(),
      ),
      GoRoute(
        path: '/profile/security',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SecurityPrivacyScreen(),
      ),
      GoRoute(
        path: '/profile/notification-settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/help',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.legalTerms,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TermsOfUseScreen(),
      ),
      GoRoute(
        path: RoutePaths.legalPrivacy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
});

/// Simple Stream -> Listenable bridge class for GoRouter.
class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
