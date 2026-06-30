import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/app_bottom_nav.dart';
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
        builder: (context, state) => const _PlaceholderScreen(title: 'Authentication Screen'),
      ),

      // Persistent Bottom-Nav Shell
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return _ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Explore Tab (Branch 1)
          StatefulShellBranch(
            navigatorKey: exploreNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.explore,
                builder: (context, state) => const _PlaceholderScreen(title: 'Explore (Home)'),
              ),
            ],
          ),

          // Search Tab (Branch 2)
          StatefulShellBranch(
            navigatorKey: searchNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.search,
                builder: (context, state) => const _PlaceholderScreen(title: 'Search Filters'),
              ),
            ],
          ),

          // Trips Tab (Branch 3)
          StatefulShellBranch(
            navigatorKey: tripsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.trips,
                builder: (context, state) => const _PlaceholderScreen(
                  title: 'Trips (Upcoming / History / Saved)',
                  showTripsSubnavigation: true,
                ),
              ),
            ],
          ),

          // Concierge Tab (Branch 4)
          StatefulShellBranch(
            navigatorKey: conciergeNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.concierge,
                builder: (context, state) => const _PlaceholderScreen(title: 'Travel Concierge Chat'),
              ),
            ],
          ),

          // Profile Tab (Branch 5)
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const _PlaceholderScreen(title: 'Profile Dashboard'),
              ),
            ],
          ),
        ],
      ),

      // Pushed / Non-Tab Routes (Stacked on top of everything)
      GoRoute(
        path: RoutePaths.searchResults,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _PlaceholderScreen(title: 'Search Results'),
      ),
      GoRoute(
        path: RoutePaths.tourDetails,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final tourId = state.pathParameters['tourId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Tour Details ($tourId)');
        },
      ),
      GoRoute(
        path: RoutePaths.bookingConfig,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final tourId = state.pathParameters['tourId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Booking Configuration ($tourId)');
        },
      ),
      GoRoute(
        path: RoutePaths.checkout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Checkout / Payment ($bookingId)');
        },
      ),
      GoRoute(
        path: RoutePaths.paymentSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Payment Success ($bookingId)');
        },
      ),
      GoRoute(
        path: RoutePaths.bookingConfirmation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Booking Confirmation ($bookingId)');
        },
      ),
      GoRoute(
        path: RoutePaths.reviewTrip,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Review Trip ($bookingId)');
        },
      ),
      GoRoute(
        path: RoutePaths.reviewSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'unknown';
          return _PlaceholderScreen(title: 'Review Success ($bookingId)');
        },
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _PlaceholderScreen(title: 'Edit Profile'),
      ),
      GoRoute(
        path: RoutePaths.paymentMethods,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _PlaceholderScreen(title: 'Payment Methods'),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _PlaceholderScreen(title: 'Notifications List'),
      ),
      GoRoute(
        path: RoutePaths.legalTerms,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _PlaceholderScreen(title: 'Terms of Use'),
      ),
      GoRoute(
        path: RoutePaths.legalPrivacy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _PlaceholderScreen(title: 'Privacy Policy'),
      ),
    ],
  );
});

/// Scaffold container for the persistent bottom navigation shell.
class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          AppBottomNavItem(
            activeIcon: Icons.explore,
            inactiveIcon: Icons.explore_outlined,
            label: 'Explore',
          ),
          AppBottomNavItem(
            activeIcon: Icons.search,
            inactiveIcon: Icons.search,
            label: 'Search',
          ),
          AppBottomNavItem(
            activeIcon: Icons.airplane_ticket,
            inactiveIcon: Icons.airplane_ticket_outlined,
            label: 'Trips',
          ),
          AppBottomNavItem(
            activeIcon: Icons.headset_mic,
            inactiveIcon: Icons.headset_mic_outlined,
            label: 'Concierge',
          ),
          AppBottomNavItem(
            activeIcon: Icons.person,
            inactiveIcon: Icons.person_outline,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Simple placeholder screen reusable stub.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final bool showTripsSubnavigation;

  const _PlaceholderScreen({
    required this.title,
    this.showTripsSubnavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$title — TODO',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            if (showTripsSubnavigation) ...[
              ElevatedButton(
                onPressed: () => context.push(RoutePaths.bookingConfirmationPath('booking-123')),
                child: const Text('Go to Booking Itinerary'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () => context.push(RoutePaths.reviewTripPath('booking-123')),
                child: const Text('Leave a Review'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
