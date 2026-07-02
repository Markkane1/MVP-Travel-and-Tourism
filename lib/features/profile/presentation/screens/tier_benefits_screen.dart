import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/app_card.dart';

class TierBenefitsScreen extends StatelessWidget {
  const TierBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Loyalty Tiers & Benefits',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          children: [
            // Standard Tier
            _buildTierCard(
              context,
              'Standard Tier',
              'Entry Level (0 - 4,999 Points)',
              [
                'Earn Loyalty Points on All Bookings',
                'Standard Support Chat Access',
                'General Destination Access',
                'Self-service Cancellation Options',
              ],
              AppColors.outlineVariant,
            ),
            AppSpacing.gapLg,

            // Elite Horizon Tier
            _buildTierCard(
              context,
              'Elite Horizon Status',
              'Verified Elite Status (5,000 - 14,999 Points)',
              [
                '24/7 Personal Concierge Access',
                'Private Airport Lounge Access',
                'Priority Expedited Boarding',
                'Complimentary Room & Cabin Upgrades',
                'Exclusive Invitation-only Tour Access',
              ],
              AppColors.secondary, // Gold
              isGold: true,
            ),
            AppSpacing.gapLg,

            // Legend Tier
            _buildTierCard(
              context,
              'Horizon Legend Status',
              'Super Elite Level (15,000+ Points)',
              [
                'All Elite Horizon Benefits Included',
                'Unlimited Private Chauffeur Services',
                'Complimentary Private Chef Dining Sessions',
                'Free Multi-trip Travel Insurance coverages',
                'Dedicated 1-on-1 Concierge Manager',
              ],
              Colors.blue.shade900,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    String name,
    String threshold,
    List<String> benefits,
    Color bannerColor, {
    bool isGold = false,
  }) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: bannerColor,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isGold ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                    Text(
                      threshold,
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
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.check, color: isGold ? AppColors.secondary : AppColors.primary, size: 16.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      benefit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
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
}
