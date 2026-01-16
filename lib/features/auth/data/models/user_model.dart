import '../../domain/entities/auth_entity.dart';

class UserModel extends AuthEntity {
  const UserModel({
    String? userId,
    String? userName,
    required String email,
    String? password,
    String? profileImage,
    String? token,
  }) : super(
          userId: userId,
          userName: userName,
          email: email,
          password: password,
          profileImage: profileImage,
          token: token,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['_id'],
      userName: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      token: json['token'],
    );
  }
}
