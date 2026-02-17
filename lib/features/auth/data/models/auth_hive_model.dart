import 'package:hive/hive.dart';
import 'package:sneak_fit/core/constants/hive_table_constants.dart';
import '../../domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authtypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String? userName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String? profileImage;

  @HiveField(5)
  final String? name;

  @HiveField(6)
  final String? role;

  AuthHiveModel({
    String? userId,
    required String email,
    required this.password,
    this.userName,
    this.name,
    this.profileImage,
    this.role,
  })  : userId = userId ?? const Uuid().v4(),
        email = email.toLowerCase().trim();

  factory AuthHiveModel.fromEntity(AuthEntity authEntity) {
    return AuthHiveModel(
      userId: authEntity.userId,
      email: authEntity.email,
      password: authEntity.password!,
      userName: authEntity.userName,
      name: authEntity.name,
      profileImage: authEntity.profileImage,
      role: authEntity.role,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      email: email,
      password: password,
      userName: userName,
      name: name,
      profileImage: profileImage,
      role: role,
    );
  }
}
