import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radii.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _firebaseStatus = 'Not Signed In';
  String _firebaseLog = 'Ready to test...';

  Future<void> _signInAnonymously() async {
    try {
      setState(() {
        _firebaseStatus = 'Signing in...';
        _firebaseLog = 'Auth.signInAnonymously()...';
      });
      final creds = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _firebaseStatus = 'Signed In: ${creds.user?.uid}';
        _firebaseLog = 'Successfully signed in anonymously!';
      });
    } catch (e) {
      setState(() {
        _firebaseStatus = 'Sign In Failed';
        _firebaseLog = 'Error: $e';
      });
    }
  }

  Future<void> _writeOwnDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _firebaseLog = 'Error: Please sign in anonymously first!';
      });
      return;
    }
    try {
      setState(() {
        _firebaseLog = 'Writing to users/${user.uid}...';
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': 'Anonymous Test User',
        'email': 'anonymous@mvptravel.com',
        'tier': 'Standard',
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _firebaseLog = 'Success! Wrote own document successfully.';
      });
    } catch (e) {
      setState(() {
        _firebaseLog = 'Error: $e';
      });
    }
  }

  Future<void> _writeOtherDoc() async {
    try {
      setState(() {
        _firebaseLog = 'Writing to users/some-other-uid-123 (should fail)...';
      });
      await FirebaseFirestore.instance.collection('users').doc('some-other-uid-123').set({
        'displayName': 'Malicious Hacker',
        'tier': 'Elite Horizon',
      });
      setState(() {
        _firebaseLog = 'Error: Write succeeded! Security rules did not block it.';
      });
    } catch (e) {
      setState(() {
        _firebaseLog = 'Success! Blocked by security rules:\n$e';
      });
    }
  }

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
            AppSpacing.gapXl,

            const SectionHeader(title: 'Firebase Integration & Security Rules Test'),
            AppSpacing.gapMd,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_firebaseStatus',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: '1. Sign In Anon',
                          onPressed: _signInAnonymously,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: PrimaryButton(
                          label: '2. Write Own Doc',
                          onPressed: _writeOwnDoc,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapBase,
                  PrimaryButton(
                    label: '3. Write Other Doc (Should Fail)',
                    onPressed: _writeOtherDoc,
                  ),
                  AppSpacing.gapMd,
                  const Text('Log Output:', style: TextStyle(fontWeight: FontWeight.bold)),
                  AppSpacing.gapBase,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppRadii.borderDefault,
                    ),
                    child: Text(
                      _firebaseLog,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }
}
