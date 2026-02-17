import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/login_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/register_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/reset_password_usecase.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    loginUsecase: ref.read(loginUsecaseProvider),
    registerUsecase: ref.read(registerUsecaseProvider),
    logoutUsecase: ref.read(logoutUsecaseProvider),
    updateProfileUsecase: ref.read(updateProfileUsecaseProvider),
    getUserProfileUsecase: ref.read(getUserProfileUsecaseProvider),
    forgotPasswordUsecase: ref.read(forgotPasswordUsecaseProvider),
    resetPasswordUsecase: ref.read(resetPasswordUsecaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final GetUserProfileUsecase _getUserProfileUsecase;
  final ForgotPasswordUsecase _forgotPasswordUsecase;
  final ResetPasswordUsecase _resetPasswordUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required LogoutUsecase logoutUsecase,
    required UpdateProfileUsecase updateProfileUsecase,
    required GetUserProfileUsecase getUserProfileUsecase,
    required ForgotPasswordUsecase forgotPasswordUsecase,
    required ResetPasswordUsecase resetPasswordUsecase,
  })  : _loginUsecase = loginUsecase,
        _registerUsecase = registerUsecase,
        _logoutUsecase = logoutUsecase,
        _updateProfileUsecase = updateProfileUsecase,
        _getUserProfileUsecase = getUserProfileUsecase,
        _forgotPasswordUsecase = forgotPasswordUsecase,
        _resetPasswordUsecase = resetPasswordUsecase,
        super(AuthState());

  Future<void> getUserProfile() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _getUserProfileUsecase.call();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: user,
      ),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _logoutUsecase.call();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = AuthState(),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, isAuthenticating: true);
    final result = await _loginUsecase.call(LoginUsecaseParams(email: email, password: password));
    
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
        isAuthenticating: false,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: user,
        isAuthenticating: false,
      ),
    );
  }

  Future<void> register(RegisterUsecaseParams params) async {
    state = state.copyWith(status: AuthStatus.loading, isAuthenticating: true);
    final result = await _registerUsecase.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
        isAuthenticating: false,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.registered,
        isAuthenticating: false,
      ),
    );
  }

  Future<void> updateProfile(String name, String? imagePath) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _updateProfileUsecase.call(
      UpdateProfileParams(name: name, imagePath: imagePath),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: user,
      ),
    );
  }

  void resetState() {
    state = AuthState();
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, isAuthenticating: true);
    final result = await _forgotPasswordUsecase.call(email);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
        isAuthenticating: false,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.forgotPasswordSent,
        isAuthenticating: false,
      ),
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, isAuthenticating: true);
    final result = await _resetPasswordUsecase.call(token, newPassword);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
        isAuthenticating: false,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.passwordReset,
        isAuthenticating: false,
      ),
    );
  }
}
