import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/screens/home_screen.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockItemViewModel extends StateNotifier<ItemState> with Mock implements ItemViewModel {
  MockItemViewModel() : super(const ItemState());
}

class MockThemeViewModel extends StateNotifier<ThemeState> with Mock implements ThemeViewModel {
  MockThemeViewModel() : super(ThemeState(isDarkMode: false));
}

void main() {
  testWidgets('HomeScreen should display search bar and popular brands title', (tester) async {
    // Arrange
    final mockItemViewModel = MockItemViewModel();
    final mockThemeViewModel = MockThemeViewModel();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemViewModelProvider.overrideWith((ref) => mockItemViewModel),
          themeViewModelProvider.overrideWith((ref) => mockThemeViewModel),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => const MaterialApp(
            home: Scaffold(body: HomeScreen()),
          ),
        ),
      ),
    );

    // Assert
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Popular Brands'), findsOneWidget);
    expect(find.text('Search your kicks...'), findsOneWidget);

    // Clean up timers by disposing the widget
    await tester.pumpWidget(Container());
  });
}
