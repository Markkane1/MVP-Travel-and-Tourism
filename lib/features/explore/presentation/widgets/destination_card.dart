import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/tour.dart';

/// Renders a popular destination card image and rating capsule overlay.
class DestinationCard extends StatelessWidget {
  final Tour tour;

  const DestinationCard({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/search/results?destination=${Uri.encodeComponent(tour.destination.split(',').first)}'),
      child: Container(
        width: 170.0,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with bottom-left rating badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    tour.heroImageUrl,
                    height: 160.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          tour.ratingAverage.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapBase,
            // Name below image
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                tour.destination,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
