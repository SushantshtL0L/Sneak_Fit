import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/item/data/models/item_api_model.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

void main() {
  group('ItemApiModel', () {
    final tItemApiModel = ItemApiModel(
      id: '1',
      name: 'Nike Air Max',
      condition: 'new',
      price: 15000.0,
      description: 'Classic comfort',
      image: 'nike.jpg',
      status: 'available',
      createdAt: DateTime.parse('2024-01-31T00:00:00Z'),
    );

    final tJson = {
      '_id': '1',
      'name': 'Nike Air Max',
      'condition': 'new',
      'price': 15000.0,
      'description': 'Classic comfort',
      'image': 'nike.jpg',
      'status': 'available',
      'createdAt': '2024-01-31T00:00:00.000Z',
    };

    test('fromJson should return a valid model', () {
      // Act
      final result = ItemApiModel.fromJson(tJson);

      // Assert
      expect(result.id, tItemApiModel.id);
      expect(result.name, tItemApiModel.name);
      expect(result.price, tItemApiModel.price);
    });

    test('toJson should return a JSON map containing proper data', () {
      // Act
      final result = tItemApiModel.toJson();

      // Assert
      final expectedJson = {
        'name': 'Nike Air Max',
        'condition': 'new',
        'price': 15000.0,
        'description': 'Classic comfort',
        'image': 'nike.jpg',
        'status': 'available',
      };
      expect(result, expectedJson);
    });

    test('toEntity should convert model to entity correctly', () {
      // Act
      final result = tItemApiModel.toEntity();

      // Assert
      expect(result, isA<ItemEntity>());
      expect(result.itemId, tItemApiModel.id);
      expect(result.itemName, tItemApiModel.name);
      expect(result.condition, ItemCondition.newCondition);
    });
  });
}
