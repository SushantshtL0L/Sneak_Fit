import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/core/usecase/app_usecase.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}
