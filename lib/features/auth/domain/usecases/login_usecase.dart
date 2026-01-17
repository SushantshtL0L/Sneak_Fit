import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/core/usecase/app_usecase.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;
  LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

//provider for login usecase
final LoginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginUsecase
    implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}