import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/data/datasources/remote/auth_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/auth_hive_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final datasource = ref.watch(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: datasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;
  AuthRepository({required IAuthDatasource authDatasource}) : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDatasource.getCurrentUser();
      if (model != null) return Right(model.toEntity());
      return Left(LocalDatabaseFailure(message: "User not found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final model = await _authDatasource.login(email, password);
      if (model != null) return Right(model.toEntity());
      return Left(LocalDatabaseFailure(message: "Login failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) return Right(true);
      return Left(LocalDatabaseFailure(message: "Logout failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) return Right(true);
      return Left(LocalDatabaseFailure(message: "Registration failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
