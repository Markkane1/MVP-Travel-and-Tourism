import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/notification_item.dart';
import '../../data/notifications_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Map<String, List<NotificationItem>> _groupNotifications(List<NotificationItem> items) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final List<NotificationItem> todayList = [];
    final List<NotificationItem> earlierList = [];

    for (var item in items) {
      if (item.createdAt.isAfter(todayStart)) {
        todayList.add(item);
      } else {
        earlierList.add(item);
      }
    }

    final Map<String, List<NotificationItem>> grouped = {};
    if (todayList.isNotEmpty) grouped['Today'] = todayList;
    if (earlierList.isNotEmpty) grouped['Earlier'] = earlierList;
    return grouped;
  }

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _onNotificationTap(BuildContext context, WidgetRef ref, String uid, NotificationItem item) {
    // 1. Mark as read
    ref.read(notificationsRepositoryProvider).markAsRead(uid, item.id);

    // 2. Deep link if present
    if (item.deepLink.isNotEmpty) {
      context.push(item.deepLink);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final notificationsState = ref.watch(notificationsStreamProvider(user.uid));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsRepositoryProvider).markAllAsRead(user.uid),
            child: const Text(
              'Mark all read',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: notificationsState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => Center(child: Text('Error loading notifications: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.containerMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_off_outlined,
                      size: 64.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'No notifications yet.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final grouped = _groupNotifications(items);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            children: grouped.keys.map((groupTitle) {
              final groupItems = grouped[groupTitle]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, top: 8.0),
                    child: Text(
                      groupTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...groupItems.map((item) => _buildNotificationRow(context, ref, user.uid, item)),
                  const SizedBox(height: 16.0),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildNotificationRow(BuildContext context, WidgetRef ref, String uid, NotificationItem item) {
    final theme = Theme.of(context);

    IconData iconData = Icons.notifications_none_outlined;
    Color iconColor = AppColors.primary;

    if (item.type == 'booking') {
      iconData = Icons.book_online_outlined;
      iconColor = AppColors.success;
    } else if (item.type == 'promo') {
      iconData = Icons.local_offer_outlined;
      iconColor = AppColors.warning;
    } else if (item.type == 'concierge') {
      iconData = Icons.support_agent_outlined;
      iconColor = AppColors.secondary;
    } else if (item.type == 'system') {
      iconData = Icons.info_outline;
      iconColor = AppColors.primary;
    }

    final relativeTime = _formatRelativeTime(item.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => _onNotificationTap(context, ref, uid, item),
        child: Container(
          decoration: BoxDecoration(
            color: item.read
                ? AppColors.surfaceContainerLowest
                : AppColors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
            border: Border.all(
              color: item.read ? AppColors.outlineVariant : AppColors.primary.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading Type Icon
                CircleAvatar(
                  radius: 20.0,
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(iconData, color: iconColor, size: 20.0),
                ),
                const SizedBox(width: 12.0),

                // Title, Body & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            relativeTime,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        item.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Unread Indicator navy dot
                if (!item.read) ...[
                  const SizedBox(width: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
