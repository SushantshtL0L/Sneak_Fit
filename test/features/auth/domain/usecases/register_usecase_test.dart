import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/repositories/auth_repository.dart';
import 'package:sneak_fit/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class FakeAuthEntity extends Fake implements AuthEntity {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeAuthEntity());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  const tParams = RegisterUsecaseParams(
    name: 'Test Name',
    userName: 'testuser',
    email: 'test@gmail.com',
    password: 'password123',
    confirmPassword: 'password123',
    phoneNumber: '9876543210',
    profileImage: 'image.jpg',
  );

  const tAuthEntity = AuthEntity(
    name: 'Test Name',
    userName: 'testuser',
    email: 'test@gmail.com',
    password: 'password123',
    profileImage: 'image.jpg',
  );

  test('should call register on the repository with correct entity', () async {
    // Arrange
    when(() => mockAuthRepository.register(any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Right(true));
    verify(() => mockAuthRepository.register(tAuthEntity)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when repository register fails', () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Registration Failed');
    when(() => mockAuthRepository.register(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.register(tAuthEntity)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
