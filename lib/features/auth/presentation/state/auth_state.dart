import 'package:equatable/equatable.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus { initial, loading, registered, authenticated, forgotPasswordSent, passwordReset, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  final bool isAuthenticating; 

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
    this.isAuthenticating = false,
  });
  //copywith
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
    bool? isAuthenticating,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage, isAuthenticating];
}