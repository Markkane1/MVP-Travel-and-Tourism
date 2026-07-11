import 'package:flutter/material.dart';
import '../../../../core/theme/app_radii.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/explore_repository.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/category_selector.dart';
import '../widgets/special_offers_grid.dart';
import '../widgets/tour_card.dart';
import '../widgets/destination_card.dart';
import '../widgets/reviewer_card.dart';

/// The Explore (Home) dashboard screen.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch independent streams
    final user = ref.watch(authServiceProvider).currentUser;
    final heroPromo = ref.watch(heroPromotionsProvider);
    final featured = ref.watch(featuredToursProvider);
    final popular = ref.watch(popularDestinationsProvider);
    final reviews = ref.watch(recentReviewsProvider);

    Future<void> handleRefresh() async {
      ref.invalidate(heroPromotionsProvider);
      ref.invalidate(featuredToursProvider);
      ref.invalidate(popularDestinationsProvider);
      ref.invalidate(recentReviewsProvider);
    }

    return Scaffold(
      key: const Key('explore_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: AppColors.onSurface),
          onPressed: () => context.push('/search'),
        ),
        title: SizedBox(
          height: 34.0,
          child: Image.asset(
            'assets/icons/app_logo_full.png',
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 18.0,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                    ? const Icon(Icons.person, size: 20.0, color: AppColors.primary)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapMd,

              // 1. Hero Promo Carousel Section
              heroPromo.when(
                data: (promotions) => PromoCarousel(promotions: promotions),
                loading: () => _buildSectionSkeleton(height: 200.0),
                error: (err, stack) => _buildSectionError(
                  'Failed to load promotions',
                  () => ref.invalidate(heroPromotionsProvider),
                ),
              ),
              AppSpacing.gapLg,

              // 2. Tappable Search Trigger Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.borderMd,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          'Where to next?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.gapLg,

              // 3. Category selector row
              CategorySelector(
                onCategorySelected: (category) {
                  context.push(
                    '${RoutePaths.searchResults}?category=${Uri.encodeComponent(category)}',
                  );
                },
              ),
              AppSpacing.gapLg,

              // 4. Featured Tours Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Featured Tours',
                    actionLabel: 'See All',
                    onActionPressed: () => context.push(
                      '${RoutePaths.searchResults}?featured=true',
                    ),
                  ),
                  AppSpacing.gapMd,
                  featured.when(
                    data: (tours) {
                      if (tours.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Text(
                            'Featured tours will appear here once they are available.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 220.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: tours.length,
                          itemBuilder: (context, index) =>
                              TourCard(tour: tours[index]),
                        ),
                      );
                    },
                    loading: () => _buildSectionSkeleton(height: 200.0),
                    error: (err, stack) => _buildSectionError(
                      'Failed to load featured tours',
                      () => ref.invalidate(featuredToursProvider),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,

              // 5. Special Offers section
              const SpecialOffersGrid(),
              AppSpacing.gapLg,

              // 6. Popular Destinations Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Popular Destinations',
                    actionLabel: 'See All',
                    onActionPressed: () => context.push(
                      '${RoutePaths.searchResults}?featured=true',
                    ),
                  ),
                  AppSpacing.gapMd,
                  popular.when(
                    data: (destinations) {
                      if (destinations.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Text(
                            'Popular destinations will appear here soon.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 220.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: destinations.length,
                          itemBuilder: (context, index) =>
                              DestinationCard(tour: destinations[index]),
                        ),
                      );
                    },
                    loading: () => _buildSectionSkeleton(height: 200.0),
                    error: (err, stack) => _buildSectionError(
                      'Failed to load destinations',
                      () => ref.invalidate(popularDestinationsProvider),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,

              // 7. Traveler Stories Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      'Traveler Stories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  reviews.when(
                    data: (reviewList) {
                      if (reviewList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Text(
                            'Traveler stories will appear here once guests share their experiences.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 140.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: reviewList.length,
                          itemBuilder: (context, index) =>
                              ReviewerCard(review: reviewList[index]),
                        ),
                      );
                    },
                    loading: () => _buildSectionSkeleton(height: 120.0),
                    error: (err, stack) => _buildSectionError(
                      'Failed to load reviews. Indices may be compiling.',
                      () => ref.invalidate(recentReviewsProvider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSkeleton({required double height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppRadii.borderLg,
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
      ),
    );
  }

  Widget _buildSectionError(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: AppRadii.borderLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(color: AppColors.onErrorContainer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16.0),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
