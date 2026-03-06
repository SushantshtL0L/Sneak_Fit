import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/domain/usecases/delete_item_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late DeleteItemUsecase usecase;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    usecase = DeleteItemUsecase(mockItemRepository);
  });

  const tId = 'item-123';

  test('should call deleteProduct on the repository', () async {
    // Arrange
    when(() => mockItemRepository.deleteProduct(any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(tId);

    // Assert
    expect(result, const Right(true));
    verify(() => mockItemRepository.deleteProduct(tId)).called(1);
    verifyNoMoreInteractions(mockItemRepository);
  });

  test('should return Exception when deletion fails', () async {
    // Arrange
    final tException = Exception('Deletion Failed');
    when(() => mockItemRepository.deleteProduct(any()))
        .thenAnswer((_) async => Left(tException));

    // Act
    final result = await usecase(tId);

    // Assert
    expect(result, Left(tException));
  });
}
