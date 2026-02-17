import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_button.dart';

void main() {
  testWidgets('MyButton should display the correct text', (WidgetTester tester) async {
    const buttonText = 'Click Me';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: buttonText,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text(buttonText), findsOneWidget);
  });

  testWidgets('MyButton should call onPressed when tapped', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Tap Me',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isTrue);
  });

  testWidgets('MyButton should show CircularProgressIndicator when isLoading is true', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Loading...',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsNothing);
  });
}