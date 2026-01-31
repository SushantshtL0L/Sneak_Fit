import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/data/repositories/item_repository.dart';

final getAllItemsUsecaseProvider = Provider<GetAllItemsUsecase>((ref) {
  return GetAllItemsUsecase(ref.read(itemRepositoryProvider));
});

class GetAllItemsUsecase {
  final IItemRepository _repository;

  GetAllItemsUsecase(this._repository);

  Future<Either<Exception, List<ItemEntity>>> call() async {
    return await _repository.getAllItems();
  }
}
