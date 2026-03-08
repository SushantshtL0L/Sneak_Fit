import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/screens/all_products_screen.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockItemViewModel extends StateNotifier<ItemState> with Mock implements ItemViewModel {
  MockItemViewModel() : super(const ItemState());
}

class MockThemeViewModel extends StateNotifier<ThemeState> with Mock implements ThemeViewModel {
  MockThemeViewModel() : super(ThemeState(isDarkMode: false));
}

void main() {
  testWidgets('AllProductsScreen should display items list when items are available', (tester) async {
    // Arrange
    final mockItemViewModel = MockItemViewModel();
    final mockThemeViewModel = MockThemeViewModel();
    
    final tItem = ItemEntity(
      itemId: '1',
      itemName: 'Test Sneaker',
      price: 100.0,
      condition: ItemCondition.newCondition,
    );

    mockItemViewModel.state = ItemState(
      status: ItemStatus.loaded,
      items: [tItem],
      filteredItems: [tItem],
    );

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
            home: AllProductsScreen(),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('All Products'), findsOneWidget);
    expect(find.text('Test Sneaker'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
