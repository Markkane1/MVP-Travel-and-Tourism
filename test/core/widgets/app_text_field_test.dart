import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/core/widgets/app_text_field.dart';
import 'package:mvp_travel/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('AppTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextField(labelText: 'Email')));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text inside input', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(labelText: 'Email', hintText: 'you@example.com'),
        ),
      );
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('shows errorText when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(labelText: 'Email', errorText: 'Invalid email'),
        ),
      );
      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('password field shows eye icon (suffix icon visible)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(labelText: 'Password', isPassword: true)),
      );
      // Eye icon (visibility_off = initially obscured) should be present
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets(
      'password eye icon toggles between visibility_off and visibility',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const AppTextField(labelText: 'Password', isPassword: true)),
        );
        // Initially: eye-off visible (text is obscured)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Tap the eye icon
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // After toggle: eye (visibility) visible (text is revealed)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);
      },
    );

    testWidgets('disabled field shows as disabled in decoration', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(labelText: 'Email', enabled: false)),
      );
      // Verify the widget renders without error when disabled
      expect(find.byType(TextFormField), findsOneWidget);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });
  });
}
