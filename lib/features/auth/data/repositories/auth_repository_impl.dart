import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';
import 'package:sneak_fit/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:sneak_fit/features/auth/data/models/auth_hive_model.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';

// Riverpod provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDatasource = ref.read(authRemoteDatasourceProvider);
  final sessionService = ref.read(userSessionServiceProvider);

  return AuthRepositoryImpl(
    remote: remoteDatasource,
    sessionService: sessionService,
  );
});

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource remote;
  final UserSessionService sessionService;

  AuthRepositoryImpl({
    required this.remote,
    required this.sessionService,
  });

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final response = await remote.login(email, password);

      if (response == null) {
        return const Left(ApiFailure(message: 'Login failed: Invalid credentials'));
      }

      await sessionService.saveUserSession(
        userId: response.userId,
        email: response.email,
        username: response.userName ?? '',
      );

      return Right(
        AuthEntity(
          userId: response.userId,
          email: response.email,
          userName: response.userName,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: 'Login failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) async {
    try {
      final result = await remote.register(
        AuthHiveModel.fromEntity(authEntity),
      );

      if (result) {
        return const Right(true);
      } else {
        return const Left(ApiFailure(message: 'Registration failed'));
      }
    } catch (e) {
      return Left(
        ApiFailure(message: 'Registration failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final userSession = await sessionService.getUserSession();
      if (userSession == null) {
        return Left(
          ApiFailure(message: 'No user session found'),
        );
      }

      return Right(
        AuthEntity(
          userId: userSession.userId,
          email: userSession.email,
          userName: userSession.username,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: 'Failed to get current user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await sessionService.clearUserSession();
      return const Right(true);
    } catch (e) {
      return Left(
        ApiFailure(message: 'Logout failed: ${e.toString()}'),
      );
    }
  }
}