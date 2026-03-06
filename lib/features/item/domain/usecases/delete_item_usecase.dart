import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/data/repositories/item_repository.dart';

final deleteItemUsecaseProvider = Provider<DeleteItemUsecase>((ref) {
  return DeleteItemUsecase(ref.read(itemRepositoryProvider));
});

class DeleteItemUsecase {
  final IItemRepository _repository;

  DeleteItemUsecase(this._repository);

  Future<Either<Exception, bool>> call(String id) async {
    return await _repository.deleteProduct(id);
  }
}
