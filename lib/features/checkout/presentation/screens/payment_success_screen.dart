import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_paths.dart';

/// Screen displayed after a successful booking payment transaction.
class PaymentSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String bookingReferenceCode;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.bookingReferenceCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('payment_success_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Checkout',
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
      body: Stack(
        children: [
          // Success content container
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Checked Circle Badge
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, // Navy circle
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 40.0),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Headline
                  Text(
                    AppStrings.checkout.successHeader,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),

                  // Body Subtext
                  Text(
                    AppStrings.checkout.successSub,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),

                  // Confirmation Reference card
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.checkout.referenceLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            bookingReferenceCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky bottom View Itinerary button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: AppShadows.level2,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg),
                ),
              ),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  buttonKey: const Key('payment_success_view_itinerary_button'),
                  label: AppStrings.checkout.viewItineraryButton,
                  onPressed: () {
                    // Navigate to Itinerary/Booking confirmation inside Trips tab
                    context.go(RoutePaths.bookingConfirmationPath(bookingId));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
