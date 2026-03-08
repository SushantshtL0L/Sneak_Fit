import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  group('CartItemEntity', () {
    const tCartItem = CartItemEntity(
      id: '1',
      name: 'Item 1',
      price: 100.0,
      image: 'image.png',
      brand: 'Brand A',
      quantity: 2,
      size: '42',
      color: 'Black',
      description: 'Desc',
    );

    test('should support value equality', () {
      const sameItem = CartItemEntity(
        id: '1',
        name: 'Item 1',
        price: 100.0,
        image: 'image.png',
        brand: 'Brand A',
        quantity: 2,
        size: '42',
        color: 'Black',
        description: 'Desc',
      );

      expect(tCartItem, equals(sameItem));
    });

    test('copyWith should return updated object', () {
      final updatedItem = tCartItem.copyWith(quantity: 5);

      expect(updatedItem.quantity, 5);
      expect(updatedItem.id, tCartItem.id);
      expect(updatedItem.name, tCartItem.name);
    });
  });
}
