import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/core/usecase/app_usecase.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';

/// Params for Register Usecase
class RegisterUsecaseParams extends Equatable {
  final String name;
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String? profileImage;
  final String? role;

  const RegisterUsecaseParams({
    required this.name,
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    this.profileImage,
    this.role,
  });

  @override
  List<Object?> get props => [
        name,
        userName,
        email,
        password,
        confirmPassword,
        phoneNumber,
        profileImage,
        role,
      ];
}

/// Riverpod provider for RegisterUsecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

/// Register Usecase implementation
class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  const RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    // Map params to AuthEntity
    final authEntity = AuthEntity(
      name: params.name,
      userName: params.userName,
      email: params.email,
      password: params.password,
      profileImage: params.profileImage,
      role: params.role,
    );

    // Call repository
    return _authRepository.register(authEntity);
  }
}
