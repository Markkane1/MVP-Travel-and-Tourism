import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/core/widgets/app_card.dart';
import 'package:mvp_travel/core/theme/app_colors.dart';
import 'package:mvp_travel/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('AppCard', () {
    testWidgets('renders its child widget', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppCard(child: Text('Card content'))),
      );
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('applies default white background', (tester) async {
      await tester.pumpWidget(_wrap(const AppCard(child: SizedBox())));
      final material = tester.widget<Material>(find.descendant(of: find.byType(AppCard), matching: find.byType(Material)).first);
      expect(material.color, equals(AppColors.surfaceContainerLowest));
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCard(backgroundColor: Colors.blueGrey, child: SizedBox()),
        ),
      );
      final material = tester.widget<Material>(find.descendant(of: find.byType(AppCard), matching: find.byType(Material)).first);
      expect(material.color, equals(Colors.blueGrey));
    });

    testWidgets('applies custom border radius', (tester) async {
      const customRadius = BorderRadius.all(Radius.circular(32.0));
      await tester.pumpWidget(
        _wrap(const AppCard(borderRadius: customRadius, child: SizedBox())),
      );
      final material = tester.widget<Material>(find.descendant(of: find.byType(AppCard), matching: find.byType(Material)).first);
      expect(material.borderRadius, equals(customRadius));
    });

    testWidgets('clips child to its border radius', (tester) async {
      await tester.pumpWidget(_wrap(const AppCard(child: Text('Clipped'))));
      final material = tester.widget<Material>(find.descendant(of: find.byType(AppCard), matching: find.byType(Material)).first);
      expect(material.clipBehavior, equals(Clip.antiAlias));
    });
  });
}
