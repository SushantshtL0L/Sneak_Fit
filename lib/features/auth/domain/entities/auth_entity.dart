import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? userName;
  final String email;
  final String? password;
  final String? profileImage;
  final String? token;

  const AuthEntity({
    this.userId,
    this.userName,
    required this.email,
    this.password,
    this.profileImage,
    this.token,
  });

  @override
  List<Object?> get props =>
      [userId, userName, email, password, profileImage, token];
}
