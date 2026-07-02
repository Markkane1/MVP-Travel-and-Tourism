import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_bottom_nav.dart';

/// Scaffold container for the persistent bottom navigation shell.
class ShellScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        ref.read(notificationServiceProvider).setupNotifications(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
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
