import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/auth/presentation/pages/signup_screen.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_button.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';

// Create a Mock for AuthViewModel
class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel() : super(const AuthState());
}

void main() {
  late MockAuthViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockAuthViewModel();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => mockViewModel),
      ],
      child: const MaterialApp(
        home: SignupScreen(),
      ),
    );
  }

  testWidgets('SignupScreen should display all registration fields and sign up button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify Title
    expect(find.text("Create Your Account"), findsOneWidget);

    // Verify TextFields (Name, Email, Password, Confirm Password)
    expect(find.byType(MyTextField), findsNWidgets(4));
    expect(find.widgetWithText(MyTextField, "Full Name"), findsOneWidget);
    expect(find.widgetWithText(MyTextField, "Email"), findsOneWidget);
    expect(find.widgetWithText(MyTextField, "Password"), findsOneWidget);
    expect(find.widgetWithText(MyTextField, "Confirm Password"), findsOneWidget);

    // Verify Sign Up Button
    expect(find.byType(MyButton), findsOneWidget);
    expect(find.text("Sign Up"), findsOneWidget);
  });

  testWidgets('SignupScreen should show error snackbar when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap sign up button without entering anything
    await tester.tap(find.text("Sign Up"));
    await tester.pump();

    // Verify SnackBar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Please fill all fields"), findsOneWidget);
  });

  testWidgets('SignupScreen should show error snackbar when passwords do not match', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter details with mismatching passwords
    await tester.enterText(find.widgetWithText(MyTextField, "Full Name"), "John Doe");
    await tester.enterText(find.widgetWithText(MyTextField, "Email"), "john@example.com");
    await tester.enterText(find.widgetWithText(MyTextField, "Password"), "password123");
    await tester.enterText(find.widgetWithText(MyTextField, "Confirm Password"), "password456");

    // Tap sign up button
    await tester.tap(find.text("Sign Up"));
    await tester.pump();

    // Verify SnackBar
    expect(find.text("Passwords do not match"), findsOneWidget);
  });
}