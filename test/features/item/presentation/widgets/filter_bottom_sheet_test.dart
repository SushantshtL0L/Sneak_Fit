import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/item/presentation/widgets/filter_bottom_sheet.dart';

class MockItemViewModel extends StateNotifier<ItemState> with Mock
    implements ItemViewModel {
  MockItemViewModel() : super(const ItemState());
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockItemViewModel mockItemViewModel;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockItemViewModel = MockItemViewModel();
    mockPrefs = MockSharedPreferences();

    // Stub SharedPreferences methods
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  testWidgets('FilterBottomSheet should display Filter title and Apply button',
      (tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemViewModelProvider.overrideWith((ref) => mockItemViewModel),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => const MaterialApp(
            home: Scaffold(body: FilterBottomSheet()),
          ),
        ),
      ),
    );

    // Wait for the bottom sheet to build
    await tester.pump();

    // Assert
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
  });
}
