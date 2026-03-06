import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late ItemViewModel viewModel;
  late MockItemRepository mockRepository;

  setUp(() {
    mockRepository = MockItemRepository();
    
    // getAllItems is called in constructor
    when(() => mockRepository.getAllItems())
        .thenAnswer((_) async => const Right([]));
    
    // getLocalItems is also called in constructor now
    when(() => mockRepository.getLocalItems())
        .thenAnswer((_) async => const Right([]));

    viewModel = ItemViewModel(mockRepository);
  });

  const tItem = ItemEntity(
    itemId: '1',
    itemName: 'Nike Air Max',
    brand: 'Nike',
    price: 150.0,
    size: '10',
    condition: ItemCondition.newCondition,
  );

  group('getAllItems', () {
    test('should load items into state when successful', () async {
      // Arrange
      when(() => mockRepository.getAllItems())
          .thenAnswer((_) async => const Right([tItem]));

      // Act
      await viewModel.getAllItems();

      // Assert
      expect(viewModel.state.status, ItemStatus.loaded);
      expect(viewModel.state.items, [tItem]);
      expect(viewModel.state.filteredItems, [tItem]);
    });
  });

  group('searchProducts', () {
    test('should filter items by name/brand', () async {
      // Arrange
      const adidasItem = ItemEntity(
        itemId: '2',
        itemName: 'Adidas Boost',
        brand: 'Adidas',
        price: 90.0,
        condition: ItemCondition.thrift,
      );
      final items = [tItem, adidasItem];
      viewModel.state = viewModel.state.copyWith(items: items, filteredItems: items);

      // Act
      viewModel.searchProducts('Nike');

      // Assert
      expect(viewModel.state.filteredItems.length, 1);
      expect(viewModel.state.filteredItems.first.brand, 'Nike');
    });
  });

  group('filterItems', () {
    test('should filter by brand and size', () {
       // Arrange
      const nikeSize11 = ItemEntity(
        itemId: '2',
        itemName: 'Nike Air Force',
        brand: 'Nike',
        price: 120.0,
        size: '11',
        condition: ItemCondition.newCondition,
      );
      const adidasItem = ItemEntity(
        itemId: '3',
        itemName: 'Adidas Stan Smith',
        brand: 'Adidas',
        price: 80.0,
        size: '10',
        condition: ItemCondition.thrift,
      );
      final items = [tItem, nikeSize11, adidasItem];
      viewModel.state = viewModel.state.copyWith(items: items);

      // Act
      viewModel.filterItems(brand: 'Nike', size: '10');

      // Assert
      expect(viewModel.state.filteredItems.length, 1);
      expect(viewModel.state.filteredItems.first.itemId, '1');
    });
  });
}
