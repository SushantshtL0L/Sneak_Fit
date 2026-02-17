import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';

final getUserProfileUsecaseProvider = Provider<GetUserProfileUsecase>((ref) {
  return GetUserProfileUsecase(ref.read(authRepositoryProvider));
});

class GetUserProfileUsecase {
  final IAuthRepository _repository;

  GetUserProfileUsecase(this._repository);

  Future<Either<Failure, AuthEntity>> call() async {
    return await _repository.getUserProfile();
  }
}
