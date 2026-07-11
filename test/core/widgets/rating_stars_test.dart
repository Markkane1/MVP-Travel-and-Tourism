import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/core/widgets/rating_stars.dart';
import 'package:mvp_travel/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('RatingStars — read-only display', () {
    testWidgets('renders 5 filled stars for rating 5.0', (tester) async {
      await tester.pumpWidget(_wrap(const RatingStars(rating: 5.0)));
      expect(find.byIcon(Icons.star), findsNWidgets(5));
    });

    testWidgets('renders 5 empty stars for rating 0.0', (tester) async {
      await tester.pumpWidget(_wrap(const RatingStars(rating: 0.0)));
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });

    testWidgets('renders half star for 2.5 rating', (tester) async {
      await tester.pumpWidget(_wrap(const RatingStars(rating: 2.5)));
      // 2 full, 1 half, 2 empty
      expect(find.byIcon(Icons.star), findsNWidgets(2));
      expect(find.byIcon(Icons.star_half), findsNWidgets(1));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('renders 3 filled and 2 empty for rating 3.0', (tester) async {
      await tester.pumpWidget(_wrap(const RatingStars(rating: 3.0)));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });
  });

  group('RatingStars — interactive input', () {
    testWidgets('fires onRatingChanged with correct value on tap', (
      tester,
    ) async {
      double? selectedRating;
      await tester.pumpWidget(
        _wrap(
          RatingStars(
            rating: 0.0,
            onRatingChanged: (val) => selectedRating = val,
          ),
        ),
      );

      // Stars are GestureDetectors; tap the 4th star (index 3, value 4)
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gestureDetectors.length, equals(5));

      await tester.tap(find.byType(GestureDetector).at(3)); // 4th star
      await tester.pump();

      expect(selectedRating, equals(4.0));
    });

    testWidgets('tapping 1st star gives rating 1.0', (tester) async {
      double? selectedRating;
      await tester.pumpWidget(
        _wrap(
          RatingStars(
            rating: 3.0,
            onRatingChanged: (val) => selectedRating = val,
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(selectedRating, equals(1.0));
    });

    testWidgets('tapping 5th star gives rating 5.0', (tester) async {
      double? selectedRating;
      await tester.pumpWidget(
        _wrap(
          RatingStars(
            rating: 0.0,
            onRatingChanged: (val) => selectedRating = val,
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();

      expect(selectedRating, equals(5.0));
    });
  });
}
