import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/routing/route_paths.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchSupportMail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@mvptravel.com',
      queryParameters: {'subject': 'MVP Travel & Tourism - Support Request'},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open your email app right now. Please try again later.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Help Center & Support',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Assistance?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Our dedicated travel concierge support team is available to assist you with booking issues, preferences, or refunds.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _launchSupportMail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50.0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined),
                        SizedBox(width: 8.0),
                        Text(
                          'Contact Support',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // FAQ accordion
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildFaqItem(
              context,
              'How do loyalty points work?',
              'You automatically earn loyalty points on every luxury booking equal to 10% of the total price (rounded down). Points accumulate over time and unlock higher tier statuses.',
            ),
            _buildFaqItem(
              context,
              'What is the cancellation policy?',
              'Cancellations are subject to the specific tour operator\'s policy. You can cancel any pending or confirmed upcoming bookings directly from your Trips tab.',
            ),
            _buildFaqItem(
              context,
              'How can I update my preferences?',
              'Go to Profile > Travel Preferences to configure seat preferences, hotel standards, and dietary guidelines which will be pre-filled during bookings.',
            ),
            AppSpacing.gapLg,

            // Legal Links
            Text(
              'Legal Documents',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            AppCard(
              child: Column(
                children: [
                  _buildLegalRow(
                    context,
                    'Terms of Use',
                    () => context.push(RoutePaths.legalTerms),
                  ),
                  const Divider(height: 16.0, color: AppColors.outlineVariant),
                  _buildLegalRow(
                    context,
                    'Privacy Policy',
                    () => context.push(RoutePaths.legalPrivacy),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8.0),
          expandedAlignment: Alignment.topLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.0,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalRow(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14.0,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
