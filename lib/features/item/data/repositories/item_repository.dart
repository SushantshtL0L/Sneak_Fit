import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/data/datasources/remote/item_remote_datasource.dart';
import 'package:sneak_fit/features/item/data/datasources/local/item_local_datasource.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';

final itemRepositoryProvider = Provider<IItemRepository>((ref) {
  return ItemRepository(
    ref.read(itemRemoteDataSourceProvider),
    ref.read(itemLocalDatasourceProvider),
  );
});

class ItemRepository implements IItemRepository {
  final ItemRemoteDataSource _remoteDataSource;
  final ItemLocalDatasource _localDataSource;

  ItemRepository(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Exception, List<ItemEntity>>> getAllItems() async {
    try {
      // 1. Try to fetch from Remote
      final models = await _remoteDataSource.getAllItems();
      
      // 2. Save items to Hive for offline use
      final hiveModels = models.map((m) => m.toHiveModel()).toList();
      
      // Clear old cached items to keep in sync with backend
      await _localDataSource.deleteAllItems(); 
      await _localDataSource.saveAllItems(hiveModels);

      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      // 3. Fallback to Hive if Remote fails
      try {
        final hiveModels = await _localDataSource.getAllItems();
        if (hiveModels.isNotEmpty) {
          final entities = hiveModels.map((m) => m.toEntity()).toList();
          return Right(entities);
        }
        return Left(Exception("No internet connection and no cached products found."));
      } catch (localError) {
        return Left(Exception("Failed to load products: $e"));
      }
    }
  }

  @override
  Future<Either<Exception, List<ItemEntity>>> getLocalItems() async {
    try {
      final hiveModels = await _localDataSource.getAllItems();
      final entities = hiveModels.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(Exception("Failed to load cached items: $e"));
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
    String? size,
    String? color,
  ) async {
    try {
      final result = await _remoteDataSource.createProduct(
        name,
        description,
        condition,
        imagePath,
        price,
        brand,
        size,
        color,
      );
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, bool>> updateProduct(
    String id,
    String name,
    String description,
    String condition,
    String? imagePath,
    double price,
    String brand,
    String? size,
    String? color,
  ) async {
    try {
      final result = await _remoteDataSource.updateProduct(
        id,
        name,
        description,
        condition,
        imagePath,
        price,
        brand,
        size,
        color,
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

  @override
  Future<Either<Exception, bool>> deleteProduct(String id) async {
    try {
      final result = await _remoteDataSource.deleteProduct(id);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
