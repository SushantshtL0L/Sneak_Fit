import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? userName;
  final String? name;
  final String email;
  final String? password;
  final String? profileImage;
  final String? token;
  final String? role;

  const AuthEntity({
    this.userId,
    this.userName,
    this.name,
    required this.email,
    this.password,
    this.profileImage,
    this.token,
    this.role,
  });

  @override
  List<Object?> get props =>
      [userId, userName, name, email, password, profileImage, token, role];
}
