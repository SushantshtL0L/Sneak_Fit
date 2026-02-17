import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  return ForgotPasswordUsecase(ref.read(authRepositoryProvider));
});

class ForgotPasswordUsecase {
  final IAuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  Future<Either<Failure, bool>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}
