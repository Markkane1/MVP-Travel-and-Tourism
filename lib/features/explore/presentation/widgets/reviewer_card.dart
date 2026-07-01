import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../domain/review.dart';

/// Testimonial reviewer card for Traveler Stories section.
class ReviewerCard extends StatelessWidget {
  final Review review;

  const ReviewerCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280.0,
      margin: const EdgeInsets.only(right: 16.0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.outlineVariant, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(review.userPhotoUrl),
              ),
              const SizedBox(width: 12.0),
              // Reviewer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    RatingStars(
                      rating: review.overallRating,
                      starSize: 14.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          // 2-line italic quote
          Text(
            '"${review.comment}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
