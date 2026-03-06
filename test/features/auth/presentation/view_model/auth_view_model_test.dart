import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/error/failure.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';
import 'package:sneak_fit/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/get_local_profile_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/login_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/register_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}
class MockGetUserProfileUsecase extends Mock implements GetUserProfileUsecase {}
class MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}
class MockChangePasswordUsecase extends Mock implements ChangePasswordUsecase {}
class MockGetLocalProfileUsecase extends Mock implements GetLocalProfileUsecase {}

class FakeRegisterUsecaseParams extends Fake implements RegisterUsecaseParams {}
class FakeLoginUsecaseParams extends Fake implements LoginUsecaseParams {}

void main() {
  late AuthViewModel viewModel;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockGetUserProfileUsecase mockGetUserProfileUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late MockChangePasswordUsecase mockChangePasswordUsecase;
  late MockGetLocalProfileUsecase mockGetLocalProfileUsecase;

  setUpAll(() {
    registerFallbackValue(FakeRegisterUsecaseParams());
    registerFallbackValue(FakeLoginUsecaseParams());
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockGetUserProfileUsecase = MockGetUserProfileUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
    mockChangePasswordUsecase = MockChangePasswordUsecase();
    mockGetLocalProfileUsecase = MockGetLocalProfileUsecase();

    // Mock initial load (called in constructor)
    when(() => mockGetLocalProfileUsecase.call())
        .thenAnswer((_) async => const Left(ApiFailure(message: 'Empty')));

    viewModel = AuthViewModel(
      loginUsecase: mockLoginUsecase,
      registerUsecase: mockRegisterUsecase,
      logoutUsecase: mockLogoutUsecase,
      updateProfileUsecase: mockUpdateProfileUsecase,
      getUserProfileUsecase: mockGetUserProfileUsecase,
      forgotPasswordUsecase: mockForgotPasswordUsecase,
      resetPasswordUsecase: mockResetPasswordUsecase,
      changePasswordUsecase: mockChangePasswordUsecase,
      getLocalProfileUsecase: mockGetLocalProfileUsecase,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthEntity = AuthEntity(email: tEmail, name: 'Test User');

  group('login', () {
    test('should change state to authenticated when login is successful', () async {
      // Arrange
      when(() => mockLoginUsecase.call(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await viewModel.login(tEmail, tPassword);

      // Assert
      expect(viewModel.state.status, AuthStatus.authenticated);
      expect(viewModel.state.authEntity, tAuthEntity);
      expect(viewModel.state.isAuthenticating, false);
    });

    test('should change state to error when login fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Invalid credentials');
      when(() => mockLoginUsecase.call(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      await viewModel.login(tEmail, tPassword);

      // Assert
      expect(viewModel.state.status, AuthStatus.error);
      expect(viewModel.state.errorMessage, tFailure.message);
      expect(viewModel.state.isAuthenticating, false);
    });
  });

  group('logout', () {
    test('should reset state when logout is successful', () async {
      // Arrange
      when(() => mockLogoutUsecase.call())
          .thenAnswer((_) async => const Right(true));

      // Act
      await viewModel.logout();

      // Assert
      expect(viewModel.state.status, AuthStatus.initial);
      expect(viewModel.state.authEntity, isNull);
    });
  });

  group('register', () {
    test('should change status to registered when successful', () async {
      // Arrange
      when(() => mockRegisterUsecase.call(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      await viewModel.register(const RegisterUsecaseParams(
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
        userName: 'test',
        name: 'Test',
        phoneNumber: '1234567890',
      ));

      // Assert
      expect(viewModel.state.status, AuthStatus.registered);
    });
  });
}
