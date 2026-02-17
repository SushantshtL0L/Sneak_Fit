import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/domain/usecases/get_all_items_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late GetAllItemsUsecase usecase;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    usecase = GetAllItemsUsecase(mockItemRepository);
  });

  final tItems = [
    const ItemEntity(
      itemId: '1',
      itemName: 'Nike Air Max',
      condition: ItemCondition.newCondition,
      price: 15000.0,
      description: 'Classic comfort',
      media: 'nike.jpg',
      status: 'available',
    ),
  ];

  test('should return list of items from repository', () async {
    // Arrange
    when(() => mockItemRepository.getAllItems())
        .thenAnswer((_) async => Right(tItems));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Right(tItems));
    verify(() => mockItemRepository.getAllItems()).called(1);
    verifyNoMoreInteractions(mockItemRepository);
  });

  test('should return exception when repository fails', () async {
    // Arrange
    final tException = Exception('Failed to fetch items');
    when(() => mockItemRepository.getAllItems())
        .thenAnswer((_) async => Left(tException));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Left(tException));
    verify(() => mockItemRepository.getAllItems()).called(1);
    verifyNoMoreInteractions(mockItemRepository);
  });
}
