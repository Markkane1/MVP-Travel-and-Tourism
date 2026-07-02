import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable star rating widget.
/// Supports read-only fractional display and interactive selection.
class RatingStars extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double starSize;
  final ValueChanged<double>? onRatingChanged;
  final Color starColor;
  final String? interactiveKeyPrefix;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.starSize = 20.0,
    this.onRatingChanged,
    this.starColor = AppColors.secondary, // Gold/secondary color for ratings
    this.interactiveKeyPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onRatingChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        Widget starIcon;

        if (isInteractive) {
          final isSelected = starValue <= rating;
          starIcon = GestureDetector(
            key: interactiveKeyPrefix == null
                ? null
                : Key('${interactiveKeyPrefix!}_$starValue'),
            onTap: () => onRatingChanged?.call(starValue.toDouble()),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: starColor,
              size: starSize,
            ),
          );
        } else {
          // Read-only display logic supporting half-stars
          if (rating >= starValue) {
            starIcon = Icon(Icons.star, color: starColor, size: starSize);
          } else if (rating >= starValue - 0.5) {
            starIcon = Icon(Icons.star_half, color: starColor, size: starSize);
          } else {
            starIcon = Icon(
              Icons.star_border,
              color: starColor,
              size: starSize,
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: starIcon,
        );
      }),
    );
  }
}
