import 'package:dartz/dartz.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

abstract class IItemRepository {
  Future<Either<Exception, List<ItemEntity>>> getAllItems();
  Future<Either<Exception, bool>> createProduct(
    String name,
    String description,
    String condition,
    String imagePath,
    double price,
    String brand,
    String? size,
    String? color,
  );
  Future<Either<Exception, ItemEntity?>> getItemById(String id);
  Future<Either<Exception, bool>> deleteProduct(String id);
}
