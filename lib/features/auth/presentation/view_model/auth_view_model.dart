import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/auth/domain/usecases/login_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/register_usecase.dart';
import 'package:sneak_fit/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    loginUsecase: ref.read(loginUsecaseProvider),
    registerUsecase: ref.read(registerUsecaseProvider),
    logoutUsecase: ref.read(logoutUsecaseProvider),
    updateProfileUsecase: ref.read(updateProfileUsecaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required LogoutUsecase logoutUsecase,
    required UpdateProfileUsecase updateProfileUsecase,
  })  : _loginUsecase = loginUsecase,
        _registerUsecase = registerUsecase,
        _logoutUsecase = logoutUsecase,
        _updateProfileUsecase = updateProfileUsecase,
        super(AuthState());

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
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _loginUsecase.call(LoginUsecaseParams(email: email, password: password));
    
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

  Future<void> register(RegisterUsecaseParams params) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _registerUsecase.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.registered,
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
}
