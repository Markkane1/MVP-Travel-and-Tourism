import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('MVP Travel Admin'),
            const SizedBox(width: 32),
            // Simple Breadcrumbs
            Text(
              ' / ${_calculateBreadcrumb(context)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('My Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Sign Out'),
                  ),
                ];
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ref.watch(authProvider).user?.email ?? 'Admin',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.tour),
                label: Text('Tours'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.design_services),
                label: Text('Services'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online),
                label: Text('Bookings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.support_agent),
                label: Text('Concierge'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings),
                label: Text('Staff'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('Audit Logs'),
              ),
            ],
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (int index) {
              _onItemTapped(index, context);
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/tours')) return 1;
    if (location.startsWith('/services')) return 2;
    if (location.startsWith('/bookings')) return 3;
    if (location.startsWith('/users')) return 4;
    if (location.startsWith('/concierge')) return 5;
    if (location.startsWith('/notifications')) return 6;
    if (location.startsWith('/staff')) return 7;
    if (location.startsWith('/audit')) return 8;
    return 0;
  }

  static String _calculateBreadcrumb(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 'Dashboard';
    if (location.startsWith('/tours')) return 'Tours Management';
    if (location.startsWith('/services')) return 'Services Config';
    if (location.startsWith('/bookings')) return 'Bookings Operations';
    if (location.startsWith('/users')) return 'Users';
    if (location.startsWith('/concierge')) return 'Concierge Hub';
    if (location.startsWith('/notifications')) return 'Push Notifications';
    if (location.startsWith('/staff')) return 'Staff & Access';
    if (location.startsWith('/audit')) return 'Security Audit';
    return '';
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/tours');
        break;
      case 2:
        context.go('/services');
        break;
      case 3:
        context.go('/bookings');
        break;
      case 4:
        context.go('/users');
        break;
      case 5:
        context.go('/concierge');
        break;
      case 6:
        context.go('/notifications');
        break;
      case 7:
        context.go('/staff');
        break;
      case 8:
        context.go('/audit');
        break;
    }
  }
}
