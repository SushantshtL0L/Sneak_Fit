import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/auth/presentation/pages/login_screen.dart';
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
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen should display logo, title, and input fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify Title
    expect(find.text("Login to Your Account"), findsOneWidget);

    // Verify TextFields (Email and Password)
    expect(find.byType(MyTextField), findsNWidgets(2));
    expect(find.widgetWithText(MyTextField, "Email"), findsOneWidget);
    expect(find.widgetWithText(MyTextField, "Password"), findsOneWidget);

    // Verify Login Button
    expect(find.byType(MyButton), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);
  });

  testWidgets('LoginScreen should show error snackbar when fields are empty and login is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap login button without entering anything
    await tester.tap(find.text("Login"));
    await tester.pump();

    // Verify Snackback
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Please fill all fields"), findsOneWidget);
  });

  testWidgets('LoginScreen should show loading indicator on button when state is loading', (WidgetTester tester) async {
    // Set state to loading
    mockViewModel.state = const AuthState(status: AuthStatus.loading);

    await tester.pumpWidget(createWidgetUnderTest());

    // MyButton shows CircularProgressIndicator when isLoading is true
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}