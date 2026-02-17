import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/domain/usecases/login_usecase.dart';

// Create Mock class
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthEntity = AuthEntity(
    userId: '1',
    name: 'Test User',
    email: tEmail,
  );

  test('should call login on the repository with correct parameters', () async {
    // Arrange
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tAuthEntity));

    // Act
    final result = await usecase(const LoginUsecaseParams(email: tEmail, password: tPassword));

    // Assert
    expect(result, const Right(tAuthEntity));
    verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when repository login fails', () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Invalid Credentials');
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(const LoginUsecaseParams(email: tEmail, password: tPassword));

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
  });
}
