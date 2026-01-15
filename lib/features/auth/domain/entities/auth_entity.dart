import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? userName;
  final String email;
  final String? phoneNumber; // added phone number
  final String? password;
  final String? profileImage;

  const AuthEntity({
    this.userId,
    required this.email,
    this.userName,
    this.phoneNumber,
    this.password,
    this.profileImage,
  });

  @override
  List<Object?> get props => [email, userName, phoneNumber, password, profileImage];
}
