import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/auth_service.dart';
import '../../../profile/data/profile_repository.dart';

class ReviewSuccessScreen extends ConsumerWidget {
  final Map<String, dynamic> extraData;

  const ReviewSuccessScreen({super.key, required this.extraData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final firestoreState = ref.watch(userFirestoreDataProvider);
    final theme = Theme.of(context);

    final String tourTitle = extraData['tourTitle'] ?? 'the tour';
    final String? tourHeroImageUrl = extraData['tourHeroImageUrl'];
    final bool hasUploadedPhotos = extraData['hasUploadedPhotos'] ?? false;

    // Sourced first name from current session displayName
    final String fullName = user?.displayName ?? 'Guest';
    final String firstName = fullName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24.0),

              // Tour hero image with gold checkmark overlay
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: tourHeroImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(tourHeroImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.primaryContainer,
                      ),
                      child: tourHeroImageUrl == null
                          ? const Icon(Icons.celebration, size: 48.0, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary, // Gold
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              // Headline & thank you
              Text(
                'Thank You, $firstName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Text(
                'Your review of $tourTitle has been shared. Your insights help us maintain the world-class standards of MVP Travel.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapLg,

              // Points earned details card
              AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.stars, color: AppColors.secondary, size: 36.0),
                    const SizedBox(height: 8.0),
                    Text(
                      'POINTS EARNED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      '+250 pts',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const Divider(height: 24.0, color: AppColors.outlineVariant, thickness: 1.0),
                    
                    // Reactive balance line with loading state
                    firestoreState.when(
                      loading: () => const Text(
                        'Updating balance...',
                        style: TextStyle(fontSize: 13.0, color: AppColors.onSurfaceVariant),
                      ),
                      error: (err, stack) => const Text(
                        'New Balance: -- pts',
                        style: TextStyle(fontSize: 13.0, color: AppColors.error),
                      ),
                      data: (profile) {
                        final points = profile?['loyaltyPoints'] ?? 0;
                        return Text(
                          'New Balance: $points pts',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,

              // Photo pill banner info message
              if (hasUploadedPhotos) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 16.0, color: AppColors.primary),
                      const SizedBox(width: 8.0),
                      Text(
                        'Your photos have been added to the tour gallery.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapLg,
              ],

              // Navigation options buttons
              PrimaryButton(
                label: 'Back to Dashboard',
                onPressed: () => context.go('/trips'),
              ),
              const SizedBox(height: 12.0),
              OutlinedButton(
                onPressed: () => context.go('/explore'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50.0),
                  side: const BorderSide(color: AppColors.outline),
                ),
                child: const Text(
                  'Explore New Destinations',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
