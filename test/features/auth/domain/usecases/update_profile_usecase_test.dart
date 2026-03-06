import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/domain/usecases/update_profile_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UpdateProfileUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UpdateProfileUsecase(authRepository: mockAuthRepository);
  });

  const tParams = UpdateProfileParams(name: 'Updated Name', imagePath: 'new_image.jpg');
  const tAuthEntity = AuthEntity(email: 'test@example.com', name: 'Updated Name');

  test('should call updateProfile on the repository', () async {
    // Arrange
    when(() => mockAuthRepository.updateProfile(any(), any()))
        .thenAnswer((_) async => const Right(tAuthEntity));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Right(tAuthEntity));
    verify(() => mockAuthRepository.updateProfile(tParams.name, tParams.imagePath)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when update fails', () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Update Failed');
    when(() => mockAuthRepository.updateProfile(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });
}
