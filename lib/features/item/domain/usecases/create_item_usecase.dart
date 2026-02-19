import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/data/repositories/item_repository.dart';

final createItemUsecaseProvider = Provider<CreateItemUsecase>((ref) {
  return CreateItemUsecase(ref.read(itemRepositoryProvider));
});

class CreateItemUsecase {
  final IItemRepository _repository;

  CreateItemUsecase(this._repository);

  Future<Either<Exception, bool>> call({
    required String name,
    required String description,
    required String condition,
    required String imagePath,
    required double price,
    required String brand,
    String? size,
    String? color,
  }) async {
    return await _repository.createProduct(
      name,
      description,
      condition,
      imagePath,
      price,
      brand,
      size,
      color,
    );
  }
}
