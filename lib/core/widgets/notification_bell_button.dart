import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../services/notification_service.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountState = ref.watch(unreadNotificationCountProvider);

    return unreadCountState.when(
      loading: () => IconButton(
        icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
        onPressed: () => context.push('/notifications'),
      ),
      error: (e, s) => IconButton(
        icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
        onPressed: () => context.push('/notifications'),
      ),
      data: (count) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
              onPressed: () => context.push('/notifications'),
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
