import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  return ResetPasswordUsecase(ref.read(authRepositoryProvider));
});

class ResetPasswordUsecase {
  final IAuthRepository repository;

  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, bool>> call(String token, String newPassword) async {
    return await repository.resetPassword(token, newPassword);
  }
}
