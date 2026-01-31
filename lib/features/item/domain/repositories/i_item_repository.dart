import 'package:dartz/dartz.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

abstract class IItemRepository {
  Future<Either<Exception, List<ItemEntity>>> getAllItems();
  Future<Either<Exception, bool>> createProduct(String name, String description, String condition, String imagePath);
}
