import 'package:flutter/material.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/secondary_button.dart';
import '../core/widgets/gold_accent_button.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_chip.dart';
import '../core/widgets/rating_stars.dart';
import '../core/widgets/section_header.dart';
import '../core/widgets/loading_indicator.dart';
import '../core/widgets/empty_state_view.dart';
import '../core/widgets/error_state_view.dart';
import '../core/widgets/app_avatar.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/theme/app_spacing.dart';

/// A catalog screen displaying all the shared widgets built in Prompt 2.
class WidgetsCatalogScreen extends StatefulWidget {
  const WidgetsCatalogScreen({super.key});

  @override
  State<WidgetsCatalogScreen> createState() => _WidgetsCatalogScreenState();
}

class _WidgetsCatalogScreenState extends State<WidgetsCatalogScreen> {
  double _userRating = 3.0;
  bool _isChipActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets Catalog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Buttons'),
            AppSpacing.gapMd,
            PrimaryButton(
              label: 'Primary Button',
              onPressed: () {},
            ),
            AppSpacing.gapBase,
            PrimaryButton(
              label: 'Primary Loading',
              onPressed: () {},
              isLoading: true,
            ),
            AppSpacing.gapBase,
            const PrimaryButton(
              label: 'Primary Disabled',
              onPressed: null,
            ),
            AppSpacing.gapMd,
            SecondaryButton(
              label: 'Secondary Button',
              onPressed: () {},
              icon: const Icon(Icons.share),
            ),
            AppSpacing.gapMd,
            GoldAccentButton(
              label: 'Book Now (Gold Accent)',
              onPressed: () {},
            ),
            AppSpacing.gapXl,

            const SectionHeader(title: 'Inputs'),
            AppSpacing.gapMd,
            const AppTextField(
              labelText: 'Email Address',
              hintText: 'email@example.com',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            AppSpacing.gapMd,
            const AppTextField(
              labelText: 'Password',
              hintText: 'Enter your password',
              isPassword: true,
              prefixIcon: Icon(Icons.lock_outline),
            ),
            AppSpacing.gapMd,
            const AppTextField(
              labelText: 'Field with Error',
              hintText: 'Invalid value',
              errorText: 'Please enter a valid input',
            ),
            AppSpacing.gapXl,

            const SectionHeader(title: 'Cards & Avatars'),
            AppSpacing.gapMd,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AppCard Container',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  AppSpacing.gapBase,
                  const Text('This container is styled with a white surface, 16px border radius, and a navy-tinted level 2 elevation shadow.'),
                ],
              ),
            ),
            AppSpacing.gapMd,
            const Row(
              children: [
                AppAvatar(
                  imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
                  radius: 32.0,
                ),
                SizedBox(width: 16.0),
                AppAvatar(
                  initials: 'JD',
                  radius: 32.0,
                ),
                SizedBox(width: 16.0),
                AppAvatar(
                  initials: '?',
                  radius: 32.0,
                ),
              ],
            ),
            AppSpacing.gapXl,

            const SectionHeader(title: 'Chips & Ratings'),
            AppSpacing.gapMd,
            Wrap(
              spacing: 8.0,
              children: [
                AppChip(
                  label: 'Beach Category',
                  isActive: _isChipActive,
                  avatar: const Icon(Icons.beach_access),
                  onSelected: (selected) {
                    setState(() {
                      _isChipActive = selected;
                    });
                  },
                ),
                AppChip(
                  label: 'Mountain Category',
                  isActive: !_isChipActive,
                  avatar: const Icon(Icons.terrain),
                  onSelected: (selected) {
                    setState(() {
                      _isChipActive = !selected;
                    });
                  },
                ),
              ],
            ),
            AppSpacing.gapMd,
            const Row(
              children: [
                Text('Read-Only (4.5): '),
                RatingStars(rating: 4.5),
              ],
            ),
            AppSpacing.gapBase,
            Row(
              children: [
                Text('Interactive ($_userRating): '),
                RatingStars(
                  rating: _userRating,
                  onRatingChanged: (newRating) {
                    setState(() {
                      _userRating = newRating;
                    });
                  },
                ),
              ],
            ),
            AppSpacing.gapXl,

            const SectionHeader(title: 'States & Loaders'),
            AppSpacing.gapMd,
            const LoadingIndicator(size: 40.0),
            AppSpacing.gapMd,
            AppCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 250.0,
                child: EmptyStateView(
                  title: 'No Bookings Found',
                  message: 'You have no upcoming travel plans booked at the moment.',
                  icon: Icons.calendar_today,
                  actionLabel: 'Explore Tours',
                  onActionPressed: () {},
                ),
              ),
            ),
            AppSpacing.gapMd,
            AppCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 250.0,
                child: ErrorStateView(
                  message: 'Failed to retrieve listings due to a connection timeout.',
                  onRetry: () {},
                ),
              ),
            ),
            AppSpacing.gapXl,

            const SectionHeader(title: 'Custom Navigation Bar'),
            AppSpacing.gapMd,
            AppBottomNav(
              currentIndex: 0,
              onTap: (index) {},
              items: const [
                AppBottomNavItem(
                  activeIcon: Icons.explore,
                  inactiveIcon: Icons.explore_outlined,
                  label: 'Explore',
                ),
                AppBottomNavItem(
                  activeIcon: Icons.search,
                  inactiveIcon: Icons.search,
                  label: 'Search',
                ),
                AppBottomNavItem(
                  activeIcon: Icons.airplane_ticket,
                  inactiveIcon: Icons.airplane_ticket_outlined,
                  label: 'Trips',
                ),
              ],
            ),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }
}
