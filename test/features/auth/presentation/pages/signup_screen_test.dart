import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/auth/presentation/pages/signup_screen.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_button.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';

class MockAuthViewModel extends StateNotifier<AuthState>
    with Mock
    implements AuthViewModel {
  MockAuthViewModel() : super(const AuthState());
}

void main() {
  late MockAuthViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockAuthViewModel();
  });

  // Helper: build widget with large screen to prevent off-screen tap issues
  Future<void> pumpSignupScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith((ref) => mockViewModel),
        ],
        child: MaterialApp(
          home: const SignupScreen(),
          routes: {
            '/login': (_) => const Scaffold(body: Text('Login')),
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('SignupScreen should display all registration fields and sign up button',
      (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    expect(find.text("Create Your Account"), findsOneWidget);
    expect(find.byType(MyTextField), findsNWidgets(4));
    expect(find.byType(MyButton), findsOneWidget);
    expect(find.text("Sign Up"), findsOneWidget);
  });

  testWidgets('SignupScreen should show error snackbar when fields are empty',
      (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    await tester.ensureVisible(find.text("Sign Up"));
    await tester.tap(find.text("Sign Up"), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text("Please fill all fields"), findsOneWidget);
  });

  testWidgets('SignupScreen should show error snackbar when passwords do not match',
      (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    // Enter text into the 4 fields by index
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(3), 'password456');
    await tester.pump();

    await tester.ensureVisible(find.text("Sign Up"));
    await tester.tap(find.text("Sign Up"), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text("Passwords do not match"), findsOneWidget);
  });
}