import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/core/widgets/primary_button.dart';
import 'package:mvp_travel/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('PrimaryButton', () {
    testWidgets('renders label text in active state', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Book Now', onPressed: () {})),
      );
      expect(find.text('Book Now'), findsOneWidget);
      // Opacity should be 1.0 when active
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(1.0));
    });

    testWidgets('shows 0.38 opacity when onPressed is null (disabled)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(label: 'Book Now', onPressed: null)),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(0.38, 0.01));
    });

    testWidgets('shows CircularProgressIndicator in loading state', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(label: 'Book Now', onPressed: () {}, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Book Now'), findsNothing);
    });

    testWidgets('loading button is not tappable', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Book Now',
            onPressed: () => taps++,
            isLoading: true,
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(taps, equals(0));
    });

    testWidgets('isPill renders without error', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Pill', onPressed: () {}, isPill: true)),
      );
      expect(find.text('Pill'), findsOneWidget);
    });

    testWidgets('onPressed fires when tapped', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Tap Me', onPressed: () => taps++)),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(taps, equals(1));
    });
  });
}
