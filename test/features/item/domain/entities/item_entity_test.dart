import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

void main() {
  group('ItemEntity', () {
    final tCreatedAt = DateTime.now();
    final tItemEntity = ItemEntity(
      itemId: 'it-123',
      itemName: 'Nike Air Max',
      condition: ItemCondition.newCondition,
      price: 120.0,
      description: 'Classic sneakers',
      media: 'path/to/img.jpg',
      mediaType: 'image',
      status: 'available',
      createdAt: tCreatedAt,
      brand: 'Nike',
      size: '10',
    );

    test('should hold correct values and support value equality', () {
      final tItemEntityDuplicate = ItemEntity(
        itemId: 'it-123',
        itemName: 'Nike Air Max',
        condition: ItemCondition.newCondition,
        price: 120.0,
        description: 'Classic sneakers',
        media: 'path/to/img.jpg',
        mediaType: 'image',
        status: 'available',
        createdAt: tCreatedAt,
        brand: 'Nike',
        size: '10',
      );

      expect(tItemEntity, equals(tItemEntityDuplicate));
    });

    test('should detect inequality when fields differ', () {
      final tDifferentEntity = ItemEntity(
        itemId: 'it-456',
        itemName: 'Adidas Boost',
        condition: ItemCondition.thrift,
        price: 90.0,
      );

      expect(tItemEntity == tDifferentEntity, isFalse);
    });
  });
}
