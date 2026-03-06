import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/domain/usecases/create_item_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late CreateItemUsecase usecase;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    usecase = CreateItemUsecase(mockItemRepository);
  });

  const tName = 'Jordan 1';
  const tDescription = 'A legendary sneaker';
  const tCondition = 'New';
  const tImagePath = 'jordan.jpg';
  const tPrice = 190.0;
  const tBrand = 'Nike';

  test('should call createProduct on the repository', () async {
    // Arrange
    when(() => mockItemRepository.createProduct(
          any(), any(), any(), any(), any(), any(), any(), any(),
        )).thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(
      name: tName,
      description: tDescription,
      condition: tCondition,
      imagePath: tImagePath,
      price: tPrice,
      brand: tBrand,
    );

    // Assert
    expect(result, const Right(true));
    verify(() => mockItemRepository.createProduct(
          tName, tDescription, tCondition, tImagePath, tPrice, tBrand, null, null,
        )).called(1);
  });

  test('should return Exception when creation fails', () async {
    // Arrange
    final tException = Exception('Failed to create product');
    when(() => mockItemRepository.createProduct(
          any(), any(), any(), any(), any(), any(), any(), any(),
        )).thenAnswer((_) async => Left(tException));

    // Act
    final result = await usecase(
      name: tName,
      description: tDescription,
      condition: tCondition,
      imagePath: tImagePath,
      price: tPrice,
      brand: tBrand,
    );

    // Assert
    expect(result, Left(tException));
  });
}
