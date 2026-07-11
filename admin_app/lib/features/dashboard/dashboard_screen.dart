import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(totalBookingsProvider);
    final toursAsync = ref.watch(totalToursProvider);
    final conciergeAsync = ref.watch(totalConciergeThreadsProvider);
    final reviewsAsync = ref.watch(totalReviewsProvider);

    // Phase 9 additional metrics
    final pendingBookingsAsync = ref.watch(pendingBookingsProvider);
    final confirmedBookingsAsync = ref.watch(confirmedBookingsProvider);
    final activeServicesAsync = ref.watch(activeServicesProvider);
    final recentRefundsAsync = ref.watch(recentRefundsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Admin',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Here is what\'s happening with your travel business today.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            Text(
              'Primary Operations',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 4;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 900) {
                  crossAxisCount = 2;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.5,
                  children: [
                    _MetricCard(
                      title: 'Total Bookings',
                      valueAsync: bookingsAsync,
                      icon: Icons.book_online,
                      color: Colors.blue,
                    ),
                    _MetricCard(
                      title: 'Pending Bookings',
                      valueAsync: pendingBookingsAsync,
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    _MetricCard(
                      title: 'Confirmed Bookings',
                      valueAsync: confirmedBookingsAsync,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _MetricCard(
                      title: 'Recent Refunds',
                      valueAsync: recentRefundsAsync,
                      icon: Icons.currency_exchange,
                      color: Colors.red,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 48),
            Text(
              'Catalog & Engagement',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 4;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 900) {
                  crossAxisCount = 2;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.5,
                  children: [
                    _MetricCard(
                      title: 'Active Tours',
                      valueAsync: toursAsync,
                      icon: Icons.tour,
                      color: Colors.teal,
                    ),
                    _MetricCard(
                      title: 'Active Services',
                      valueAsync: activeServicesAsync,
                      icon: Icons.room_service,
                      color: Colors.purple,
                    ),
                    _MetricCard(
                      title: 'Concierge Threads',
                      valueAsync: conciergeAsync,
                      icon: Icons.support_agent,
                      color: Colors.indigo,
                    ),
                    _MetricCard(
                      title: 'Total Reviews',
                      valueAsync: reviewsAsync,
                      icon: Icons.star_rate,
                      color: Colors.amber,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final AsyncValue<int> valueAsync;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.valueAsync,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
              ],
            ),
            valueAsync.when(
              data: (value) => Text(
                value.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              loading: () => const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) =>
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}
