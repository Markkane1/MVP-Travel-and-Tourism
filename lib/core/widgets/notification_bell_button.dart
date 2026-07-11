import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/route_paths.dart';
import '../theme/app_colors.dart';
import '../services/notification_service.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  void _pushNotifications(BuildContext context) {
    final uri = Uri(
      path: RoutePaths.notifications,
      queryParameters: {
        'nonce': DateTime.now().microsecondsSinceEpoch.toString(),
      },
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountState = ref.watch(unreadNotificationCountProvider);

    return unreadCountState.when(
      loading: () => IconButton(
        tooltip: 'Notifications',
        icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
        onPressed: () => _pushNotifications(context),
      ),
      error: (e, s) => IconButton(
        tooltip: 'Notifications',
        icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
        onPressed: () => _pushNotifications(context),
      ),
      data: (count) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.onSurface,
              ),
              onPressed: () => _pushNotifications(context),
            ),
            if (count > 0)
              Positioned(
                top: 12.0,
                right: 12.0,
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
