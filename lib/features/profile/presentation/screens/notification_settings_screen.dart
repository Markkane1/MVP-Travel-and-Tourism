import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/profile_repository.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _bookingUpdates = true;
  bool _promotions = false;
  bool _conciergeMessages = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load initial values from Firestore user document
    final profile = ref.read(userFirestoreDataProvider).value;
    if (profile != null && profile['notificationPrefs'] is Map) {
      final prefs = profile['notificationPrefs'] as Map;
      _bookingUpdates = prefs['bookingUpdates'] ?? true;
      _promotions = prefs['promotions'] ?? false;
      _conciergeMessages = prefs['conciergeMessages'] ?? true;
    }
  }

  Future<void> _updateNotificationPreference(String key, bool value, String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ref.read(profileRepositoryProvider).updateNotificationPreference(
            uid: uid,
            key: key,
            value: value,
          );

      await result.when(
        onSuccess: (_) {
          // Update local state variables
          setState(() {
            if (key == 'bookingUpdates') _bookingUpdates = value;
            if (key == 'promotions') _promotions = value;
            if (key == 'conciergeMessages') _conciergeMessages = value;
          });

          ref.invalidate(userFirestoreDataProvider);
        },
        onFailure: (exception) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update preference: ${exception.message}')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preference: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preference Controls',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Configure when and how you receive alerts and communications from MVP Travel.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Booking updates switch
                  _buildToggleRow(
                    context,
                    'Booking Updates',
                    'Alerts regarding status confirmations, cancellations and schedule modifications.',
                    _bookingUpdates,
                    (val) => _updateNotificationPreference('bookingUpdates', val, user.uid),
                  ),
                  const Divider(height: 24.0, color: AppColors.outlineVariant),

                  // Promotions switch
                  _buildToggleRow(
                    context,
                    'Promotions & Discounts',
                    'Receive exclusive member discounts, promo tier benefits and limited safari deals.',
                    _promotions,
                    (val) => _updateNotificationPreference('promotions', val, user.uid),
                  ),
                  const Divider(height: 24.0, color: AppColors.outlineVariant),

                  // Concierge messages switch
                  _buildToggleRow(
                    context,
                    'Concierge Messaging',
                    'Instant alert alerts when your personal travel coordinator sends you gear suggestions.',
                    _conciergeMessages,
                    (val) => _updateNotificationPreference('conciergeMessages', val, user.uid),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context,
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Switch(
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: _isSaving ? null : onChanged,
        ),
      ],
    );
  }
}
