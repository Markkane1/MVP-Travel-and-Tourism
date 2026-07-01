import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_travel/app.dart';
import 'package:mvp_travel/core/routing/app_router.dart';

void main() {
  testWidgets('App boots up successfully smoke test', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(router)],
        child: const App(),
      ),
    );

    // Verify that the App widget is created
    expect(find.byType(App), findsOneWidget);
  });
}
