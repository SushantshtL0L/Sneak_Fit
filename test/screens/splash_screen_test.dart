import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/screens/splash_screen.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  testWidgets('SplashScreen should display logo and progress indicator', (tester) async {
    // Arrange
    final mockSessionService = MockUserSessionService();
    when(() => mockSessionService.isLoggedIn()).thenReturn(false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(mockSessionService),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      ),
    );

    // Assert
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
