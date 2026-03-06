import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/domain/usecases/get_item_by_id_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late GetItemByIdUsecase usecase;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    usecase = GetItemByIdUsecase(mockItemRepository);
  });

  const tId = '1';
  const tItem = ItemEntity(
    itemId: '1',
    itemName: 'Sneaker',
    condition: ItemCondition.newCondition,
    price: 100,
  );

  test('should return ItemEntity when repository call is successful', () async {
    // Arrange
    when(() => mockItemRepository.getItemById(any()))
        .thenAnswer((_) async => const Right(tItem));

    // Act
    final result = await usecase(tId);

    // Assert
    expect(result, const Right(tItem));
    verify(() => mockItemRepository.getItemById(tId)).called(1);
    verifyNoMoreInteractions(mockItemRepository);
  });

  test('should return Exception when call fails', () async {
    // Arrange
    final tException = Exception('Item not found');
    when(() => mockItemRepository.getItemById(any()))
        .thenAnswer((_) async => Left(tException));

    // Act
    final result = await usecase(tId);

    // Assert
    expect(result, Left(tException));
  });
}
