import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import 'admin_shell.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/unauthorized_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/tours/tours_screen.dart';
import '../../features/services/services_screen.dart';
import '../../features/bookings/bookings_screen.dart';
import '../../features/users/users_screen.dart';
import '../../features/concierge/concierge_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/staff/staff_screen.dart';
import '../../features/audit/audit_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      if (authState.isLoading) {
        return null; // Wait for loading to finish, or maybe redirect to a splash? Let's just return null and wait.
      }

      final isLoggedIn = authState.user != null;
      final isAdmin = authState.isAdmin;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToUnauthorized = state.uri.path == '/unauthorized';
      final isGoingToStaff = state.uri.path == '/staff';

      if (!isLoggedIn) {
        if (!isGoingToLogin) {
          return '/login';
        }
        return null;
      }

      if (!isAdmin) {
        if (!isGoingToUnauthorized && !isGoingToLogin) {
          return '/unauthorized';
        }
        return null;
      }

      if (isGoingToStaff && !authState.isSuperAdmin) {
        return '/unauthorized';
      }

      if (isGoingToLogin) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          if (authState.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return AdminShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tours',
            builder: (context, state) => const ToursScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/concierge',
            builder: (context, state) => const ConciergeScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffScreen(),
          ),
          GoRoute(
            path: '/audit',
            builder: (context, state) => const AuditScreen(),
          ),
        ],
      ),
    ],
  );
});
