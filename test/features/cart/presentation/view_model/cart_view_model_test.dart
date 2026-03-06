import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/cart/domain/entities/cart_item_entity.dart';
import 'package:sneak_fit/features/cart/presentation/view_model/cart_view_model.dart';

class MockRef extends Mock implements Ref {}

void main() {
  late CartViewModel cartViewModel;
  late MockRef mockRef;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockRef = MockRef();

    // Mock ref.read(authViewModelProvider)
    when(() => mockRef.read(authViewModelProvider)).thenReturn(
      const AuthState(
        authEntity: AuthEntity(userId: 'user-123', email: 'test@test.com'),
      ),
    );

    cartViewModel = CartViewModel(mockRef);
  });

  final tCartItem = const CartItemEntity(
    id: 'prod-1',
    name: 'Sneaker',
    price: 100.0,
    image: 'img.jpg',
    brand: 'Nike',
    quantity: 1,
    size: '10',
    color: 'Red',
    description: 'Nice',
  );

  group('addToCart', () {
    test('should add a new item to the cart', () {
      // Act
      cartViewModel.addToCart(tCartItem);

      // Assert
      expect(cartViewModel.state.cartItems.length, 1);
      expect(cartViewModel.state.cartItems.first, tCartItem);
    });

    test('should update quantity if item with same id and size exists', () {
      // Act
      cartViewModel.addToCart(tCartItem);
      cartViewModel.addToCart(tCartItem.copyWith(quantity: 2));

      // Assert
      expect(cartViewModel.state.cartItems.length, 1);
      expect(cartViewModel.state.cartItems.first.quantity, 3);
    });
  });

  group('removeFromCart', () {
    test('should remove item from cart', () {
      // Arrange
      cartViewModel.addToCart(tCartItem);

      // Act
      cartViewModel.removeFromCart(tCartItem.id, tCartItem.size);

      // Assert
      expect(cartViewModel.state.cartItems.isEmpty, true);
    });
  });

  group('CartState Calculations', () {
    test('totalPrice should calculate correctly', () {
      // Arrange
      cartViewModel.addToCart(tCartItem); // 100 * 1
      cartViewModel.addToCart(tCartItem.copyWith(id: 'prod-2', price: 150.0)); // 150 * 1

      // Assert
      expect(cartViewModel.state.totalPrice, 250.0);
    });

    test('totalItems should calculate correctly', () {
      // Arrange
      cartViewModel.addToCart(tCartItem.copyWith(quantity: 5));
      
      // Assert
      expect(cartViewModel.state.totalItems, 5);
    });
  });

  group('clearCart', () {
    test('should remove all items', () {
      // Arrange
      cartViewModel.addToCart(tCartItem);
      
      // Act
      cartViewModel.clearCart();

      // Assert
      expect(cartViewModel.state.cartItems.isEmpty, true);
    });
  });
}
