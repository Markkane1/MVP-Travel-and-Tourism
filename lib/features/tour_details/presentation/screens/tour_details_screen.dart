import 'package:flutter/material.dart';
import '../../../../core/theme/app_radii.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../../core/widgets/section_header.dart';

import '../../../explore/domain/review.dart';
import '../../../search/search.dart';

import '../../data/tour_details_repository.dart';

/// Detailed view of a single selected Tour package.
class TourDetailsScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourDetailsScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends ConsumerState<TourDetailsScreen> {
  int _galleryIndex = 0;
  bool _isOverviewExpanded = false;
  bool _isItineraryExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tourDetail = ref.watch(tourDetailsProvider(widget.tourId));
    final tourReviewsVal = ref.watch(tourReviewsProvider(widget.tourId));
    final savedTours =
        ref.watch(optimisticSavedToursProvider).value ?? <String>{};
    final isSaved = savedTours.contains(widget.tourId);

    return Scaffold(
      key: const Key('tour_details_screen'),
      backgroundColor: AppColors.background,
      body: tourDetail.when(
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found.'));
          }

          final gallery = tour.galleryImageUrls.isNotEmpty
              ? tour.galleryImageUrls
              : [tour.heroImageUrl];

          return Stack(
            children: [
              // 1. Scrollable Master Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Gallery Space (represented by Stack image behind details card)
                    const SizedBox(height: 280.0),

                    // Overlapping Details Card
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadii.xl),
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Pill
                          if (tour.badges.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                tour.badges.first.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            AppSpacing.gapSm,
                          ],

                          // Title
                          Text(
                            tour.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          // Rating and Location
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.warning,
                                size: 18.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                '${tour.ratingAverage} · ${tour.destination}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapMd,

                          // Metadata horizontal icons row
                          Row(
                            children: [
                              _buildMetadataIcon(
                                Icons.calendar_today,
                                '${tour.durationDays} Days',
                              ),
                              const SizedBox(width: 20.0),
                              _buildMetadataIcon(
                                Icons.people,
                                'Max ${tour.maxParticipants} People',
                              ),
                            ],
                          ),
                          const Divider(height: 32.0),

                          // Overview Segment
                          Text(
                            'Overview',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.gapSm,
                          Text(
                            tour.overview,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: _isOverviewExpanded ? null : 4,
                            overflow: _isOverviewExpanded
                                ? null
                                : TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isOverviewExpanded = !_isOverviewExpanded;
                              });
                            },
                            child: Text(
                              _isOverviewExpanded ? 'Read less' : 'Read more',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(height: 32.0),

                          // Itinerary Segment
                          Text(
                            'Itinerary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.gapMd,
                          _buildItineraryTimeline(tour.itinerary),
                          const Divider(height: 32.0),

                          // Inclusions Checklist
                          Text(
                            'What\'s Included',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.gapMd,
                          ...tour.inclusions.map(
                            (inc) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.success,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      inc,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 32.0),

                          // Reviews segment
                          tourReviewsVal.when(
                            data: (reviews) =>
                                _buildReviewsSegment(reviews, theme),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, stack) =>
                                const Text('Failed to load reviews.'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Fixed Full-Bleed Image Gallery PageView at back
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 300.0,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: gallery.length,
                      onPageChanged: (index) {
                        setState(() {
                          _galleryIndex = index;
                        });
                      },
                      itemBuilder: (context, index) => Image.network(
                        gallery[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    // Slide dot indicator overlay
                    Positioned(
                      bottom: 32.0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          gallery.length,
                          (idx) => Container(
                            width: 6.0,
                            height: 6.0,
                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _galleryIndex == idx
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Floating Overlay Navigation Header Buttons
              Positioned(
                top: MediaQuery.of(context).padding.top + 8.0,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button in translucent circle
                    CircleAvatar(
                      backgroundColor: AppColors.onSurface.withValues(
                        alpha: 0.4,
                      ),
                      radius: 20.0,
                      child: Semantics(
                        label: 'Go back',
                        button: true,
                        child: IconButton(
                          tooltip: 'Go back',
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20.0,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    // Bookmark toggle in translucent circle
                    CircleAvatar(
                      backgroundColor: AppColors.onSurface.withValues(
                        alpha: 0.4,
                      ),
                      radius: 20.0,
                      child: Semantics(
                        label: isSaved ? 'Remove from saved' : 'Save tour',
                        button: true,
                        child: IconButton(
                          tooltip: isSaved ? 'Remove from saved' : 'Save tour',
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? AppColors.error : Colors.white,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            final res = await ref
                                .read(optimisticSavedToursProvider.notifier)
                                .toggleSave(widget.tourId);
                            res.when(
                              onSuccess: (_) {},
                              onFailure: (exception) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Bookmark sync error: ${exception.message}',
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Pinned Sticky Bottom Booking Details Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${tour.currency} ${tour.pricePerPerson.toInt()} / person',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: PrimaryButton(
                          buttonKey: const Key('tour_details_book_button'),
                          label: 'Book Now',
                          onPressed: () =>
                              context.push('/tour/${widget.tourId}/book'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load tour details.'),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(tourDetailsProvider(widget.tourId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16.0),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
      ],
    );
  }

  Widget _buildItineraryTimeline(List<dynamic> itinerary) {
    if (itinerary.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount = _isItineraryExpanded ? itinerary.length : 1;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final Map<String, dynamic> step =
                itinerary[index] as Map<String, dynamic>;
            final String title = step['title'] as String? ?? '';
            final String description = step['description'] as String? ?? '';
            final int day = step['day'] as int? ?? (index + 1);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28.0,
                        height: 28.0,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2.0,
                          color: index == displayCount - 1
                              ? Colors.transparent
                              : AppColors.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            description,
                            style: const TextStyle(
                              color: AppColors.outline,
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (itinerary.length > 1)
          TextButton(
            onPressed: () {
              setState(() {
                _isItineraryExpanded = !_isItineraryExpanded;
              });
            },
            child: Text(
              _isItineraryExpanded
                  ? 'Collapse Itinerary'
                  : 'View Full Itinerary',
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsSegment(List<Review> reviews, ThemeData theme) {
    if (reviews.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews (0)', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.0),
          Text('No traveler reviews yet.'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Reviews (${reviews.length})'),
        AppSpacing.gapMd,
        SizedBox(
          height: 130.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: 260.0,
                margin: const EdgeInsets.only(right: 12.0),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.0,
                          backgroundImage: review.userPhotoUrl.isNotEmpty
                              ? NetworkImage(review.userPhotoUrl)
                              : null,
                          child: review.userPhotoUrl.isNotEmpty
                              ? null
                              : const Icon(Icons.person, size: 16.0),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              RatingStars(
                                rating: review.overallRating,
                                starSize: 12.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: Text(
                        '"${review.comment}"',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
