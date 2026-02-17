import '../../domain/entities/auth_entity.dart';

class UserModel extends AuthEntity {
  const UserModel({
    super.userId,
    super.userName,
    super.name,
    required super.email,
    super.password,
    super.profileImage,
    super.token,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['_id'],
      userName: json['username'],
      name: json['name'],
      email: json['email'],
      profileImage: json['image'],
      token: json['token'],
      role: json['role'],
    );
  }
}
