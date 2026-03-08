import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/order/domain/entities/order_entity.dart';

void main() {
  group('OrderEntity', () {
    final tCreatedAt = DateTime.now();
    final tOrder = OrderEntity(
      id: 'o1',
      items: const [
        OrderItemEntity(
          product: 'p1',
          name: 'Shoe',
          price: 100.0,
          quantity: 1,
          size: '42',
          image: 'img.png',
        )
      ],
      totalAmount: 100.0,
      paymentMethod: 'cod',
      status: 'pending',
      createdAt: tCreatedAt,
    );

    test('should support value equality', () {
      final sameOrder = OrderEntity(
        id: 'o1',
        items: const [
          OrderItemEntity(
            product: 'p1',
            name: 'Shoe',
            price: 100.0,
            quantity: 1,
            size: '42',
            image: 'img.png',
          )
        ],
        totalAmount: 100.0,
        paymentMethod: 'cod',
        status: 'pending',
        createdAt: tCreatedAt,
      );

      expect(tOrder, equals(sameOrder));
    });

    test('OrderItemEntity should support value equality', () {
      const item1 = OrderItemEntity(
        product: 'p1',
        name: 'Shoe',
        price: 100.0,
        quantity: 1,
        size: '42',
        image: 'img.png',
      );
      const item2 = OrderItemEntity(
        product: 'p1',
        name: 'Shoe',
        price: 100.0,
        quantity: 1,
        size: '42',
        image: 'img.png',
      );

      expect(item1, equals(item2));
    });
  });
}
