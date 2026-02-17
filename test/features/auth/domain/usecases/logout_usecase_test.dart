import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: mockAuthRepository);
  });

  test('should call logout on the repository', () async {
    // Arrange
    when(() => mockAuthRepository.logout())
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase();

    // Assert
    expect(result, const Right(true));
    verify(() => mockAuthRepository.logout()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return failure when logout fails', () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Logout session expired');
    when(() => mockAuthRepository.logout())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase();

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.logout()).called(1);
  });
}
