import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/app.dart';

void main() {
  testWidgets('App boots up successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the App widget is created
    expect(find.byType(App), findsOneWidget);
  });
}
