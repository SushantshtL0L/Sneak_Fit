import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';

class MockRef extends Mock implements Ref {}
class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late WishlistViewModel viewModel;
  late MockRef mockRef;

  setUp(() async {
    mockRef = MockRef();
    SharedPreferences.setMockInitialValues({});

    // Mock auth state
    when(() => mockRef.read(authViewModelProvider)).thenReturn(
      const AuthState(authEntity: AuthEntity(userId: 'test_user', email: 'test@test.com', name: 'test')),
    );

    viewModel = WishlistViewModel(mockRef);
  });

  final tItem = ItemEntity(
    itemId: '1',
    itemName: 'Test Sneaker',
    price: 99.99,
    condition: ItemCondition.newCondition,
  );

  group('WishlistViewModel', () {
    test('initial state should be empty', () {
      expect(viewModel.state.items, isEmpty);
    });

    test('toggleWishlist should add item if it does not exist', () async {
      // Act
      viewModel.toggleWishlist(tItem);

      // Assert
      expect(viewModel.state.items, contains(tItem));
      expect(viewModel.isInWishlist('1'), isTrue);
    });

    test('toggleWishlist should remove item if it exists', () {
      // Arrange
      viewModel.toggleWishlist(tItem);
      expect(viewModel.state.items, contains(tItem));

      // Act
      viewModel.toggleWishlist(tItem);

      // Assert
      expect(viewModel.state.items, isEmpty);
      expect(viewModel.isInWishlist('1'), isFalse);
    });
  });
}
