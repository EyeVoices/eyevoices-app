// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:eyevoices_app/main.dart';

void main() {
  testWidgets('EyeVoices app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EyeVoicesApp(cameras: []));

    // Verify that our app title is present.
    expect(find.text('EyeVoices'), findsOneWidget);
    
    // Verify that sentences are displayed
    expect(find.text('Hello, how are you today?'), findsOneWidget);
  });
}
