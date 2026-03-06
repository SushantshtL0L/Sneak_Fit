import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/domain/usecases/forgot_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ForgotPasswordUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = ForgotPasswordUsecase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';

  test('should call forgotPassword on the repository', () async {
    // Arrange
    when(() => mockAuthRepository.forgotPassword(any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(tEmail);

    // Assert
    expect(result, const Right(true));
    verify(() => mockAuthRepository.forgotPassword(tEmail)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    const tFailure = ApiFailure(message: 'User not found');
    when(() => mockAuthRepository.forgotPassword(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tEmail);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.forgotPassword(tEmail)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
