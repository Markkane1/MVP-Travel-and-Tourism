import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

/// Screen displaying MVP Travel's Terms of Use.
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Use')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MVP Travel & Tourism LLC\nTerms of Use',
              style: textTheme.headlineMedium,
            ),
            AppSpacing.gapLg,
            Text(
              'Last Updated: July 2026',
              style: textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            AppSpacing.gapMd,
            Text(
              'Welcome to MVP Travel. By using our application, digital concierge systems, booking portals, and travel services, you agree to comply with and be bound by the following terms of use. Please review these terms carefully.',
              style: textTheme.bodyLarge,
            ),
            AppSpacing.gapMd,
            Text('1. Premium Booking Services', style: textTheme.headlineSmall),
            AppSpacing.gapBase,
            Text(
              'All bookings are made directly through official channels. Loyalty points earned during tour itineraries are non-transferable and carry zero cash redemption value. Cancellation policies apply per specific tour details.',
              style: textTheme.bodyMedium,
            ),
            AppSpacing.gapMd,
            Text('2. User Obligations', style: textTheme.headlineSmall),
            AppSpacing.gapBase,
            Text(
              'You agree to provide accurate and complete email, profile details, and payment authorization credentials. Impersonating other users or attempting to circumvent account data and media controls is strictly prohibited.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }
}

/// Screen displaying MVP Travel's Privacy Policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MVP Travel & Tourism LLC\nPrivacy Policy',
              style: textTheme.headlineMedium,
            ),
            AppSpacing.gapLg,
            Text(
              'Last Updated: July 2026',
              style: textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            AppSpacing.gapMd,
            Text(
              'At MVP Travel, we are committed to maintaining the highest global standards of data privacy and user security. This document details how we collect, store, and process your travel logs, profiles, and payment tokens.',
              style: textTheme.bodyLarge,
            ),
            AppSpacing.gapMd,
            Text(
              '1. Data Collection & Cloud Datastores',
              style: textTheme.headlineSmall,
            ),
            AppSpacing.gapBase,
            Text(
              'User profiles and travel bookings are stored in encrypted cloud databases. We collect email addresses, names, and transaction references necessary to fulfill booking reservations. Raw card data is never processed or stored on our servers; payments are managed entirely by Stripe.',
              style: textTheme.bodyMedium,
            ),
            AppSpacing.gapMd,
            Text('2. Data Security', style: textTheme.headlineSmall),
            AppSpacing.gapBase,
            Text(
              'Access to account data is protected by strict role-based API authorization. Uploaded photos are compressed locally prior to upload and stored in secure user-isolated media folders.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }
}
