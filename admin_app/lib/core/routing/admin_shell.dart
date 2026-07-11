import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isSuperAdmin = authState.isSuperAdmin;

    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: Text('Tours'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.room_service_outlined),
        selectedIcon: Icon(Icons.room_service),
        label: Text('Services'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.book_online_outlined),
        selectedIcon: Icon(Icons.book_online),
        label: Text('Bookings'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: Text('Users'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.support_agent_outlined),
        selectedIcon: Icon(Icons.support_agent),
        label: Text('Concierge'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.campaign_outlined),
        selectedIcon: Icon(Icons.campaign),
        label: Text('Notifications'),
      ),
      if (isSuperAdmin)
        const NavigationRailDestination(
          icon: Icon(Icons.manage_accounts_outlined),
          selectedIcon: Icon(Icons.manage_accounts),
          label: Text('Staff'),
        ),
      // Keep audit if it existed before
      const NavigationRailDestination(
        icon: Icon(Icons.security_outlined),
        selectedIcon: Icon(Icons.security),
        label: Text('Audit Logs'),
      ),
    ];

    int selectedIndex = _calculateSelectedIndex(context);
    // If superAdmin is false, and index is on Staff or Audit, it might be off by 1 since we conditionally exclude Staff.
    // Let's just adjust index logic for non-superAdmins
    if (!isSuperAdmin) {
      if (selectedIndex == 7) {
        // trying to access staff without permission! The router should handle this really, but let's fall back to 0
        selectedIndex = 0;
      } else if (selectedIndex == 8) {
        // audit log shifts to index 7 because staff was removed
        selectedIndex = 7;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVP Travel Admin'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < destinations.length
                ? selectedIndex
                : 0,
            onDestinationSelected: (index) {
              // Map index back to correct route if superAdmin is false
              int targetIndex = index;
              if (!isSuperAdmin && index >= 7) {
                targetIndex = index + 1;
              }
              _onItemTapped(targetIndex, context);
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
