import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mvp_travel/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screen coverage smoke test', () {
    testWidgets('seeded user can reach remaining app screens', (tester) async {
      app.main();
      _step('launch app');
      await _settle(tester, timeout: const Duration(seconds: 5));

      _step('ensure explore ready');
      await _ensureExploreReady(tester);

      await _waitFor(
        tester,
        find.byKey(const Key('explore_screen')),
        label: 'explore screen',
      );

      _step('open concierge');
      await tester.tap(find.text('Concierge').last);
      await _settle(tester, timeout: const Duration(seconds: 3));
      await _waitFor(
        tester,
        find.text('Travel Concierge'),
        label: 'concierge title',
      );
      _step('tap concierge quick help');
      await _pressGestureDetector(
        tester,
        find.byKey(const Key('concierge_quick_help_private_jet')),
      );
      await _settle(tester);
      _step('send concierge message');
      await tester.tap(find.byIcon(Icons.send));
      await _settle(tester, timeout: const Duration(seconds: 3));

      _step('open notifications');
      await tester.tap(find.byTooltip('Notifications'));
      await _settle(tester, timeout: const Duration(seconds: 3));
      await _waitFor(
        tester,
        find.text('Notifications'),
        label: 'notifications title',
      );
      _step('open booking notification');
      await tester.tap(find.text('Kyoto trip completed'));
      await _settle(tester, timeout: const Duration(seconds: 3));
      await _waitFor(
        tester,
        find.byKey(const Key('trips_screen')),
        label: 'trips screen',
      );

      _step('switch trips to history');
      await tester.tap(find.text('History'));
      await _settle(tester, timeout: const Duration(seconds: 2));
      await _waitFor(
        tester,
        find.byKey(const Key('trip_history_card_0')),
        label: 'trip history card',
      );
      if (tester.any(find.text('Leave a Review'))) {
        _step('open review trip');
        await tester.tap(find.text('Leave a Review').first);
        await _settle(tester, timeout: const Duration(seconds: 3));
        await _waitFor(
          tester,
          find.byKey(const Key('review_trip_screen')),
          label: 'review trip screen',
        );
        _step('submit review');
        await tester.tap(find.byKey(const Key('review_star_5')));
        await _settle(tester);
        await tester.enterText(find.byType(TextField).last, 'Excellent trip.');
        await _settle(tester);
        await tester.tap(find.byKey(const Key('review_submit_button')));
        await _settle(tester, timeout: const Duration(seconds: 12));
        await _waitFor(
          tester,
          find.byKey(const Key('review_success_screen')),
          label: 'review success screen',
        );
        _step('back from review success');
        await tester.pageBack();
        await _settle(tester, timeout: const Duration(seconds: 2));
      } else {
        _step('review already submitted');
      }

      _step('open profile');
      await tester.tap(find.text('Profile').last);
      await _settle(tester, timeout: const Duration(seconds: 3));
      await _waitFor(
        tester,
        find.text('Edit Profile'),
        label: 'profile actions',
      );

      await _openAndBack(
        tester,
        find.text('Edit Profile'),
        find.text('Change Photo'),
        label: 'edit profile',
      );
      await _openAndBack(
        tester,
        find.text('View All Benefits'),
        find.text('Standard Tier'),
        label: 'tier benefits',
      );
      await _openAndBack(
        tester,
        find.text('Payment Methods'),
        find.text('Add Payment Method'),
        label: 'payment methods',
      );
      await _openAndBack(
        tester,
        find.text('Travel Preferences'),
        find.text('Configure Preferences'),
        label: 'travel preferences',
      );
      await _openAndBack(
        tester,
        find.text('Explore Travel Map'),
        find.text('Travel Map'),
        label: 'travel map',
      );
      await _openAndBack(
        tester,
        find.text('Security & Privacy'),
        find.text('Security & Privacy').last,
        label: 'security privacy',
      );
      await _openAndBack(
        tester,
        find.text('Notification Settings'),
        find.text('Preference Controls'),
        label: 'notification settings',
      );

      _step('open help support');
      await tester.tap(find.text('Help Center & Support'));
      await _settle(tester, timeout: const Duration(seconds: 2));
      await _waitFor(
        tester,
        find.text('Frequently Asked Questions'),
        label: 'help support screen',
      );
      await _openAndBack(
        tester,
        find.text('Terms of Use'),
        find.text('Terms of Use').last,
        label: 'terms of use',
      );
      await _openAndBack(
        tester,
        find.text('Privacy Policy'),
        find.text('Privacy Policy').last,
        label: 'privacy policy',
      );
      _step('back from help support');
      await _goBack(tester);
      await _settle(tester, timeout: const Duration(seconds: 2));
    });
  });
}

Future<void> _ensureExploreReady(WidgetTester tester) async {
  final authScreen = find.byKey(const Key('auth_screen'));
  final exploreScreen = find.byKey(const Key('explore_screen'));
  final startupDeadline = DateTime.now().add(const Duration(seconds: 20));

  while (DateTime.now().isBefore(startupDeadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(exploreScreen)) {
      return;
    }
    if (!tester.any(authScreen)) {
      continue;
    }

    await tester.runAsync(() async {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'codex.demo.mvptravel@gmail.com',
        password: 'Codex1234!',
      );
    });
    await _settle(tester, timeout: const Duration(seconds: 8));
    if (tester.any(authScreen)) {
      await tester.tap(find.byIcon(Icons.close));
      await _settle(tester, timeout: const Duration(seconds: 5));
    }
    return;
  }

  expect(
    exploreScreen,
    findsOneWidget,
    reason: 'Timed out waiting for auth or explore startup state.',
  );
}

Future<void> _openAndBack(
  WidgetTester tester,
  Finder tapTarget,
  Finder destination, {
  required String label,
}) async {
  _step('open $label');
  await tester.ensureVisible(tapTarget.first);
  await tester.tap(tapTarget.first);
  await _settle(tester, timeout: const Duration(seconds: 3));
  await _waitFor(tester, destination, label: label);
  _step('back from $label');
  await _goBack(tester);
  await _settle(tester, timeout: const Duration(seconds: 2));
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

Future<void> _pressGestureDetector(WidgetTester tester, Finder finder) async {
  final detector = tester.widget<GestureDetector>(finder);
  expect(
    detector.onTap,
    isNotNull,
    reason: 'Expected tappable gesture: $finder',
  );
  detector.onTap!.call();
  await tester.pump();
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  required String label,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) {
      return;
    }
  }

  expect(finder, findsWidgets, reason: 'Timed out waiting for $label.');
}

void _step(String message) {
  // ignore: avoid_print
  print('STEP: $message');
}

Future<void> _goBack(WidgetTester tester) async {
  final materialBack = find.byIcon(Icons.arrow_back);
  if (tester.any(materialBack)) {
    await tester.tap(materialBack.first);
    return;
  }

  await tester.pageBack();
}
