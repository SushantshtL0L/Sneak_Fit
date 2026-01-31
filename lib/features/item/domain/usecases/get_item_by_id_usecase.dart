import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/data/repositories/item_repository.dart';

final getItemByIdUsecaseProvider = Provider<GetItemByIdUsecase>((ref) {
  return GetItemByIdUsecase(ref.read(itemRepositoryProvider));
});

class GetItemByIdUsecase {
  final IItemRepository _repository;

  GetItemByIdUsecase(this._repository);

  Future<Either<Exception, ItemEntity?>> call(String id) async {
    // Note: IItemRepository needs to be updated if you want to use this
    // For now, it only has getAllItems and createProduct
    return Left(Exception("Not implemented in Repository yet"));
  }
}
