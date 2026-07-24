import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../booking/domain/booking.dart';

class ErrorBannerWidget extends StatelessWidget {
  final String errorMessage;

  const ErrorBannerWidget({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
        border: Border.all(color: AppColors.error, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryCardWidget extends StatelessWidget {
  final Booking booking;

  const OrderSummaryCardWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String dateStr =
        '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';
    final int guestCount = booking.adults + booking.children;
    final String guestLabel = guestCount == 1 ? 'Guest' : 'Guests';

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Image
          Container(
            width: 72.0,
            height: 72.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
              image: DecorationImage(
                image: NetworkImage(booking.tourSnapshot.heroImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Booking info summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.tourSnapshot.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '$dateStr - $guestCount $guestLabel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (booking.privateVehicle) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.airport_shuttle,
                        size: 14.0,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Private SUV included',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrustFootnoteWidget extends StatelessWidget {
  const TrustFootnoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.checkout.footnote,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 10.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ProcessingOverlayWidget extends StatelessWidget {
  const ProcessingOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Blurs checkout contents behind
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: AppColors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          // Rotating rings and lock icon
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    RotatingRingAnim(),
                    Icon(Icons.lock, color: AppColors.primary, size: 28.0),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Processing Payment...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic rotating ring graphic.
class RotatingRingAnim extends StatefulWidget {
  const RotatingRingAnim({super.key});

  @override
  State<RotatingRingAnim> createState() => _RotatingRingAnimState();
}

class _RotatingRingAnimState extends State<RotatingRingAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 4.0,
          ),
        ),
        child: const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 4.0,
          value: 0.25,
        ),
      ),
    );
  }
}
