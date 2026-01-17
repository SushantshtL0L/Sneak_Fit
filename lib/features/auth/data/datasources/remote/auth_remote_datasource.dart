import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:sneak_fit/features/auth/data/models/auth_hive_model.dart';
import 'package:sneak_fit/features/auth/data/models/auth_response.dart';
import 'package:sneak_fit/features/auth/data/models/login_request.dart';
import 'package:sneak_fit/features/auth/data/models/signup_request.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDatasource(apiClient);
});

class AuthRemoteDatasource implements IAuthDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(response.data);

      // Save token to secure storage
      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: authResponse.token);

      return AuthHiveModel(
        userId: authResponse.userId,
        email: authResponse.email,
        password: '', // We don't store password from remote
        userName: authResponse.username,
      );
    }
    return null;
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: {
        'name': model.name,
        'email': model.email,
        'password': model.password,
        'confirmPassword': model.password, // For now, use the same password
        'username': model.userName,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    // Implement if needed
    return null;
  }

  @override
  Future<bool> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    return true;
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return false;
  }
}
