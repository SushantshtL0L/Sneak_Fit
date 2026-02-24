import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';

final changePasswordUsecaseProvider = Provider<ChangePasswordUsecase>((ref) {
  return ChangePasswordUsecase(ref.read(authRepositoryProvider));
});

class ChangePasswordUsecase {
  final IAuthRepository repository;

  ChangePasswordUsecase(this.repository);

  Future<Either<Failure, bool>> call(String oldPassword, String newPassword) async {
    return await repository.changePassword(oldPassword, newPassword);
  }
}
