// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    // Note: The default app templated header/text might not be present, so checking for MyApp existence is better if specific text isn't there.
    // But the standard template has a counter.
    // However, the provided main.dart is a Driving School App, NOT the counter app.
    // So the standard counter test will FAIL.
    // I should replace it with a basic smoke test that checks if MyApp builds.
    
    expect(find.byType(MyApp), findsOneWidget);
  });
}
