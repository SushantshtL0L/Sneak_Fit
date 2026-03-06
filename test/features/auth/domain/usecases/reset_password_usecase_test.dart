import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/domain/usecases/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ResetPasswordUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = ResetPasswordUsecase(mockAuthRepository);
  });

  const tToken = 'reset_token';
  const tNewPassword = 'new_password123';

  test('should call resetPassword on the repository', () async {
    // Arrange
    when(() => mockAuthRepository.resetPassword(any(), any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(tToken, tNewPassword);

    // Assert
    expect(result, const Right(true));
    verify(() => mockAuthRepository.resetPassword(tToken, tNewPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when reset fails', () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Token expired');
    when(() => mockAuthRepository.resetPassword(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tToken, tNewPassword);

    // Assert
    expect(result, const Left(tFailure));
  });
}
