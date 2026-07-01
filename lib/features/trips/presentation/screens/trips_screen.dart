import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/trips_repository.dart';
import '../../../reviews/data/reviews_repository.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/booking.dart';
import '../../../search/data/saved_tours_repository.dart';
import '../../../explore/domain/tour.dart';

/// Screen representing the user's trips list dashboard.
class TripsScreen extends ConsumerStatefulWidget {
  final String? initialSegment;

  const TripsScreen({super.key, this.initialSegment});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialSegment == 'saved') {
      initialIndex = 2;
    } else if (widget.initialSegment == 'history') {
      initialIndex = 1;
    }
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelBooking(String bookingId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.trips.cancelDialogTitle),
          content: Text(AppStrings.trips.cancelDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                AppStrings.trips.cancelDismissText,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppStrings.trips.cancelConfirmText,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final res = await ref.read(tripsRepositoryProvider).cancelBooking(bookingId);
      res.when(
        onSuccess: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.trips.cancelSuccessMessage)),
            );
          }
        },
        onFailure: (exception) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(exception.message)),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancellation failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _unsaveTour(Tour tour) async {
    final optimisticSaved = ref.read(optimisticSavedToursProvider.notifier);
    await optimisticSaved.toggleSave(tour.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tour removed from saved list.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref.read(optimisticSavedToursProvider.notifier).toggleSave(tour.id),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authServiceProvider).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your trips.')),
      );
    }

    final bookingsState = ref.watch(userBookingsProvider(user.uid));

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 16.0,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? const Icon(Icons.person, size: 18.0, color: AppColors.primary)
                    : null,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary, // Gold indicator
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          tabs: [
            Tab(text: AppStrings.trips.segmentUpcoming),
            Tab(text: AppStrings.trips.segmentHistory),
            Tab(text: AppStrings.trips.segmentSaved),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Upcoming Segment
          bookingsState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) => Center(child: ErrorStateView(message: err.toString(), onRetry: () => ref.refresh(userBookingsProvider(user.uid)))),
            data: (list) {
              final upcoming = list.where((b) {
                final isFuture = b.tourDate.isAfter(DateTime.now().subtract(const Duration(days: 1)));
                return (b.status == 'pending' || b.status == 'confirmed') && isFuture;
              }).toList();

              if (upcoming.isEmpty) {
                return _buildUpcomingEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.containerMargin),
                itemCount: upcoming.length,
                itemBuilder: (context, index) {
                  final booking = upcoming[index];
                  return _buildUpcomingCard(booking);
                },
              );
            },
          ),

          // 2. History Segment
          bookingsState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) => Center(child: ErrorStateView(message: err.toString(), onRetry: () => ref.refresh(userBookingsProvider(user.uid)))),
            data: (list) {
              final history = list.where((b) {
                final isPast = b.tourDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                return b.status == 'completed' || (b.status == 'confirmed' && isPast);
              }).toList();

              if (history.isEmpty) {
                return Center(child: Text(AppStrings.trips.emptyHistory));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.containerMargin),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final booking = history[index];
                  return _buildHistoryCard(booking);
                },
              );
            },
          ),

          // 3. Saved Tours Segment
          ref.watch(savedToursListProvider).when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) => Center(child: ErrorStateView(message: err.toString(), onRetry: () => ref.refresh(savedToursListProvider))),
            data: (savedTours) {
              if (savedTours.isEmpty) {
                return Center(child: Text(AppStrings.trips.emptySaved));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.containerMargin),
                itemCount: savedTours.length,
                itemBuilder: (context, index) {
                  final tour = savedTours[index];
                  return _buildSavedTourCard(tour);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1.5,
              style: BorderStyle.solid, // Custom dashed borders can be simulated with CustomPaint, standard solid looks extremely clean
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.trips.emptyUpcomingTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8.0),
              Text(
                AppStrings.trips.emptyUpcomingBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              PrimaryButton(
                label: AppStrings.trips.exploreToursButton,
                onPressed: () => context.go('/explore'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(Booking booking) {
    final theme = Theme.of(context);
    final dateStr = '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';
    final isConfirmed = booking.status == 'confirmed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    image: DecorationImage(
                      image: NetworkImage(booking.tourSnapshot.heroImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Title and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.tourSnapshot.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? const Color(0xFFE8F5E9) // Light green
                                  : const Color(0xFFFFF3E0), // Light amber
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                            ),
                            child: Text(
                              booking.status.toUpperCase(),
                              style: TextStyle(
                                color: isConfirmed
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFE65100),
                                fontWeight: FontWeight.bold,
                                fontSize: 9.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            dateStr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24.0, color: AppColors.outlineVariant, thickness: 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.push('/trips/${booking.id}'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'View Details →',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _cancelBooking(booking.id),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Booking booking) {
    final theme = Theme.of(context);
    final dateStr = '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';
    final isReviewedState = ref.watch(tourReviewedProvider(booking.tourId));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    image: DecorationImage(
                      image: NetworkImage(booking.tourSnapshot.heroImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.tourSnapshot.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        dateStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24.0, color: AppColors.outlineVariant, thickness: 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.push('/trips/${booking.id}'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'View Details →',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                if (booking.reviewed)
                  Text(
                    AppStrings.trips.reviewedIndicator,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  )
                else
                  isReviewedState.when(
                    loading: () => const SizedBox(width: 24.0, height: 24.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
                    error: (e, s) => const SizedBox.shrink(),
                    data: (reviewed) {
                      if (reviewed) {
                        return Text(
                          AppStrings.trips.reviewedIndicator,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        );
                      }
                      return TextButton(
                        onPressed: () => context.push('/trips/${booking.id}/review'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          AppStrings.trips.leaveReviewButton,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedTourCard(Tour tour) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Image
            GestureDetector(
              onTap: () => context.push('/tour/${tour.id}'),
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  image: DecorationImage(
                    image: NetworkImage(tour.heroImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Info and heart toggle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/tour/${tour.id}'),
                          child: Text(
                            tour.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _unsaveTour(tour),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    tour.destination,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
