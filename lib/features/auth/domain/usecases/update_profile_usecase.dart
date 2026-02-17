import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/core/usecase/app_usecase.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/data/repositories/auth_repository_impl.dart';

class UpdateProfileParams extends Equatable {
  final String name;
  final String? imagePath;

  const UpdateProfileParams({required this.name, this.imagePath});

  @override
  List<Object?> get props => [name, imagePath];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, UpdateProfileParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return _authRepository.updateProfile(params.name, params.imagePath);
  }
}
