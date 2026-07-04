import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/notification_bell_button.dart';
import '../../../auth/auth.dart';
import '../../../booking/booking.dart';
import '../../../search/search.dart';
import '../../data/profile_repository.dart';

/// Defined Map of benefits per tier status.
const Map<String, List<String>> tierBenefits = {
  'Standard': [
    'Standard Support Chat Access',
    'Earn Loyalty Points on All Bookings',
    'Self-service Cancellation Options',
    'General Destination Access',
  ],
  'Elite Horizon': [
    '24/7 Personal Concierge Access',
    'Private Airport Lounge Access',
    'Priority Expedited Boarding',
    'Complimentary Luxury Upgrades',
  ],
};

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    final firestoreState = ref.watch(userFirestoreDataProvider);
    final bookingsState = ref.watch(userBookingsProvider(user.uid));
    final savedIdsState = ref.watch(savedTourIdsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.common.appDisplayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [NotificationBellButton()],
      ),
      body: firestoreState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => Center(
          child: ErrorStateView(
            message: err.toString(),
            onRetry: () => ref.refresh(userFirestoreDataProvider),
          ),
        ),
        data: (profileDoc) {
          final profile = profileDoc ?? {};
          final String name =
              profile['displayName'] ?? user.displayName ?? 'Valued Guest';
          final String email = profile['email'] ?? user.email;
          final int loyaltyPoints = profile['loyaltyPoints'] ?? 0;
          final String tier = profile['tier'] ?? 'Standard';
          final String? photoUrl = profile['photoUrl'] ?? user.photoUrl;

          return bookingsState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error loading stats: $err')),
            data: (bookings) {
              final upcomingBookings = bookings.where((b) {
                final isFuture = b.tourDate.isAfter(
                  DateTime.now().subtract(const Duration(days: 1)),
                );
                return (b.status == 'pending' || b.status == 'confirmed') &&
                    isFuture;
              }).toList();

              final completedBookings = bookings.where((b) {
                final isPast = b.tourDate.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                );
                return b.status == 'completed' ||
                    (b.status == 'confirmed' && isPast);
              }).toList();

              final int activeCount = upcomingBookings.length;
              final Set<String> visitedDests = completedBookings
                  .map((b) => b.tourSnapshot.destination.split(',').last.trim())
                  .toSet();
              final int destinationsVisited = visitedDests.length;
              final int savedCount = savedIdsState.value?.length ?? 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    _buildProfileHeader(
                      context,
                      name,
                      email,
                      photoUrl,
                      loyaltyPoints,
                    ),
                    AppSpacing.gapLg,
                    _buildCurrentTierCard(context, tier),
                    AppSpacing.gapLg,
                    _buildNextMilestoneCard(context, loyaltyPoints, tier),
                    AppSpacing.gapLg,
                    _buildAccountOverview(context, activeCount, savedCount),
                    AppSpacing.gapLg,
                    _buildTravelSummaryCard(
                      context,
                      destinationsVisited,
                      activeCount,
                      profile,
                    ),
                    AppSpacing.gapLg,
                    _buildSettingsSection(context, ref),
                    const SizedBox(height: 40.0),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    String? photoUrl,
    int loyaltyPoints,
  ) {
    final theme = Theme.of(context);
    final hasPhoto = (photoUrl ?? '').isNotEmpty;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _viewFullAvatar(context, photoUrl),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48.0,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
                child: !hasPhoto
                    ? const Icon(
                        Icons.person,
                        size: 48.0,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: AppColors.warningContainer,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Text(
            AppStrings.profile.eliteMemberPill,
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 11.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '$loyaltyPoints ${AppStrings.profile.loyaltyPointsLabel}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        OutlinedButton(
          onPressed: () => context.push(RoutePaths.editProfile),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
          ),
          child: Text(
            AppStrings.profile.editProfileButton,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _viewFullAvatar(BuildContext context, String? photoUrl) {
    final hasPhoto = (photoUrl ?? '').isNotEmpty;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 300.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    image: DecorationImage(
                      image: hasPhoto
                          ? NetworkImage(photoUrl!)
                          : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8.0,
                right: 8.0,
                child: CircleAvatar(
                  backgroundColor: AppColors.onSurface.withValues(alpha: 0.54),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentTierCard(BuildContext context, String tier) {
    final theme = Theme.of(context);
    final String displayTier = tier == 'Elite Horizon'
        ? 'Elite Horizon Status'
        : '$tier Status';
    final List<String> benefits =
        tierBenefits[tier] ?? tierBenefits['Standard']!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.profile.currentTierLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Icon(Icons.stars, color: AppColors.secondary, size: 24.0),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            displayTier,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.secondary,
                    size: 16.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNextMilestoneCard(
    BuildContext context,
    int loyaltyPoints,
    String tier,
  ) {
    final theme = Theme.of(context);

    int nextTierThreshold = 5000;
    String nextTierName = 'Elite Horizon';
    double percentage = 0.0;

    if (tier == 'Standard') {
      nextTierThreshold = 5000;
      nextTierName = 'Elite Horizon';
      percentage = (loyaltyPoints / nextTierThreshold).clamp(0.0, 1.0);
    } else {
      nextTierThreshold = 15000;
      nextTierName = 'Horizon Legend';
      percentage = ((loyaltyPoints - 5000) / (nextTierThreshold - 5000)).clamp(
        0.0,
        1.0,
      );
    }

    final pointsNeeded = nextTierThreshold - loyaltyPoints;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.profile.nextMilestoneLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            pointsNeeded > 0
                ? '$pointsNeeded points to $nextTierName'
                : 'Highest Tier Status Achieved!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.outlineVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                    minHeight: 8.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Center(
            child: OutlinedButton(
              onPressed: () => context.push(RoutePaths.tierBenefits),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outline),
                shape: const StadiumBorder(),
              ),
              child: Text(
                AppStrings.profile.viewBenefitsButton,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOverview(
    BuildContext context,
    int activeCount,
    int savedCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, AppStrings.profile.sectionOverview),
        AppCard(
          child: Column(
            children: [
              _buildOverviewRow(
                context,
                Icons.calendar_today_outlined,
                AppStrings.profile.rowMyTrips,
                '$activeCount upcoming bookings',
                () => context.go('/trips'),
              ),
              _buildOverviewDivider(),
              _buildOverviewRow(
                context,
                Icons.favorite_outline,
                AppStrings.profile.rowSavedDestinations,
                '$savedCount items in wishlist',
                () => context.go('/trips?segment=saved'),
              ),
              _buildOverviewDivider(),
              _buildOverviewRow(
                context,
                Icons.credit_card_outlined,
                AppStrings.profile.rowPaymentMethods,
                'Saved payment credentials',
                () => context.push(RoutePaths.paymentMethods),
              ),
              _buildOverviewDivider(),
              _buildOverviewRow(
                context,
                Icons.settings_suggest_outlined,
                AppStrings.profile.rowPreferences,
                'Travel preferences & configurations',
                () => context.push(RoutePaths.travelPreferences),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildOverviewDivider() {
    return const Divider(
      height: 8.0,
      color: AppColors.outlineVariant,
      thickness: 1.0,
    );
  }

  Widget _buildTravelSummaryCard(
    BuildContext context,
    int destinationsVisited,
    int activeCount,
    Map<String, dynamic> profileDoc,
  ) {
    final int milesTraveled = profileDoc['milesTraveled'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, AppStrings.profile.sectionSummary),
        AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    context,
                    statDestinations,
                    destinationsVisited.toString(),
                  ),
                  _buildStatColumn(
                    context,
                    statMiles,
                    milesTraveled.toString(),
                  ),
                  _buildStatColumn(
                    context,
                    statBookings,
                    activeCount.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => context.push(RoutePaths.travelMap),
                child: Container(
                  width: double.infinity,
                  height: 110.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      color: AppColors.onSurface.withValues(alpha: 0.4),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map, color: Colors.white),
                          const SizedBox(width: 8.0),
                          Text(
                            AppStrings.profile.exploreMapButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, AppStrings.profile.sectionSettings),
        AppCard(
          child: Column(
            children: [
              _buildOverviewRow(
                context,
                Icons.security_outlined,
                AppStrings.profile.rowSecurity,
                'Security parameters & deletion',
                () => context.push(RoutePaths.securityPrivacy),
              ),
              _buildOverviewDivider(),
              _buildOverviewRow(
                context,
                Icons.notifications_active_outlined,
                AppStrings.profile.rowNotificationPrefs,
                'App notification filters',
                () => context.push(RoutePaths.notificationSettings),
              ),
              _buildOverviewDivider(),
              _buildOverviewRow(
                context,
                Icons.help_outline,
                AppStrings.profile.rowHelp,
                'Support centre, terms & policies',
                () => context.push(RoutePaths.helpSupport),
              ),
              _buildOverviewDivider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.exit_to_app, color: AppColors.error),
                title: Text(
                  AppStrings.profile.rowLogout,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                ),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.profile.logoutTitle),
          content: Text(AppStrings.profile.logoutBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go(RoutePaths.auth);
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static const String statDestinations = 'Destinations';
  static const String statMiles = 'Miles Traveled';
  static const String statBookings = 'Active Trips';
}
