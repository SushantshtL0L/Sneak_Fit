import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        role: response.role,
      );

      return Right(
        AuthEntity(
          userId: response.userId,
          email: response.email,
          userName: response.userName,
          role: response.role,
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
          role: userSession.role,
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

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(
      String name, String? imagePath) async {
    try {
      final userModel = await remote.updateProfile(name, imagePath);

      if (userModel == null) {
        return const Left(ApiFailure(message: 'Profile update failed'));
      }

      await sessionService.saveUserSession(
        userId: userModel.userId ?? '',
        email: userModel.email,
        username: userModel.userName ?? '',
        profilePicture: userModel.profileImage,
        role: userModel.role,
      );

      return Right(
        AuthEntity(
          userId: userModel.userId,
          email: userModel.email,
          userName: userModel.userName,
          name: userModel.name,
          profileImage: userModel.profileImage,
          role: userModel.role,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: 'Profile update failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getUserProfile() async {
    try {
      final userModel = await remote.getMe();

      if (userModel == null) {
        return const Left(ApiFailure(message: 'Failed to fetch user profile'));
      }

      await sessionService.saveUserSession(
        userId: userModel.userId ?? '',
        email: userModel.email,
        username: userModel.userName ?? '',
        profilePicture: userModel.profileImage,
        role: userModel.role,
      );

      return Right(
        AuthEntity(
          userId: userModel.userId,
          email: userModel.email,
          userName: userModel.userName,
          name: userModel.name,
          profileImage: userModel.profileImage,
          role: userModel.role,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: 'Failed to fetch user profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    try {
      final success = await remote.forgotPassword(email);
      if (success) {
        return const Right(true);
      } else {
        return const Left(ApiFailure(message: 'Failed to send reset email'));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String token, String newPassword) async {
    try {
      final success = await remote.resetPassword(token, newPassword);
      if (success) {
        return const Right(true);
      } else {
        return const Left(ApiFailure(message: 'Failed to reset password'));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}