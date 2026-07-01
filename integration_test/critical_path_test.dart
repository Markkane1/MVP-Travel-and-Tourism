// Critical path integration test.
//
// This test runs against the **dev** Firebase project with MockPaymentService.
// It exercises the full user journey from registration through booking and review.
//
// Run on an emulator/device:
//   flutter test integration_test/critical_path_test.dart \
//     --device-id <device_id> \
//     --dart-define=FLAVOR=dev
//
// Prerequisites:
//   - Dev Firebase project seeded with at least one tour in 'Bora Bora' destination.
//   - MockPaymentService is the active PaymentService implementation (v1 default).

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mvp_travel/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical Path — register → book → review', () {
    testWidgets('full user journey', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // -----------------------------------------------------------------------
      // 1. Register a new test user
      // -----------------------------------------------------------------------
      final email =
          'test_${Random().nextInt(999999)}@mvptravel.test';
      const password = 'Test@12345!';

      // Should be on the auth screen (redirect because no session)
      await _waitFor(tester, find.byKey(const Key('auth_toggle_register')));
      await tester.tap(find.byKey(const Key('auth_toggle_register')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('auth_email_field')), email);
      await tester.enterText(
          find.byKey(const Key('auth_password_field')), password);
      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // -----------------------------------------------------------------------
      // 2. Assert landing on Explore tab
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('explore_screen')), findsOneWidget,
          reason: 'Should land on Explore after registration');

      // -----------------------------------------------------------------------
      // 3. Search for a tour
      // -----------------------------------------------------------------------
      await tester.tap(find.byKey(const Key('bottom_nav_search')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('search_query_field')), 'Bora Bora');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap first search result
      await _waitFor(tester, find.byKey(const Key('search_result_card_0')));
      await tester.tap(find.byKey(const Key('search_result_card_0')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // -----------------------------------------------------------------------
      // 4. Tour details → Book Now
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('tour_details_screen')), findsOneWidget,
          reason: 'Should be on Tour Details screen');

      await tester.tap(find.byKey(const Key('tour_details_book_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // -----------------------------------------------------------------------
      // 5. Booking configuration → pick first available date, 2 adults
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('booking_screen')), findsOneWidget);

      // Tap first available date in calendar
      await _waitFor(tester, find.byKey(const Key('booking_calendar_date_0')));
      await tester.tap(find.byKey(const Key('booking_calendar_date_0')));
      await tester.pumpAndSettle();

      // Adults already defaults to 1, increment to 2
      await tester.tap(find.byKey(const Key('booking_adults_increment')));
      await tester.pumpAndSettle();

      // Fill pickup location
      await tester.enterText(
          find.byKey(const Key('booking_pickup_field')), 'Main Airport');
      await tester.pumpAndSettle();

      // Continue to checkout
      await tester.tap(find.byKey(const Key('booking_continue_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // -----------------------------------------------------------------------
      // 6. Checkout → Pay Now (MockPaymentService ~2s delay)
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('checkout_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('checkout_pay_button')));
      // Wait for mock payment processing + success redirect
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // -----------------------------------------------------------------------
      // 7. Payment success screen
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('payment_success_screen')), findsOneWidget,
          reason: 'Should reach success screen after payment');

      // Navigate to Trips tab
      await tester.tap(find.byKey(const Key('payment_success_go_trips')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // -----------------------------------------------------------------------
      // 8. Booking appears in Trips tab
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('trips_screen')), findsOneWidget);
      // Booking card for this tour should be visible
      await _waitFor(tester, find.byKey(const Key('trip_card_0')));
      expect(find.byKey(const Key('trip_card_0')), findsOneWidget,
          reason: 'New booking should appear in Trips list');

      // -----------------------------------------------------------------------
      // 9. Leave a review
      // -----------------------------------------------------------------------
      await tester.tap(find.byKey(const Key('trip_card_0')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // On booking confirmation screen, tap Review button
      await _waitFor(tester, find.byKey(const Key('booking_confirmation_review_button')));
      await tester.tap(find.byKey(const Key('booking_confirmation_review_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Review screen — tap 5th star (overall rating)
      await _waitFor(tester, find.byKey(const Key('review_star_5')));
      await tester.tap(find.byKey(const Key('review_star_5')));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byKey(const Key('review_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 12));

      // -----------------------------------------------------------------------
      // 10. Review success + loyalty points incremented
      // -----------------------------------------------------------------------
      expect(find.byKey(const Key('review_success_screen')), findsOneWidget,
          reason: 'Should reach review success screen');

      // Verify points are shown as > 0 (Cloud Function should have run)
      final pointsText = find.byKey(const Key('review_success_points'));
      if (tester.any(pointsText)) {
        final text = tester.widget<Text>(pointsText).data ?? '0';
        final points = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        expect(points, greaterThan(0),
            reason: 'Loyalty points should be awarded after review');
      }
    });
  });
}

/// Waits up to [timeout] for [finder] to appear, pumping frames.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  // Final check — will throw meaningful error if not found
  expect(finder, findsOneWidget,
      reason: 'Timed out waiting for widget: $finder');
}
