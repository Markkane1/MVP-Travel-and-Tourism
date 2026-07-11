@Tags(['integration'])
// Critical path integration test.
//
// This test runs against the dev Firebase project with MockPaymentService.
// It exercises the bookable traveler journey from registration through
// successful checkout and verifies the booking appears in Trips.
//
// Run on an Android emulator/device:
//   flutter test integration_test/critical_path_test.dart \
//     --device-id <device_id> \
//     --dart-define=FLAVOR=dev
//
// Prerequisites:
//   - Dev Firebase project seeded with at least one tour in Bora Bora.
//   - MockPaymentService is the active PaymentService implementation.
//   - App data cleared before the run so the test starts signed out.
//
// Note:
//   Leaving a review is intentionally not part of this flow. Reviews are only
//   allowed for completed trips, so that behavior needs a separate seeded test.

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mvp_travel/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical Path - register -> book -> trips', () {
    testWidgets('traveler can register, book, pay, and see trip', (
      tester,
    ) async {
      app.main();
      await _settle(tester, timeout: const Duration(seconds: 5));

      final email = 'test_${Random().nextInt(999999)}@mvptravel.test';
      const password = 'Test@12345!';

      await _ensureSignedOut(tester);
      await _waitFor(tester, find.byKey(const Key('auth_screen')));
      await _ensureRegisterMode(tester);

      await tester.enterText(
        find.byKey(const Key('auth_full_name_field')),
        'Phase Eight Tester',
      );
      await tester.enterText(find.byKey(const Key('auth_email_field')), email);
      await tester.enterText(
        find.byKey(const Key('auth_password_field')),
        password,
      );
      await tester.enterText(
        find.byKey(const Key('auth_confirm_password_field')),
        password,
      );
      await tester.ensureVisible(find.byKey(const Key('auth_terms_checkbox')));
      await tester.tap(find.byKey(const Key('auth_terms_checkbox')));
      await _settle(tester);

      await tester.ensureVisible(
        find.byKey(const Key('auth_submit_button')).last,
      );
      await _settle(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      await _pressElevatedButton(
        tester,
        find.byKey(const Key('auth_submit_button')).last,
      );
      await _settle(tester, timeout: const Duration(seconds: 8));

      expect(
        find.byKey(const Key('explore_screen')),
        findsOneWidget,
        reason: 'Should land on Explore after registration',
      );

      await tester.tap(find.text('Search').last);
      await _settle(tester);

      await tester.enterText(
        find.byKey(const Key('search_query_field')),
        'Bora Bora',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await _settle(tester, timeout: const Duration(seconds: 5));

      await _waitFor(tester, find.byKey(const Key('search_result_card_0')));
      await tester.tap(find.byKey(const Key('search_result_card_0')));
      await _settle(tester, timeout: const Duration(seconds: 3));

      expect(
        find.byKey(const Key('tour_details_screen')),
        findsOneWidget,
        reason: 'Should be on Tour Details screen',
      );

      await tester.tap(find.byKey(const Key('tour_details_book_button')));
      await _settle(tester, timeout: const Duration(seconds: 2));

      expect(find.byKey(const Key('booking_screen')), findsOneWidget);

      await _waitFor(tester, find.byKey(const Key('booking_calendar_date_0')));
      await tester.tap(find.byKey(const Key('booking_calendar_date_0')));
      await _settle(tester);

      await tester.ensureVisible(
        find.byKey(const Key('booking_adults_increment')),
      );
      await tester.tap(find.byKey(const Key('booking_adults_increment')));
      await _settle(tester);

      await tester.enterText(
        find.byKey(const Key('booking_pickup_field')),
        'Main Airport',
      );
      await _settle(tester);

      await tester.tap(find.byKey(const Key('booking_continue_button')));
      await _settle(tester, timeout: const Duration(seconds: 3));

      expect(find.byKey(const Key('checkout_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('checkout_pay_button')));
      await _settle(tester, timeout: const Duration(seconds: 8));

      expect(
        find.byKey(const Key('payment_success_screen')),
        findsOneWidget,
        reason: 'Should reach success screen after payment',
      );

      await tester.tap(
        find.byKey(const Key('payment_success_view_itinerary_button')),
      );
      await _settle(tester, timeout: const Duration(seconds: 3));

      expect(
        find.byKey(const Key('booking_confirmation_screen')),
        findsOneWidget,
        reason: 'Should reach booking confirmation after success',
      );

      await tester.ensureVisible(
        find.byKey(const Key('booking_confirmation_back_home_button')),
      );
      await tester.tap(
        find.byKey(const Key('booking_confirmation_back_home_button')),
      );
      await _settle(tester, timeout: const Duration(seconds: 3));

      expect(find.byKey(const Key('explore_screen')), findsOneWidget);

      await tester.tap(find.text('Trips').last);
      await _settle(tester, timeout: const Duration(seconds: 3));

      expect(find.byKey(const Key('trips_screen')), findsOneWidget);
      await _waitFor(tester, find.byKey(const Key('trip_card_0')));
      expect(
        find.byKey(const Key('trip_card_0')),
        findsOneWidget,
        reason: 'New booking should appear in Upcoming Trips',
      );
    });
  });
}

Future<void> _ensureSignedOut(WidgetTester tester) async {
  final authScreen = find.byKey(const Key('auth_screen'));
  final exploreScreen = find.byKey(const Key('explore_screen'));
  final startupDeadline = DateTime.now().add(const Duration(seconds: 15));

  while (DateTime.now().isBefore(startupDeadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(authScreen)) {
      return;
    }
    if (tester.any(exploreScreen)) {
      await FirebaseAuth.instance.signOut();
      await _settle(tester, timeout: const Duration(seconds: 5));
      return;
    }
  }

  expect(
    authScreen,
    findsOneWidget,
    reason: 'Timed out waiting for auth or explore startup state.',
  );
}

Future<void> _ensureRegisterMode(WidgetTester tester) async {
  if (tester.any(find.byKey(const Key('auth_full_name_field')))) {
    return;
  }

  final registerToggle = find.byKey(const Key('auth_toggle_register'));
  if (tester.any(registerToggle)) {
    await tester.tap(registerToggle);
  } else {
    await tester.tap(find.text('Register').last);
  }
  await _settle(tester);
  await _waitFor(tester, find.byKey(const Key('auth_full_name_field')));
}

Future<void> _settle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  await tester.pump();
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  } on FlutterError {
    await tester.pump(timeout);
  }
}

Future<void> _pressElevatedButton(WidgetTester tester, Finder finder) async {
  final button = tester.widget<ElevatedButton>(finder);
  expect(
    button.onPressed,
    isNotNull,
    reason: 'Expected enabled button: $finder',
  );
  button.onPressed!.call();
  await tester.pump();
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) {
      return;
    }
  }

  expect(
    finder,
    findsOneWidget,
    reason: 'Timed out waiting for widget: $finder',
  );
}
