import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/screens/dashboard_screen.dart';
import 'package:sneak_fit/screens/home_screen.dart';
import 'package:sneak_fit/screens/cart_screen.dart';
import 'package:sneak_fit/screens/orders_screen.dart';
import 'package:sneak_fit/screens/profile_screen.dart';

// Mocks
class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel() : super(const AuthState());
}

class MockItemViewModel extends StateNotifier<ItemState> with Mock implements ItemViewModel {
  MockItemViewModel() : super(const ItemState());
}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockItemViewModel mockItemViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockItemViewModel = MockItemViewModel();

    // Default states
    mockAuthViewModel.state = const AuthState(
      authEntity: AuthEntity(
        userId: '1',
        name: 'Test User',
        email: 'test@example.com',
        userName: 'testuser',
      ),
    );
    mockItemViewModel.state = const ItemState();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => mockAuthViewModel),
        itemViewModelProvider.overrideWith((ref) => mockItemViewModel),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  testWidgets('DashboardScreen should display AppBar with title "SneakFit"', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text("SneakFit"), findsOneWidget);
  });

  testWidgets('DashboardScreen should start with HomeScreen as the default page', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('DashboardScreen should navigate to CartScreen when Cart icon is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap on Cart nav item
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);
  });

  testWidgets('DashboardScreen should navigate to OrdersScreen when Orders icon is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap on Orders nav item
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.byType(OrdersScreen), findsOneWidget);
  });

  testWidgets('DashboardScreen should navigate to ProfileScreen when Profile icon is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap on Profile nav item
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('DashboardScreen should have a FloatingActionButton', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
