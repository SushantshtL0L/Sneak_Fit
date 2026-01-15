import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/services/hive/hive_service.dart';
import 'package:sneak_fit/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:sneak_fit/features/auth/data/models/auth_hive_model.dart';
import 'package:sneak_fit/main.dart';


final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return _hiveService.getCurrentUser();
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.isEmailExists(email);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return _hiveService.loginUser(email, password);
  }

  @override
  Future<bool> logout() async {
    await _hiveService.logoutUser();
    return true;
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    return _hiveService.registerUser(model);
  }
}
