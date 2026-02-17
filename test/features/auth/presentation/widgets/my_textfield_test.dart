import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';

void main() {
  testWidgets('MyTextField should display the hint text', (WidgetTester tester) async {
    final controller = TextEditingController();
    const hint = 'Enter your name';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextField(
            hint: hint,
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.text(hint), findsOneWidget);
  });

  testWidgets('MyTextField should update controller when text is entered', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextField(
            hint: 'Hint',
            controller: controller,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Hello World');
    expect(controller.text, 'Hello World');
  });

  testWidgets('MyTextField should obscure text when isPassword is true', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextField(
            hint: 'Password',
            controller: controller,
            isPassword: true,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, isTrue);
  });
}