
import 'package:sneak_fit/features/auth/data/models/auth_hive_model.dart';
import 'package:sneak_fit/features/auth/data/models/user_model.dart';


abstract interface class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
  Future<UserModel?> getMe();
  Future<UserModel?> updateProfile(String name, String? imagePath);
  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword(String token, String newPassword);
  Future<bool> changePassword(String oldPassword, String newPassword);
}