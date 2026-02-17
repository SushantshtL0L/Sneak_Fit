import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/data/datasources/remote/item_remote_datasource.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';

final itemRepositoryProvider = Provider<IItemRepository>((ref) {
  return ItemRepository(ref.read(itemRemoteDataSourceProvider));
});

class ItemRepository implements IItemRepository {
  final ItemRemoteDataSource _remoteDataSource;

  ItemRepository(this._remoteDataSource);

  @override
  Future<Either<Exception, List<ItemEntity>>> getAllItems() async {
    try {
      final models = await _remoteDataSource.getAllItems();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, bool>> createProduct(
    String name,
    String description,
    String condition,
    String imagePath,
    double price,
    String brand,
  ) async {
    try {
      final result = await _remoteDataSource.createProduct(
        name,
        description,
        condition,
        imagePath,
        price,
        brand,
      );
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, ItemEntity?>> getItemById(String id) async {
    try {
      final model = await _remoteDataSource.getItemById(id);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
