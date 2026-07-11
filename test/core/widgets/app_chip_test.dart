import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/core/widgets/app_chip.dart';
import 'package:mvp_travel/core/theme/app_colors.dart';
import 'package:mvp_travel/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('AppChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(const AppChip(label: 'Beach')));
      expect(find.text('Beach'), findsOneWidget);
    });

    testWidgets('inactive chip uses surfaceContainer background', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppChip(label: 'Beach', isActive: false)),
      );
      final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(chip.backgroundColor, equals(AppColors.surfaceContainer));
    });

    testWidgets('active chip uses primary selectedColor', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChip(label: 'Beach', isActive: true)),
      );
      final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(chip.selectedColor, equals(AppColors.primary));
    });

    testWidgets('onSelected callback fires when tapped', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(
        _wrap(
          AppChip(
            label: 'Beach',
            isActive: false,
            onSelected: (val) => lastValue = val,
          ),
        ),
      );
      await tester.tap(find.byType(ChoiceChip));
      await tester.pump();
      expect(lastValue, isNotNull);
    });

    testWidgets('renders avatar when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChip(label: 'Beach', avatar: Icon(Icons.beach_access))),
      );
      expect(find.byIcon(Icons.beach_access), findsOneWidget);
    });
  });
}
